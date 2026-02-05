-- ================================================
-- LIMPIEZA: Eliminar políticas duplicadas/conflictivas
-- ================================================

-- ELIMINAR TODAS las políticas antiguas y conflictivas
DROP POLICY IF EXISTS "Los usuarios pueden ver revisiones de su empresa" ON titv_revisiones;
DROP POLICY IF EXISTS "Los usuarios pueden insertar revisiones en su empresa" ON titv_revisiones;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar revisiones de su empresa" ON titv_revisiones;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar registros de su empresa" ON titv_revisiones;
DROP POLICY IF EXISTS "delete_titv_revisiones_con_roles" ON titv_revisiones;

-- MANTENER SOLO las políticas correctas (ya están creadas, no las borramos)
-- authenticated_can_select_titv_revisiones ✅
-- authenticated_can_insert_titv_revisiones ✅
-- authenticated_can_update_titv_revisiones ✅
-- authenticated_can_delete_titv_revisiones ✅

-- Verificar que quedaron SOLO 4 políticas
SELECT
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'titv_revisiones'
ORDER BY cmd, policyname;

-- ================================================
-- RESULTADO ESPERADO: Solo 4 políticas
-- ================================================
-- 1. authenticated_can_delete_titv_revisiones (DELETE)
-- 2. authenticated_can_insert_titv_revisiones (INSERT)
-- 3. authenticated_can_select_titv_revisiones (SELECT)
-- 4. authenticated_can_update_titv_revisiones (UPDATE)
-- ================================================
