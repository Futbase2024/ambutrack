-- =====================================================
-- Migración: Agregar campos de vehículo a registros_horarios
-- Fecha: 2026-02-13
-- Descripción: Agrega vehiculo_id, vehiculo_matricula y precision_gps
--              para trazabilidad histórica del vehículo asignado
-- =====================================================

-- 1. Agregar columna vehiculo_id (UUID, nullable, FK a vehiculos)
ALTER TABLE registros_horarios
ADD COLUMN IF NOT EXISTS vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE SET NULL;

-- 2. Agregar columna vehiculo_matricula (TEXT, nullable, desnormalizado)
ALTER TABLE registros_horarios
ADD COLUMN IF NOT EXISTS vehiculo_matricula TEXT;

-- 3. Agregar columna precision_gps (DOUBLE PRECISION, nullable)
ALTER TABLE registros_horarios
ADD COLUMN IF NOT EXISTS precision_gps DOUBLE PRECISION;

-- 4. Crear índice en vehiculo_id para consultas rápidas por vehículo
CREATE INDEX IF NOT EXISTS idx_registros_horarios_vehiculo_id
ON registros_horarios(vehiculo_id)
WHERE vehiculo_id IS NOT NULL;

-- 5. Crear índice en personal_id + fecha_hora para consultas temporales
CREATE INDEX IF NOT EXISTS idx_registros_horarios_personal_fecha
ON registros_horarios(personal_id, fecha_hora DESC);

-- 6. Comentarios en columnas para documentación
COMMENT ON COLUMN registros_horarios.vehiculo_id IS
'ID del vehículo asignado en el momento del fichaje (snapshot histórico)';

COMMENT ON COLUMN registros_horarios.vehiculo_matricula IS
'Matrícula del vehículo (desnormalizado para consultas rápidas)';

COMMENT ON COLUMN registros_horarios.precision_gps IS
'Precisión GPS del fichaje en metros';

-- =====================================================
-- Notas de Migración:
--
-- - vehiculo_id es nullable porque personal administrativo
--   puede no tener vehículo asignado
--
-- - vehiculo_matricula se guarda desnormalizado para:
--   * Consultas rápidas sin JOIN
--   * Histórico inmutable (si cambia matrícula, el histórico mantiene la original)
--
-- - precision_gps se agrega para validación de calidad GPS
--
-- - ON DELETE SET NULL: Si se elimina un vehículo,
--   el registro queda con vehiculo_id=NULL pero mantiene la matrícula
--
-- - Backward compatibility: Registros antiguos tendrán estos campos NULL
-- =====================================================
