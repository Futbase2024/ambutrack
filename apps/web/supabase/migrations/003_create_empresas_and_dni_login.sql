-- ==============================================================================
-- AmbuTrack Web - Crear tabla empresas y soporte para login con DNI
-- Migración: 003_create_empresas_and_dni_login.sql
-- ==============================================================================

-- ==============================================================================
-- TABLA: empresas
-- Catálogo de empresas para multi-tenancy
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.empresas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    cif TEXT UNIQUE,
    razon_social TEXT,
    direccion TEXT,
    telefono TEXT,
    email TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    logo_url TEXT,
    configuracion JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_empresas_activo ON empresas(activo);
CREATE INDEX IF NOT EXISTS idx_empresas_cif ON empresas(cif);

-- Trigger de updated_at
CREATE TRIGGER update_empresas_updated_at
    BEFORE UPDATE ON empresas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================================
-- DATOS INICIALES (ANTES DE FK)
-- ==============================================================================

-- Insertar empresa por defecto si no existe ninguna
INSERT INTO empresas (id, nombre, cif, activo)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'AmbuTrack - Empresa Demo',
    'B12345678',
    true
)
ON CONFLICT (id) DO NOTHING;

-- ==============================================================================
-- AGREGAR FK DE usuarios.empresa_id → empresas.id
-- ==============================================================================
ALTER TABLE usuarios
    DROP CONSTRAINT IF EXISTS fk_usuarios_empresa;

ALTER TABLE usuarios
    ADD CONSTRAINT fk_usuarios_empresa
    FOREIGN KEY (empresa_id)
    REFERENCES empresas(id)
    ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_usuarios_empresa_id ON usuarios(empresa_id);

-- ==============================================================================
-- FUNCIÓN: Obtener email desde DNI
-- Usada para login con DNI + contraseña
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.get_email_by_dni(dni_input TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_email TEXT;
BEGIN
    -- Buscar email asociado al DNI (case-insensitive, sin espacios)
    SELECT email INTO user_email
    FROM public.usuarios
    WHERE UPPER(REPLACE(dni, ' ', '')) = UPPER(REPLACE(dni_input, ' ', ''))
    AND activo = true
    LIMIT 1;

    RETURN user_email;
END;
$$;

COMMENT ON FUNCTION public.get_email_by_dni IS 'Obtiene el email de un usuario dado su DNI. Usado para login con DNI + contraseña.';

-- ==============================================================================
-- FUNCIÓN: Sincronizar auth.users → usuarios (automático)
-- Crea registro en usuarios cuando se crea usuario en auth.users
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.usuarios (id, email, created_at, updated_at)
    VALUES (NEW.id, NEW.email, NOW(), NOW())
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        updated_at = NOW();

    RETURN NEW;
END;
$$;

-- Trigger para sincronizar automáticamente
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_auth_user();

-- ==============================================================================
-- RLS PARA EMPRESAS
-- ==============================================================================
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;

-- Usuarios autenticados pueden ver empresas activas
CREATE POLICY "Usuarios autenticados pueden ver empresas activas"
    ON empresas FOR SELECT
    USING (auth.role() = 'authenticated' AND activo = true);

-- Solo admins pueden gestionar empresas
CREATE POLICY "Solo admins pueden gestionar empresas"
    ON empresas FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- ==============================================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- ==============================================================================
COMMENT ON TABLE empresas IS 'Catálogo de empresas para multi-tenancy. Cada usuario pertenece a una empresa.';
COMMENT ON COLUMN empresas.configuracion IS 'Configuración personalizada de la empresa en formato JSON';
COMMENT ON COLUMN usuarios.empresa_id IS 'Referencia a la empresa a la que pertenece el usuario';
COMMENT ON COLUMN usuarios.dni IS 'DNI del usuario. Permite login con DNI + contraseña en lugar de email';
