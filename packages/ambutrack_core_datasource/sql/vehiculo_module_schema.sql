-- ============================================================================
-- MÓDULO DE VEHÍCULOS - SCHEMA COMPLETO
-- ============================================================================
-- Incluye:
-- 1. Tabla de incidencias de vehículos
-- 2. Tabla de checklists de vehículos
-- 3. Tabla de items de checklist
-- 4. Tabla de plantilla de checklist (con 47 items del protocolo A2)
-- 5. Vista de caducidades con alertas
-- 6. Trigger para actualizar contadores de checklist
-- ============================================================================

-- ============================================================================
-- 1. TABLA: incidencias_vehiculos
-- ============================================================================
CREATE TABLE IF NOT EXISTS incidencias_vehiculos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vehiculo_id UUID NOT NULL REFERENCES tvehiculos(id) ON DELETE CASCADE,
  reportado_por UUID NOT NULL REFERENCES usuarios(id),
  reportado_por_nombre TEXT NOT NULL,
  fecha_reporte TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  tipo TEXT NOT NULL CHECK (tipo IN (
    'mecanica', 'electrica', 'carroceria', 'neumaticos',
    'limpieza', 'equipamiento', 'documentacion', 'otra'
  )),
  prioridad TEXT NOT NULL CHECK (prioridad IN ('baja', 'media', 'alta', 'critica')),
  estado TEXT NOT NULL DEFAULT 'reportada' CHECK (estado IN (
    'reportada', 'enRevision', 'enReparacion', 'resuelta', 'cerrada'
  )),
  titulo TEXT NOT NULL CHECK (LENGTH(titulo) <= 100),
  descripcion TEXT NOT NULL CHECK (LENGTH(descripcion) <= 500),
  kilometraje_reporte NUMERIC(10, 2),
  fotos_urls TEXT[],
  ubicacion_reporte JSONB,

  -- Campos de resolución
  asignado_a UUID REFERENCES usuarios(id),
  fecha_asignacion TIMESTAMPTZ,
  fecha_resolucion TIMESTAMPTZ,
  solucion_aplicada TEXT,
  costo_reparacion NUMERIC(10, 2),
  taller_responsable TEXT,

  empresa_id UUID NOT NULL REFERENCES tempresas(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_incidencias_vehiculo_id ON incidencias_vehiculos(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_incidencias_estado ON incidencias_vehiculos(estado);
CREATE INDEX IF NOT EXISTS idx_incidencias_fecha ON incidencias_vehiculos(fecha_reporte DESC);
CREATE INDEX IF NOT EXISTS idx_incidencias_empresa ON incidencias_vehiculos(empresa_id);

-- Comentarios
COMMENT ON TABLE incidencias_vehiculos IS 'Registro de incidencias reportadas para vehículos';
COMMENT ON COLUMN incidencias_vehiculos.reportado_por_nombre IS 'Nombre completo en MAYÚSCULAS';
COMMENT ON COLUMN incidencias_vehiculos.titulo IS 'Título breve (max 100 caracteres)';
COMMENT ON COLUMN incidencias_vehiculos.descripcion IS 'Descripción detallada (max 500 caracteres)';
COMMENT ON COLUMN incidencias_vehiculos.fotos_urls IS 'URLs de fotos adjuntas (máximo 5)';
COMMENT ON COLUMN incidencias_vehiculos.ubicacion_reporte IS 'GPS JSON {lat, lng}';

-- ============================================================================
-- 2. TABLA: checklists_vehiculo
-- ============================================================================
CREATE TABLE IF NOT EXISTS checklists_vehiculo (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vehiculo_id UUID NOT NULL REFERENCES tvehiculos(id) ON DELETE CASCADE,
  realizado_por UUID NOT NULL REFERENCES usuarios(id),
  realizado_por_nombre TEXT NOT NULL,
  fecha_realizacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  tipo TEXT NOT NULL CHECK (tipo IN ('mensual', 'preServicio', 'postServicio')),
  kilometraje NUMERIC(10, 2) NOT NULL,

  items_presentes INT NOT NULL DEFAULT 0,
  items_ausentes INT NOT NULL DEFAULT 0,
  checklist_completo BOOLEAN NOT NULL DEFAULT true,

  observaciones_generales TEXT,
  firma_url TEXT,

  empresa_id UUID NOT NULL REFERENCES tempresas(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_checklists_vehiculo_id ON checklists_vehiculo(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_checklists_fecha ON checklists_vehiculo(fecha_realizacion DESC);
CREATE INDEX IF NOT EXISTS idx_checklists_tipo ON checklists_vehiculo(tipo);
CREATE INDEX IF NOT EXISTS idx_checklists_empresa ON checklists_vehiculo(empresa_id);

-- Comentarios
COMMENT ON TABLE checklists_vehiculo IS 'Registros de checklists de vehículos';
COMMENT ON COLUMN checklists_vehiculo.realizado_por_nombre IS 'Nombre completo en MAYÚSCULAS';
COMMENT ON COLUMN checklists_vehiculo.tipo IS 'Tipo de checklist: mensual (día 1 cada mes), preServicio, postServicio';

-- ============================================================================
-- 3. TABLA: items_checklist_vehiculo
-- ============================================================================
CREATE TABLE IF NOT EXISTS items_checklist_vehiculo (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  checklist_id UUID NOT NULL REFERENCES checklists_vehiculo(id) ON DELETE CASCADE,
  categoria TEXT NOT NULL CHECK (categoria IN (
    'equipos_traslado', 'equipo_ventilacion', 'equipo_diagnostico',
    'equipo_infusion', 'equipo_emergencia', 'vendajes_asistencia', 'documentacion'
  )),
  item_nombre TEXT NOT NULL,
  cantidad_requerida INT,
  resultado TEXT NOT NULL CHECK (resultado IN ('presente', 'ausente', 'noAplica')),
  observaciones TEXT,
  orden INT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_items_checklist_id ON items_checklist_vehiculo(checklist_id);
CREATE INDEX IF NOT EXISTS idx_items_categoria ON items_checklist_vehiculo(categoria);

-- Comentarios
COMMENT ON TABLE items_checklist_vehiculo IS 'Items individuales de cada checklist';
COMMENT ON COLUMN items_checklist_vehiculo.cantidad_requerida IS 'NULL equivale a "X" (sin cantidad específica)';

-- ============================================================================
-- 4. TABLA: plantilla_checklist_vehiculo
-- ============================================================================
CREATE TABLE IF NOT EXISTS plantilla_checklist_vehiculo (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tipo_checklist TEXT NOT NULL,
  categoria TEXT NOT NULL CHECK (categoria IN (
    'equipos_traslado', 'equipo_ventilacion', 'equipo_diagnostico',
    'equipo_infusion', 'equipo_emergencia', 'vendajes_asistencia', 'documentacion'
  )),
  item_nombre TEXT NOT NULL,
  cantidad_requerida INT,
  orden INT NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT true,
  empresa_id UUID REFERENCES empresas(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_plantilla_tipo ON plantilla_checklist_vehiculo(tipo_checklist);
CREATE INDEX IF NOT EXISTS idx_plantilla_activo ON plantilla_checklist_vehiculo(activo) WHERE activo = true;

-- Comentarios
COMMENT ON TABLE plantilla_checklist_vehiculo IS 'Plantilla oficial de items según protocolo A2 (actualizado 23/02/2023)';

-- ============================================================================
-- SEED DATA: 47 items del protocolo oficial A2
-- ============================================================================

-- 1.1 EQUIPOS DE TRASLADO (7 items)
INSERT INTO plantilla_checklist_vehiculo (tipo_checklist, categoria, item_nombre, cantidad_requerida, orden) VALUES
('mensual', 'equipos_traslado', 'Camilla principal', 1, 1),
('mensual', 'equipos_traslado', 'Dispositivo para trasladar paciente sentado', 1, 2),
('mensual', 'equipos_traslado', 'Sábana traslado', 1, 3),
('mensual', 'equipos_traslado', 'Silla sube escalera eléctrica', NULL, 4),
('mensual', 'equipos_traslado', 'Sistema de rampa para acceso', 1, 5),
('mensual', 'equipos_traslado', 'Sistema de sujeción silla de ruedas', NULL, 6),
('mensual', 'equipos_traslado', 'Cortacinturones', NULL, 7);

-- 1.2 EQUIPO VENTILACIÓN (11 items)
INSERT INTO plantilla_checklist_vehiculo (tipo_checklist, categoria, item_nombre, cantidad_requerida, orden) VALUES
('mensual', 'equipo_ventilacion', 'Oxígeno fijo - 2 botellas con caudalímetro ≥15 L/min', NULL, 10),
('mensual', 'equipo_ventilacion', 'Oxígeno portátil - Mínimo 400L con caudalímetro ≥15 L/min', 1, 11),
('mensual', 'equipo_ventilacion', 'Resucitador con entrada oxígeno, mascarillas y bolsa reservorio', NULL, 12),
('mensual', 'equipo_ventilacion', 'Ventilador con acoplamiento boca-máscara', 1, 13),
('mensual', 'equipo_ventilacion', 'Aspirador de secreciones portátil', 1, 14),
('mensual', 'equipo_ventilacion', 'Mascarilla Venturi adulto', NULL, 15),
('mensual', 'equipo_ventilacion', 'Mascarilla Venturi pediátrica', NULL, 16),
('mensual', 'equipo_ventilacion', 'Mascarilla Alto flujo adulto', NULL, 17),
('mensual', 'equipo_ventilacion', 'Mascarilla Alto flujo pediátrica', NULL, 18),
('mensual', 'equipo_ventilacion', 'Juego sondas aspiración', NULL, 19),
('mensual', 'equipo_ventilacion', 'Juego de guedells', NULL, 20);

-- 1.3 EQUIPO DIAGNÓSTICO (1 item)
INSERT INTO plantilla_checklist_vehiculo (tipo_checklist, categoria, item_nombre, cantidad_requerida, orden) VALUES
('mensual', 'equipo_diagnostico', 'Oxímetro con 2 Pilas AAA', NULL, 30);

-- 1.4 EQUIPO INFUSIÓN (1 item)
INSERT INTO plantilla_checklist_vehiculo (tipo_checklist, categoria, item_nombre, cantidad_requerida, orden) VALUES
('mensual', 'equipo_infusion', 'Dispositivo suspensión soluciones perfusión intravenosa', 2, 40);

-- 1.5 EQUIPO GESTIÓN EMERGENCIAS (3 items)
INSERT INTO plantilla_checklist_vehiculo (tipo_checklist, categoria, item_nombre, cantidad_requerida, orden) VALUES
('mensual', 'equipo_emergencia', 'Desfibrilador DESA', 1, 50),
('mensual', 'equipo_emergencia', 'Tijera cortar ropa', 1, 51),
('mensual', 'equipo_emergencia', 'Rasuradora', 1, 52);

-- 1.6 VENDAJES Y ASISTENCIA SANITARIA (15 items)
INSERT INTO plantilla_checklist_vehiculo (tipo_checklist, categoria, item_nombre, cantidad_requerida, orden) VALUES
('mensual', 'vendajes_asistencia', 'Equipo de cama', 2, 60),
('mensual', 'vendajes_asistencia', 'Batea vomitoria', 2, 61),
('mensual', 'vendajes_asistencia', 'Mantas', 4, 62),
('mensual', 'vendajes_asistencia', 'Material tratamientos de heridas', NULL, 63),
('mensual', 'vendajes_asistencia', 'Alcohol, Betadine, suero fisiológico', 1, 64),
('mensual', 'vendajes_asistencia', 'Bolsa vomitoria', 1, 65),
('mensual', 'vendajes_asistencia', 'Cuña', 1, 66),
('mensual', 'vendajes_asistencia', 'Botella urinaria no vidrio', 1, 67),
('mensual', 'vendajes_asistencia', 'Recipiente porta objetos punzocortantes', 1, 68),
('mensual', 'vendajes_asistencia', 'Guantes quirúrgicos estériles (2 und talla)', NULL, 69),
('mensual', 'vendajes_asistencia', 'Guantes no estériles', 100, 70),
('mensual', 'vendajes_asistencia', 'Kit asistencia al parto', 1, 71),
('mensual', 'vendajes_asistencia', 'Bolsas de residuos clínicos', 1, 72),
('mensual', 'vendajes_asistencia', 'Sábanas sin tejer de la camilla', 1, 73),
('mensual', 'vendajes_asistencia', 'Juego suministros emergencias (hemostáticos, torniquetes, agujas, apósitos, parches)', NULL, 74);

-- 2. DOCUMENTACIÓN OBLIGATORIA (9 items)
INSERT INTO plantilla_checklist_vehiculo (tipo_checklist, categoria, item_nombre, cantidad_requerida, orden) VALUES
('mensual', 'documentacion', 'Certificado conformidad fabricante (EN 1789:2021)', NULL, 80),
('mensual', 'documentacion', 'Registro de desinfecciones periódicas', NULL, 81),
('mensual', 'documentacion', 'Hojas quejas y reclamaciones', NULL, 82),
('mensual', 'documentacion', 'Hoja revisión de extintor', NULL, 83),
('mensual', 'documentacion', 'Ficha técnica, permiso circulación, póliza seguro', NULL, 84),
('mensual', 'documentacion', 'Certificado sanitario ITS', NULL, 85),
('mensual', 'documentacion', 'Certificado desinfección de ambulancia', NULL, 86),
('mensual', 'documentacion', 'Certificado norma UNE', NULL, 87),
('mensual', 'documentacion', 'Certificado NICA autorización centro sanitario', NULL, 88);

-- ============================================================================
-- 5. VISTA: v_caducidades_vehiculo_alertas
-- ============================================================================
CREATE OR REPLACE VIEW v_caducidades_vehiculo_alertas AS
SELECT
  sv.id,
  sv.vehiculo_id,
  v.matricula,
  sv.producto_id,
  p.nombre as producto_nombre,
  p.nombre_comercial,
  sv.cantidad_actual,
  sv.fecha_caducidad,
  sv.lote,
  sv.ubicacion,
  p.categoria,
  CASE
    WHEN sv.fecha_caducidad < CURRENT_DATE THEN 'caducado'
    WHEN sv.fecha_caducidad <= CURRENT_DATE + INTERVAL '7 days' THEN 'critico'
    WHEN sv.fecha_caducidad <= CURRENT_DATE + INTERVAL '30 days' THEN 'proximo'
    ELSE 'ok'
  END as estado_caducidad,
  EXTRACT(DAY FROM (sv.fecha_caducidad - CURRENT_DATE))::INT as dias_restantes
FROM stock_vehiculo sv
JOIN vehiculos v ON v.id = sv.vehiculo_id
JOIN productos p ON p.id = sv.producto_id
WHERE sv.fecha_caducidad IS NOT NULL
  AND p.tiene_caducidad = true
ORDER BY sv.fecha_caducidad ASC;

COMMENT ON VIEW v_caducidades_vehiculo_alertas IS 'Vista de caducidades de productos en vehículos con alertas automáticas';

-- ============================================================================
-- 6. TRIGGER: Actualizar contadores de checklist
-- ============================================================================
CREATE OR REPLACE FUNCTION actualizar_contadores_checklist()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE checklists_vehiculo
  SET
    items_presentes = (
      SELECT COUNT(*) FROM items_checklist_vehiculo
      WHERE checklist_id = NEW.checklist_id AND resultado = 'presente'
    ),
    items_ausentes = (
      SELECT COUNT(*) FROM items_checklist_vehiculo
      WHERE checklist_id = NEW.checklist_id AND resultado = 'ausente'
    ),
    checklist_completo = (
      SELECT COUNT(*) FROM items_checklist_vehiculo
      WHERE checklist_id = NEW.checklist_id AND resultado = 'ausente'
    ) = 0
  WHERE id = NEW.checklist_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_actualizar_contadores ON items_checklist_vehiculo;
CREATE TRIGGER trigger_actualizar_contadores
AFTER INSERT OR UPDATE ON items_checklist_vehiculo
FOR EACH ROW
EXECUTE FUNCTION actualizar_contadores_checklist();

COMMENT ON FUNCTION actualizar_contadores_checklist() IS 'Actualiza automáticamente contadores de items presentes/ausentes en checklist';

-- ============================================================================
-- FIN DEL SCHEMA
-- ============================================================================
