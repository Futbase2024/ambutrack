-- ================================================
-- FIX: Políticas RLS para titv_revisiones
-- ================================================
-- Problema: Las políticas intentaban usar tabla 'users' que no existe
-- Solución: Usar tabla 'usuarios' correctamente
-- ================================================

-- 1. Ver políticas actuales (antes de eliminar)
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'titv_revisiones';

-- 2. ELIMINAR todas las políticas problemáticas de titv_revisiones
DROP POLICY IF EXISTS "titv_revisiones_select_policy" ON titv_revisiones;
DROP POLICY IF EXISTS "titv_revisiones_insert_policy" ON titv_revisiones;
DROP POLICY IF EXISTS "titv_revisiones_update_policy" ON titv_revisiones;
DROP POLICY IF EXISTS "titv_revisiones_delete_policy" ON titv_revisiones;
DROP POLICY IF EXISTS "Enable read access for all users" ON titv_revisiones;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON titv_revisiones;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON titv_revisiones;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON titv_revisiones;

-- 3. Crear políticas CORRECTAS usando tabla 'usuarios'

-- SELECT: Ver todas las revisiones de su empresa
CREATE POLICY "authenticated_can_select_titv_revisiones"
ON titv_revisiones
FOR SELECT
TO authenticated
USING (
  empresa_id IN (
    SELECT empresa_id FROM usuarios WHERE id = auth.uid()
  )
);

-- INSERT: Crear revisiones para su empresa
CREATE POLICY "authenticated_can_insert_titv_revisiones"
ON titv_revisiones
FOR INSERT
TO authenticated
WITH CHECK (
  empresa_id IN (
    SELECT empresa_id FROM usuarios WHERE id = auth.uid()
  )
);

-- UPDATE: Actualizar revisiones de su empresa
CREATE POLICY "authenticated_can_update_titv_revisiones"
ON titv_revisiones
FOR UPDATE
TO authenticated
USING (
  empresa_id IN (
    SELECT empresa_id FROM usuarios WHERE id = auth.uid()
  )
)
WITH CHECK (
  empresa_id IN (
    SELECT empresa_id FROM usuarios WHERE id = auth.uid()
  )
);

-- DELETE: Eliminar revisiones de su empresa
CREATE POLICY "authenticated_can_delete_titv_revisiones"
ON titv_revisiones
FOR DELETE
TO authenticated
USING (
  empresa_id IN (
    SELECT empresa_id FROM usuarios WHERE id = auth.uid()
  )
);

-- 4. Asegurar que RLS está habilitado
ALTER TABLE titv_revisiones ENABLE ROW LEVEL SECURITY;

-- 5. Dar permisos SELECT a tabla usuarios (necesario para las políticas)
GRANT SELECT ON usuarios TO authenticated;

-- 6. Verificar políticas creadas correctamente
SELECT
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'titv_revisiones';

-- ================================================
-- RESULTADO ESPERADO:
-- ================================================
-- Deberías ver 4 políticas creadas:
-- 1. authenticated_can_select_titv_revisiones (SELECT)
-- 2. authenticated_can_insert_titv_revisiones (INSERT)
-- 3. authenticated_can_update_titv_revisiones (UPDATE)
-- 4. authenticated_can_delete_titv_revisiones (DELETE)
-- ================================================
