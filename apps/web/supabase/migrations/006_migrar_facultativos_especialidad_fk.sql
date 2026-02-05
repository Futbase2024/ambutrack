-- ==============================================================================
-- AmbuTrack Web - Migración Facultativos: Especialidad TEXT → FK
-- Convierte el campo 'especialidad' de TEXT a FK hacia tespecialidades
-- ==============================================================================

-- ==============================================================================
-- PASO 1: Agregar nueva columna especialidad_id
-- ==============================================================================
ALTER TABLE tfacultativos
ADD COLUMN especialidad_id UUID;

-- ==============================================================================
-- PASO 2: Migrar datos existentes (mapear texto → UUID)
-- ==============================================================================
-- Mapear especialidades comunes desde los datos seed de tespecialidades
UPDATE tfacultativos
SET especialidad_id = (
    SELECT id FROM tespecialidades
    WHERE LOWER(tespecialidades.nombre) = LOWER(tfacultativos.especialidad)
    LIMIT 1
)
WHERE especialidad IS NOT NULL
  AND especialidad != '';

-- Alternativa: Mapear por código si el texto coincide
UPDATE tfacultativos
SET especialidad_id = (
    SELECT id FROM tespecialidades
    WHERE LOWER(tespecialidades.codigo) = LOWER(REPLACE(tfacultativos.especialidad, ' ', '-'))
    LIMIT 1
)
WHERE especialidad_id IS NULL
  AND especialidad IS NOT NULL
  AND especialidad != '';

-- ==============================================================================
-- PASO 3: Crear Foreign Key constraint
-- ==============================================================================
ALTER TABLE tfacultativos
ADD CONSTRAINT fk_tfacultativos_especialidad
FOREIGN KEY (especialidad_id)
REFERENCES tespecialidades(id)
ON DELETE SET NULL
ON UPDATE CASCADE;

-- ==============================================================================
-- PASO 4: Crear índice para mejorar rendimiento de JOINs
-- ==============================================================================
CREATE INDEX idx_tfacultativos_especialidad_id ON tfacultativos(especialidad_id);

-- ==============================================================================
-- PASO 5: Eliminar columna antigua 'especialidad' (TEXT)
-- ==============================================================================
-- IMPORTANTE: Solo descomentar esto cuando se haya verificado que la migración funciona correctamente
-- y que todos los facultativos tienen su especialidad_id correctamente asignada
-- ALTER TABLE tfacultativos DROP COLUMN especialidad;

-- ==============================================================================
-- PASO 6: Comentarios descriptivos
-- ==============================================================================
COMMENT ON COLUMN tfacultativos.especialidad_id IS 'FK hacia tespecialidades - Especialidad médica del facultativo';

-- ==============================================================================
-- VERIFICACIÓN
-- ==============================================================================
DO $$
DECLARE
    total_facultativos INTEGER;
    facultativos_con_especialidad INTEGER;
    facultativos_sin_especialidad INTEGER;
BEGIN
    -- Contar totales
    SELECT COUNT(*) INTO total_facultativos FROM tfacultativos;
    SELECT COUNT(*) INTO facultativos_con_especialidad FROM tfacultativos WHERE especialidad_id IS NOT NULL;
    SELECT COUNT(*) INTO facultativos_sin_especialidad FROM tfacultativos WHERE especialidad_id IS NULL;

    -- Reportar resultados
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ Migración de especialidad completada';
    RAISE NOTICE '========================================';
    RAISE NOTICE '📊 Total de facultativos: %', total_facultativos;
    RAISE NOTICE '✅ Con especialidad_id: %', facultativos_con_especialidad;
    RAISE NOTICE '⚠️  Sin especialidad_id: %', facultativos_sin_especialidad;
    RAISE NOTICE '========================================';

    -- Mostrar facultativos sin especialidad mapeada (si hay)
    IF facultativos_sin_especialidad > 0 THEN
        RAISE NOTICE '⚠️  Facultativos sin especialidad mapeada:';
        FOR i IN (
            SELECT nombre, apellidos, especialidad
            FROM tfacultativos
            WHERE especialidad_id IS NULL
            LIMIT 10
        ) LOOP
            RAISE NOTICE '   - % % (especialidad: %)', i.nombre, i.apellidos, COALESCE(i.especialidad, 'NULL');
        END LOOP;
    END IF;

    -- Verificar constraint
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_tfacultativos_especialidad'
        AND table_name = 'tfacultativos'
    ) THEN
        RAISE NOTICE '✅ Foreign key constraint creado exitosamente';
    ELSE
        RAISE EXCEPTION '❌ Error: No se pudo crear el constraint FK';
    END IF;
END $$;
