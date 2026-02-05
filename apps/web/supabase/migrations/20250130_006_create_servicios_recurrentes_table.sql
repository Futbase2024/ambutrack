-- =====================================================
-- TABLA: servicios_recurrentes
-- Descripción: Configuración de recurrencia para servicios
-- Arquitectura de 3 niveles:
--   servicios (cabecera) → servicios_recurrentes (configuración) → traslados (instancias)
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-01-30
-- =====================================================

-- Crear tabla servicios_recurrentes
CREATE TABLE IF NOT EXISTS servicios_recurrentes (
  -- Identificación
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo VARCHAR(50) UNIQUE NOT NULL,
  id_servicio UUID NOT NULL REFERENCES servicios(id) ON DELETE CASCADE,
  id_paciente UUID NOT NULL REFERENCES pacientes(id) ON DELETE RESTRICT,

  -- Tipo de recurrencia
  tipo_recurrencia TEXT NOT NULL DEFAULT 'unico',
  CONSTRAINT ck_servicios_rec_tipo CHECK (tipo_recurrencia IN (
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

  -- Período del servicio recurrente
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

  -- Observaciones
  observaciones TEXT,

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
CREATE INDEX idx_servicios_rec_servicio ON servicios_recurrentes(id_servicio);
CREATE INDEX idx_servicios_rec_paciente ON servicios_recurrentes(id_paciente);
CREATE INDEX idx_servicios_rec_tipo ON servicios_recurrentes(tipo_recurrencia);
CREATE INDEX idx_servicios_rec_activo ON servicios_recurrentes(activo) WHERE activo = true;
CREATE INDEX idx_servicios_rec_fecha_inicio ON servicios_recurrentes(fecha_servicio_inicio);
CREATE INDEX idx_servicios_rec_fecha_fin ON servicios_recurrentes(fecha_servicio_fin);

-- Índice compuesto para el job nocturno de generación
CREATE INDEX idx_servicios_rec_generacion ON servicios_recurrentes(activo, fecha_servicio_inicio, fecha_servicio_fin)
WHERE activo = true;

-- Comentarios de documentación
COMMENT ON TABLE servicios_recurrentes IS 'Configuración de recurrencia para servicios. Un servicio puede tener múltiples configuraciones de recurrencia que generan traslados automáticamente';
COMMENT ON COLUMN servicios_recurrentes.id_servicio IS 'FK hacia servicios (tabla cabecera/padre)';
COMMENT ON COLUMN servicios_recurrentes.tipo_recurrencia IS 'Tipo de recurrencia (unico, diario, semanal, semanas_alternas, dias_alternos, mensual, especifico)';
COMMENT ON COLUMN servicios_recurrentes.traslados_generados_hasta IS 'Última fecha hasta la que se generaron traslados automáticamente';

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_servicios_recurrentes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_servicios_rec_updated_at
  BEFORE UPDATE ON servicios_recurrentes
  FOR EACH ROW
  EXECUTE FUNCTION update_servicios_recurrentes_updated_at();

-- Función para generar código automático
CREATE OR REPLACE FUNCTION generar_codigo_servicio_recurrente()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.codigo IS NULL THEN
    NEW.codigo := 'SRV-' || TO_CHAR(now(), 'YYYYMMDDHHMIssMS');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generar_codigo_servicio_rec
  BEFORE INSERT ON servicios_recurrentes
  FOR EACH ROW
  EXECUTE FUNCTION generar_codigo_servicio_recurrente();

-- Validaciones adicionales
CREATE OR REPLACE FUNCTION validar_servicios_rec_recurrencia()
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

CREATE TRIGGER trigger_validar_servicios_rec
  BEFORE INSERT OR UPDATE ON servicios_recurrentes
  FOR EACH ROW
  EXECUTE FUNCTION validar_servicios_rec_recurrencia();
