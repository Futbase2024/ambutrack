-- =============================================
-- MÓDULO TALLER: Tablas maestras de Talleres y Proveedores
-- Ejecutar manualmente en Supabase Dashboard > SQL Editor
-- =============================================

-- 1. Tabla maestra de Talleres
CREATE TABLE IF NOT EXISTS ttalleres (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL,
  nombre TEXT NOT NULL,
  nif TEXT,
  direccion TEXT,
  ciudad TEXT,
  provincia TEXT,
  codigo_postal TEXT,
  telefono TEXT,
  email TEXT,
  contacto_nombre TEXT,
  especialidad TEXT,
  tipo TEXT NOT NULL DEFAULT 'propio',
  activo BOOLEAN DEFAULT true,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID
);

-- 2. Tabla de Proveedores del Taller
CREATE TABLE IF NOT EXISTS tproveedores_taller (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL,
  nombre TEXT NOT NULL,
  nif TEXT,
  direccion TEXT,
  ciudad TEXT,
  provincia TEXT,
  codigo_postal TEXT,
  telefono TEXT,
  email TEXT,
  contacto_nombre TEXT,
  tipo TEXT NOT NULL DEFAULT 'repuestos',
  forma_pago TEXT,
  cuenta_bancaria TEXT,
  activo BOOLEAN DEFAULT true,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID
);

-- 3. Índices
CREATE INDEX IF NOT EXISTS idx_ttalleres_empresa ON ttalleres(empresa_id);
CREATE INDEX IF NOT EXISTS idx_ttalleres_tipo ON ttalleres(tipo);
CREATE INDEX IF NOT EXISTS idx_ttalleres_activo ON ttalleres(activo);
CREATE INDEX IF NOT EXISTS idx_tproveedores_empresa ON tproveedores_taller(empresa_id);
CREATE INDEX IF NOT EXISTS idx_tproveedores_tipo ON tproveedores_taller(tipo);
CREATE INDEX IF NOT EXISTS idx_tproveedores_activo ON tproveedores_taller(activo);

-- 4. RLS
ALTER TABLE ttalleres ENABLE ROW LEVEL SECURITY;
ALTER TABLE tproveedores_taller ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ttalleres_read" ON ttalleres FOR SELECT USING (true);
CREATE POLICY "ttalleres_insert" ON ttalleres FOR INSERT WITH CHECK (true);
CREATE POLICY "ttalleres_update" ON ttalleres FOR UPDATE USING (true);
CREATE POLICY "ttalleres_delete" ON ttalleres FOR DELETE USING (true);

CREATE POLICY "tproveedores_read" ON tproveedores_taller FOR SELECT USING (true);
CREATE POLICY "tproveedores_insert" ON tproveedores_taller FOR INSERT WITH CHECK (true);
CREATE POLICY "tproveedores_update" ON tproveedores_taller FOR UPDATE USING (true);
CREATE POLICY "tproveedores_delete" ON tproveedores_taller FOR DELETE USING (true);

-- 5. Trigger para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_ttalleres_updated_at ON ttalleres;
CREATE TRIGGER trg_ttalleres_updated_at
  BEFORE UPDATE ON ttalleres
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trg_tproveedores_updated_at ON tproveedores_taller;
CREATE TRIGGER trg_tproveedores_updated_at
  BEFORE UPDATE ON tproveedores_taller
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 6. Comentarios
COMMENT ON TABLE ttalleres IS 'Catálogo maestro de talleres mecánicos (propios, externos, ITV)';
COMMENT ON TABLE tproveedores_taller IS 'Catálogo de proveedores de repuestos y servicios para el taller';
