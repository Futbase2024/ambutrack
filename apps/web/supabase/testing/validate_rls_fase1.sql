-- ==========================================
-- VALIDACIÓN RÁPIDA - FASE 1
-- Ejecuta este script en Supabase SQL Editor
-- ==========================================

-- ============================================
-- 1. VERIFICAR RLS HABILITADO
-- ============================================
SELECT
  '✅ TEST 1: RLS Habilitado' as test_name,
  tablename,
  CASE
    WHEN rowsecurity = true THEN '✅ PASS'
    ELSE '❌ FAIL - RLS NO HABILITADO'
  END as status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'servicios')
ORDER BY tablename;

-- ============================================
-- 2. CONTAR POLÍTICAS CREADAS
-- ============================================
SELECT
  '✅ TEST 2: Políticas RLS Creadas' as test_name,
  tablename,
  COUNT(*) as total_policies,
  CASE
    WHEN tablename = 'usuarios' AND COUNT(*) = 6 THEN '✅ PASS (6 esperadas)'
    WHEN tablename = 'servicios' AND COUNT(*) = 4 THEN '✅ PASS (4 esperadas)'
    ELSE '❌ FAIL - Número incorrecto de políticas'
  END as status
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'servicios')
GROUP BY tablename
ORDER BY tablename;

-- ============================================
-- 3. LISTAR POLÍTICAS DETALLADAS
-- ============================================
SELECT
  '📋 DETALLE: Políticas por Tabla' as info,
  tablename,
  policyname,
  cmd as operation,
  permissive,
  roles
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'servicios')
ORDER BY tablename, cmd, policyname;

-- ============================================
-- 4. VERIFICAR FUNCIÓN can_manage_servicios
-- ============================================
SELECT
  '✅ TEST 3: Función can_manage_servicios' as test_name,
  proname as function_name,
  CASE
    WHEN proname = 'can_manage_servicios' THEN '✅ PASS'
    ELSE '❌ FAIL'
  END as status
FROM pg_proc
WHERE proname = 'can_manage_servicios';

-- ============================================
-- 5. VERIFICAR USUARIOS DE PRUEBA
-- ============================================
SELECT
  '✅ TEST 4: Usuarios de Prueba' as test_name,
  COUNT(*) as total_usuarios_activos,
  COUNT(DISTINCT rol) as total_roles_diferentes,
  CASE
    WHEN COUNT(*) >= 3 AND COUNT(DISTINCT rol) >= 3
    THEN '✅ PASS - Suficientes usuarios para testing'
    ELSE '⚠️ WARNING - Necesitas al menos 3 usuarios con roles diferentes'
  END as status
FROM usuarios
WHERE activo = true;

-- ============================================
-- 6. LISTAR USUARIOS POR ROL
-- ============================================
SELECT
  '📋 DETALLE: Usuarios por Rol' as info,
  rol,
  COUNT(*) as cantidad,
  STRING_AGG(email, ', ') as emails
FROM usuarios
WHERE activo = true
GROUP BY rol
ORDER BY rol;

-- ============================================
-- 7. VERIFICAR USUARIO ADMIN EXISTE
-- ============================================
SELECT
  '✅ TEST 5: Usuario Admin Existe' as test_name,
  COUNT(*) as admin_count,
  STRING_AGG(email, ', ') as admin_emails,
  CASE
    WHEN COUNT(*) >= 1 THEN '✅ PASS'
    ELSE '❌ FAIL - NO HAY ADMIN! Crítico!'
  END as status
FROM usuarios
WHERE rol = 'admin' AND activo = true;

-- ============================================
-- 8. VERIFICAR POLÍTICAS INSEGURAS ELIMINADAS
-- ============================================
SELECT
  '✅ TEST 6: Políticas Inseguras Eliminadas' as test_name,
  COALESCE(COUNT(*), 0) as insecure_policies_count,
  CASE
    WHEN COUNT(*) = 0 THEN '✅ PASS - No hay políticas inseguras'
    ELSE '❌ FAIL - Políticas inseguras encontradas: ' || STRING_AGG(policyname, ', ')
  END as status
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'servicios')
  AND (
    policyname IN (
      'usuarios_read_all',
      'usuarios_insert',
      'usuarios_update',
      'Usuarios pueden actualizar su propio perfil',
      'Usuarios pueden ver su propio perfil',
      'servicios_all_authenticated'
    )
    OR roles @> ARRAY['public']::name[]
  );

-- ============================================
-- 9. RESUMEN FINAL
-- ============================================
SELECT
  '=' as separator,
  '🎯 RESUMEN FINAL' as resumen,
  '=' as separator2;

SELECT
  'RLS Habilitado' as feature,
  COUNT(*) FILTER (WHERE rowsecurity = true)::text || ' / 2' as status,
  CASE
    WHEN COUNT(*) FILTER (WHERE rowsecurity = true) = 2 THEN '✅'
    ELSE '❌'
  END as result
FROM pg_tables
WHERE schemaname = 'public' AND tablename IN ('usuarios', 'servicios')

UNION ALL

SELECT
  'Políticas Creadas' as feature,
  COUNT(*)::text || ' / 10' as status,
  CASE
    WHEN COUNT(*) = 10 THEN '✅'
    ELSE '❌'
  END as result
FROM pg_policies
WHERE schemaname = 'public' AND tablename IN ('usuarios', 'servicios')

UNION ALL

SELECT
  'Función can_manage_servicios' as feature,
  CASE WHEN COUNT(*) = 1 THEN 'Existe' ELSE 'No existe' END as status,
  CASE
    WHEN COUNT(*) = 1 THEN '✅'
    ELSE '❌'
  END as result
FROM pg_proc
WHERE proname = 'can_manage_servicios'

UNION ALL

SELECT
  'Usuarios Activos' as feature,
  COUNT(*)::text as status,
  CASE
    WHEN COUNT(*) >= 3 THEN '✅'
    ELSE '⚠️'
  END as result
FROM usuarios
WHERE activo = true

UNION ALL

SELECT
  'Usuario Admin' as feature,
  CASE WHEN COUNT(*) >= 1 THEN 'Existe' ELSE 'NO EXISTE' END as status,
  CASE
    WHEN COUNT(*) >= 1 THEN '✅'
    ELSE '❌'
  END as result
FROM usuarios
WHERE rol = 'admin' AND activo = true

UNION ALL

SELECT
  'Políticas Inseguras' as feature,
  CASE WHEN COUNT(*) = 0 THEN 'Ninguna' ELSE COUNT(*)::text || ' encontradas' END as status,
  CASE
    WHEN COUNT(*) = 0 THEN '✅'
    ELSE '❌'
  END as result
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'servicios')
  AND (
    policyname IN ('usuarios_read_all', 'usuarios_insert', 'usuarios_update', 'servicios_all_authenticated')
    OR roles @> ARRAY['public']::name[]
  );

-- ============================================
-- 10. RECOMENDACIONES
-- ============================================
SELECT
  '💡 RECOMENDACIONES' as titulo;

-- Si no hay admin
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM usuarios WHERE rol = 'admin' AND activo = true) THEN
    RAISE WARNING '❌ CRÍTICO: No hay usuario admin. Crea uno inmediatamente desde Supabase Dashboard > Authentication';
  END IF;
END $$;

-- Si hay pocas usuarios
DO $$
DECLARE
  user_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO user_count FROM usuarios WHERE activo = true;
  IF user_count < 3 THEN
    RAISE WARNING '⚠️ RECOMENDACIÓN: Solo hay % usuarios activos. Crea al menos 3 con roles diferentes para testing completo.', user_count;
  END IF;
END $$;

-- ============================================
-- FIN DE VALIDACIÓN
-- ============================================
SELECT
  '✅ VALIDACIÓN COMPLETADA' as mensaje,
  NOW() as timestamp;
