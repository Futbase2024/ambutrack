-- =============================================
-- MÓDULO TALLER - FASE 2: Órdenes de Reparación y Repuestos
-- Requiere: 002_create_taller_tables.sql (ttalleres, tproveedores_taller)
-- =============================================

-- 1. Órdenes de reparación
CREATE TABLE IF NOT EXISTS tordenes_reparacion (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL,
  numero_orden TEXT NOT NULL,
  vehiculo_id UUID NOT NULL REFERENCES tvehiculos(id) ON DELETE RESTRICT,
  taller_id UUID REFERENCES ttalleres(id) ON DELETE SET NULL,

  -- Origen
  origen TEXT NOT NULL DEFAULT 'averia'
    CHECK (origen IN ('averia', 'mantenimiento', 'itv', 'voluntaria')),
  incidencia_id UUID REFERENCES incidencias_vehiculos(id) ON DELETE SET NULL,
  mantenimiento_id UUID REFERENCES tmantenimientos(id) ON DELETE SET NULL,

  -- Estado
  estado TEXT NOT NULL DEFAULT 'abierta'
    CHECK (estado IN ('abierta', 'en_proceso', 'esperando_repuestos', 'finalizada', 'cerrada', 'anulada')),
  prioridad TEXT NOT NULL DEFAULT 'normal'
    CHECK (prioridad IN ('baja', 'normal', 'alta', 'urgente')),

  -- Trabajo
  diagnostico TEXT,
  trabajos_realizados TEXT,
  kilometraje_entrada INTEGER CHECK (kilometraje_entrada IS NULL OR kilometraje_entrada >= 0),
  kilometraje_salida INTEGER CHECK (kilometraje_salida IS NULL OR kilometraje_salida >= 0),

  -- Asignación
  mecanico_asignado UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  mecanico_nombre TEXT,

  -- Fechas del proceso
  fecha_entrada TIMESTAMPTZ NOT NULL DEFAULT now(),
  fecha_inicio_trabajo TIMESTAMPTZ,
  fecha_espera_repuestos TIMESTAMPTZ,
  fecha_finalizacion TIMESTAMPTZ,
  fecha_cierre TIMESTAMPTZ,

  -- Costes (costo_repuestos lo mantiene el trigger; costo_total es generado)
  mano_obra_horas NUMERIC(6,2) NOT NULL DEFAULT 0,
  costo_mano_obra NUMERIC(10,2) NOT NULL DEFAULT 0,
  costo_repuestos NUMERIC(10,2) NOT NULL DEFAULT 0,
  costo_grua NUMERIC(10,2) NOT NULL DEFAULT 0,
  costo_total NUMERIC(10,2) GENERATED ALWAYS AS (costo_mano_obra + costo_repuestos + costo_grua) STORED,
  cubierto_seguro BOOLEAN NOT NULL DEFAULT false,

  -- Garantía
  garantia_meses INTEGER CHECK (garantia_meses IS NULL OR garantia_meses >= 0),
  fecha_fin_garantia TIMESTAMPTZ,

  observaciones TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID DEFAULT auth.uid(),

  CONSTRAINT uq_tordenes_numero UNIQUE (empresa_id, numero_orden)
);

-- 2. Repuestos por orden
CREATE TABLE IF NOT EXISTS trepuestos_orden (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  orden_id UUID NOT NULL REFERENCES tordenes_reparacion(id) ON DELETE CASCADE,
  proveedor_id UUID REFERENCES tproveedores_taller(id) ON DELETE SET NULL,
  descripcion TEXT NOT NULL,
  referencia TEXT,
  cantidad INTEGER NOT NULL DEFAULT 1 CHECK (cantidad > 0),
  precio_unitario NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (precio_unitario >= 0),
  precio_total NUMERIC(12,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
  estado TEXT NOT NULL DEFAULT 'solicitado'
    CHECK (estado IN ('solicitado', 'pedido', 'recibido', 'instalado')),
  fecha_pedido TIMESTAMPTZ,
  fecha_recibido TIMESTAMPTZ,
  observaciones TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Índices
CREATE INDEX IF NOT EXISTS idx_tordenes_empresa ON tordenes_reparacion(empresa_id);
CREATE INDEX IF NOT EXISTS idx_tordenes_vehiculo ON tordenes_reparacion(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_tordenes_taller ON tordenes_reparacion(taller_id);
CREATE INDEX IF NOT EXISTS idx_tordenes_estado ON tordenes_reparacion(estado);
CREATE INDEX IF NOT EXISTS idx_tordenes_fecha_entrada ON tordenes_reparacion(fecha_entrada DESC);
CREATE INDEX IF NOT EXISTS idx_tordenes_incidencia ON tordenes_reparacion(incidencia_id);
CREATE INDEX IF NOT EXISTS idx_trepuestos_orden ON trepuestos_orden(orden_id);
CREATE INDEX IF NOT EXISTS idx_trepuestos_proveedor ON trepuestos_orden(proveedor_id);
CREATE INDEX IF NOT EXISTS idx_trepuestos_estado ON trepuestos_orden(estado);

-- 4. Número de orden autogenerado: OR-AAAA-NNNN (correlativo por empresa y año)
CREATE OR REPLACE FUNCTION generar_numero_orden_reparacion()
RETURNS TRIGGER AS $$
DECLARE
  v_anio TEXT := to_char(COALESCE(NEW.fecha_entrada, now()), 'YYYY');
  v_siguiente INTEGER;
BEGIN
  IF NEW.numero_orden IS NOT NULL AND NEW.numero_orden <> '' THEN
    RETURN NEW;
  END IF;

  -- Bloqueo por empresa+año para evitar duplicados en inserciones concurrentes
  PERFORM pg_advisory_xact_lock(hashtext(NEW.empresa_id::TEXT || v_anio));

  SELECT COALESCE(MAX(split_part(numero_orden, '-', 3)::INTEGER), 0) + 1
    INTO v_siguiente
    FROM tordenes_reparacion
   WHERE empresa_id = NEW.empresa_id
     AND numero_orden LIKE 'OR-' || v_anio || '-%';

  NEW.numero_orden := 'OR-' || v_anio || '-' || lpad(v_siguiente::TEXT, 4, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_tordenes_numero ON tordenes_reparacion;
CREATE TRIGGER trg_tordenes_numero
  BEFORE INSERT ON tordenes_reparacion
  FOR EACH ROW EXECUTE FUNCTION generar_numero_orden_reparacion();

-- 5. Recalcular costo_repuestos de la orden cuando cambian sus repuestos
CREATE OR REPLACE FUNCTION recalcular_costo_repuestos_orden()
RETURNS TRIGGER AS $$
DECLARE
  v_orden UUID;
BEGIN
  FOR v_orden IN
    SELECT DISTINCT x FROM unnest(ARRAY[
      CASE WHEN TG_OP <> 'INSERT' THEN OLD.orden_id END,
      CASE WHEN TG_OP <> 'DELETE' THEN NEW.orden_id END
    ]) AS x WHERE x IS NOT NULL
  LOOP
    UPDATE tordenes_reparacion
       SET costo_repuestos = COALESCE(
             (SELECT SUM(precio_total) FROM trepuestos_orden WHERE orden_id = v_orden), 0)
     WHERE id = v_orden;
  END LOOP;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_trepuestos_costes ON trepuestos_orden;
CREATE TRIGGER trg_trepuestos_costes
  AFTER INSERT OR UPDATE OR DELETE ON trepuestos_orden
  FOR EACH ROW EXECUTE FUNCTION recalcular_costo_repuestos_orden();

-- 6. updated_at (función creada en 002)
DROP TRIGGER IF EXISTS trg_tordenes_updated_at ON tordenes_reparacion;
CREATE TRIGGER trg_tordenes_updated_at
  BEFORE UPDATE ON tordenes_reparacion
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 7. RLS: solo usuarios autenticados
ALTER TABLE tordenes_reparacion ENABLE ROW LEVEL SECURITY;
ALTER TABLE trepuestos_orden ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "tordenes_select" ON tordenes_reparacion;
DROP POLICY IF EXISTS "tordenes_insert" ON tordenes_reparacion;
DROP POLICY IF EXISTS "tordenes_update" ON tordenes_reparacion;
DROP POLICY IF EXISTS "tordenes_delete" ON tordenes_reparacion;
CREATE POLICY "tordenes_select" ON tordenes_reparacion FOR SELECT TO authenticated USING (true);
CREATE POLICY "tordenes_insert" ON tordenes_reparacion FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "tordenes_update" ON tordenes_reparacion FOR UPDATE TO authenticated USING (true);
CREATE POLICY "tordenes_delete" ON tordenes_reparacion FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "trepuestos_select" ON trepuestos_orden;
DROP POLICY IF EXISTS "trepuestos_insert" ON trepuestos_orden;
DROP POLICY IF EXISTS "trepuestos_update" ON trepuestos_orden;
DROP POLICY IF EXISTS "trepuestos_delete" ON trepuestos_orden;
CREATE POLICY "trepuestos_select" ON trepuestos_orden FOR SELECT TO authenticated USING (true);
CREATE POLICY "trepuestos_insert" ON trepuestos_orden FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "trepuestos_update" ON trepuestos_orden FOR UPDATE TO authenticated USING (true);
CREATE POLICY "trepuestos_delete" ON trepuestos_orden FOR DELETE TO authenticated USING (true);

-- 8. Comentarios
COMMENT ON TABLE tordenes_reparacion IS 'Órdenes de reparación del taller (origen: avería, mantenimiento, ITV o voluntaria)';
COMMENT ON TABLE trepuestos_orden IS 'Repuestos asociados a una orden de reparación';
COMMENT ON COLUMN tordenes_reparacion.numero_orden IS 'Autogenerado OR-AAAA-NNNN si se inserta vacío';
COMMENT ON COLUMN tordenes_reparacion.costo_repuestos IS 'Mantenido por trigger: suma de trepuestos_orden.precio_total';
