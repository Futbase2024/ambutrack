-- ==============================================================================
-- CENTROS HOSPITALARIOS
-- Tabla de centros hospitalarios, clínicas y centros de salud
-- Dependencia: tpoblaciones
-- Requerida por: tfacultativos, servicios
-- ==============================================================================

-- Crear tabla
CREATE TABLE IF NOT EXISTS tcentros_hospitalarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    direccion TEXT,
    localidad_id UUID REFERENCES tpoblaciones(id) ON DELETE SET NULL,
    telefono TEXT,
    email TEXT,
    tipo_centro TEXT CHECK (tipo_centro IN ('hospital', 'centro_salud', 'clinica')),
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_tcentros_nombre ON tcentros_hospitalarios(nombre);
CREATE INDEX idx_tcentros_localidad ON tcentros_hospitalarios(localidad_id);
CREATE INDEX idx_tcentros_tipo ON tcentros_hospitalarios(tipo_centro);
CREATE INDEX idx_tcentros_activo ON tcentros_hospitalarios(activo);

-- Trigger para actualizar updated_at
CREATE TRIGGER update_tcentros_hospitalarios_updated_at
    BEFORE UPDATE ON tcentros_hospitalarios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE tcentros_hospitalarios ENABLE ROW LEVEL SECURITY;

-- Política: Todos pueden ver (lectura)
CREATE POLICY "Usuarios autenticados pueden ver centros" ON tcentros_hospitalarios
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política: Solo admins pueden modificar
CREATE POLICY "Admins pueden gestionar centros" ON tcentros_hospitalarios
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- ==============================================================================
-- DATOS INICIALES - Principales centros hospitalarios de España
-- ==============================================================================

DO $$
DECLARE
    v_madrid_ciudad UUID;
    v_barcelona_ciudad UUID;
    v_valencia_ciudad UUID;
    v_sevilla_ciudad UUID;
BEGIN
    -- Obtener IDs de localidades principales
    SELECT id INTO v_madrid_ciudad FROM tpoblaciones WHERE codigo_postal = '28001' LIMIT 1;
    SELECT id INTO v_barcelona_ciudad FROM tpoblaciones WHERE codigo_postal = '08001' LIMIT 1;
    SELECT id INTO v_valencia_ciudad FROM tpoblaciones WHERE codigo_postal = '46001' LIMIT 1;
    SELECT id INTO v_sevilla_ciudad FROM tpoblaciones WHERE codigo_postal = '41001' LIMIT 1;

    -- Insertar centros hospitalarios de ejemplo
    INSERT INTO tcentros_hospitalarios (nombre, direccion, localidad_id, telefono, tipo_centro) VALUES
        -- Madrid
        ('Hospital Universitario La Paz', 'Paseo de la Castellana, 261', v_madrid_ciudad, '917277000', 'hospital'),
        ('Hospital Universitario 12 de Octubre', 'Av. de Córdoba, s/n', v_madrid_ciudad, '913908000', 'hospital'),
        ('Hospital Universitario Ramón y Cajal', 'Ctra. de Colmenar Viejo, km 9,100', v_madrid_ciudad, '913368000', 'hospital'),
        ('Hospital General Universitario Gregorio Marañón', 'C/ Dr. Esquerdo, 46', v_madrid_ciudad, '915868000', 'hospital'),
        ('Hospital Clínico San Carlos', 'C/ Profesor Martín Lagos, s/n', v_madrid_ciudad, '913303000', 'hospital'),

        -- Barcelona
        ('Hospital Clínic de Barcelona', 'C/ Villarroel, 170', v_barcelona_ciudad, '932275400', 'hospital'),
        ('Hospital Universitari Vall d''Hebron', 'Passeig de la Vall d''Hebron, 119-129', v_barcelona_ciudad, '932746000', 'hospital'),
        ('Hospital del Mar', 'Passeig Marítim, 25-29', v_barcelona_ciudad, '932483000', 'hospital'),
        ('Hospital de Sant Pau', 'C/ Sant Quintí, 89', v_barcelona_ciudad, '935565600', 'hospital'),

        -- Valencia
        ('Hospital Clínico Universitario de Valencia', 'Av. de Blasco Ibáñez, 17', v_valencia_ciudad, '963862600', 'hospital'),
        ('Hospital Universitario La Fe', 'Av. de Fernando Abril Martorell, 106', v_valencia_ciudad, '961244000', 'hospital'),
        ('Hospital General Universitario de Valencia', 'Av. de les Tres Creus, 2', v_valencia_ciudad, '963131800', 'hospital'),

        -- Sevilla
        ('Hospital Universitario Virgen del Rocío', 'Av. Manuel Siurot, s/n', v_sevilla_ciudad, '955012000', 'hospital'),
        ('Hospital Universitario Virgen Macarena', 'Av. Dr. Fedriani, 3', v_sevilla_ciudad, '955008000', 'hospital'),
        ('Hospital Universitario Virgen de Valme', 'Ctra. de Cádiz, s/n', v_sevilla_ciudad, '955015000', 'hospital')
    ON CONFLICT DO NOTHING;
END $$;

-- ==============================================================================
-- COMENTARIOS
-- ==============================================================================
COMMENT ON TABLE tcentros_hospitalarios IS 'Centros hospitalarios, clínicas y centros de salud';
COMMENT ON COLUMN tcentros_hospitalarios.nombre IS 'Nombre del centro hospitalario';
COMMENT ON COLUMN tcentros_hospitalarios.direccion IS 'Dirección completa del centro';
COMMENT ON COLUMN tcentros_hospitalarios.localidad_id IS 'Localidad donde se encuentra el centro';
COMMENT ON COLUMN tcentros_hospitalarios.telefono IS 'Teléfono de contacto del centro';
COMMENT ON COLUMN tcentros_hospitalarios.email IS 'Email de contacto del centro';
COMMENT ON COLUMN tcentros_hospitalarios.tipo_centro IS 'Tipo: hospital, centro_salud o clinica';

-- ==============================================================================
-- NOTA IMPORTANTE
-- ==============================================================================
-- Este es un conjunto inicial de los principales hospitales de España.
-- Se pueden añadir más centros según las necesidades del proyecto.
