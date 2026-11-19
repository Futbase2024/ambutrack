-- ============================================================================
-- REVERT: Remover acceso de Jefe de Personal a gestión de usuarios
-- Fecha: 2026-02-12
-- Proyecto: AmbuTrack (ycmopmnrhrpnnzkvnihr)
-- ============================================================================
-- MOTIVO: El jefe_personal NO debe gestionar usuarios.
--         Solo el rol 'admin' debe tener acceso completo a la tabla usuarios.
--
-- ACCIÓN: Revertir la migración anterior que permitía acceso a jefe_personal
-- ============================================================================

-- ============================================================================
-- PASO 1: Eliminar políticas que usan is_manager()
-- ============================================================================

DROP POLICY IF EXISTS "Managers can view all users" ON usuarios;
DROP POLICY IF EXISTS "Managers can insert users" ON usuarios;
DROP POLICY IF EXISTS "Managers can update users" ON usuarios;
DROP POLICY IF EXISTS "Managers can delete users" ON usuarios;

-- ============================================================================
-- PASO 2: Recrear políticas usando is_admin() (solo admin)
-- ============================================================================

-- Política: Solo Admin puede ver todos los usuarios
CREATE POLICY "Admin can view all users"
  ON usuarios FOR SELECT
  TO authenticated
  USING (is_admin());

COMMENT ON POLICY "Admin can view all users" ON usuarios IS
'Permite SOLO a admin ver todos los usuarios del sistema. Jefe de personal NO tiene acceso.';

-- Política: Solo Admin puede insertar usuarios
CREATE POLICY "Admin can insert users"
  ON usuarios FOR INSERT
  TO authenticated
  WITH CHECK (is_admin());

COMMENT ON POLICY "Admin can insert users" ON usuarios IS
'Permite SOLO a admin crear nuevos usuarios. Jefe de personal NO tiene acceso.';

-- Política: Solo Admin puede actualizar usuarios
CREATE POLICY "Admin can update users"
  ON usuarios FOR UPDATE
  TO authenticated
  USING (is_admin());

COMMENT ON POLICY "Admin can update users" ON usuarios IS
'Permite SOLO a admin actualizar cualquier usuario. Jefe de personal NO tiene acceso.';

-- Política: Solo Admin puede eliminar usuarios
CREATE POLICY "Admin can delete users"
  ON usuarios FOR DELETE
  TO authenticated
  USING (is_admin());

COMMENT ON POLICY "Admin can delete users" ON usuarios IS
'Permite SOLO a admin eliminar usuarios. Jefe de personal NO tiene acceso.';

-- ============================================================================
-- NOTA: Las políticas de usuarios regulares se mantienen sin cambios
-- ============================================================================
-- "Users can view their own data" - permite a cualquier usuario ver sus propios datos
-- "Users can update their own data" - permite a cualquier usuario actualizar sus propios datos

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

-- Verificar políticas restauradas
SELECT
  policyname,
  cmd,
  qual AS using_clause
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'usuarios'
ORDER BY policyname;

-- ============================================================================
-- RESULTADO ESPERADO
-- ============================================================================
-- Admin: Puede ver/crear/editar/eliminar TODOS los usuarios
-- Jefe de Personal: Solo puede ver sus propios datos (como cualquier usuario)
-- Otros usuarios: Solo pueden ver sus propios datos
-- ============================================================================

-- ============================================================================
-- FIN DE MIGRACIÓN
-- ============================================================================
