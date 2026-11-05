-- ==============================================================================
-- AmbuTrack Web - Poblar tablas maestras de Personal
-- Migración: 028_fill_tablas_maestras_personal.sql
--
-- Población inicial de tcategorias, tpuestos y tcontratos
-- para que los dropdowns del formulario de Personal tengan opciones.
-- ==============================================================================

-- ==============================================================================
-- 1. CATEGORÍAS LABORALES (tcategorias)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tcategorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    categoria TEXT NOT NULL,
    descripcion TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO tcategorias (id, nombre, categoria, descripcion) VALUES
    ('a1000001-0000-0000-0000-000000000001', '1', 'TES', 'Técnico en Emergencias Sanitarias'),
    ('a1000001-0000-0000-0000-000000000002', '2', 'CONDUCTOR', 'Conductor'),
    ('a1000001-0000-0000-0000-000000000003', '3', 'MÉDICO', 'Médico'),
    ('a1000001-0000-0000-0000-000000000004', '4', 'ENFERMERO', 'Enfermero/a'),
    ('a1000001-0000-0000-0000-000000000005', '5', 'COORDINADOR', 'Coordinador'),
    ('a1000001-0000-0000-0000-000000000006', '6', 'ADMINISTRATIVO', 'Administrativo'),
    ('a1000001-0000-0000-0000-000000000007', '7', 'DIRECTIVO', 'Directivo')
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- 2. PUESTOS DE TRABAJO (tpuestos)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tpuestos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO tpuestos (id, nombre) VALUES
    ('b2000001-0000-0000-0000-000000000001', 'Conductor SVB'),
    ('b2000001-0000-0000-0000-000000000002', 'Conductor SVA'),
    ('b2000001-0000-0000-0000-000000000003', 'Conductor Convencional'),
    ('b2000001-0000-0000-0000-000000000004', 'Conductor Colectiva'),
    ('b2000001-0000-0000-0000-000000000005', 'TES Conductor'),
    ('b2000001-0000-0000-0000-000000000006', 'TES Sanitario'),
    ('b2000001-0000-0000-0000-000000000007', 'Médico'),
    ('b2000001-0000-0000-0000-000000000008', 'Enfermero/a'),
    ('b2000001-0000-0000-0000-000000000009', 'Coordinador de Turno'),
    ('b2000001-0000-0000-0000-000000000010', 'Coordinador de Flota'),
    ('b2000001-0000-0000-0000-000000000011', 'Administrativo'),
    ('b2000001-0000-0000-0000-000000000012', 'Gerente')
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- 3. TIPOS DE CONTRATO (tcontratos)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tcontratos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO tcontratos (id, nombre, descripcion) VALUES
    ('c3000001-0000-0000-0000-000000000001', 'Indefinido', 'Contrato indefinido a jornada completa'),
    ('c3000001-0000-0000-0000-000000000002', 'Temporal', 'Contrato temporal'),
    ('c3000001-0000-0000-0000-000000000003', 'Fijo Discontinuo', 'Contrato fijo discontinuo'),
    ('c3000001-0000-0000-0000-000000000004', 'En Prácticas', 'Contrato en prácticas'),
    ('c3000001-0000-0000-0000-000000000005', 'Por Obra o Servicio', 'Contrato por obra o servicio determinado'),
    ('c3000001-0000-0000-0000-000000000006', 'Relevo', 'Contrato de relevo')
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- 4. ROW LEVEL SECURITY
-- Permitir lectura a todos los usuarios autenticados
-- ==============================================================================
ALTER TABLE tcategorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE tpuestos ENABLE ROW LEVEL SECURITY;
ALTER TABLE tcontratos ENABLE ROW LEVEL SECURITY;

-- Políticas de SELECT para usuarios autenticados
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'tcategorias' AND policyname = 'Usuarios autenticados pueden ver categorias') THEN
        CREATE POLICY "Usuarios autenticados pueden ver categorias" ON tcategorias
            FOR SELECT USING (auth.role() = 'authenticated');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'tpuestos' AND policyname = 'Usuarios autenticados pueden ver puestos') THEN
        CREATE POLICY "Usuarios autenticados pueden ver puestos" ON tpuestos
            FOR SELECT USING (auth.role() = 'authenticated');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'tcontratos' AND policyname = 'Usuarios autenticados pueden ver contratos') THEN
        CREATE POLICY "Usuarios autenticados pueden ver contratos" ON tcontratos
            FOR SELECT USING (auth.role() = 'authenticated');
    END IF;
END $$;
