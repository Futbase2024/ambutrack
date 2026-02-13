-- ==============================================================================
-- AmbuTrack Mobile - Crear función RPC get_email_by_dni
-- Función para obtener email de usuario por DNI (login mobile)
-- ==============================================================================

-- Eliminar función si existe (para actualizaciones)
DROP FUNCTION IF EXISTS get_email_by_dni(TEXT);

-- Crear función que busca el email asociado a un DNI
CREATE OR REPLACE FUNCTION get_email_by_dni(dni_input TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER -- Ejecuta con privilegios de owner (necesario para consultar auth.users)
AS $$
DECLARE
  usuario_email TEXT;
BEGIN
  -- Buscar el email en la tabla usuarios
  -- Usar UPPER para búsqueda case-insensitive
  -- Solo retornar usuarios activos (es_activo = true)
  SELECT email INTO usuario_email
  FROM usuarios
  WHERE UPPER(dni) = UPPER(dni_input)
    AND es_activo = true
  LIMIT 1;

  -- Si no se encuentra, retornar cadena vacía (el datasource lo maneja como null)
  RETURN COALESCE(usuario_email, '');
END;
$$;

-- Comentario para documentación
COMMENT ON FUNCTION get_email_by_dni(TEXT) IS
'Función RPC para AmbuTrack Mobile: Busca el email asociado a un DNI.
Solo retorna usuarios activos (es_activo = true).
Búsqueda case-insensitive.
Retorna cadena vacía si no encuentra el usuario.';

-- ==============================================================================
-- EJEMPLO DE USO:
-- SELECT get_email_by_dni('31687068X');
-- ==============================================================================
