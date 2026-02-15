#!/bin/bash

# Script para crear las tablas de documentación de vehículos
# Autorizaos: Claude Code, AmbuTrack Web
# Fecha: 2025-02-15

PROJECT_DIR="/Users/lokisoft1/Desktop/Desarrollo/Pruebas Ambutrack/ambutrack"
DB_URL="postgresql://postgres.ambutrack:yutrack.supabase.co:6543/postgres"
DB_USER="postgres.ycmopmnrhrpnnzkvnihr"
DB_NAME="postgres"
DB_PASS="******"  # Contraseña de Supabase (oculta)

echo "🗄️ Creando tablas de documentación de vehículos en Supabase..."
echo "📍 URL: $DB_URL"

# Crear tabla tipos_documento_vehiculo
echo "   Creando tipos_documento_vehiculo..."
psql -h "$DB_URL" -U "$DB_USER" <<'EOF' <<'EOSQL'
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
  updated_at TIMAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tipos_doc_vehiculo_codigo ON tipos_documento_vehiculo(codigo);
CREATE INDEX IF NOT EXISTS idx_tipos_doc_vehiculo_categoria ON tipos_documento_vehiculo(categoria);
CREATE INDEX IF NOT EXISTS idx_tipos_doc_vehiculo_activo ON tipos_documento_vehiculo(activo);

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
EOSQL

echo "   ✅ tipos_documento_vehiculo creados"

# Crear tabla documentacion_vehiculos
echo "   Creando documentacion_vehiculos..."
psql -h "$DB_URL" -U "$DB_USER" <<'EOSQL' <<'EOSQL'
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

CREATE INDEX IF NOT EXISTS idx_doc_vehiculo_vehiculo ON documentacion_vehiculos(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_doc_vehiculo_tipo ON documentacion_vehiculos(tipo_documento_id);
CREATE INDEX IF NOT EXISTS idx_doc_vehiculo_estado ON documentacion_vehiculos(estado);
CREATE INDEX IF NOT EXISTS idx_doc_vehiculo_vencimiento ON documentacion_vehiculos(fecha_vencimiento);
CREATE INDEX IF NOT EXISTS idx_doc_vehiculo_compania ON documentacion_vehiculos(compania);

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
EOSQL

echo "   ✅ documentacion_vehiculos creados"

echo "✅ Todas las tablas creadas exitosamente!"
