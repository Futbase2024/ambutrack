-- ============================================================================
-- FIX: Permitir a Jefe de Personal gestionar usuarios
-- Fecha: 2026-02-12
-- Proyecto: AmbuTrack (ycmopmnrhrpnnzkvnihr)
-- ============================================================================
-- PROBLEMA: Las políticas RLS solo permiten a 'admin' gestionar usuarios,
--           pero 'jefe_personal' también debe tener acceso completo
--
-- SOLUCIÓN: Crear función is_manager() que incluye ambos roles y actualizar
--           políticas para usarla
-- ============================================================================

-- ============================================================================
-- PASO 1: Crear función is_manager()
-- ============================================================================

CREATE OR REPLACE FUNCTION is_manager()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN get_current_user_role() IN ('admin', 'jefe_personal');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

COMMENT ON FUNCTION is_manager() IS
'Verifica si el usuario autenticado es admin o jefe_personal. Usa SECURITY DEFINER para bypass RLS.';

GRANT EXECUTE ON FUNCTION is_manager() TO authenticated;

-- ============================================================================
-- PASO 2: Recrear políticas usando is_manager()
-- ============================================================================

-- Eliminar políticas existentes
DROP POLICY IF EXISTS "Admin can view all users" ON usuarios;
DROP POLICY IF EXISTS "Admin can insert users" ON usuarios;
DROP POLICY IF EXISTS "Admin can update users" ON usuarios;
DROP POLICY IF EXISTS "Admin can delete users" ON usuarios;

-- Política: Managers (admin y jefe_personal) pueden ver todos los usuarios
CREATE POLICY "Managers can view all users"
  ON usuarios FOR SELECT
  TO authenticated
  USING (is_manager());

COMMENT ON POLICY "Managers can view all users" ON usuarios IS
'Permite a admin y jefe_personal ver todos los usuarios del sistema';

-- Política: Managers pueden insertar usuarios
CREATE POLICY "Managers can insert users"
  ON usuarios FOR INSERT
  TO authenticated
  WITH CHECK (is_manager());

COMMENT ON POLICY "Managers can insert users" ON usuarios IS
'Permite a admin y jefe_personal crear nuevos usuarios';

-- Política: Managers pueden actualizar usuarios
CREATE POLICY "Managers can update users"
  ON usuarios FOR UPDATE
  TO authenticated
  USING (is_manager());

COMMENT ON POLICY "Managers can update users" ON usuarios IS
'Permite a admin y jefe_personal actualizar cualquier usuario';

-- Política: Managers pueden eliminar usuarios
CREATE POLICY "Managers can delete users"
  ON usuarios FOR DELETE
  TO authenticated
  USING (is_manager());

COMMENT ON POLICY "Managers can delete users" ON usuarios IS
'Permite a admin y jefe_personal eliminar usuarios';

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

-- Verificar políticas recreadas
SELECT
  schemaname,
  tablename,
  policyname,
  cmd,
  qual AS using_clause
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'usuarios'
ORDER BY policyname;

-- ============================================================================
-- FIN DE MIGRACIÓN
-- ============================================================================
