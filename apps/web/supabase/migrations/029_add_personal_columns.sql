-- ==============================================================================
-- AmbuTrack Web - Añadir columnas faltantes a tpersonal
-- Migración: 029_add_personal_columns.sql
--
-- Añade las columnas de asignación por defecto que están en la entidad
-- PersonalEntity pero no existen en la tabla tpersonal.
-- ==============================================================================

-- Añadir columnas de asignación por defecto (si no existen)
DO $$
BEGIN
    -- Contrato/Cliente asignado
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tpersonal' AND column_name = 'contrato_asignado_id'
    ) THEN
        ALTER TABLE tpersonal ADD COLUMN contrato_asignado_id UUID;
    END IF;

    -- Base
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tpersonal' AND column_name = 'base_id'
    ) THEN
        ALTER TABLE tpersonal ADD COLUMN base_id UUID;
    END IF;

    -- Dotación
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tpersonal' AND column_name = 'dotacion_id'
    ) THEN
        ALTER TABLE tpersonal ADD COLUMN dotacion_id UUID;
    END IF;

    -- Vehículo
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tpersonal' AND column_name = 'vehiculo_id'
    ) THEN
        ALTER TABLE tpersonal ADD COLUMN vehiculo_id UUID;
    END IF;
END $$;
