-- ========================================
-- POLÍTICAS RLS PARA TABLA tnotificaciones
-- ========================================
-- Este archivo contiene las políticas de Row Level Security (RLS)
-- necesarias para la tabla de notificaciones en Supabase.
--
-- IMPORTANTE: Estas políticas son necesarias para que los usuarios
-- puedan eliminar sus propias notificaciones desde la app móvil.

-- ========================================
-- 1. ELIMINAR LA POLÍTICA ANTIGUA (si existe)
-- ========================================

-- Eliminar políticas existentes de DELETE
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propias notificaciones" ON tnotificaciones;
DROP POLICY IF EXISTS "delete_own_notifications" ON tnotificaciones;

-- ========================================
-- 2. CREAR NUEVAS POLÍTICAS
-- ========================================

-- Política para SELECT (leer notificaciones)
-- Los usuarios solo pueden ver sus propias notificaciones
DROP POLICY IF EXISTS "select_own_notifications" ON tnotificaciones;
CREATE POLICY "select_own_notifications"
ON tnotificaciones
FOR SELECT
USING (
  auth.uid() = usuario_destino_id
);

-- Política para UPDATE (marcar como leída)
-- Los usuarios solo pueden actualizar sus propias notificaciones
DROP POLICY IF EXISTS "update_own_notifications" ON tnotificaciones;
CREATE POLICY "update_own_notifications"
ON tnotificaciones
FOR UPDATE
USING (
  auth.uid() = usuario_destino_id
)
WITH CHECK (
  auth.uid() = usuario_destino_id
);

-- Política para DELETE (eliminar notificaciones)
-- Los usuarios solo pueden eliminar sus propias notificaciones
DROP POLICY IF EXISTS "delete_own_notifications" ON tnotificaciones;
CREATE POLICY "delete_own_notifications"
ON tnotificaciones
FOR DELETE
USING (
  auth.uid() = usuario_destino_id
);

-- Política para INSERT (crear notificaciones)
-- Solo el sistema puede crear notificaciones
-- NOTA: Esta política puede variar según tu implementación
DROP POLICY IF EXISTS "insert_notifications" ON tnotificaciones;
CREATE POLICY "insert_notifications"
ON tnotificaciones
FOR INSERT
WITH CHECK (
  true -- Permitir a todos insertar (ajustar según necesidades)
);

-- ========================================
-- 3. HABILITAR RLS EN LA TABLA
-- ========================================

ALTER TABLE tnotificaciones ENABLE ROW LEVEL SECURITY;

-- ========================================
-- 4. VERIFICAR POLÍTICAS
-- ========================================

-- Ejecuta esta query para verificar las políticas creadas:
/*
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
WHERE tablename = 'tnotificaciones';
*/

-- ========================================
-- 5. PROBAR LA ELIMINACIÓN
-- ========================================

-- Para probar que funciona, ejecuta estas queries como usuario autenticado:
/*
-- Ver tus notificaciones
SELECT * FROM tnotificaciones WHERE usuario_destino_id = auth.uid();

-- Eliminar una notificación específica
DELETE FROM tnotificaciones WHERE id = 'ID_DE_TU_NOTIFICACION' AND usuario_destino_id = auth.uid();

-- Eliminar todas tus notificaciones
DELETE FROM tnotificaciones WHERE usuario_destino_id = auth.uid();
*/

-- ========================================
-- NOTAS IMPORTANTES
-- ========================================
/*
1. Las políticas RLS son fundamentales para la seguridad.
   Un usuario SOLO debe poder eliminar SUS PROPIAS notificaciones.

2. Si después de aplicar estas políticas sigue sin funcionar:
   - Verifica que el usuario está autenticado (auth.uid() no es null)
   - Verifica que el campo usuario_destino_id coincide con auth.uid()
   - Revisa los logs de Supabase para ver errores específicos

3. Para debugging en Supabase:
   - Ve a Table Editor → tnotificaciones
   - Haz clic en "RLS Policies"
   - Verifica que las políticas están activas

4. Si usas Service Role Key (bypass RLS):
   - Las políticas NO se aplican
   - Solo usar en backend, NUNCA en cliente
*/
