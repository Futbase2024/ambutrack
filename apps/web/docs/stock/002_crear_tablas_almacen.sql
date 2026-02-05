-- =====================================================
-- MIGRACIÓN 002: TABLAS DE ALMACÉN GENERAL
-- =====================================================
-- Proyecto: AmbuTrack Web
-- Módulo: Stock - Sistema 1 (Almacén General)
-- Fecha: 2025-01-27
-- Decisiones de Negocio:
--   - Valoración: FIFO
--   - Almacén: Único (no múltiples sedes)
--   - Órdenes de compra: NO (solo entradas directas)
--   - Stock mínimo: Basado en suma de mínimos de vehículos
--   - Transferencias urgentes: Solo desde almacén
--   - Devoluciones a proveedor: NO (baja interna)
-- =====================================================

-- =====================================================
-- TABLA: proveedores
-- =====================================================
-- Catálogo de proveedores de material médico

CREATE TABLE IF NOT EXISTS proveedores (
  -- Identificación
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo VARCHAR(20) UNIQUE,
  nombre_comercial VARCHAR(150) NOT NULL,
  razon_social VARCHAR(150),
  cif_nif VARCHAR(20),

  -- Contacto
  direccion TEXT,
  codigo_postal VARCHAR(10),
  ciudad VARCHAR(100),
  provincia VARCHAR(100),
  pais VARCHAR(100) DEFAULT 'España',
  telefono VARCHAR(20),
  email VARCHAR(100),
  web VARCHAR(200),
  persona_contacto VARCHAR(100),

  -- Información comercial
  condiciones_pago VARCHAR(50),  -- Ej: "30 días", "Contado"
  descuento_general DECIMAL(5,2) DEFAULT 0,  -- Porcentaje
  observaciones TEXT,

  -- Control
  activo BOOLEAN DEFAULT TRUE,
  fecha_alta DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_proveedores_nombre ON proveedores(nombre_comercial);
CREATE INDEX IF NOT EXISTS idx_proveedores_activo ON proveedores(activo);
CREATE INDEX IF NOT EXISTS idx_proveedores_codigo ON proveedores(codigo);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_proveedores_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proveedores_updated_at
  BEFORE UPDATE ON proveedores
  FOR EACH ROW
  EXECUTE FUNCTION update_proveedores_updated_at();

-- =====================================================
-- TABLA: stock_almacen
-- =====================================================
-- Inventario centralizado del almacén general

CREATE TABLE IF NOT EXISTS stock_almacen (
  -- Identificación
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producto_id UUID REFERENCES productos(id) ON DELETE RESTRICT NOT NULL,

  -- Cantidades
  cantidad_disponible INT NOT NULL DEFAULT 0 CHECK (cantidad_disponible >= 0),
  cantidad_reservada INT DEFAULT 0 CHECK (cantidad_reservada >= 0),
  cantidad_minima INT DEFAULT 0 CHECK (cantidad_minima >= 0),

  -- Trazabilidad
  lote VARCHAR(50),
  fecha_caducidad DATE,
  fecha_entrada DATE NOT NULL DEFAULT CURRENT_DATE,

  -- Ubicación física (almacén único)
  ubicacion_almacen VARCHAR(100),  -- Ej: "Estantería A-3"
  zona VARCHAR(50),  -- Ej: "Medicamentos", "Fungibles", "Electromedicina"

  -- Información de compra (para valoración FIFO)
  proveedor_id UUID REFERENCES proveedores(id) ON DELETE SET NULL,
  numero_factura VARCHAR(50),
  precio_unitario DECIMAL(10,2),
  precio_total DECIMAL(10,2),
  moneda VARCHAR(3) DEFAULT 'EUR',

  -- Control
  observaciones TEXT,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  updated_by UUID REFERENCES auth.users(id)
);

-- Constraint: cantidad reservada no puede exceder disponible
ALTER TABLE stock_almacen ADD CONSTRAINT IF NOT EXISTS chk_reserva_valida
  CHECK (cantidad_reservada <= cantidad_disponible);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_stock_almacen_producto ON stock_almacen(producto_id);
CREATE INDEX IF NOT EXISTS idx_stock_almacen_lote ON stock_almacen(lote);
CREATE INDEX IF NOT EXISTS idx_stock_almacen_caducidad ON stock_almacen(fecha_caducidad);
CREATE INDEX IF NOT EXISTS idx_stock_almacen_ubicacion ON stock_almacen(ubicacion_almacen);
CREATE INDEX IF NOT EXISTS idx_stock_almacen_activo ON stock_almacen(activo);
CREATE INDEX IF NOT EXISTS idx_stock_almacen_proveedor ON stock_almacen(proveedor_id);
CREATE INDEX IF NOT EXISTS idx_stock_almacen_zona ON stock_almacen(zona);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_stock_almacen_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_stock_almacen_updated_at
  BEFORE UPDATE ON stock_almacen
  FOR EACH ROW
  EXECUTE FUNCTION update_stock_almacen_updated_at();

-- =====================================================
-- TABLA: entradas_almacen
-- =====================================================
-- Registro de recepciones de material (compras)

CREATE TABLE IF NOT EXISTS entradas_almacen (
  -- Identificación
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_entrada VARCHAR(20) UNIQUE NOT NULL,  -- Auto-generado: ENT-2025-00001
  tipo VARCHAR(20) CHECK (tipo IN ('compra', 'devolucion', 'ajuste')) DEFAULT 'compra',

  -- Origen
  proveedor_id UUID REFERENCES proveedores(id) ON DELETE SET NULL,
  numero_factura VARCHAR(50),
  fecha_factura DATE,

  -- Detalles
  fecha_entrada DATE NOT NULL DEFAULT CURRENT_DATE,
  recibido_por UUID REFERENCES auth.users(id),
  observaciones TEXT,

  -- Estado
  estado VARCHAR(20) CHECK (estado IN ('pendiente', 'recibida', 'parcial', 'cancelada')) DEFAULT 'recibida',

  -- Control
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_entradas_proveedor ON entradas_almacen(proveedor_id);
CREATE INDEX IF NOT EXISTS idx_entradas_fecha ON entradas_almacen(fecha_entrada);
CREATE INDEX IF NOT EXISTS idx_entradas_estado ON entradas_almacen(estado);
CREATE INDEX IF NOT EXISTS idx_entradas_numero ON entradas_almacen(numero_entrada);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_entradas_almacen_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_entradas_almacen_updated_at
  BEFORE UPDATE ON entradas_almacen
  FOR EACH ROW
  EXECUTE FUNCTION update_entradas_almacen_updated_at();

-- Función para generar número de entrada automático
CREATE OR REPLACE FUNCTION generar_numero_entrada()
RETURNS TRIGGER AS $$
DECLARE
  anio INT;
  secuencia INT;
  nuevo_numero VARCHAR(20);
BEGIN
  -- Obtener año actual
  anio := EXTRACT(YEAR FROM CURRENT_DATE);

  -- Obtener última secuencia del año
  SELECT COALESCE(MAX(CAST(SUBSTRING(numero_entrada FROM 10) AS INT)), 0) + 1
  INTO secuencia
  FROM entradas_almacen
  WHERE numero_entrada LIKE 'ENT-' || anio || '-%';

  -- Generar nuevo número: ENT-2025-00001
  nuevo_numero := 'ENT-' || anio || '-' || LPAD(secuencia::TEXT, 5, '0');

  NEW.numero_entrada := nuevo_numero;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_generar_numero_entrada
  BEFORE INSERT ON entradas_almacen
  FOR EACH ROW
  WHEN (NEW.numero_entrada IS NULL)
  EXECUTE FUNCTION generar_numero_entrada();

-- =====================================================
-- TABLA: detalle_entradas_almacen
-- =====================================================
-- Líneas de cada entrada de material

CREATE TABLE IF NOT EXISTS detalle_entradas_almacen (
  -- Identificación
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entrada_id UUID REFERENCES entradas_almacen(id) ON DELETE CASCADE NOT NULL,
  producto_id UUID REFERENCES productos(id) ON DELETE RESTRICT NOT NULL,

  -- Cantidades
  cantidad INT NOT NULL CHECK (cantidad > 0),
  lote VARCHAR(50),
  fecha_caducidad DATE,
  ubicacion_destino VARCHAR(100),

  -- Valoración (para FIFO)
  precio_unitario DECIMAL(10,2),
  precio_total DECIMAL(10,2),

  -- Control
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_detalle_entradas_entrada ON detalle_entradas_almacen(entrada_id);
CREATE INDEX IF NOT EXISTS idx_detalle_entradas_producto ON detalle_entradas_almacen(producto_id);
CREATE INDEX IF NOT EXISTS idx_detalle_entradas_lote ON detalle_entradas_almacen(lote);

-- Trigger: Actualizar stock_almacen al insertar detalle de entrada
CREATE OR REPLACE FUNCTION actualizar_stock_desde_entrada()
RETURNS TRIGGER AS $$
BEGIN
  -- Buscar si ya existe un registro de stock para este producto/lote
  INSERT INTO stock_almacen (
    producto_id,
    cantidad_disponible,
    lote,
    fecha_caducidad,
    fecha_entrada,
    ubicacion_almacen,
    proveedor_id,
    numero_factura,
    precio_unitario,
    precio_total
  )
  SELECT
    NEW.producto_id,
    NEW.cantidad,
    NEW.lote,
    NEW.fecha_caducidad,
    e.fecha_entrada,
    NEW.ubicacion_destino,
    e.proveedor_id,
    e.numero_factura,
    NEW.precio_unitario,
    NEW.precio_total
  FROM entradas_almacen e
  WHERE e.id = NEW.entrada_id
  ON CONFLICT (producto_id, COALESCE(lote, ''))
  DO UPDATE SET
    cantidad_disponible = stock_almacen.cantidad_disponible + NEW.cantidad,
    precio_total = stock_almacen.precio_total + NEW.precio_total,
    updated_at = NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Nota: El trigger se creará después de definir el constraint único en stock_almacen

-- =====================================================
-- TABLA: transferencias_stock
-- =====================================================
-- Movimientos entre almacén y vehículos

CREATE TABLE IF NOT EXISTS transferencias_stock (
  -- Identificación
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_transferencia VARCHAR(20) UNIQUE NOT NULL,  -- Auto-generado: TRF-2025-00001

  -- Tipo de movimiento
  tipo VARCHAR(20) CHECK (tipo IN ('asignacion', 'devolucion', 'ajuste')) NOT NULL,

  -- Origen y Destino
  origen_tipo VARCHAR(20) CHECK (origen_tipo IN ('almacen', 'vehiculo')) NOT NULL,
  origen_id UUID,  -- NULL si es almacén, vehiculo_id si es vehículo

  destino_tipo VARCHAR(20) CHECK (destino_tipo IN ('almacen', 'vehiculo')) NOT NULL,
  destino_id UUID,  -- NULL si es almacén, vehiculo_id si es vehículo

  -- Producto
  producto_id UUID REFERENCES productos(id) ON DELETE RESTRICT NOT NULL,
  cantidad INT NOT NULL CHECK (cantidad > 0),
  lote VARCHAR(50),

  -- Control
  motivo TEXT,
  realizada_por UUID REFERENCES auth.users(id),
  fecha_transferencia TIMESTAMPTZ DEFAULT NOW(),
  estado VARCHAR(20) CHECK (estado IN ('pendiente', 'completada', 'cancelada')) DEFAULT 'completada',

  -- Observaciones
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_transferencias_origen ON transferencias_stock(origen_tipo, origen_id);
CREATE INDEX IF NOT EXISTS idx_transferencias_destino ON transferencias_stock(destino_tipo, destino_id);
CREATE INDEX IF NOT EXISTS idx_transferencias_producto ON transferencias_stock(producto_id);
CREATE INDEX IF NOT EXISTS idx_transferencias_fecha ON transferencias_stock(fecha_transferencia);
CREATE INDEX IF NOT EXISTS idx_transferencias_estado ON transferencias_stock(estado);
CREATE INDEX IF NOT EXISTS idx_transferencias_numero ON transferencias_stock(numero_transferencia);

-- Función para generar número de transferencia automático
CREATE OR REPLACE FUNCTION generar_numero_transferencia()
RETURNS TRIGGER AS $$
DECLARE
  anio INT;
  secuencia INT;
  nuevo_numero VARCHAR(20);
BEGIN
  -- Obtener año actual
  anio := EXTRACT(YEAR FROM CURRENT_DATE);

  -- Obtener última secuencia del año
  SELECT COALESCE(MAX(CAST(SUBSTRING(numero_transferencia FROM 10) AS INT)), 0) + 1
  INTO secuencia
  FROM transferencias_stock
  WHERE numero_transferencia LIKE 'TRF-' || anio || '-%';

  -- Generar nuevo número: TRF-2025-00001
  nuevo_numero := 'TRF-' || anio || '-' || LPAD(secuencia::TEXT, 5, '0');

  NEW.numero_transferencia := nuevo_numero;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_generar_numero_transferencia
  BEFORE INSERT ON transferencias_stock
  FOR EACH ROW
  WHEN (NEW.numero_transferencia IS NULL)
  EXECUTE FUNCTION generar_numero_transferencia();

-- =====================================================
-- CONSTRAINT ÚNICO: stock_almacen por producto/lote
-- =====================================================
-- Cada combinación producto + lote es única en el almacén

ALTER TABLE stock_almacen
  ADD CONSTRAINT IF NOT EXISTS uq_stock_almacen_producto_lote
  UNIQUE (producto_id, COALESCE(lote, ''));

-- =====================================================
-- TRIGGER: Actualizar stock desde entradas
-- =====================================================
-- Ahora sí podemos crear el trigger que usa el constraint único

CREATE TRIGGER trg_actualizar_stock_desde_entrada
  AFTER INSERT ON detalle_entradas_almacen
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_stock_desde_entrada();

-- =====================================================
-- VISTA: stock_almacen_valorado
-- =====================================================
-- Vista con valoración FIFO del stock actual

CREATE OR REPLACE VIEW stock_almacen_valorado AS
SELECT
  s.id,
  s.producto_id,
  p.nombre AS producto_nombre,
  p.codigo AS producto_codigo,
  c.nombre AS categoria_nombre,
  s.cantidad_disponible,
  s.cantidad_reservada,
  s.cantidad_minima,
  s.lote,
  s.fecha_caducidad,
  s.fecha_entrada,
  s.ubicacion_almacen,
  s.zona,
  prov.nombre_comercial AS proveedor_nombre,
  s.numero_factura,
  s.precio_unitario,
  s.precio_total,
  (s.cantidad_disponible * s.precio_unitario) AS valor_actual,
  CASE
    WHEN s.fecha_caducidad IS NOT NULL AND s.fecha_caducidad < CURRENT_DATE THEN 'caducado'
    WHEN s.fecha_caducidad IS NOT NULL AND s.fecha_caducidad < (CURRENT_DATE + INTERVAL '30 days') THEN 'proximo_a_caducar'
    WHEN s.cantidad_disponible <= s.cantidad_minima THEN 'stock_bajo'
    WHEN s.cantidad_disponible = 0 THEN 'sin_stock'
    ELSE 'normal'
  END AS estado_stock,
  s.activo,
  s.created_at,
  s.updated_at
FROM stock_almacen s
INNER JOIN productos p ON s.producto_id = p.id
LEFT JOIN categorias_equipamiento c ON p.categoria_id = c.id
LEFT JOIN proveedores prov ON s.proveedor_id = prov.id
WHERE s.activo = TRUE;

-- =====================================================
-- VISTA: necesidades_compra
-- =====================================================
-- Productos que necesitan reposición según stock mínimo de vehículos

CREATE OR REPLACE VIEW necesidades_compra AS
WITH stock_minimo_total AS (
  -- Calcular stock mínimo total sumando mínimos de todos los vehículos
  SELECT
    smt.producto_id,
    SUM(smt.cantidad_minima * COUNT(v.id)) AS cantidad_minima_total
  FROM stock_minimo_por_tipo smt
  CROSS JOIN tvehiculos v
  WHERE v.activo = TRUE
  GROUP BY smt.producto_id
),
stock_actual AS (
  -- Stock disponible actual en almacén
  SELECT
    producto_id,
    SUM(cantidad_disponible) AS cantidad_total
  FROM stock_almacen
  WHERE activo = TRUE
  GROUP BY producto_id
)
SELECT
  p.id AS producto_id,
  p.codigo AS producto_codigo,
  p.nombre AS producto_nombre,
  c.nombre AS categoria_nombre,
  COALESCE(sa.cantidad_total, 0) AS stock_actual,
  smt.cantidad_minima_total AS stock_minimo,
  (smt.cantidad_minima_total - COALESCE(sa.cantidad_total, 0)) AS cantidad_necesaria,
  CASE
    WHEN COALESCE(sa.cantidad_total, 0) = 0 THEN 'critico'
    WHEN COALESCE(sa.cantidad_total, 0) < (smt.cantidad_minima_total * 0.5) THEN 'alto'
    WHEN COALESCE(sa.cantidad_total, 0) < smt.cantidad_minima_total THEN 'medio'
    ELSE 'normal'
  END AS nivel_urgencia
FROM productos p
INNER JOIN categorias_equipamiento c ON p.categoria_id = c.id
INNER JOIN stock_minimo_total smt ON p.id = smt.producto_id
LEFT JOIN stock_actual sa ON p.id = sa.producto_id
WHERE (smt.cantidad_minima_total - COALESCE(sa.cantidad_total, 0)) > 0
ORDER BY
  CASE
    WHEN COALESCE(sa.cantidad_total, 0) = 0 THEN 1
    WHEN COALESCE(sa.cantidad_total, 0) < (smt.cantidad_minima_total * 0.5) THEN 2
    WHEN COALESCE(sa.cantidad_total, 0) < smt.cantidad_minima_total THEN 3
    ELSE 4
  END,
  p.nombre;

-- =====================================================
-- RLS (Row Level Security)
-- =====================================================
-- Seguridad a nivel de fila

-- Habilitar RLS en todas las tablas
ALTER TABLE proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_almacen ENABLE ROW LEVEL SECURITY;
ALTER TABLE entradas_almacen ENABLE ROW LEVEL SECURITY;
ALTER TABLE detalle_entradas_almacen ENABLE ROW LEVEL SECURITY;
ALTER TABLE transferencias_stock ENABLE ROW LEVEL SECURITY;

-- Políticas: Permitir SELECT a todos los usuarios autenticados
CREATE POLICY select_proveedores ON proveedores
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY select_stock_almacen ON stock_almacen
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY select_entradas_almacen ON entradas_almacen
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY select_detalle_entradas ON detalle_entradas_almacen
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY select_transferencias ON transferencias_stock
  FOR SELECT
  TO authenticated
  USING (true);

-- Políticas: Permitir INSERT/UPDATE/DELETE a todos los usuarios autenticados
-- NOTA: En producción, limitar a roles específicos (admin, responsable_almacen)

CREATE POLICY insert_proveedores ON proveedores
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY update_proveedores ON proveedores
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY delete_proveedores ON proveedores
  FOR DELETE
  TO authenticated
  USING (true);

CREATE POLICY insert_stock_almacen ON stock_almacen
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY update_stock_almacen ON stock_almacen
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY delete_stock_almacen ON stock_almacen
  FOR DELETE
  TO authenticated
  USING (true);

CREATE POLICY insert_entradas ON entradas_almacen
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY update_entradas ON entradas_almacen
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY delete_entradas ON entradas_almacen
  FOR DELETE
  TO authenticated
  USING (true);

CREATE POLICY insert_detalle_entradas ON detalle_entradas_almacen
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY update_detalle_entradas ON detalle_entradas_almacen
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY delete_detalle_entradas ON detalle_entradas_almacen
  FOR DELETE
  TO authenticated
  USING (true);

CREATE POLICY insert_transferencias ON transferencias_stock
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY update_transferencias ON transferencias_stock
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY delete_transferencias ON transferencias_stock
  FOR DELETE
  TO authenticated
  USING (true);

-- =====================================================
-- DATOS DE PRUEBA (SEED)
-- =====================================================

-- Proveedores de ejemplo
INSERT INTO proveedores (codigo, nombre_comercial, razon_social, cif_nif, telefono, email, condiciones_pago, activo)
VALUES
  ('PROV001', 'Suministros Médicos S.L.', 'Suministros Médicos Sociedad Limitada', 'B12345678', '912345678', 'ventas@suministros.es', '30 días', TRUE),
  ('PROV002', 'Farmacia Central', 'Farmacia Central S.A.', 'A87654321', '913456789', 'pedidos@farmaciacentral.es', 'Contado', TRUE),
  ('PROV003', 'Electromedicina Pro', 'Electromedicina Profesional S.L.', 'B11223344', '914567890', 'info@electromedpro.es', '60 días', TRUE)
ON CONFLICT (codigo) DO NOTHING;

-- Entradas de ejemplo (solo cabeceras, los detalles se agregarán desde la UI)
INSERT INTO entradas_almacen (numero_entrada, tipo, proveedor_id, numero_factura, fecha_factura, fecha_entrada, estado, observaciones)
SELECT
  'ENT-2025-00001',
  'compra',
  id,
  'FAC-2025-001',
  '2025-01-15',
  '2025-01-15',
  'recibida',
  'Compra inicial de stock'
FROM proveedores
WHERE codigo = 'PROV001'
LIMIT 1
ON CONFLICT (numero_entrada) DO NOTHING;

-- =====================================================
-- FIN DE MIGRACIÓN
-- =====================================================

-- Comentarios finales
COMMENT ON TABLE proveedores IS 'Catálogo de proveedores de material médico y equipamiento';
COMMENT ON TABLE stock_almacen IS 'Inventario centralizado del almacén general (Sistema 1)';
COMMENT ON TABLE entradas_almacen IS 'Registro de recepciones de material (compras, devoluciones)';
COMMENT ON TABLE detalle_entradas_almacen IS 'Líneas de detalle de cada entrada de material';
COMMENT ON TABLE transferencias_stock IS 'Movimientos de material entre almacén y vehículos';
COMMENT ON VIEW stock_almacen_valorado IS 'Vista con valoración FIFO y estado del stock';
COMMENT ON VIEW necesidades_compra IS 'Productos que necesitan reposición según stock mínimo de vehículos';
