-- ========================================
-- FIX: Recursión Infinita en Políticas RLS
-- Fecha: 2026-02-12
-- Problema: Las políticas consultan usuarios dentro de políticas de usuarios
-- Solución: Función SECURITY DEFINER que bypass RLS
-- ========================================

-- ============================================================
-- 1. CREAR FUNCIÓN AUXILIAR (SECURITY DEFINER)
-- ============================================================

-- Función que obtiene el rol del usuario autenticado sin activar RLS
CREATE OR REPLACE FUNCTION get_current_user_role()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_role TEXT;
BEGIN
  -- Consulta sin RLS gracias a SECURITY DEFINER
  SELECT rol INTO user_role
  FROM usuarios
  WHERE id = auth.uid()
    AND activo = true;

  RETURN user_role;
END;
$$;

-- Función que verifica si el usuario actual es admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN get_current_user_role() = 'admin';
END;
$$;

-- ============================================================
-- 2. ELIMINAR POLÍTICAS ANTIGUAS (CON RECURSIÓN)
-- ============================================================

DROP POLICY IF EXISTS "Admin can view all users" ON usuarios;
DROP POLICY IF EXISTS "Admin can insert users" ON usuarios;
DROP POLICY IF EXISTS "Admin can update users" ON usuarios;
DROP POLICY IF EXISTS "Admin can delete users" ON usuarios;
DROP POLICY IF EXISTS "Users can view their own data" ON usuarios;
DROP POLICY IF EXISTS "Users can update their own data" ON usuarios;

DROP POLICY IF EXISTS "Managers can view servicios" ON servicios;
DROP POLICY IF EXISTS "Admin and jefe_trafico can insert servicios" ON servicios;
DROP POLICY IF EXISTS "Admin and jefe_trafico can update servicios" ON servicios;
DROP POLICY IF EXISTS "Admin can delete servicios" ON servicios;

-- ============================================================
-- 3. RECREAR POLÍTICAS SIN RECURSIÓN
-- ============================================================

-- Tabla: usuarios
-- ============================================================

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
CREATE POLICY "Users can update their own data"
  ON usuarios FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (
    id = auth.uid() AND
    rol = get_current_user_role()
  );

-- Tabla: servicios
-- ============================================================

-- Eliminar función antigua si existe
DROP FUNCTION IF EXISTS can_manage_servicios();

-- Función auxiliar para verificar permisos de servicios
CREATE OR REPLACE FUNCTION can_manage_servicios()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_role TEXT;
BEGIN
  user_role := get_current_user_role();
  RETURN user_role IN ('admin', 'jefe_trafico', 'coordinador');
END;
$$;

-- Función para verificar si puede insertar/actualizar servicios
CREATE OR REPLACE FUNCTION can_modify_servicios()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_role TEXT;
BEGIN
  user_role := get_current_user_role();
  RETURN user_role IN ('admin', 'jefe_trafico');
END;
$$;

-- Política: Managers pueden ver servicios
CREATE POLICY "Managers can view servicios"
  ON servicios FOR SELECT
  TO authenticated
  USING (can_manage_servicios());

-- Política: Solo admin y jefe_trafico pueden insertar servicios
CREATE POLICY "Admin and jefe_trafico can insert servicios"
  ON servicios FOR INSERT
  TO authenticated
  WITH CHECK (can_modify_servicios());

-- Política: Solo admin y jefe_trafico pueden actualizar servicios
CREATE POLICY "Admin and jefe_trafico can update servicios"
  ON servicios FOR UPDATE
  TO authenticated
  USING (can_modify_servicios());

-- Política: Solo admin puede eliminar servicios
CREATE POLICY "Admin can delete servicios"
  ON servicios FOR DELETE
  TO authenticated
  USING (is_admin());

-- ============================================================
-- 4. COMENTARIOS Y DOCUMENTACIÓN
-- ============================================================

COMMENT ON FUNCTION get_current_user_role() IS
'Obtiene el rol del usuario autenticado sin activar RLS (SECURITY DEFINER)';

COMMENT ON FUNCTION is_admin() IS
'Verifica si el usuario actual es administrador';

COMMENT ON FUNCTION can_manage_servicios() IS
'Verifica si el usuario puede ver servicios (admin, jefe_trafico, coordinador)';

COMMENT ON FUNCTION can_modify_servicios() IS
'Verifica si el usuario puede crear/actualizar servicios (admin, jefe_trafico)';

COMMENT ON POLICY "Admin can view all users" ON usuarios IS
'Permite a los administradores ver todos los usuarios del sistema (sin recursión)';

COMMENT ON POLICY "Users can view their own data" ON usuarios IS
'Permite a los usuarios ver sus propios datos de perfil';

-- ============================================================
-- 5. VERIFICACIÓN
-- ============================================================

-- Query para verificar las políticas recreadas
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'servicios')
ORDER BY tablename, policyname;

-- Query para verificar las funciones creadas
SELECT
  proname as function_name,
  prosecdef as is_security_definer
FROM pg_proc
WHERE proname IN ('get_current_user_role', 'is_admin', 'can_manage_servicios', 'can_modify_servicios')
ORDER BY proname;

-- ============================================================
-- FIN DE MIGRACIÓN
-- ============================================================
