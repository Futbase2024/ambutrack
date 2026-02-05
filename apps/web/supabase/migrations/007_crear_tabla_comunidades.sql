-- ==============================================================================
-- COMUNIDADES AUTÓNOMAS
-- Tabla de comunidades autónomas de España
-- Requerida por: tprovincias
-- ==============================================================================

-- Crear tabla
CREATE TABLE IF NOT EXISTS tcomunidades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo TEXT NOT NULL UNIQUE,
    nombre TEXT NOT NULL UNIQUE,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_tcomunidades_codigo ON tcomunidades(codigo);
CREATE INDEX idx_tcomunidades_nombre ON tcomunidades(nombre);

-- Row Level Security
ALTER TABLE tcomunidades ENABLE ROW LEVEL SECURITY;

-- Política: Todos pueden ver (lectura)
CREATE POLICY "Usuarios autenticados pueden ver comunidades" ON tcomunidades
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política: Solo admins pueden modificar
CREATE POLICY "Admins pueden gestionar comunidades" ON tcomunidades
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- ==============================================================================
-- DATOS INICIALES - 17 Comunidades Autónomas de España
-- ==============================================================================
INSERT INTO tcomunidades (codigo, nombre) VALUES
    ('AN', 'Andalucía'),
    ('AR', 'Aragón'),
    ('AS', 'Principado de Asturias'),
    ('IB', 'Illes Balears'),
    ('CN', 'Canarias'),
    ('CB', 'Cantabria'),
    ('CL', 'Castilla y León'),
    ('CM', 'Castilla-La Mancha'),
    ('CT', 'Catalunya'),
    ('VC', 'Comunitat Valenciana'),
    ('EX', 'Extremadura'),
    ('GA', 'Galicia'),
    ('MD', 'Comunidad de Madrid'),
    ('MU', 'Región de Murcia'),
    ('NC', 'Comunidad Foral de Navarra'),
    ('PV', 'País Vasco'),
    ('RI', 'La Rioja')
ON CONFLICT (codigo) DO NOTHING;

-- ==============================================================================
-- COMENTARIOS
-- ==============================================================================
COMMENT ON TABLE tcomunidades IS 'Comunidades autónomas de España';
COMMENT ON COLUMN tcomunidades.codigo IS 'Código oficial de la comunidad autónoma (2 letras)';
COMMENT ON COLUMN tcomunidades.nombre IS 'Nombre oficial de la comunidad autónoma';
