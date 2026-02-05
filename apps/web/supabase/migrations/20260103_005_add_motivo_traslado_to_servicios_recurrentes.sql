-- =====================================================
-- MIGRACIÓN: Agregar id_motivo_traslado a servicios_recurrentes
-- =====================================================
-- Fecha: 2026-01-03
-- Descripción: Agregar columna id_motivo_traslado a la tabla
--              servicios_recurrentes para que la función
--              generar_traslados_periodo() pueda propagar
--              este campo a los traslados generados.
-- =====================================================

-- PASO 1: Agregar columna id_motivo_traslado a servicios_recurrentes
ALTER TABLE servicios_recurrentes
ADD COLUMN id_motivo_traslado UUID REFERENCES tmotivos_traslado(id) ON DELETE SET NULL;

-- PASO 2: Crear índice para mejorar performance
CREATE INDEX idx_servicios_recurrentes_motivo_traslado
ON servicios_recurrentes(id_motivo_traslado);

-- PASO 3: Comentario en la columna
COMMENT ON COLUMN servicios_recurrentes.id_motivo_traslado IS
'Motivo del traslado (referencia a tmotivos_traslado). Se propaga a los traslados generados automáticamente.';
