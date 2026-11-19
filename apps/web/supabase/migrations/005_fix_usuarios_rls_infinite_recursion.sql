-- ============================================================================
-- FIX: Recursión Infinita en Políticas RLS de usuarios
-- Fecha: 2026-02-12
-- Proyecto: AmbuTrack (ycmopmnrhrpnnzkvnihr)
-- ============================================================================
-- PROBLEMA: Las políticas RLS de usuarios consultan la misma tabla usuarios,
--           causando recursión infinita (PostgrestException code: 42P17)
--
-- SOLUCIÓN: Usar funciones SECURITY DEFINER que bypass RLS para verificar roles
-- ============================================================================

-- ============================================================================
-- PASO 1: Eliminar políticas recursivas existentes
-- ============================================================================

DROP POLICY IF EXISTS "Admin can view all users" ON usuarios;
DROP POLICY IF EXISTS "Admin can insert users" ON usuarios;
DROP POLICY IF EXISTS "Admin can update users" ON usuarios;
DROP POLICY IF EXISTS "Admin can delete users" ON usuarios;
DROP POLICY IF EXISTS "Users can view their own data" ON usuarios;
DROP POLICY IF EXISTS "Users can update their own data" ON usuarios;

-- ============================================================================
-- PASO 2: Crear funciones auxiliares con SECURITY DEFINER
-- ============================================================================
-- Estas funciones ejecutan con privilegios del creador (bypass RLS)

-- Función: Verificar si el usuario autenticado es admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM usuarios
    WHERE id = auth.uid()
      AND rol = 'admin'
      AND activo = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- Función: Obtener rol del usuario autenticado
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT AS $$
DECLARE
  user_role TEXT;
BEGIN
  SELECT rol INTO user_role
  FROM usuarios
  WHERE id = auth.uid()
    AND activo = true;

  RETURN user_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- ============================================================================
-- PASO 3: Recrear políticas sin recursión
-- ============================================================================

-- Política: Admin puede ver todos los usuarios
CREATE POLICY "Admin can view all users"
  ON usuarios FOR SELECT
  TO authenticated
  USING (is_admin());

-- Política: Admin puede insertar usuarios
CREATE POLICY "Admin can insert users"
  ON usuarios FOR INSERT
  TO authenticated
  WITH CHECK (is_admin());

-- Política: Admin puede actualizar usuarios
CREATE POLICY "Admin can update users"
  ON usuarios FOR UPDATE
  TO authenticated
  USING (is_admin());

-- Política: Admin puede eliminar usuarios
CREATE POLICY "Admin can delete users"
  ON usuarios FOR DELETE
  TO authenticated
  USING (is_admin());

-- Política: Usuarios pueden ver sus propios datos
CREATE POLICY "Users can view their own data"
  ON usuarios FOR SELECT
  TO authenticated
  USING (id = auth.uid());

-- Política: Usuarios pueden actualizar sus propios datos (excepto rol)
-- ⚠️ Evitar consultar usuarios nuevamente para verificar rol
CREATE POLICY "Users can update their own data"
  ON usuarios FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (
    id = auth.uid() AND
    -- Verificar que el nuevo rol sea igual al rol actual sin subconsulta
    (rol = get_my_role() OR is_admin())
  );

-- ============================================================================
-- PASO 4: Otorgar permisos a las funciones
-- ============================================================================

GRANT EXECUTE ON FUNCTION is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION get_my_role() TO authenticated;

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

-- Query para verificar las políticas recreadas
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'usuarios'
ORDER BY policyname;

-- Query para verificar las funciones creadas
SELECT
  routine_schema,
  routine_name,
  security_type,
  sql_data_access
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('is_admin', 'get_my_role');

-- ============================================================================
-- TESTING RECOMENDADO
-- ============================================================================
-- 1. Conectar como usuario admin → SELECT * FROM usuarios (debe funcionar)
-- 2. Conectar como usuario no-admin → SELECT * FROM usuarios WHERE id = auth.uid() (debe funcionar)
-- 3. Conectar como usuario no-admin → SELECT * FROM usuarios (debe retornar solo su registro)
-- 4. Verificar que no hay más errores de recursión infinita
-- ============================================================================

-- ============================================================================
-- COMENTARIOS
-- ============================================================================

COMMENT ON FUNCTION is_admin() IS
'Verifica si el usuario autenticado es admin. Usa SECURITY DEFINER para bypass RLS y evitar recursión.';

COMMENT ON FUNCTION get_my_role() IS
'Obtiene el rol del usuario autenticado. Usa SECURITY DEFINER para bypass RLS y evitar recursión.';

COMMENT ON POLICY "Admin can view all users" ON usuarios IS
'Permite a los administradores ver todos los usuarios del sistema (sin recursión)';

COMMENT ON POLICY "Users can view their own data" ON usuarios IS
'Permite a los usuarios ver sus propios datos de perfil';

-- ============================================================================
-- FIN DE MIGRACIÓN
-- ============================================================================
