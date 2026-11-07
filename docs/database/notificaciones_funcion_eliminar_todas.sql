-- ================================================================
-- FUNCIÓN PARA ELIMINAR TODAS LAS NOTIFICACIONES DE UN USUARIO
-- ================================================================
-- Esta función permite eliminar todas las notificaciones de un usuario
-- usando SECURITY DEFINER para bypass RLS.
--
-- PROBLEMA SOLUCIONADO:
-- Las políticas RLS a veces bloquean DELETE masivos incluso cuando
-- el usuario tiene permisos. Esta función garantiza la eliminación.
--
-- USO:
-- SELECT eliminar_todas_notificaciones_usuario('usuario_id_aqui');
-- ================================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS eliminar_todas_notificaciones_usuario(uuid);

-- Crear función con SECURITY DEFINER
CREATE OR REPLACE FUNCTION eliminar_todas_notificaciones_usuario(
  p_usuario_id uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER -- ⚠️ CRÍTICO: Bypass RLS
SET search_path = public
AS $$
DECLARE
  v_current_user_id uuid;
  v_deleted_count int;
BEGIN
  -- 1. Obtener el ID del usuario autenticado
  v_current_user_id := auth.uid();

  -- 2. Validar autenticación
  IF v_current_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuario no autenticado'
      USING HINT = 'Debe iniciar sesión para eliminar notificaciones';
  END IF;

  -- 3. Seguridad: Validar que el usuario solo pueda eliminar SUS notificaciones
  IF v_current_user_id != p_usuario_id THEN
    RAISE EXCEPTION 'Permiso denegado: solo puedes eliminar tus propias notificaciones'
      USING HINT = 'No tienes permisos para eliminar notificaciones de otros usuarios';
  END IF;

  -- 4. Eliminar todas las notificaciones del usuario
  DELETE FROM tnotificaciones
  WHERE usuario_destino_id = p_usuario_id;

  -- 5. Obtener cantidad de filas eliminadas
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

  -- 6. Retornar resultado como JSON
  RETURN json_build_object(
    'success', true,
    'deleted_count', v_deleted_count,
    'usuario_id', p_usuario_id,
    'timestamp', now()
  );

EXCEPTION
  WHEN OTHERS THEN
    -- Capturar cualquier error y retornarlo como JSON
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM,
      'error_detail', SQLSTATE,
      'usuario_id', p_usuario_id,
      'timestamp', now()
    );
END;
$$;

-- ================================================================
-- GRANT: Permitir que usuarios autenticados ejecuten la función
-- ================================================================
GRANT EXECUTE ON FUNCTION eliminar_todas_notificaciones_usuario(uuid) TO authenticated;

-- ================================================================
-- COMENTARIO EN LA FUNCIÓN
-- ================================================================
COMMENT ON FUNCTION eliminar_todas_notificaciones_usuario(uuid) IS
'Elimina todas las notificaciones de un usuario específico.
Usa SECURITY DEFINER para bypass RLS.
Validación: El usuario autenticado solo puede eliminar SUS propias notificaciones.
Retorna JSON con resultado de la operación.';

-- ================================================================
-- TESTING
-- ================================================================
-- Para probar la función como usuario autenticado:
/*

-- 1. Ver notificaciones actuales
SELECT id, titulo, usuario_destino_id, created_at
FROM tnotificaciones
WHERE usuario_destino_id = auth.uid()
ORDER BY created_at DESC;

-- 2. Eliminar todas las notificaciones
SELECT eliminar_todas_notificaciones_usuario(auth.uid());

-- 3. Verificar que se eliminaron
SELECT COUNT(*) as total_restantes
FROM tnotificaciones
WHERE usuario_destino_id = auth.uid();

*/

-- ================================================================
-- NOTAS IMPORTANTES
-- ================================================================
/*
1. SECURITY DEFINER:
   - La función se ejecuta con los privilegios del CREADOR (superuser)
   - Esto permite bypass de RLS
   - Por eso es CRÍTICO validar que usuario_id coincida con auth.uid()

2. VALIDACIONES:
   - ✅ Verifica que el usuario esté autenticado
   - ✅ Verifica que solo elimine SUS notificaciones
   - ✅ Retorna JSON con conteo de eliminadas

3. SEGURIDAD:
   - NO usar esta función desde código backend con service_role key
   - Solo desde cliente con usuario autenticado
   - El GRANT solo permite authenticated, no anon

4. ALTERNATIVA A RLS:
   - Esta función es necesaria porque DELETE masivo a veces falla con RLS
   - Para DELETE individual, las políticas RLS funcionan bien
   - Para operaciones masivas, usar funciones con SECURITY DEFINER

5. LOGGING:
   - El datasource debe loguear el resultado JSON
   - Si success=false, lanzar DataSourceException con el error

*/
