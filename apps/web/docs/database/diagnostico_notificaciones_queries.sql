-- =====================================================
-- SCRIPT DE DIAGNÓSTICO - NOTIFICACIONES MÓVIL → WEB
-- =====================================================
-- Ejecutar en: https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr/sql
-- Fecha: 2026-02-09

-- =====================================================
-- 1. VERIFICAR EXISTENCIA DE LA TABLA
-- =====================================================

SELECT '=== 1. EXISTENCIA DE TABLA ===' as section;

-- Verificar que la tabla existe
SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_name = 'tnotificaciones';

-- Conteo total de registros
SELECT
    COUNT(*) as total_notificaciones,
    COUNT(*) FILTER (WHERE leida = false) as no_leidas,
    COUNT(*) FILTER (WHERE leida = true) as leidas
FROM tnotificaciones;

-- =====================================================
-- 2. ANALIZAR DATOS EXISTENTES
-- =====================================================

SELECT '=== 2. ÚLTIMAS 20 NOTIFICACIONES ===' as section;

SELECT
    id,
    empresa_id,
    usuario_destino_id,
    tipo,
    titulo,
    leida,
    created_at
FROM tnotificaciones
ORDER BY created_at DESC
LIMIT 20;

-- =====================================================
-- 3. NOTIFICACIONES POR USUARIO
-- =====================================================

SELECT '=== 3. NOTIFICACIONES POR USUARIO ===' as section;

SELECT
    usuario_destino_id,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE leida = false) as no_leidas,
    MAX(created_at) as ultima_notificacion
FROM tnotificaciones
GROUP BY usuario_destino_id
ORDER BY total DESC;

-- =====================================================
-- 4. VERIFICAR USUARIOS EN AUTH
-- =====================================================

SELECT '=== 4. USUARIOS EN AUTH.USERS ===' as section;

SELECT
    id,
    email,
    created_at,
    last_sign_in_at,
    raw_user_meta_data->>'nombre' as nombre_meta,
    raw_user_meta_data->>'apellidos' as apellidos_meta
FROM auth.users
ORDER BY created_at DESC
LIMIT 20;

-- =====================================================
-- 5. VERIFICAR CORRESPONDENCIA CON TPERSONAL
-- =====================================================

SELECT '=== 5. CORRESPONDENCIA AUTH.USERS ↔ TPERSONAL ===' as section;

SELECT
    u.id as auth_user_id,
    u.email as auth_email,
    p.id as personal_id,
    p.email as personal_email,
    p.nombre,
    p.apellidos,
    p.categoria,
    p.activo
FROM auth.users u
LEFT JOIN tpersonal p ON p.usuario_id = u.id
ORDER BY u.created_at DESC
LIMIT 20;

-- Usuarios sin correspondencia en tpersonal
SELECT '=== 5b. USUARIOS AUTH SIN TPERSONAL ===' as section;

SELECT
    u.id,
    u.email,
    u.created_at
FROM auth.users u
LEFT JOIN tpersonal p ON p.usuario_id = u.id
WHERE p.id IS NULL;

-- =====================================================
-- 6. VERIFICAR REALTIME
-- =====================================================

SELECT '=== 6. CONFIGURACIÓN REALTIME ===' as section;

-- Verificar que realtime está habilitado para la tabla
SELECT
    pubname,
    schemaname,
    tablename
FROM pg_publication_tables
WHERE tablename = 'tnotificaciones';

-- =====================================================
-- 7. VERIFICAR POLÍTICAS RLS
-- =====================================================

SELECT '=== 7. POLÍTICAS RLS ===' as section;

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
WHERE tablename = 'tnotificaciones'
ORDER BY policyname;

-- =====================================================
-- 8. VERIFICAR PERMISOS DEL USUARIO ACTUAL
-- =====================================================

SELECT '=== 8. PERMISOS USUARIO ACTUAL ===' as section;

-- Nota: Esta query debe ejecutarse con un usuario autenticado
SELECT
    auth.uid() as current_user_id,
    EXISTS (
        SELECT 1 FROM tpersonal
        WHERE usuario_id = auth.uid()
        AND categoria IN ('admin', 'jefe_personal', 'jefe_trafico')
    ) as is_admin_or_jefe,
    EXISTS (
        SELECT 1 FROM tpersonal
        WHERE usuario_id = auth.uid()
    ) as exists_in_personal;

-- Intentar leer notificaciones del usuario actual
SELECT
    COUNT(*) as notificaciones_accesibles,
    STRING_AGG(DISTINCT tipo, ', ') as tipos_disponibles
FROM tnotificaciones
WHERE usuario_destino_id = auth.uid();

-- =====================================================
-- 9. NOTIFICACIONES DE LOS ÚLTIMOS 7 DÍAS
-- =====================================================

SELECT '=== 9. NOTIFICACIONES ÚLTIMOS 7 DÍAS ===' as section;

SELECT
    DATE(created_at) as fecha,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE leida = false) as no_leidas,
    STRING_AGG(DISTINCT tipo, ', ') as tipos
FROM tnotificaciones
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY fecha DESC;

-- =====================================================
-- 10. VERIFICAR ÍNDICES
-- =====================================================

SELECT '=== 10. ÍNDICES DE TABLA ===' as section;

SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'tnotificaciones'
ORDER BY indexname;

-- =====================================================
-- 11. PRUEBA DE INSERCIÓN (COMENTADA POR SEGURIDAD)
-- =====================================================

SELECT '=== 11. PRUEBA DE INSERCIÓN ===' as section;

-- Descomentar para probar inserción manual
-- Asegúrate de tener un usuario_id válido de auth.users

-- INSERT INTO tnotificaciones (
--     usuario_destino_id,
--     tipo,
--     titulo,
--     mensaje,
--     metadata
-- ) VALUES (
--     'TU_USER_ID_AQUI',  -- Reemplazar con un ID válido de auth.users
--     'info',
--     'Test de Notificación',
--     'Esta es una notificación de prueba desde SQL Editor',
--     '{"source": "sql_test"}'::jsonb
-- ) RETURNING id, created_at;

-- =====================================================
-- 12. VERIFICAR TRIGGERS DE NOTIFICACIÓN
-- =====================================================

SELECT '=== 12. TRIGGERS DE NOTIFICACIÓN ===' as section;

-- Verificar triggers en tabla vacaciones
SELECT
    trigger_name,
    event_manipulation,
    action_statement
FROM information_schema.triggers
WHERE event_object_table = 'vacaciones'
AND trigger_name LIKE '%notifica%';

-- Verificar triggers en tabla ausencias
SELECT
    trigger_name,
    event_manipulation,
    action_statement
FROM information_schema.triggers
WHERE event_object_table = 'ausencias'
AND trigger_name LIKE '%notifica%';

-- =====================================================
-- 13. VERIFICAR FUNCIONES AUXILIARES
-- =====================================================

SELECT '=== 13. FUNCIONES AUXILIARES ===' as section;

-- Verificar función crear_notificacion
SELECT
    routine_name,
    routine_type,
    data_type,
    routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name LIKE '%notifica%'
ORDER BY routine_name;

-- =====================================================
-- FIN DEL DIAGNÓSTICO
-- =====================================================

SELECT '=== DIAGNÓSTICO COMPLETADO ===' as section;
SELECT
    'Revisa los resultados de cada sección' as recomendacion,
    'Si hay errores en alguna sección, anótalos' as proximo_paso,
    'Para problemas de realtime, revisa la sección 6' as realtime_tip,
    'Para problemas de permisos, revisa las secciones 7 y 8' as rls_tip;
