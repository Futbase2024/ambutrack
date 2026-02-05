-- =====================================================
-- MIGRACIÓN: Cambiar FK de traslados de servicios a servicios_recurrentes
-- Descripción: Actualiza la arquitectura para que traslados apunte a servicios_recurrentes
-- Arquitectura correcta:
--   servicios → servicios_recurrentes → traslados
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-01-30
-- =====================================================

-- PASO 1: Eliminar constraint FK existente de traslados → servicios
ALTER TABLE traslados
DROP CONSTRAINT IF EXISTS traslados_id_servicio_fkey;

-- PASO 2: Renombrar columna id_servicio a id_servicio_recurrente (más descriptivo)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'traslados' AND column_name = 'id_servicio'
  ) THEN
    ALTER TABLE traslados RENAME COLUMN id_servicio TO id_servicio_recurrente;
  END IF;
END $$;

-- PASO 3: Crear nueva FK hacia servicios_recurrentes
ALTER TABLE traslados
ADD CONSTRAINT traslados_id_servicio_recurrente_fkey
FOREIGN KEY (id_servicio_recurrente) REFERENCES servicios_recurrentes(id) ON DELETE CASCADE;

-- PASO 4: Recrear índice con nuevo nombre de columna
DROP INDEX IF EXISTS idx_traslados_servicio;
CREATE INDEX idx_traslados_servicio_recurrente ON traslados(id_servicio_recurrente);

-- PASO 5: Actualizar comentario
COMMENT ON COLUMN traslados.id_servicio_recurrente IS 'FK hacia servicios_recurrentes (configuración de recurrencia del servicio)';

-- PASO 6: Actualizar constraint único
ALTER TABLE traslados DROP CONSTRAINT IF EXISTS uk_traslado_servicio_fecha_tipo;
ALTER TABLE traslados ADD CONSTRAINT uk_traslado_servicio_rec_fecha_tipo
  UNIQUE(id_servicio_recurrente, fecha, tipo_traslado);

-- Refrescar el schema cache de PostgREST
NOTIFY pgrst, 'reload schema';
