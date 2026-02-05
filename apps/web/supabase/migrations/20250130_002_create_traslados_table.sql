-- =====================================================
-- TABLA: traslados
-- Descripción: Almacena los traslados generados a partir de servicios
-- Incluye tracking de estados del conductor con cronas (timestamps)
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-01-30
-- =====================================================

-- Crear tabla traslados
CREATE TABLE IF NOT EXISTS traslados (
  -- Identificación
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo VARCHAR(50) UNIQUE NOT NULL,
  id_servicio UUID NOT NULL REFERENCES servicios(id) ON DELETE CASCADE,
  id_paciente UUID NOT NULL REFERENCES pacientes(id) ON DELETE RESTRICT,

  -- Tipo de traslado
  tipo_traslado VARCHAR(20) NOT NULL,
  CONSTRAINT ck_traslados_tipo_traslado CHECK (tipo_traslado IN ('ida', 'vuelta')),

  -- Fecha y hora programada
  fecha DATE NOT NULL,
  hora_programada TIME NOT NULL,

  -- Asignaciones
  id_vehiculo UUID REFERENCES vehiculos(id) ON DELETE SET NULL,
  id_conductor UUID REFERENCES personal(id) ON DELETE SET NULL,
  personal_asignado UUID[], -- Array de IDs de personal adicional

  -- Estado principal del traslado
  estado VARCHAR(50) NOT NULL DEFAULT 'pendiente',
  CONSTRAINT ck_traslados_estado CHECK (estado IN (
    'pendiente',           -- Traslado generado, no asignado
    'asignado',            -- Vehículo y conductor asignados
    'enviado',             -- Enviado al conductor (notificación)
    'recibido_conductor',  -- Conductor confirmó recepción
    'en_origen',           -- Conductor llegó al origen
    'saliendo_origen',     -- Conductor salió del origen con paciente
    'en_transito',         -- Conductor en camino al destino
    'en_destino',          -- Conductor llegó al destino
    'finalizado',          -- Traslado completado exitosamente
    'cancelado',           -- Traslado cancelado
    'no_realizado'         -- Traslado no se pudo realizar
  )),

  -- =======================================
  -- CRONAS (Marcas temporales de estados)
  -- =======================================

  -- Creación y asignación
  fecha_creacion TIMESTAMP NOT NULL DEFAULT now(),
  fecha_asignacion TIMESTAMP,
  usuario_asignacion UUID REFERENCES personal(id),

  -- Envío al conductor
  fecha_enviado TIMESTAMP,
  usuario_envio UUID REFERENCES personal(id),

  -- Confirmación del conductor
  fecha_recibido_conductor TIMESTAMP,

  -- En origen (llegada al punto de recogida)
  fecha_en_origen TIMESTAMP,
  ubicacion_en_origen JSONB, -- {lat: X, lng: Y, timestamp: '...'}

  -- Saliendo de origen (paciente a bordo)
  fecha_saliendo_origen TIMESTAMP,
  ubicacion_saliendo_origen JSONB,

  -- En destino (llegada al punto de entrega)
  fecha_en_destino TIMESTAMP,
  ubicacion_en_destino JSONB,

  -- Finalización
  fecha_finalizado TIMESTAMP,
  ubicacion_finalizado JSONB,

  -- Cancelación
  fecha_cancelacion TIMESTAMP,
  motivo_cancelacion VARCHAR(100),
  observaciones_cancelacion TEXT,
  usuario_cancelacion UUID REFERENCES personal(id),

  -- =======================================
  -- Información del trayecto
  -- =======================================
  trayecto JSONB NOT NULL,
  -- Ejemplo estructura:
  -- {
  --   "origen": {
  --     "tipo": "domicilio" | "centro_hospitalario",
  --     "domicilio": {...} | "centro": "Nombre Centro",
  --     "hora_estimada": "08:00"
  --   },
  --   "destino": {...}
  -- }

  -- =======================================
  -- Confirmación del paciente
  -- =======================================
  paciente_confirmado BOOLEAN DEFAULT false,
  fecha_confirmacion_paciente TIMESTAMP,
  metodo_confirmacion VARCHAR(50), -- 'llamada', 'sms', 'app', 'familiar'

  -- =======================================
  -- Información médica y recursos
  -- =======================================
  tipo_ambulancia VARCHAR(50),
  requiere_acompanante BOOLEAN DEFAULT false,
  requiere_silla_ruedas BOOLEAN DEFAULT false,
  requiere_camilla BOOLEAN DEFAULT false,
  observaciones TEXT,
  observaciones_medicas TEXT,

  -- =======================================
  -- Facturación y costes
  -- =======================================
  facturado BOOLEAN DEFAULT false,
  fecha_facturacion TIMESTAMP,
  importe_facturado DECIMAL(10, 2),

  -- =======================================
  -- Métricas de tiempo real
  -- =======================================
  tiempo_espera_origen_minutos INTEGER, -- Tiempo esperando en origen
  tiempo_viaje_minutos INTEGER,         -- Tiempo de viaje total
  kilometros_recorridos DECIMAL(10, 2),

  -- =======================================
  -- Metadata
  -- =======================================
  generado_automaticamente BOOLEAN DEFAULT true,
  editado_manualmente BOOLEAN DEFAULT false,
  prioridad INTEGER DEFAULT 5,
  CONSTRAINT ck_traslados_prioridad CHECK (prioridad BETWEEN 1 AND 10),

  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now(),
  created_by UUID REFERENCES personal(id),
  updated_by UUID REFERENCES personal(id),

  -- Constraint ÚNICO para evitar duplicados
  CONSTRAINT uk_traslado_servicio_fecha_tipo UNIQUE(id_servicio, fecha, tipo_traslado)
);

-- =====================================================
-- ÍNDICES para optimización de consultas
-- =====================================================

-- Índices básicos
CREATE INDEX idx_traslados_servicio ON traslados(id_servicio);
CREATE INDEX idx_traslados_paciente ON traslados(id_paciente);
CREATE INDEX idx_traslados_fecha ON traslados(fecha);
CREATE INDEX idx_traslados_estado ON traslados(estado);

-- Índices para asignaciones
CREATE INDEX idx_traslados_vehiculo ON traslados(id_vehiculo);
CREATE INDEX idx_traslados_conductor ON traslados(id_conductor);

-- Índice compuesto para búsquedas comunes
CREATE INDEX idx_traslados_fecha_estado ON traslados(fecha, estado);
CREATE INDEX idx_traslados_conductor_fecha ON traslados(id_conductor, fecha) WHERE estado NOT IN ('cancelado', 'no_realizado');

-- Índice para traslados pendientes
CREATE INDEX idx_traslados_pendientes ON traslados(fecha, estado)
WHERE estado IN ('pendiente', 'asignado', 'enviado');

-- Índice para traslados en curso
CREATE INDEX idx_traslados_en_curso ON traslados(id_conductor, estado)
WHERE estado IN ('recibido_conductor', 'en_origen', 'saliendo_origen', 'en_transito', 'en_destino');

-- =====================================================
-- TABLA DE AUDITORÍA: historial_estados_traslado
-- =====================================================

CREATE TABLE IF NOT EXISTS historial_estados_traslado (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_traslado UUID NOT NULL REFERENCES traslados(id) ON DELETE CASCADE,

  -- Estado
  estado_anterior VARCHAR(50),
  estado_nuevo VARCHAR(50) NOT NULL,

  -- Usuario que realizó el cambio
  id_usuario UUID REFERENCES personal(id),

  -- Ubicación GPS en el momento del cambio
  ubicacion JSONB,

  -- Timestamp
  fecha_cambio TIMESTAMP NOT NULL DEFAULT now(),

  -- Observaciones
  observaciones TEXT,

  -- Metadata adicional
  metadata JSONB -- Información extra como batería del móvil, señal GPS, etc.
);

-- Índices para historial
CREATE INDEX idx_historial_traslado ON historial_estados_traslado(id_traslado);
CREATE INDEX idx_historial_fecha ON historial_estados_traslado(fecha_cambio);
CREATE INDEX idx_historial_estado_nuevo ON historial_estados_traslado(estado_nuevo);

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_traslados_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_traslados_updated_at
  BEFORE UPDATE ON traslados
  FOR EACH ROW
  EXECUTE FUNCTION update_traslados_updated_at();

-- Función para generar código automático de traslado
CREATE OR REPLACE FUNCTION generar_codigo_traslado()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.codigo IS NULL THEN
    NEW.codigo := 'TRS-' || TO_CHAR(NEW.fecha, 'YYYYMMDD') || '-' ||
                  LPAD(nextval('traslados_codigo_seq')::TEXT, 4, '0') ||
                  CASE WHEN NEW.tipo_traslado = 'vuelta' THEN '-V' ELSE '-I' END;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Secuencia para código de traslado
CREATE SEQUENCE IF NOT EXISTS traslados_codigo_seq;

CREATE TRIGGER trigger_generar_codigo_traslado
  BEFORE INSERT ON traslados
  FOR EACH ROW
  EXECUTE FUNCTION generar_codigo_traslado();

-- Trigger para registrar cambios de estado en historial
CREATE OR REPLACE FUNCTION registrar_cambio_estado_traslado()
RETURNS TRIGGER AS $$
BEGIN
  -- Solo si el estado cambió
  IF OLD.estado IS DISTINCT FROM NEW.estado THEN
    INSERT INTO historial_estados_traslado (
      id_traslado,
      estado_anterior,
      estado_nuevo,
      id_usuario,
      observaciones
    ) VALUES (
      NEW.id,
      OLD.estado,
      NEW.estado,
      NEW.updated_by,
      'Cambio automático de estado'
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_registrar_cambio_estado_traslado
  AFTER UPDATE ON traslados
  FOR EACH ROW
  WHEN (OLD.estado IS DISTINCT FROM NEW.estado)
  EXECUTE FUNCTION registrar_cambio_estado_traslado();

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE traslados IS 'Traslados generados automáticamente a partir de servicios, con tracking completo de estados del conductor';
COMMENT ON COLUMN traslados.tipo_traslado IS 'Tipo de traslado: ida o vuelta';
COMMENT ON COLUMN traslados.estado IS 'Estado actual del traslado en el flujo del conductor';

COMMENT ON COLUMN traslados.fecha_enviado IS 'Cuándo se envió la notificación al conductor';
COMMENT ON COLUMN traslados.fecha_recibido_conductor IS 'Cuándo el conductor confirmó recepción (visto)';
COMMENT ON COLUMN traslados.fecha_en_origen IS 'Cuándo el conductor llegó al punto de recogida';
COMMENT ON COLUMN traslados.fecha_saliendo_origen IS 'Cuándo el conductor salió del origen con el paciente';
COMMENT ON COLUMN traslados.fecha_en_destino IS 'Cuándo el conductor llegó al punto de entrega';
COMMENT ON COLUMN traslados.fecha_finalizado IS 'Cuándo se completó el traslado';

COMMENT ON COLUMN traslados.ubicacion_en_origen IS 'Coordenadas GPS cuando el conductor llegó al origen';
COMMENT ON COLUMN traslados.ubicacion_saliendo_origen IS 'Coordenadas GPS cuando salió del origen';
COMMENT ON COLUMN traslados.ubicacion_en_destino IS 'Coordenadas GPS cuando llegó al destino';
COMMENT ON COLUMN traslados.ubicacion_finalizado IS 'Coordenadas GPS cuando finalizó el traslado';

COMMENT ON TABLE historial_estados_traslado IS 'Auditoría completa de todos los cambios de estado de los traslados';
