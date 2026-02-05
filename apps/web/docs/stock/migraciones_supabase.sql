-- ============================================================================
-- MIGRACIONES SUPABASE - MÓDULO DE STOCK DE EQUIPAMIENTO
-- ============================================================================
-- Proyecto: AmbuTrack Web
-- Módulo: Stock de Equipamiento Médico por Tipo de Vehículo
-- Fecha: 2025-01-27
-- ============================================================================

-- ============================================================================
-- 1. TABLA: categorias_equipamiento
-- ============================================================================
CREATE TABLE IF NOT EXISTS categorias_equipamiento (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo VARCHAR(10) NOT NULL UNIQUE,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  orden INT DEFAULT 0,
  dia_revision INT DEFAULT 1 CHECK (dia_revision IN (1, 2, 3)),
  icono VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE categorias_equipamiento IS 'Categorías de equipamiento médico según normativa EN 1789:2021';
COMMENT ON COLUMN categorias_equipamiento.dia_revision IS 'Día del mes para revisión (1, 2 o 3)';

-- Datos iniciales
INSERT INTO categorias_equipamiento (codigo, nombre, dia_revision, icono, orden) VALUES
('1.1', 'Equipos de Traslado e Inmovilización', 1, 'local_hospital', 1),
('1.2', 'Equipos de Ventilación y Respiración', 1, 'air', 2),
('1.3', 'Equipos de Diagnóstico', 1, 'monitor_heart', 3),
('1.4', 'Equipos de Infusión (Sueroterapia)', 2, 'water_drop', 4),
('1.5', 'Medicación', 1, 'medication', 5),
('1.6', 'Mochilas de Intervención', 2, 'backpack', 6),
('1.7', 'Vendajes y Asistencia Sanitaria', 2, 'healing', 7),
('1.8', 'Protección y Rescate', 3, 'security', 8),
('1.9', 'Documentación', 3, 'description', 9)
ON CONFLICT (codigo) DO NOTHING;

-- ============================================================================
-- 2. TABLA: productos
-- ============================================================================
CREATE TABLE IF NOT EXISTS productos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  categoria_id UUID REFERENCES categorias_equipamiento(id) ON DELETE RESTRICT,
  codigo VARCHAR(20),
  nombre VARCHAR(150) NOT NULL,
  nombre_comercial VARCHAR(100),
  descripcion TEXT,
  unidad_medida VARCHAR(20) DEFAULT 'unidades',
  requiere_refrigeracion BOOLEAN DEFAULT FALSE,
  tiene_caducidad BOOLEAN DEFAULT FALSE,
  dias_alerta_caducidad INT DEFAULT 30,
  ubicacion_default VARCHAR(100),
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE productos IS 'Catálogo de productos y equipamiento médico';
COMMENT ON COLUMN productos.nombre_comercial IS 'Nombre comercial del medicamento (ej: ADENOCOR para Adenosina)';
COMMENT ON COLUMN productos.dias_alerta_caducidad IS 'Días antes de la caducidad para generar alerta';

-- Índices
CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos(categoria_id);
CREATE INDEX IF NOT EXISTS idx_productos_activo ON productos(activo);
CREATE INDEX IF NOT EXISTS idx_productos_nombre ON productos(nombre);

-- ============================================================================
-- 3. TABLA: stock_minimo_por_tipo
-- ============================================================================
CREATE TABLE IF NOT EXISTS stock_minimo_por_tipo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
  tipo_vehiculo VARCHAR(10) NOT NULL CHECK (tipo_vehiculo IN ('A2', 'B', 'C')),
  cantidad_minima INT NOT NULL DEFAULT 0 CHECK (cantidad_minima >= 0),
  cantidad_recomendada INT CHECK (cantidad_recomendada >= cantidad_minima),
  obligatorio BOOLEAN DEFAULT TRUE,
  UNIQUE(producto_id, tipo_vehiculo)
);

COMMENT ON TABLE stock_minimo_por_tipo IS 'Stock mínimo requerido por tipo de ambulancia (A2, B, C)';
COMMENT ON COLUMN stock_minimo_por_tipo.tipo_vehiculo IS 'A2: Transporte, B: SVB, C: SVA';

-- Índice
CREATE INDEX IF NOT EXISTS idx_stock_minimo_tipo ON stock_minimo_por_tipo(tipo_vehiculo);

-- ============================================================================
-- 4. TABLA: stock_vehiculo
-- ============================================================================
CREATE TABLE IF NOT EXISTS stock_vehiculo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE CASCADE,
  producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
  cantidad_actual INT NOT NULL DEFAULT 0 CHECK (cantidad_actual >= 0),
  fecha_caducidad DATE,
  lote VARCHAR(50),
  ubicacion VARCHAR(100),
  observaciones TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  updated_by UUID REFERENCES auth.users(id),
  UNIQUE(vehiculo_id, producto_id, lote)
);

COMMENT ON TABLE stock_vehiculo IS 'Stock actual de cada producto por vehículo';
COMMENT ON COLUMN stock_vehiculo.lote IS 'Número de lote del producto (permite múltiples lotes del mismo producto)';

-- Índices
CREATE INDEX IF NOT EXISTS idx_stock_vehiculo ON stock_vehiculo(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_stock_producto ON stock_vehiculo(producto_id);
CREATE INDEX IF NOT EXISTS idx_stock_caducidad ON stock_vehiculo(fecha_caducidad);

-- ============================================================================
-- 5. TABLA: movimientos_stock
-- ============================================================================
CREATE TABLE IF NOT EXISTS movimientos_stock (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stock_vehiculo_id UUID REFERENCES stock_vehiculo(id) ON DELETE SET NULL,
  vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE CASCADE,
  producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
  tipo_movimiento VARCHAR(20) NOT NULL CHECK (tipo_movimiento IN ('entrada', 'salida', 'ajuste', 'caducidad', 'transferencia')),
  cantidad INT NOT NULL,
  cantidad_anterior INT,
  cantidad_nueva INT,
  motivo TEXT,
  referencia VARCHAR(100),
  vehiculo_destino_id UUID REFERENCES vehiculos(id),
  usuario_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE movimientos_stock IS 'Historial de movimientos de stock (entradas, salidas, ajustes)';
COMMENT ON COLUMN movimientos_stock.referencia IS 'Número de servicio, pedido, etc.';

-- Índices
CREATE INDEX IF NOT EXISTS idx_movimientos_vehiculo ON movimientos_stock(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_movimientos_fecha ON movimientos_stock(created_at);
CREATE INDEX IF NOT EXISTS idx_movimientos_tipo ON movimientos_stock(tipo_movimiento);

-- ============================================================================
-- 6. TABLA: revisiones_mensuales
-- ============================================================================
CREATE TABLE IF NOT EXISTS revisiones_mensuales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE CASCADE,
  fecha DATE NOT NULL,
  mes INT NOT NULL CHECK (mes BETWEEN 1 AND 12),
  anio INT NOT NULL,
  dia_revision INT NOT NULL CHECK (dia_revision IN (1, 2, 3)),
  tecnico_id UUID REFERENCES auth.users(id),
  tecnico_nombre VARCHAR(100),
  completada BOOLEAN DEFAULT FALSE,
  firma_base64 TEXT,
  observaciones_generales TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  UNIQUE(vehiculo_id, mes, anio, dia_revision)
);

COMMENT ON TABLE revisiones_mensuales IS 'Revisiones mensuales de stock por día (1, 2 o 3)';
COMMENT ON COLUMN revisiones_mensuales.dia_revision IS 'Día de revisión mensual (1, 2 o 3)';

-- Índice
CREATE INDEX IF NOT EXISTS idx_revisiones_vehiculo ON revisiones_mensuales(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_revisiones_fecha ON revisiones_mensuales(fecha);

-- ============================================================================
-- 7. TABLA: items_revision
-- ============================================================================
CREATE TABLE IF NOT EXISTS items_revision (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  revision_id UUID REFERENCES revisiones_mensuales(id) ON DELETE CASCADE,
  producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
  verificado BOOLEAN DEFAULT FALSE,
  cantidad_encontrada INT,
  caducidad_ok BOOLEAN DEFAULT TRUE,
  estado VARCHAR(20) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'ok', 'falta', 'caducado', 'dañado')),
  observacion TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE items_revision IS 'Items verificados en cada revisión mensual';

-- Índice
CREATE INDEX IF NOT EXISTS idx_items_revision ON items_revision(revision_id);

-- ============================================================================
-- 8. TABLA: alertas_stock
-- ============================================================================
CREATE TABLE IF NOT EXISTS alertas_stock (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE CASCADE,
  producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
  tipo_alerta VARCHAR(30) NOT NULL CHECK (tipo_alerta IN ('stock_bajo', 'caducidad_proxima', 'caducado', 'sin_stock')),
  mensaje TEXT,
  nivel VARCHAR(10) DEFAULT 'warning' CHECK (nivel IN ('info', 'warning', 'critical')),
  fecha_caducidad DATE,
  cantidad_actual INT,
  cantidad_minima INT,
  resuelta BOOLEAN DEFAULT FALSE,
  resuelta_por UUID REFERENCES auth.users(id),
  resuelta_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE alertas_stock IS 'Alertas automáticas de stock bajo y caducidad';

-- Índice
CREATE INDEX IF NOT EXISTS idx_alertas_activas ON alertas_stock(resuelta, created_at);
CREATE INDEX IF NOT EXISTS idx_alertas_vehiculo ON alertas_stock(vehiculo_id);

-- ============================================================================
-- VISTAS
-- ============================================================================

-- Vista de stock con estado calculado
CREATE OR REPLACE VIEW v_stock_vehiculo_estado AS
SELECT
  sv.id,
  sv.vehiculo_id,
  v.matricula,
  v.tipo as tipo_vehiculo,
  sv.producto_id,
  p.nombre as producto_nombre,
  p.nombre_comercial,
  c.codigo as categoria_codigo,
  c.nombre as categoria_nombre,
  sv.cantidad_actual,
  COALESCE(sm.cantidad_minima, 0) as cantidad_minima,
  sv.fecha_caducidad,
  sv.lote,
  sv.ubicacion,
  sv.observaciones,
  CASE
    WHEN sv.cantidad_actual = 0 THEN 'sin_stock'
    WHEN sv.cantidad_actual < COALESCE(sm.cantidad_minima, 0) THEN 'bajo'
    ELSE 'ok'
  END as estado_stock,
  CASE
    WHEN sv.fecha_caducidad IS NULL THEN 'sin_caducidad'
    WHEN sv.fecha_caducidad < CURRENT_DATE THEN 'caducado'
    WHEN sv.fecha_caducidad < CURRENT_DATE + INTERVAL '7 days' THEN 'critico'
    WHEN sv.fecha_caducidad < CURRENT_DATE + INTERVAL '30 days' THEN 'proximo'
    ELSE 'ok'
  END as estado_caducidad
FROM stock_vehiculo sv
JOIN vehiculos v ON sv.vehiculo_id = v.id
JOIN productos p ON sv.producto_id = p.id
JOIN categorias_equipamiento c ON p.categoria_id = c.id
LEFT JOIN stock_minimo_por_tipo sm ON sm.producto_id = p.id AND sm.tipo_vehiculo = v.tipo;

COMMENT ON VIEW v_stock_vehiculo_estado IS 'Vista con estado calculado de stock y caducidad';

-- Vista resumen de alertas por vehículo
CREATE OR REPLACE VIEW v_resumen_alertas_vehiculo AS
SELECT
  vehiculo_id,
  COUNT(*) FILTER (WHERE tipo_alerta = 'sin_stock' AND NOT resuelta) as sin_stock,
  COUNT(*) FILTER (WHERE tipo_alerta = 'stock_bajo' AND NOT resuelta) as stock_bajo,
  COUNT(*) FILTER (WHERE tipo_alerta = 'caducado' AND NOT resuelta) as caducados,
  COUNT(*) FILTER (WHERE tipo_alerta = 'caducidad_proxima' AND NOT resuelta) as proximos_caducar,
  COUNT(*) FILTER (WHERE NOT resuelta) as total_alertas
FROM alertas_stock
GROUP BY vehiculo_id;

COMMENT ON VIEW v_resumen_alertas_vehiculo IS 'Resumen de alertas activas por vehículo';

-- ============================================================================
-- FUNCIONES RPC
-- ============================================================================

-- Función para registrar movimiento de stock
CREATE OR REPLACE FUNCTION registrar_movimiento_stock(
  p_vehiculo_id UUID,
  p_producto_id UUID,
  p_tipo VARCHAR(20),
  p_cantidad INT,
  p_motivo TEXT DEFAULT NULL,
  p_lote VARCHAR(50) DEFAULT NULL,
  p_fecha_caducidad DATE DEFAULT NULL,
  p_usuario_id UUID DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
  v_stock_id UUID;
  v_cantidad_anterior INT;
  v_cantidad_nueva INT;
BEGIN
  -- Buscar o crear registro de stock
  SELECT id, cantidad_actual INTO v_stock_id, v_cantidad_anterior
  FROM stock_vehiculo
  WHERE vehiculo_id = p_vehiculo_id
    AND producto_id = p_producto_id
    AND (lote = p_lote OR (lote IS NULL AND p_lote IS NULL))
  LIMIT 1;

  IF v_stock_id IS NULL THEN
    v_cantidad_anterior := 0;
    INSERT INTO stock_vehiculo (vehiculo_id, producto_id, cantidad_actual, lote, fecha_caducidad)
    VALUES (p_vehiculo_id, p_producto_id, 0, p_lote, p_fecha_caducidad)
    RETURNING id INTO v_stock_id;
  END IF;

  -- Calcular nueva cantidad
  IF p_tipo IN ('entrada', 'ajuste_positivo') THEN
    v_cantidad_nueva := v_cantidad_anterior + p_cantidad;
  ELSIF p_tipo IN ('salida', 'caducidad', 'ajuste_negativo') THEN
    v_cantidad_nueva := GREATEST(0, v_cantidad_anterior - p_cantidad);
  ELSE
    v_cantidad_nueva := p_cantidad; -- ajuste absoluto
  END IF;

  -- Actualizar stock
  UPDATE stock_vehiculo
  SET cantidad_actual = v_cantidad_nueva,
      fecha_caducidad = COALESCE(p_fecha_caducidad, fecha_caducidad),
      updated_at = NOW(),
      updated_by = p_usuario_id
  WHERE id = v_stock_id;

  -- Registrar movimiento
  INSERT INTO movimientos_stock (
    stock_vehiculo_id, vehiculo_id, producto_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_nueva,
    motivo, usuario_id
  ) VALUES (
    v_stock_id, p_vehiculo_id, p_producto_id,
    p_tipo, p_cantidad, v_cantidad_anterior, v_cantidad_nueva,
    p_motivo, p_usuario_id
  );

  RETURN json_build_object(
    'success', true,
    'stock_id', v_stock_id,
    'cantidad_anterior', v_cantidad_anterior,
    'cantidad_nueva', v_cantidad_nueva
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION registrar_movimiento_stock IS 'Registra un movimiento de stock y actualiza cantidad actual';

-- Función para generar alertas automáticas
CREATE OR REPLACE FUNCTION generar_alertas_stock() RETURNS void AS $$
BEGIN
  -- Limpiar alertas resueltas antiguas (>30 días)
  DELETE FROM alertas_stock WHERE resuelta AND resuelta_at < NOW() - INTERVAL '30 days';

  -- Alertas de stock bajo
  INSERT INTO alertas_stock (vehiculo_id, producto_id, tipo_alerta, mensaje, nivel, cantidad_actual, cantidad_minima)
  SELECT
    sv.vehiculo_id,
    sv.producto_id,
    CASE WHEN sv.cantidad_actual = 0 THEN 'sin_stock' ELSE 'stock_bajo' END,
    p.nombre || ': ' || sv.cantidad_actual || '/' || sm.cantidad_minima,
    CASE WHEN sv.cantidad_actual = 0 THEN 'critical' ELSE 'warning' END,
    sv.cantidad_actual,
    sm.cantidad_minima
  FROM stock_vehiculo sv
  JOIN vehiculos v ON sv.vehiculo_id = v.id
  JOIN productos p ON sv.producto_id = p.id
  JOIN stock_minimo_por_tipo sm ON sm.producto_id = p.id AND sm.tipo_vehiculo = v.tipo
  WHERE sv.cantidad_actual < sm.cantidad_minima
    AND NOT EXISTS (
      SELECT 1 FROM alertas_stock a
      WHERE a.vehiculo_id = sv.vehiculo_id
        AND a.producto_id = sv.producto_id
        AND a.tipo_alerta IN ('sin_stock', 'stock_bajo')
        AND NOT a.resuelta
    );

  -- Alertas de caducidad
  INSERT INTO alertas_stock (vehiculo_id, producto_id, tipo_alerta, mensaje, nivel, fecha_caducidad, cantidad_actual)
  SELECT
    sv.vehiculo_id,
    sv.producto_id,
    CASE
      WHEN sv.fecha_caducidad < CURRENT_DATE THEN 'caducado'
      ELSE 'caducidad_proxima'
    END,
    p.nombre || ' caduca: ' || sv.fecha_caducidad,
    CASE
      WHEN sv.fecha_caducidad < CURRENT_DATE THEN 'critical'
      WHEN sv.fecha_caducidad < CURRENT_DATE + INTERVAL '7 days' THEN 'critical'
      ELSE 'warning'
    END,
    sv.fecha_caducidad,
    sv.cantidad_actual
  FROM stock_vehiculo sv
  JOIN productos p ON sv.producto_id = p.id
  WHERE sv.fecha_caducidad IS NOT NULL
    AND sv.fecha_caducidad < CURRENT_DATE + INTERVAL '30 days'
    AND sv.cantidad_actual > 0
    AND NOT EXISTS (
      SELECT 1 FROM alertas_stock a
      WHERE a.vehiculo_id = sv.vehiculo_id
        AND a.producto_id = sv.producto_id
        AND a.tipo_alerta IN ('caducado', 'caducidad_proxima')
        AND NOT a.resuelta
    );
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generar_alertas_stock IS 'Genera alertas automáticas de stock bajo y caducidad';

-- ============================================================================
-- POLÍTICAS RLS (Row Level Security)
-- ============================================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE categorias_equipamiento ENABLE ROW LEVEL SECURITY;
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_minimo_por_tipo ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_vehiculo ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_stock ENABLE ROW LEVEL SECURITY;
ALTER TABLE revisiones_mensuales ENABLE ROW LEVEL SECURITY;
ALTER TABLE items_revision ENABLE ROW LEVEL SECURITY;
ALTER TABLE alertas_stock ENABLE ROW LEVEL SECURITY;

-- Políticas para categorias_equipamiento (lectura pública)
CREATE POLICY "Lectura pública de categorías"
  ON categorias_equipamiento FOR SELECT
  USING (true);

-- Políticas para productos (lectura pública, escritura autenticada)
CREATE POLICY "Lectura pública de productos"
  ON productos FOR SELECT
  USING (true);

CREATE POLICY "Usuarios autenticados pueden crear productos"
  ON productos FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden actualizar productos"
  ON productos FOR UPDATE
  TO authenticated
  USING (true);

-- Políticas para stock_minimo_por_tipo (lectura pública)
CREATE POLICY "Lectura pública de stock mínimo"
  ON stock_minimo_por_tipo FOR SELECT
  USING (true);

-- Políticas para stock_vehiculo (usuarios autenticados)
CREATE POLICY "Usuarios autenticados pueden ver stock"
  ON stock_vehiculo FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuarios autenticados pueden crear stock"
  ON stock_vehiculo FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden actualizar stock"
  ON stock_vehiculo FOR UPDATE
  TO authenticated
  USING (true);

-- Políticas para movimientos_stock (usuarios autenticados)
CREATE POLICY "Usuarios autenticados pueden ver movimientos"
  ON movimientos_stock FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuarios autenticados pueden crear movimientos"
  ON movimientos_stock FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Políticas para revisiones_mensuales (usuarios autenticados)
CREATE POLICY "Usuarios autenticados pueden ver revisiones"
  ON revisiones_mensuales FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuarios autenticados pueden crear revisiones"
  ON revisiones_mensuales FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden actualizar revisiones"
  ON revisiones_mensuales FOR UPDATE
  TO authenticated
  USING (true);

-- Políticas para items_revision (usuarios autenticados)
CREATE POLICY "Usuarios autenticados pueden ver items de revisión"
  ON items_revision FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuarios autenticados pueden crear items de revisión"
  ON items_revision FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden actualizar items de revisión"
  ON items_revision FOR UPDATE
  TO authenticated
  USING (true);

-- Políticas para alertas_stock (usuarios autenticados)
CREATE POLICY "Usuarios autenticados pueden ver alertas"
  ON alertas_stock FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuarios autenticados pueden crear alertas"
  ON alertas_stock FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden actualizar alertas"
  ON alertas_stock FOR UPDATE
  TO authenticated
  USING (true);

-- ============================================================================
-- FIN DE MIGRACIONES
-- ============================================================================
