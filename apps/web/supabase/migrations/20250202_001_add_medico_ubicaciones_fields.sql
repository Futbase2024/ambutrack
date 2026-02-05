-- =====================================================
-- Añadir campos de médico y ubicaciones en centro
-- Descripción: Agrega medico_id a servicios y ubicaciones_centro al JSONB de trayectos
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-02-02
-- =====================================================

-- =====================================================
-- 1. TABLA servicios: Añadir medico_id (opcional)
-- =====================================================

ALTER TABLE servicios
ADD COLUMN IF NOT EXISTS medico_id UUID REFERENCES tfacultativos(id) ON DELETE SET NULL;

-- Índice para búsquedas por médico
CREATE INDEX IF NOT EXISTS idx_servicios_medico ON servicios(medico_id) WHERE medico_id IS NOT NULL;

COMMENT ON COLUMN servicios.medico_id IS 'Facultativo médico asignado al servicio (opcional)';

-- =====================================================
-- 2. TABLA traslados: Añadir campos de ubicación en centro
-- =====================================================

-- Añadir campos para ubicación dentro del centro hospitalario
ALTER TABLE traslados
ADD COLUMN IF NOT EXISTS origen_ubicacion_centro TEXT,
ADD COLUMN IF NOT EXISTS destino_ubicacion_centro TEXT;

COMMENT ON COLUMN traslados.origen_ubicacion_centro IS 'Ubicación específica dentro del centro hospitalario de origen (ej: Urgencias, Hab-202, UCI)';
COMMENT ON COLUMN traslados.destino_ubicacion_centro IS 'Ubicación específica dentro del centro hospitalario de destino (ej: Urgencias, Hab-202, UCI)';

-- =====================================================
-- NOTA IMPORTANTE sobre trayectos JSONB
-- =====================================================
-- El campo "trayectos" en servicios es JSONB y ya soporta campos adicionales.
-- Las ubicaciones en centro se guardarán en la estructura JSONB de cada trayecto:
--
-- Ejemplo de trayecto con ubicación en centro:
-- {
--   "orden": 1,
--   "tipo_origen": "centro_hospitalario",
--   "tipo_destino": "domicilio",
--   "origen_centro": "H. PTO. REAL",
--   "origen_ubicacion_centro": "Urgencias",  <-- NUEVO CAMPO OPCIONAL
--   "destino_domicilio": {...},
--   "hora": "08:00"
-- }
--
-- No se requiere ALTER COLUMN para JSONB ya que es flexible por naturaleza.
