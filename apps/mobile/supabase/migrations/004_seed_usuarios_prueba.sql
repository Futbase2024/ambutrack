-- ==============================================================================
-- AmbuTrack Mobile - Seed de usuarios de prueba
-- Datos de prueba para desarrollo y testing
-- ==============================================================================

-- ==============================================================================
-- IMPORTANTE: Estos usuarios deben existir PRIMERO en auth.users
-- ==============================================================================
-- Para crear usuarios en Supabase Auth, usar la consola de Supabase o el dashboard:
-- 1. Ir a Authentication > Users > Add User
-- 2. Crear con email y password
-- 3. Copiar el UUID generado
-- 4. Actualizar este script con los UUIDs reales
--
-- O usar la función de Supabase Auth:
-- INSERT INTO auth.users (email, encrypted_password, email_confirmed_at, ...)
-- ==============================================================================

-- Usuario de prueba 1: Admin
-- Email: 31687068X@ambutrack.com
-- Password: admin123 (cambiar en producción)
-- UUID: Reemplazar con el UUID real de auth.users
INSERT INTO usuarios (
  id,
  email,
  dni,
  nombre,
  apellidos,
  telefono,
  rol,
  es_activo,
  empresa_id,
  created_at,
  updated_at
) VALUES (
  'REEMPLAZAR_CON_UUID_AUTH_USERS', -- UUID del usuario en auth.users
  '31687068X@ambutrack.com',
  '31687068X',
  'ADMIN',
  'DE PRUEBA',
  '+34600000001',
  'admin',
  true,
  (SELECT id FROM empresas LIMIT 1), -- Primera empresa disponible
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Usuario de prueba 2: Conductor
-- Email: 12345678A@ambutrack.com
-- Password: conductor123
INSERT INTO usuarios (
  id,
  email,
  dni,
  nombre,
  apellidos,
  telefono,
  rol,
  es_activo,
  empresa_id,
  created_at,
  updated_at
) VALUES (
  'REEMPLAZAR_CON_UUID_AUTH_USERS_2',
  '12345678A@ambutrack.com',
  '12345678A',
  'CONDUCTOR',
  'DE PRUEBA',
  '+34600000002',
  'conductor',
  true,
  (SELECT id FROM empresas LIMIT 1),
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Usuario de prueba 3: Gestor
-- Email: 87654321B@ambutrack.com
-- Password: gestor123
INSERT INTO usuarios (
  id,
  email,
  dni,
  nombre,
  apellidos,
  telefono,
  rol,
  es_activo,
  empresa_id,
  created_at,
  updated_at
) VALUES (
  'REEMPLAZAR_CON_UUID_AUTH_USERS_3',
  '87654321B@ambutrack.com',
  '87654321B',
  'GESTOR',
  'DE PRUEBA',
  '+34600000003',
  'gestor',
  true,
  (SELECT id FROM empresas LIMIT 1),
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- ==============================================================================
-- INSTRUCCIONES DE USO:
-- ==============================================================================
-- 1. Crear usuarios en Supabase Auth primero:
--    - Email: 31687068X@ambutrack.com, Password: admin123
--    - Email: 12345678A@ambutrack.com, Password: conductor123
--    - Email: 87654321B@ambutrack.com, Password: gestor123
--
-- 2. Copiar los UUIDs generados por Supabase Auth
--
-- 3. Reemplazar 'REEMPLAZAR_CON_UUID_AUTH_USERS' con los UUIDs reales
--
-- 4. Ejecutar este script
--
-- 5. Ahora puedes hacer login en AmbuTrack Mobile con:
--    - DNI: 31687068X
--    - Password: admin123
-- ==============================================================================
