-- Migration: Documentación de Vehículos
-- Date: 2025-02-15
-- Description: Crear tablas para gestión de documentación de vehículos (seguros, ITV, permisos)

-- Tabla: tipos_documento_vehiculo (Catálogo)
CREATE TABLE IF NOT EXISTS tipos_documento_vehiculo (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo TEXT NOT NULL UNIQUE,
  nombre TEXT NOT NULL,
  descripcion TEXT,
  categoria TEXT NOT NULL CHECK (categoria IN ('seguro', 'itv', 'permiso', 'licencia', 'otro')),
  vigencia_meses INTEGER NOT NULL DEFAULT 12,
  obligatorio BOOLEAN NOT NULL DEFAULT true,
  activo BOOLEAN NOT NULL DEFAULT true,
  fecha_baja TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_tipos_doc_vehiculo_codigo ON tipos_documento_vehiculo(codigo);
CREATE INDEX IF NOT EXISTS idx_tipos_doc_vehiculo_categoria ON tipos_documento_vehiculo(categoria);
CREATE INDEX IF NOT EXISTS idx_tipos_doc_vehiculo_activo ON tipos_documento_vehiculo(activo);

-- RLS
ALTER TABLE tipos_documento_vehiculo ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Permitir lectura a todos los usuarios autenticados"
  ON tipos_documento_vehiculo FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY IF NOT EXISTS "Permitir modificacion solo a administradores y gestores de flota"
  ON tipos_documento_vehiculo FOR ALL
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol IN ('admin', 'jefe_flota')
    )
  );

-- Tabla: documentacion_vehiculos (Registros)
CREATE TABLE IF NOT EXISTS documentacion_vehiculos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vehiculo_id UUID NOT NULL REFERENCES vehiculos(id) ON DELETE CASCADE,
  tipo_documento_id UUID NOT NULL REFERENCES tipos_documento_vehiculo(id) ON DELETE RESTRICT,
  numero_poliza TEXT NOT NULL,
  compania TEXT NOT NULL,
  fecha_emision TIMESTAMPTZ NOT NULL,
  fecha_vencimiento TIMESTAMPTZ NOT NULL,
  fecha_proximo_vencimiento TIMESTAMPTZ,
  estado TEXT NOT NULL CHECK (estado IN ('vigente', 'proxima_vencer', 'vencida')) DEFAULT 'vigente',
  costo_anual NUMERIC(10, 2),
  observaciones TEXT,
  documento_url TEXT,
  documento_url_2 TEXT,
  requiere_renovacion BOOLEAN NOT NULL DEFAULT false,
  dias_alerta INTEGER NOT NULL DEFAULT 30,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT unica_doc_por_vehiculo_tipo UNIQUE (vehiculo_id, tipo_documento_id, fecha_vencimiento)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_doc_vehiculo_vehiculo ON documentacion_vehiculos(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_doc_vehiculo_tipo ON documentacion_vehiculos(tipo_documento_id);
CREATE INDEX IF NOT EXISTS idx_doc_vehiculo_estado ON documentacion_vehiculos(estado);
CREATE INDEX IF NOT EXISTS idx_doc_vehiculo_vencimiento ON documentacion_vehiculos(fecha_vencimiento);
CREATE INDEX IF NOT EXISTS idx_doc_vehiculo_compania ON documentacion_vehiculos(compania);

-- RLS
ALTER TABLE documentacion_vehiculos ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Permitir lectura a todos los usuarios autenticados"
  ON documentacion_vehiculos FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY IF NOT EXISTS "Permitir modificacion solo a administradores y gestores de flota"
  ON documentacion_vehiculos FOR ALL
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol IN ('admin', 'jefe_flota', 'gestor_flota')
    )
  );

-- Trigger para actualizar estado automáticamente
CREATE OR REPLACE FUNCTION actualizar_estado_doc_vehiculo()
RETURNS TRIGGER AS $$
BEGIN
  -- Actualizar estado basado en fecha_vencimiento
  IF NEW.fecha_vencimiento <= NOW() THEN
    NEW.estado := 'vencida';
  ELSEIF NEW.fecha_vencimiento <= NOW() + (COALESCE(NEW.dias_alerta, 30) || ' days')::INTERVAL THEN
    NEW.estado := 'proxima_vencer';
  ELSE
    NEW.estado := 'vigente';
  END IF;

  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IF NOT EXISTS trigger_actualizar_estado_doc_vehiculo
  BEFORE INSERT OR UPDATE ON documentacion_vehiculos
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_estado_doc_vehiculo();

-- Función para alertas de vencimiento
CREATE OR REPLACE FUNCTION docs_vehiculos_proximos_vencer()
RETURNS TABLE (
  vehiculo_id UUID,
  vehiculo_matricula TEXT,
  tipo_documento TEXT,
  fecha_vencimiento TIMESTAMPTZ,
  dias_restantes INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    dv.vehiculo_id,
    v.matricula,
    td.nombre as tipo_documento,
    dv.fecha_vencimiento,
    EXTRACT(DAY FROM (dv.fecha_vencimiento - NOW()))::INTEGER as dias_restantes
  FROM documentacion_vehiculos dv
  JOIN vehiculos v ON v.id = dv.vehiculo_id
  JOIN tipos_documento_vehiculo td ON td.id = dv.tipo_documento_id
  WHERE dv.estado IN ('proxima_vencer', 'vencida')
    AND v.estado = 'activo'
  ORDER BY dv.fecha_vencimiento ASC;
END;
$$ LANGUAGE plpgsql;
