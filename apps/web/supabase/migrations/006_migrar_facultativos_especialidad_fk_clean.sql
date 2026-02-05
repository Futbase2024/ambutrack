-- Migración: Facultativos - Especialidad TEXT → FK
-- Convierte el campo 'especialidad' de TEXT a FK hacia tespecialidades

-- PASO 1: Agregar nueva columna especialidad_id (si no existe)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tfacultativos' AND column_name = 'especialidad_id'
    ) THEN
        ALTER TABLE tfacultativos ADD COLUMN especialidad_id UUID;
        RAISE NOTICE '✅ Columna especialidad_id creada';
    ELSE
        RAISE NOTICE '⚠️  Columna especialidad_id ya existe';
    END IF;
END $$;

-- PASO 2: Migrar datos existentes (mapear texto → UUID)
-- Solo si la columna 'especialidad' TEXT existe
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tfacultativos' AND column_name = 'especialidad'
    ) THEN
        -- Mapear especialidades por nombre
        UPDATE tfacultativos
        SET especialidad_id = (
            SELECT id FROM tespecialidades
            WHERE LOWER(tespecialidades.nombre) = LOWER(tfacultativos.especialidad)
            LIMIT 1
        )
        WHERE especialidad IS NOT NULL
          AND especialidad != ''
          AND especialidad_id IS NULL;

        RAISE NOTICE '✅ Datos migrados desde columna especialidad';
    ELSE
        RAISE NOTICE '⚠️  Columna especialidad (TEXT) no existe, se omite migración de datos';
    END IF;
END $$;

-- PASO 3: Crear Foreign Key constraint (si no existe)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_tfacultativos_especialidad'
        AND table_name = 'tfacultativos'
    ) THEN
        ALTER TABLE tfacultativos
        ADD CONSTRAINT fk_tfacultativos_especialidad
        FOREIGN KEY (especialidad_id)
        REFERENCES tespecialidades(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE;
        RAISE NOTICE '✅ Foreign key constraint creado';
    ELSE
        RAISE NOTICE '⚠️  Foreign key constraint ya existe';
    END IF;
END $$;

-- PASO 4: Crear índice (si no existe)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE tablename = 'tfacultativos' AND indexname = 'idx_tfacultativos_especialidad_id'
    ) THEN
        CREATE INDEX idx_tfacultativos_especialidad_id ON tfacultativos(especialidad_id);
        RAISE NOTICE '✅ Índice creado';
    ELSE
        RAISE NOTICE '⚠️  Índice ya existe';
    END IF;
END $$;

-- PASO 5: Agregar comentario
COMMENT ON COLUMN tfacultativos.especialidad_id IS 'FK hacia tespecialidades - Especialidad médica del facultativo';

-- VERIFICACIÓN FINAL
DO $$
DECLARE
    total_facultativos INTEGER;
    facultativos_con_especialidad INTEGER;
    facultativos_sin_especialidad INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_facultativos FROM tfacultativos;
    SELECT COUNT(*) INTO facultativos_con_especialidad FROM tfacultativos WHERE especialidad_id IS NOT NULL;
    SELECT COUNT(*) INTO facultativos_sin_especialidad FROM tfacultativos WHERE especialidad_id IS NULL;

    RAISE NOTICE '========================================';
    RAISE NOTICE 'MIGRACIÓN COMPLETADA';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Total de facultativos: %', total_facultativos;
    RAISE NOTICE 'Con especialidad_id: %', facultativos_con_especialidad;
    RAISE NOTICE 'Sin especialidad_id: %', facultativos_sin_especialidad;
    RAISE NOTICE '========================================';

    -- Verificar constraint
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_tfacultativos_especialidad'
        AND table_name = 'tfacultativos'
    ) THEN
        RAISE NOTICE '✅ Foreign key constraint verificado';
    ELSE
        RAISE EXCEPTION '❌ Error: Foreign key constraint no encontrado';
    END IF;
END $$;
