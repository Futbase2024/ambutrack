-- ==============================================================================
-- PROVINCIAS
-- Tabla de provincias de España
-- Dependencia: tcomunidades
-- Requerida por: tpoblaciones
-- ==============================================================================

-- Crear tabla
CREATE TABLE IF NOT EXISTS tprovincias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo TEXT NOT NULL UNIQUE,
    nombre TEXT NOT NULL,
    comunidad_autonoma_id UUID NOT NULL REFERENCES tcomunidades(id) ON DELETE CASCADE,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_tprovincias_codigo ON tprovincias(codigo);
CREATE INDEX idx_tprovincias_nombre ON tprovincias(nombre);
CREATE INDEX idx_tprovincias_comunidad ON tprovincias(comunidad_autonoma_id);

-- Trigger para actualizar updated_at
CREATE TRIGGER update_tprovincias_updated_at
    BEFORE UPDATE ON tprovincias
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE tprovincias ENABLE ROW LEVEL SECURITY;

-- Política: Todos pueden ver (lectura)
CREATE POLICY "Usuarios autenticados pueden ver provincias" ON tprovincias
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política: Solo admins pueden modificar
CREATE POLICY "Admins pueden gestionar provincias" ON tprovincias
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- ==============================================================================
-- DATOS INICIALES - 52 Provincias de España (incluidas Ceuta y Melilla)
-- ==============================================================================

-- Obtener IDs de comunidades autónomas para las inserciones
DO $$
DECLARE
    v_andalucia UUID;
    v_aragon UUID;
    v_asturias UUID;
    v_baleares UUID;
    v_canarias UUID;
    v_cantabria UUID;
    v_castilla_leon UUID;
    v_castilla_mancha UUID;
    v_catalunya UUID;
    v_valencia UUID;
    v_extremadura UUID;
    v_galicia UUID;
    v_madrid UUID;
    v_murcia UUID;
    v_navarra UUID;
    v_pais_vasco UUID;
    v_rioja UUID;
BEGIN
    -- Obtener IDs de comunidades
    SELECT id INTO v_andalucia FROM tcomunidades WHERE codigo = 'AN';
    SELECT id INTO v_aragon FROM tcomunidades WHERE codigo = 'AR';
    SELECT id INTO v_asturias FROM tcomunidades WHERE codigo = 'AS';
    SELECT id INTO v_baleares FROM tcomunidades WHERE codigo = 'IB';
    SELECT id INTO v_canarias FROM tcomunidades WHERE codigo = 'CN';
    SELECT id INTO v_cantabria FROM tcomunidades WHERE codigo = 'CB';
    SELECT id INTO v_castilla_leon FROM tcomunidades WHERE codigo = 'CL';
    SELECT id INTO v_castilla_mancha FROM tcomunidades WHERE codigo = 'CM';
    SELECT id INTO v_catalunya FROM tcomunidades WHERE codigo = 'CT';
    SELECT id INTO v_valencia FROM tcomunidades WHERE codigo = 'VC';
    SELECT id INTO v_extremadura FROM tcomunidades WHERE codigo = 'EX';
    SELECT id INTO v_galicia FROM tcomunidades WHERE codigo = 'GA';
    SELECT id INTO v_madrid FROM tcomunidades WHERE codigo = 'MD';
    SELECT id INTO v_murcia FROM tcomunidades WHERE codigo = 'MU';
    SELECT id INTO v_navarra FROM tcomunidades WHERE codigo = 'NC';
    SELECT id INTO v_pais_vasco FROM tcomunidades WHERE codigo = 'PV';
    SELECT id INTO v_rioja FROM tcomunidades WHERE codigo = 'RI';

    -- Insertar provincias
    INSERT INTO tprovincias (codigo, nombre, comunidad_autonoma_id) VALUES
        -- Andalucía (8)
        ('04', 'Almería', v_andalucia),
        ('11', 'Cádiz', v_andalucia),
        ('14', 'Córdoba', v_andalucia),
        ('18', 'Granada', v_andalucia),
        ('21', 'Huelva', v_andalucia),
        ('23', 'Jaén', v_andalucia),
        ('29', 'Málaga', v_andalucia),
        ('41', 'Sevilla', v_andalucia),

        -- Aragón (3)
        ('22', 'Huesca', v_aragon),
        ('44', 'Teruel', v_aragon),
        ('50', 'Zaragoza', v_aragon),

        -- Asturias (1)
        ('33', 'Asturias', v_asturias),

        -- Illes Balears (1)
        ('07', 'Illes Balears', v_baleares),

        -- Canarias (2)
        ('35', 'Las Palmas', v_canarias),
        ('38', 'Santa Cruz de Tenerife', v_canarias),

        -- Cantabria (1)
        ('39', 'Cantabria', v_cantabria),

        -- Castilla y León (9)
        ('05', 'Ávila', v_castilla_leon),
        ('09', 'Burgos', v_castilla_leon),
        ('24', 'León', v_castilla_leon),
        ('34', 'Palencia', v_castilla_leon),
        ('37', 'Salamanca', v_castilla_leon),
        ('40', 'Segovia', v_castilla_leon),
        ('42', 'Soria', v_castilla_leon),
        ('47', 'Valladolid', v_castilla_leon),
        ('49', 'Zamora', v_castilla_leon),

        -- Castilla-La Mancha (5)
        ('02', 'Albacete', v_castilla_mancha),
        ('13', 'Ciudad Real', v_castilla_mancha),
        ('16', 'Cuenca', v_castilla_mancha),
        ('19', 'Guadalajara', v_castilla_mancha),
        ('45', 'Toledo', v_castilla_mancha),

        -- Catalunya (4)
        ('08', 'Barcelona', v_catalunya),
        ('17', 'Girona', v_catalunya),
        ('25', 'Lleida', v_catalunya),
        ('43', 'Tarragona', v_catalunya),

        -- Comunitat Valenciana (3)
        ('03', 'Alicante', v_valencia),
        ('12', 'Castellón', v_valencia),
        ('46', 'Valencia', v_valencia),

        -- Extremadura (2)
        ('06', 'Badajoz', v_extremadura),
        ('10', 'Cáceres', v_extremadura),

        -- Galicia (4)
        ('15', 'A Coruña', v_galicia),
        ('27', 'Lugo', v_galicia),
        ('32', 'Ourense', v_galicia),
        ('36', 'Pontevedra', v_galicia),

        -- Madrid (1)
        ('28', 'Madrid', v_madrid),

        -- Murcia (1)
        ('30', 'Murcia', v_murcia),

        -- Navarra (1)
        ('31', 'Navarra', v_navarra),

        -- País Vasco (3)
        ('01', 'Álava', v_pais_vasco),
        ('48', 'Bizkaia', v_pais_vasco),
        ('20', 'Gipuzkoa', v_pais_vasco),

        -- La Rioja (1)
        ('26', 'La Rioja', v_rioja),

        -- Ceuta y Melilla (2)
        ('51', 'Ceuta', v_andalucia),  -- Asociadas a Andalucía por cercanía
        ('52', 'Melilla', v_andalucia)
    ON CONFLICT (codigo) DO NOTHING;
END $$;

-- ==============================================================================
-- COMENTARIOS
-- ==============================================================================
COMMENT ON TABLE tprovincias IS 'Provincias de España (52 incluyendo Ceuta y Melilla)';
COMMENT ON COLUMN tprovincias.codigo IS 'Código INE de la provincia (2 dígitos)';
COMMENT ON COLUMN tprovincias.nombre IS 'Nombre oficial de la provincia';
COMMENT ON COLUMN tprovincias.comunidad_autonoma_id IS 'Comunidad autónoma a la que pertenece';
