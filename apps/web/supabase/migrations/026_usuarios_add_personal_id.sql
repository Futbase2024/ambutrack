-- ==============================================================================
-- AmbuTrack Web - Asociar usuarios con tpersonal
-- Migración: 026_usuarios_add_personal_id.sql
--
-- Relaciona usuarios con tpersonal para que los nombres se obtengan
-- desde tpersonal (fuente única de verdad) mediante JOIN.
-- ==============================================================================

-- ==============================================================================
-- 1. AGREGAR columna personal_id
-- ==============================================================================
ALTER TABLE usuarios
    ADD COLUMN personal_id UUID REFERENCES tpersonal(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_usuarios_personal_id ON usuarios(personal_id);

-- ==============================================================================
-- 2. BACKFILL: Vincular usuarios existentes con su registro en tpersonal
-- ==============================================================================
UPDATE usuarios u
SET personal_id = p.id,
    updated_at = NOW()
FROM tpersonal p
WHERE p.usuario_id = u.id
    AND u.personal_id IS NULL;
