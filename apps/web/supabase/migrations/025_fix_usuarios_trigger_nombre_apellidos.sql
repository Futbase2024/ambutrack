-- ==============================================================================
-- AmbuTrack Web - Fix: Capturar nombre/apellidos desde auth metadata
-- Migración: 025_fix_usuarios_trigger_nombre_apellidos.sql
--
-- Problema: El trigger handle_new_auth_user() solo insertaba id y email,
-- dejando nombre y apellidos como NULL. Esto causaba que en la gestión
-- de usuarios apareciera "Sin nombre" para muchos registros.
--
-- Soluciones:
-- 1. Actualizar el trigger para capturar nombre/apellidos desde raw_user_meta_data
-- 2. Backfill: Actualizar usuarios existentes sin nombre usando datos de personal
-- ==============================================================================

-- ==============================================================================
-- 1. ACTUALIZAR TRIGGER: handle_new_auth_user()
-- Ahora captura nombre y apellidos desde raw_user_meta_data de auth.users
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.usuarios (id, email, nombre, apellidos, created_at, updated_at)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'nombre', SPLIT_PART(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'apellidos',
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        nombre = COALESCE(EXCLUDED.nombre, usuarios.nombre),
        apellidos = COALESCE(EXCLUDED.apellidos, usuarios.apellidos),
        updated_at = NOW();

    RETURN NEW;
END;
$$;

-- ==============================================================================
-- 2. BACKFILL: Actualizar usuarios existentes sin nombre
-- Toma el nombre desde la tabla tpersonal si existe relación
-- Cubre tanto NULL como strings vacíos
-- ==============================================================================
UPDATE usuarios u
SET
    nombre = p.nombre,
    apellidos = p.apellidos,
    updated_at = NOW()
FROM tpersonal p
WHERE p.usuario_id = u.id
    AND (u.nombre IS NULL OR u.nombre = '' OR u.apellidos IS NULL OR u.apellidos = '');

-- Para usuarios sin relación en tpersonal, usar la parte local del email
UPDATE usuarios u
SET
    nombre = INITCAP(REPLACE(SPLIT_PART(u.email, '@', 1), '.', ' ')),
    updated_at = NOW()
WHERE (u.nombre IS NULL OR u.nombre = '')
    AND u.email IS NOT NULL;


