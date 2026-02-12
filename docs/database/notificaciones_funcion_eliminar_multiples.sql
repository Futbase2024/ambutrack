-- ================================================================
-- FUNCIÓN PARA ELIMINAR MÚLTIPLES NOTIFICACIONES DE UN USUARIO
-- ================================================================
-- Esta función permite eliminar varias notificaciones específicas
-- usando SECURITY DEFINER para bypass RLS.
--
-- PROBLEMA SOLUCIONADO:
-- Las políticas RLS a veces bloquean DELETE con IN clause
-- incluso cuando el usuario tiene permisos.
--
-- USO:
-- SELECT eliminar_notificaciones_usuario(
--   ARRAY['id1', 'id2', 'id3']::uuid[]
-- );
-- ================================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS eliminar_notificaciones_usuario(uuid[]);

-- Crear función con SECURITY DEFINER
CREATE OR REPLACE FUNCTION eliminar_notificaciones_usuario(
  p_notification_ids uuid[]
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER -- ⚠️ CRÍTICO: Bypass RLS
SET search_path = public
AS $$
DECLARE
  v_current_user_id uuid;
  v_deleted_count int;
  v_not_owned_count int;
BEGIN
  -- 1. Obtener el ID del usuario autenticado
  v_current_user_id := auth.uid();

  -- 2. Validar autenticación
  IF v_current_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuario no autenticado'
      USING HINT = 'Debe iniciar sesión para eliminar notificaciones';
  END IF;

  -- 3. Validar que el array no esté vacío
  IF p_notification_ids IS NULL OR array_length(p_notification_ids, 1) IS NULL THEN
    RETURN json_build_object(
      'success', true,
      'deleted_count', 0,
      'message', 'No se proporcionaron IDs para eliminar',
      'timestamp', now()
    );
  END IF;

  -- 4. Contar notificaciones que NO pertenecen al usuario
  SELECT COUNT(*)
  INTO v_not_owned_count
  FROM tnotificaciones
  WHERE id = ANY(p_notification_ids)
    AND usuario_destino_id != v_current_user_id;

  -- 5. Si hay notificaciones que no pertenecen al usuario, denegar
  IF v_not_owned_count > 0 THEN
    RAISE EXCEPTION 'Permiso denegado: intentas eliminar % notificaciones que no te pertenecen', v_not_owned_count
      USING HINT = 'Solo puedes eliminar tus propias notificaciones';
  END IF;

  -- 6. Eliminar las notificaciones que SÍ pertenecen al usuario
  DELETE FROM tnotificaciones
  WHERE id = ANY(p_notification_ids)
    AND usuario_destino_id = v_current_user_id;

  -- 7. Obtener cantidad de filas eliminadas
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

  -- 8. Retornar resultado como JSON
  RETURN json_build_object(
    'success', true,
    'deleted_count', v_deleted_count,
    'requested_count', array_length(p_notification_ids, 1),
    'usuario_id', v_current_user_id,
    'timestamp', now()
  );

EXCEPTION
  WHEN OTHERS THEN
    -- Capturar cualquier error y retornarlo como JSON
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM,
      'error_detail', SQLSTATE,
      'requested_count', array_length(p_notification_ids, 1),
      'timestamp', now()
    );
END;
$$;

-- ================================================================
-- GRANT: Permitir que usuarios autenticados ejecuten la función
-- ================================================================
GRANT EXECUTE ON FUNCTION eliminar_notificaciones_usuario(uuid[]) TO authenticated;

-- ================================================================
-- COMENTARIO EN LA FUNCIÓN
-- ================================================================
COMMENT ON FUNCTION eliminar_notificaciones_usuario(uuid[]) IS
'Elimina múltiples notificaciones de un usuario específico.
Usa SECURITY DEFINER para bypass RLS.
Validación: El usuario autenticado solo puede eliminar SUS propias notificaciones.
Retorna JSON con resultado de la operación y conteo de eliminadas.';

-- ================================================================
-- TESTING
-- ================================================================
-- Para probar la función como usuario autenticado:
/*

-- 1. Ver tus notificaciones actuales
SELECT id, titulo, usuario_destino_id, created_at
FROM tnotificaciones
WHERE usuario_destino_id = auth.uid()
ORDER BY created_at DESC;

-- 2. Eliminar notificaciones específicas (reemplaza con tus IDs)
SELECT eliminar_notificaciones_usuario(
  ARRAY[
    'id-notificacion-1'::uuid,
    'id-notificacion-2'::uuid,
    'id-notificacion-3'::uuid
  ]
);

-- 3. Verificar que se eliminaron
SELECT COUNT(*) as total_restantes
FROM tnotificaciones
WHERE usuario_destino_id = auth.uid();

-- 4. Intentar eliminar notificación de otro usuario (debe fallar)
-- Esto debe retornar success=false con mensaje de permiso denegado
SELECT eliminar_notificaciones_usuario(
  ARRAY['id-de-otro-usuario'::uuid]
);

*/

-- ================================================================
-- NOTAS IMPORTANTES
-- ================================================================
/*
1. SECURITY DEFINER:
   - La función se ejecuta con los privilegios del CREADOR
   - Permite bypass de RLS
   - CRÍTICO: Validar que las notificaciones pertenezcan al usuario

2. VALIDACIONES:
   - ✅ Verifica autenticación
   - ✅ Valida que TODAS las notificaciones pertenezcan al usuario
   - ✅ Si UNA no pertenece, falla TODA la operación (atomicidad)
   - ✅ Retorna conteo de eliminadas vs solicitadas

3. SEGURIDAD:
   - Cuenta las notificaciones que NO pertenecen al usuario
   - Si hay alguna, RAISE EXCEPTION (operación atómica)
   - Solo elimina si TODAS pertenecen al usuario

4. RETORNO:
   - success: true/false
   - deleted_count: cuántas se eliminaron
   - requested_count: cuántas se solicitaron eliminar
   - Si deleted_count < requested_count: algunas no existían

5. USO DESDE DART:
   ```dart
   final response = await _client.rpc(
     'eliminar_notificaciones_usuario',
     params: {'p_notification_ids': ids},
   );
   ```

*/
