-- =====================================================
-- INSTRUCCIONES DE EJECUCIÓN
-- =====================================================
-- 1. Abre Supabase Dashboard: https://app.supabase.com
-- 2. Ve a tu proyecto
-- 3. Click en "SQL Editor" en el menú lateral
-- 4. Copia y pega este script completo
-- 5. Click en "Run" (Ctrl/Cmd + Enter)
-- =====================================================

-- VERIFICAR SI LA TABLA EXISTE
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_schema = 'public'
               AND table_name = 'pacientes') THEN

        -- La tabla existe, solo agregar la columna si no existe
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                       WHERE table_schema = 'public'
                       AND table_name = 'pacientes'
                       AND column_name = 'recogida_festivos') THEN

            -- Agregar la columna
            ALTER TABLE public.pacientes
            ADD COLUMN recogida_festivos BOOLEAN DEFAULT FALSE;

            RAISE NOTICE 'Columna recogida_festivos agregada exitosamente';
        ELSE
            RAISE NOTICE 'La columna recogida_festivos ya existe';
        END IF;

    ELSE
        RAISE EXCEPTION 'La tabla pacientes no existe. Por favor ejecuta la migración completa: 20250129_create_pacientes_table.sql';
    END IF;
END $$;

-- Agregar comentario a la columna
COMMENT ON COLUMN public.pacientes.recogida_festivos IS 'Indica si el paciente tiene recogida en días festivos';

-- Refrescar el schema cache de PostgREST
NOTIFY pgrst, 'reload schema';
