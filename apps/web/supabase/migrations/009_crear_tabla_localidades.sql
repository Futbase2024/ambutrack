-- ==============================================================================
-- LOCALIDADES / POBLACIONES
-- Tabla de localidades y poblaciones
-- Dependencia: tprovincias
-- Requerida por: tcentros_hospitalarios
-- ==============================================================================

-- Crear tabla
CREATE TABLE IF NOT EXISTS tpoblaciones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provincia_id UUID NOT NULL REFERENCES tprovincias(id) ON DELETE CASCADE,
    codigo_postal TEXT NOT NULL,
    nombre TEXT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_tpoblaciones_provincia ON tpoblaciones(provincia_id);
CREATE INDEX idx_tpoblaciones_cp ON tpoblaciones(codigo_postal);
CREATE INDEX idx_tpoblaciones_nombre ON tpoblaciones(nombre);
CREATE INDEX idx_tpoblaciones_provincia_cp ON tpoblaciones(provincia_id, codigo_postal);

-- Trigger para actualizar updated_at
CREATE TRIGGER update_tpoblaciones_updated_at
    BEFORE UPDATE ON tpoblaciones
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE tpoblaciones ENABLE ROW LEVEL SECURITY;

-- Política: Todos pueden ver (lectura)
CREATE POLICY "Usuarios autenticados pueden ver poblaciones" ON tpoblaciones
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política: Solo admins pueden modificar
CREATE POLICY "Admins pueden gestionar poblaciones" ON tpoblaciones
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- ==============================================================================
-- DATOS INICIALES - Principales localidades de España
-- ==============================================================================

DO $$
DECLARE
    v_madrid UUID;
    v_barcelona UUID;
    v_valencia UUID;
    v_sevilla UUID;
    v_malaga UUID;
    v_murcia UUID;
    v_palma UUID;
    v_las_palmas UUID;
BEGIN
    -- Obtener IDs de provincias para ejemplos
    SELECT id INTO v_madrid FROM tprovincias WHERE codigo = '28';
    SELECT id INTO v_barcelona FROM tprovincias WHERE codigo = '08';
    SELECT id INTO v_valencia FROM tprovincias WHERE codigo = '46';
    SELECT id INTO v_sevilla FROM tprovincias WHERE codigo = '41';
    SELECT id INTO v_malaga FROM tprovincias WHERE codigo = '29';
    SELECT id INTO v_murcia FROM tprovincias WHERE codigo = '30';
    SELECT id INTO v_palma FROM tprovincias WHERE codigo = '07';
    SELECT id INTO v_las_palmas FROM tprovincias WHERE codigo = '35';

    -- Insertar localidades principales (ejemplos)
    -- Nota: En producción, se deben cargar TODAS las localidades desde fuente oficial (INE)
    INSERT INTO tpoblaciones (provincia_id, codigo_postal, nombre) VALUES
        -- Madrid
        (v_madrid, '28001', 'Madrid'),
        (v_madrid, '28002', 'Madrid'),
        (v_madrid, '28003', 'Madrid'),
        (v_madrid, '28004', 'Madrid'),
        (v_madrid, '28005', 'Madrid'),
        (v_madrid, '28300', 'Aranjuez'),
        (v_madrid, '28500', 'Arganda del Rey'),
        (v_madrid, '28600', 'Navalcarnero'),
        (v_madrid, '28700', 'San Sebastián de los Reyes'),
        (v_madrid, '28800', 'Alcalá de Henares'),

        -- Barcelona
        (v_barcelona, '08001', 'Barcelona'),
        (v_barcelona, '08002', 'Barcelona'),
        (v_barcelona, '08003', 'Barcelona'),
        (v_barcelona, '08004', 'Barcelona'),
        (v_barcelona, '08005', 'Barcelona'),
        (v_barcelona, '08720', 'Vilafranca del Penedès'),
        (v_barcelona, '08850', 'Gavà'),
        (v_barcelona, '08901', 'L''Hospitalet de Llobregat'),

        -- Valencia
        (v_valencia, '46001', 'Valencia'),
        (v_valencia, '46002', 'Valencia'),
        (v_valencia, '46003', 'Valencia'),
        (v_valencia, '46004', 'Valencia'),
        (v_valencia, '46005', 'Valencia'),
        (v_valencia, '46400', 'Cullera'),
        (v_valencia, '46500', 'Sagunto'),

        -- Sevilla
        (v_sevilla, '41001', 'Sevilla'),
        (v_sevilla, '41002', 'Sevilla'),
        (v_sevilla, '41003', 'Sevilla'),
        (v_sevilla, '41004', 'Sevilla'),
        (v_sevilla, '41200', 'Alcalá de Guadaíra'),

        -- Málaga
        (v_malaga, '29001', 'Málaga'),
        (v_malaga, '29002', 'Málaga'),
        (v_malaga, '29600', 'Marbella'),

        -- Murcia
        (v_murcia, '30001', 'Murcia'),
        (v_murcia, '30002', 'Murcia'),
        (v_murcia, '30003', 'Murcia'),

        -- Palma
        (v_palma, '07001', 'Palma'),
        (v_palma, '07002', 'Palma'),
        (v_palma, '07003', 'Palma'),

        -- Las Palmas
        (v_las_palmas, '35001', 'Las Palmas de Gran Canaria'),
        (v_las_palmas, '35002', 'Las Palmas de Gran Canaria')
    ON CONFLICT DO NOTHING;
END $$;

-- ==============================================================================
-- COMENTARIOS
-- ==============================================================================
COMMENT ON TABLE tpoblaciones IS 'Localidades y poblaciones de España';
COMMENT ON COLUMN tpoblaciones.provincia_id IS 'Provincia a la que pertenece la localidad';
COMMENT ON COLUMN tpoblaciones.codigo_postal IS 'Código postal de la localidad';
COMMENT ON COLUMN tpoblaciones.nombre IS 'Nombre de la localidad';

-- ==============================================================================
-- NOTA IMPORTANTE
-- ==============================================================================
-- Este es un conjunto inicial de localidades principales.
-- Para un sistema en producción, se recomienda cargar el listado completo
-- de localidades desde fuentes oficiales como:
-- - INE (Instituto Nacional de Estadística)
-- - Correos (base de datos de códigos postales)
-- - Catastro
--
-- Se pueden añadir más localidades manualmente o mediante scripts de carga masiva.
