-- =====================================================
-- MIGRACIÓN: Agregar id_servicio a tabla traslados
-- Problema: Traslados solo se vinculaban a servicios_recurrentes
-- Solución: Permitir vincular directamente a servicios (para servicios únicos)
-- Fecha: 2025-01-31
-- =====================================================

-- PASO 1: Agregar columna id_servicio (nullable)
ALTER TABLE traslados
ADD COLUMN id_servicio UUID REFERENCES servicios(id) ON DELETE CASCADE;

-- PASO 2: Crear índice en id_servicio
CREATE INDEX idx_traslados_servicio_directo ON traslados(id_servicio);

-- PASO 3: Modificar constraint UNIQUE
-- Eliminar constraint antiguo
ALTER TABLE traslados
DROP CONSTRAINT IF EXISTS uk_traslado_servicio_fecha_tipo;

-- Crear nuevo constraint que soporte ambos casos
-- Un traslado se identifica únicamente por:
-- - (id_servicio_recurrente, fecha, tipo_traslado) para servicios recurrentes
-- - (id_servicio, fecha, tipo_traslado) para servicios únicos
ALTER TABLE traslados
ADD CONSTRAINT uk_traslado_unico
UNIQUE NULLS NOT DISTINCT (id_servicio_recurrente, id_servicio, fecha, tipo_traslado);

-- PASO 4: Agregar CHECK constraint para asegurar que al menos uno esté presente
ALTER TABLE traslados
ADD CONSTRAINT ck_traslado_origen CHECK (
  (id_servicio_recurrente IS NOT NULL AND id_servicio IS NULL) OR
  (id_servicio IS NOT NULL AND id_servicio_recurrente IS NULL)
);

-- PASO 5: Modificar id_servicio_recurrente para permitir NULL
ALTER TABLE traslados
ALTER COLUMN id_servicio_recurrente DROP NOT NULL;

-- Comentarios
COMMENT ON COLUMN traslados.id_servicio IS
'Referencia directa a servicios (para servicios únicos). Mutuamente excluyente con id_servicio_recurrente.';

COMMENT ON CONSTRAINT ck_traslado_origen ON traslados IS
'Asegura que un traslado esté vinculado EXCLUSIVAMENTE a id_servicio O id_servicio_recurrente, pero no ambos.';
