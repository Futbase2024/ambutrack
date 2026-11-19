-- ==============================================================================
-- SCRIPT RÁPIDO: Crear usuario de prueba en AmbuTrack Mobile
-- ==============================================================================
-- Este script crea un usuario completo (auth + usuarios) listo para usar
-- ==============================================================================

-- PASO 1: Crear función RPC get_email_by_dni (si no existe)
-- ==============================================================================
CREATE OR REPLACE FUNCTION get_email_by_dni(dni_input TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  usuario_email TEXT;
BEGIN
  SELECT email INTO usuario_email
  FROM usuarios
  WHERE UPPER(dni) = UPPER(dni_input)
    AND es_activo = true
  LIMIT 1;

  RETURN COALESCE(usuario_email, '');
END;
$$;

-- PASO 2: Crear usuario en Supabase Auth
-- ==============================================================================
-- NOTA: Este paso debe hacerse desde la consola de Supabase:
-- 1. Ir a: Authentication > Users > Add User
-- 2. Email: 31687068X@ambutrack.com
-- 3. Password: admin123 (temporal, cambiar después)
-- 4. Copiar el UUID generado
-- 5. Reemplazar 'UUID_AQUI' abajo con ese UUID

-- PASO 3: Crear registro en tabla usuarios
-- ==============================================================================
-- Reemplazar 'UUID_AQUI' con el UUID del usuario creado en auth.users
-- Reemplazar 'EMPRESA_ID_AQUI' con el ID de tu empresa

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
  'UUID_AQUI', -- ⚠️ Reemplazar con UUID de auth.users
  '31687068X@ambutrack.com',
  '31687068X',
  'ADMIN',
  'DE PRUEBA',
  '+34600000001',
  'admin',
  true,
  'EMPRESA_ID_AQUI', -- ⚠️ Reemplazar con ID de empresa
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  dni = EXCLUDED.dni,
  email = EXCLUDED.email,
  updated_at = NOW();

-- ==============================================================================
-- VERIFICACIÓN: Probar que funciona
-- ==============================================================================
-- Ejecutar esta consulta para verificar que el usuario existe:
SELECT id, email, dni, nombre, apellidos, es_activo
FROM usuarios
WHERE dni = '31687068X';

-- Probar la función RPC:
SELECT get_email_by_dni('31687068X');
-- Debería retornar: 31687068X@ambutrack.com

-- ==============================================================================
-- AHORA PUEDES HACER LOGIN EN LA APP CON:
-- DNI: 31687068X
-- Password: admin123
-- ==============================================================================

-- ==============================================================================
-- CONSULTA DE AYUDA: Obtener ID de empresa
-- ==============================================================================
-- Si no conoces el ID de tu empresa, ejecuta:
SELECT id, nombre
FROM empresas
LIMIT 5;
