-- ============================================================================
-- COMPLETAR USUARIO JEFE DE PERSONAL EN public.usuarios
-- ============================================================================
--
-- CONTEXTO:
-- El usuario YA FUE CREADO en auth.users con:
--   - Email: personal@ambulanciasbarbate.es
--   - Password: 123456
--
-- Este SQL completa el registro en public.usuarios
--
-- INSTRUCCIONES:
-- 1. Ir a: https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr/sql/new
-- 2. Copiar y pegar este SQL completo
-- 3. Click "Run" o presionar Ctrl+Enter
--
-- ============================================================================

-- PASO 1: Verificar si el usuario ya existe en public.usuarios
SELECT
  'VERIFICACIÓN: Usuario en public.usuarios' as paso,
  CASE
    WHEN COUNT(*) > 0 THEN '✅ YA EXISTE - No es necesario crear'
    ELSE '⏳ NO EXISTE - Proceder a crear'
  END as resultado,
  COUNT(*) as registros
FROM public.usuarios
WHERE email = 'personal@ambulanciasbarbate.es';

-- ============================================================================

-- PASO 2: Insertar el usuario en public.usuarios
-- (Solo se ejecutará si no existe)

INSERT INTO public.usuarios (
  id,
  email,
  dni,
  nombre,
  apellidos,
  rol,
  activo,
  empresa_id,
  created_at,
  updated_at
)
SELECT
  au.id,                                              -- UUID del usuario de auth.users
  'personal@ambulanciasbarbate.es',                  -- Email
  '44045224V',                                        -- DNI
  'Jorge Tomas',                                      -- Nombre
  'Ruiz Gallardo',                                    -- Apellidos
  'jefe_personal',                                    -- Rol
  true,                                               -- Activo
  '00000000-0000-0000-0000-000000000001',            -- Empresa (Ambulancias Barbate)
  NOW(),                                              -- Created at
  NOW()                                               -- Updated at
FROM auth.users au
WHERE au.email = 'personal@ambulanciasbarbate.es'
  AND NOT EXISTS (
    SELECT 1 FROM public.usuarios u
    WHERE u.email = 'personal@ambulanciasbarbate.es'
  )
RETURNING
  id as uuid,
  email,
  dni,
  nombre || ' ' || apellidos as nombre_completo,
  rol,
  activo,
  empresa_id;

-- ============================================================================

-- PASO 3: Verificar que todo esté correcto

SELECT
  'VERIFICACIÓN FINAL' as paso,
  u.id as uuid,
  u.email,
  u.dni,
  u.nombre,
  u.apellidos,
  u.nombre || ' ' || u.apellidos as nombre_completo,
  u.rol,
  u.activo,
  u.empresa_id,
  e.nombre as empresa_nombre,
  au.email_confirmed_at as email_confirmado,
  (SELECT COUNT(*) FROM auth.identities WHERE user_id = u.id) as identities_count
FROM public.usuarios u
LEFT JOIN public.empresas e ON u.empresa_id = e.id
LEFT JOIN auth.users au ON au.id = u.id
WHERE u.email = 'personal@ambulanciasbarbate.es';

-- ============================================================================
-- RESULTADO ESPERADO:
-- ============================================================================
--
-- PASO 1: Debe mostrar "⏳ NO EXISTE - Proceder a crear" (o "✅ YA EXISTE")
--
-- PASO 2: Debe retornar:
--   uuid: [UUID generado automáticamente]
--   email: personal@ambulanciasbarbate.es
--   dni: 44045224V
--   nombre_completo: Jorge Tomas Ruiz Gallardo
--   rol: jefe_personal
--   activo: true
--   empresa_id: 00000000-0000-0000-0000-000000000001
--
-- PASO 3: Debe mostrar todos los datos completos y:
--   email_confirmado: [timestamp]
--   identities_count: 1 (o más)
--
-- ============================================================================
-- PROBAR LOGIN:
-- ============================================================================
--
-- Una vez completado, puedes hacer login con:
--   - DNI: 44045224V + password: 123456
--   - Email: personal@ambulanciasbarbate.es + password: 123456
--
-- ============================================================================
