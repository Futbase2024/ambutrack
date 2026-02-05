-- =====================================================
-- TABLA: servicios
-- Descripción: Almacena la configuración de servicios recurrentes para pacientes
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-01-30
-- =====================================================

-- Crear tabla servicios
CREATE TABLE IF NOT EXISTS servicios (
  -- Identificación
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo VARCHAR(50) UNIQUE NOT NULL,
  id_paciente UUID NOT NULL REFERENCES pacientes(id) ON DELETE RESTRICT,

  -- Tipo de recurrencia
  tipo_recurrencia TEXT NOT NULL DEFAULT 'unico',
  CONSTRAINT ck_servicios_tipo_recurrencia CHECK (tipo_recurrencia IN (
    'unico',            -- Servicio único (una sola fecha)
    'diario',           -- Todos los días
    'semanal',          -- Semanas específicas
    'semanas_alternas', -- Cada N semanas
    'dias_alternos',    -- Cada N días
    'mensual',          -- Días específicos del mes
    'especifico'        -- Fechas específicas
  )),

  -- Parámetros de recurrencia
  dias_semana INTEGER[],     -- [0-6] donde 0=domingo, para 'semanal' y 'semanas_alternas'
  intervalo_semanas INTEGER, -- Para 'semanas_alternas' (ej: 2 = cada 2 semanas)
  intervalo_dias INTEGER,    -- Para 'dias_alternos' (ej: 2 = cada 2 días)
  dias_mes INTEGER[],        -- [1-31] para 'mensual'
  fechas_especificas DATE[], -- Para 'especifico'

  -- Período del servicio
  fecha_servicio_inicio DATE NOT NULL,
  fecha_servicio_fin DATE, -- NULL = servicio indefinido

  -- Horarios
  hora_recogida TIME NOT NULL,
  hora_vuelta TIME, -- NULL si no requiere vuelta

  -- Ida y vuelta
  requiere_vuelta BOOLEAN NOT NULL DEFAULT false,

  -- Trayectos (estructura JSONB para flexibilidad)
  trayectos JSONB NOT NULL,
  -- Ejemplo estructura:
  -- [
  --   {
  --     "orden": 1,
  --     "tipo": "domicilio", // o "centro_hospitalario"
  --     "domicilio": {...},  // si tipo = domicilio
  --     "centro": "Centro X",// si tipo = centro_hospitalario
  --     "hora": "08:00"
  --   }
  -- ]

  -- Recursos necesarios
  tipo_ambulancia VARCHAR(50),
  personal_requerido INTEGER DEFAULT 2,
  requiere_acompanante BOOLEAN DEFAULT false,
  requiere_silla_ruedas BOOLEAN DEFAULT false,
  requiere_camilla BOOLEAN DEFAULT false,
  prioridad INTEGER DEFAULT 5,
  CONSTRAINT ck_servicios_prioridad CHECK (prioridad BETWEEN 1 AND 10),

  -- Observaciones
  observaciones TEXT,
  observaciones_medicas TEXT,

  -- Control de generación de traslados
  traslados_generados_hasta DATE, -- Última fecha hasta la que se generaron traslados

  -- Estado
  activo BOOLEAN NOT NULL DEFAULT true,

  -- Metadata
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now(),
  created_by UUID REFERENCES personal(id),
  updated_by UUID REFERENCES personal(id)
);

-- Índices para optimizar consultas comunes
CREATE INDEX idx_servicios_paciente ON servicios(id_paciente);
CREATE INDEX idx_servicios_tipo_recurrencia ON servicios(tipo_recurrencia);
CREATE INDEX idx_servicios_activo ON servicios(activo) WHERE activo = true;
CREATE INDEX idx_servicios_fecha_inicio ON servicios(fecha_servicio_inicio);
CREATE INDEX idx_servicios_fecha_fin ON servicios(fecha_servicio_fin);
CREATE INDEX idx_servicios_generados_hasta ON servicios(traslados_generados_hasta);

-- Índice compuesto para el job nocturno de generación
CREATE INDEX idx_servicios_generacion_activa ON servicios(activo, fecha_servicio_inicio, fecha_servicio_fin)
WHERE activo = true;

-- Comentarios de documentación
COMMENT ON TABLE servicios IS 'Configuración de servicios recurrentes de traslado para pacientes';
COMMENT ON COLUMN servicios.tipo_recurrencia IS 'Tipo de recurrencia del servicio (unico, diario, semanal, semanas_alternas, dias_alternos, mensual, especifico)';
COMMENT ON COLUMN servicios.dias_semana IS 'Array de días de la semana [0-6] donde 0=domingo. Usado para semanal y semanas_alternas';
COMMENT ON COLUMN servicios.intervalo_semanas IS 'Cada cuántas semanas se repite (para semanas_alternas). Ej: 2 = cada 2 semanas';
COMMENT ON COLUMN servicios.intervalo_dias IS 'Cada cuántos días se repite (para dias_alternos). Ej: 2 = cada 2 días';
COMMENT ON COLUMN servicios.dias_mes IS 'Array de días del mes [1-31] para recurrencia mensual';
COMMENT ON COLUMN servicios.fechas_especificas IS 'Array de fechas específicas para tipo especifico';
COMMENT ON COLUMN servicios.fecha_servicio_fin IS 'Fecha de finalización del servicio. NULL = servicio indefinido';
COMMENT ON COLUMN servicios.requiere_vuelta IS 'Si true, se generan traslados de ida y vuelta';
COMMENT ON COLUMN servicios.trayectos IS 'Array JSONB con trayectos del servicio (origen, destinos, horas)';
COMMENT ON COLUMN servicios.traslados_generados_hasta IS 'Última fecha hasta la que se generaron traslados automáticamente';

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_servicios_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_servicios_updated_at
  BEFORE UPDATE ON servicios
  FOR EACH ROW
  EXECUTE FUNCTION update_servicios_updated_at();

-- Función para generar código automático de servicio
CREATE OR REPLACE FUNCTION generar_codigo_servicio()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.codigo IS NULL THEN
    NEW.codigo := 'SRV-' || TO_CHAR(now(), 'YYYYMMDD') || '-' || LPAD(nextval('servicios_codigo_seq')::TEXT, 4, '0');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Secuencia para código de servicio
CREATE SEQUENCE IF NOT EXISTS servicios_codigo_seq;

CREATE TRIGGER trigger_generar_codigo_servicio
  BEFORE INSERT ON servicios
  FOR EACH ROW
  EXECUTE FUNCTION generar_codigo_servicio();

-- Validaciones adicionales
CREATE OR REPLACE FUNCTION validar_servicios_recurrencia()
RETURNS TRIGGER AS $$
BEGIN
  -- Validar que tipo_recurrencia tenga los parámetros necesarios
  CASE NEW.tipo_recurrencia
    WHEN 'semanal', 'semanas_alternas' THEN
      IF NEW.dias_semana IS NULL OR array_length(NEW.dias_semana, 1) IS NULL THEN
        RAISE EXCEPTION 'dias_semana es obligatorio para tipo_recurrencia = %', NEW.tipo_recurrencia;
      END IF;
    WHEN 'semanas_alternas' THEN
      IF NEW.intervalo_semanas IS NULL OR NEW.intervalo_semanas < 2 THEN
        RAISE EXCEPTION 'intervalo_semanas debe ser >= 2 para semanas_alternas';
      END IF;
    WHEN 'dias_alternos' THEN
      IF NEW.intervalo_dias IS NULL OR NEW.intervalo_dias < 2 THEN
        RAISE EXCEPTION 'intervalo_dias debe ser >= 2 para dias_alternos';
      END IF;
    WHEN 'mensual' THEN
      IF NEW.dias_mes IS NULL OR array_length(NEW.dias_mes, 1) IS NULL THEN
        RAISE EXCEPTION 'dias_mes es obligatorio para tipo_recurrencia = mensual';
      END IF;
    WHEN 'especifico' THEN
      IF NEW.fechas_especificas IS NULL OR array_length(NEW.fechas_especificas, 1) IS NULL THEN
        RAISE EXCEPTION 'fechas_especificas es obligatorio para tipo_recurrencia = especifico';
      END IF;
  END CASE;

  -- Validar que si requiere vuelta, tenga hora_vuelta
  IF NEW.requiere_vuelta = true AND NEW.hora_vuelta IS NULL THEN
    RAISE EXCEPTION 'hora_vuelta es obligatoria si requiere_vuelta = true';
  END IF;

  -- Validar fechas
  IF NEW.fecha_servicio_fin IS NOT NULL AND NEW.fecha_servicio_fin < NEW.fecha_servicio_inicio THEN
    RAISE EXCEPTION 'fecha_servicio_fin no puede ser anterior a fecha_servicio_inicio';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_servicios_recurrencia
  BEFORE INSERT OR UPDATE ON servicios
  FOR EACH ROW
  EXECUTE FUNCTION validar_servicios_recurrencia();
