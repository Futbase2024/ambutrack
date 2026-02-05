-- ==============================================================================
-- AmbuTrack Web - Agregar DNI a tabla usuarios
-- Migración para soportar login con DNI en mobile
-- ==============================================================================

-- Agregar columna dni a la tabla usuarios
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS dni TEXT UNIQUE;

-- Crear índice para búsquedas rápidas por DNI
CREATE INDEX IF NOT EXISTS idx_usuarios_dni ON usuarios(dni);

-- Comentario en la columna para documentación
COMMENT ON COLUMN usuarios.dni IS 'DNI del usuario (formato: 8 dígitos + 1 letra, ej: 31687068Z). Usado para login en AmbuTrack Mobile.';

-- ==============================================================================
-- IMPORTANTE:
-- Los usuarios que se loguean con DNI en mobile usarán el formato:
-- {DNI}@ambutrack.com como email en auth.users
-- El campo dni en usuarios permite búsqueda directa y validación
-- ==============================================================================
