-- Migración: Sistema Híbrido de Cuadrantes
-- Fecha: 2024-12-22
-- Descripción: Tabla unificada que reemplaza turnos + asignaciones_vehiculos_turnos

-- Crear tabla cuadrante_asignaciones
CREATE TABLE IF NOT EXISTS cuadrante_asignaciones (
  -- Identificación
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Fecha y horarios
  fecha DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME NOT NULL,
  cruza_medianoche BOOLEAN DEFAULT FALSE,

  -- Personal (obligatorio)
  id_personal UUID NOT NULL REFERENCES personal(id) ON DELETE RESTRICT,
  nombre_personal VARCHAR(255) NOT NULL,
  categoria_personal VARCHAR(100),

  -- Tipo de turno
  tipo_turno VARCHAR(50) NOT NULL DEFAULT 'personalizado',
  plantilla_turno_id UUID,

  -- Vehículo (opcional, depende de categoría)
  id_vehiculo UUID REFERENCES tvehiculos(id) ON DELETE SET NULL,
  matricula_vehiculo VARCHAR(20),

  -- Dotación/Contrato (obligatorio)
  id_dotacion UUID NOT NULL REFERENCES dotaciones(id) ON DELETE RESTRICT,
  nombre_dotacion VARCHAR(255) NOT NULL,
  numero_unidad INT NOT NULL DEFAULT 1,

  -- Destino (opcional)
  id_hospital UUID REFERENCES tcentros_hospitalarios(id) ON DELETE SET NULL,
  id_base UUID REFERENCES bases(id) ON DELETE SET NULL,

  -- Estado y seguimiento
  estado VARCHAR(50) DEFAULT 'planificada',
  confirmada_por UUID,
  fecha_confirmacion TIMESTAMP,

  -- Métricas operacionales
  km_inicial DECIMAL(10, 2),
  km_final DECIMAL(10, 2),
  servicios_realizados INT DEFAULT 0,
  horas_efectivas DECIMAL(5, 2),

  -- Observaciones
  observaciones TEXT,

  -- Metadata
  metadata JSONB,

  -- Auditoría
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by UUID,
  updated_by UUID,

  -- Constraints
  CONSTRAINT check_horas_validas
    CHECK (hora_inicio != hora_fin OR cruza_medianoche = TRUE),

  CONSTRAINT check_destino_unico
    CHECK (
      (id_hospital IS NULL AND id_base IS NULL) OR
      (id_hospital IS NOT NULL AND id_base IS NULL) OR
      (id_hospital IS NULL AND id_base IS NOT NULL)
    ),

  CONSTRAINT check_tipo_turno_valido
    CHECK (tipo_turno IN ('manana', 'tarde', 'noche', 'personalizado')),

  CONSTRAINT check_estado_valido
    CHECK (estado IN ('planificada', 'confirmada', 'activa', 'completada', 'cancelada')),

  CONSTRAINT check_numero_unidad_positivo
    CHECK (numero_unidad > 0)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_cuadrante_fecha ON cuadrante_asignaciones(fecha);
CREATE INDEX IF NOT EXISTS idx_cuadrante_personal ON cuadrante_asignaciones(id_personal);
CREATE INDEX IF NOT EXISTS idx_cuadrante_vehiculo ON cuadrante_asignaciones(id_vehiculo);
CREATE INDEX IF NOT EXISTS idx_cuadrante_dotacion ON cuadrante_asignaciones(id_dotacion);
CREATE INDEX IF NOT EXISTS idx_cuadrante_estado ON cuadrante_asignaciones(estado);
CREATE INDEX IF NOT EXISTS idx_cuadrante_fecha_personal ON cuadrante_asignaciones(fecha, id_personal);
CREATE INDEX IF NOT EXISTS idx_cuadrante_fecha_vehiculo ON cuadrante_asignaciones(fecha, id_vehiculo);
CREATE INDEX IF NOT EXISTS idx_cuadrante_fecha_dotacion ON cuadrante_asignaciones(fecha, id_dotacion);
CREATE INDEX IF NOT EXISTS idx_cuadrante_activo ON cuadrante_asignaciones(activo) WHERE activo = TRUE;

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_cuadrante_asignaciones_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_cuadrante_asignaciones_updated_at
  BEFORE UPDATE ON cuadrante_asignaciones
  FOR EACH ROW
  EXECUTE FUNCTION update_cuadrante_asignaciones_updated_at();

-- Comentarios descriptivos
COMMENT ON TABLE cuadrante_asignaciones IS 'Tabla unificada de cuadrantes: personal + vehículos + dotaciones';
COMMENT ON COLUMN cuadrante_asignaciones.fecha IS 'Fecha del día de la asignación';
COMMENT ON COLUMN cuadrante_asignaciones.hora_inicio IS 'Hora de inicio del turno (HH:mm)';
COMMENT ON COLUMN cuadrante_asignaciones.hora_fin IS 'Hora de fin del turno (HH:mm)';
COMMENT ON COLUMN cuadrante_asignaciones.cruza_medianoche IS 'Indica si el turno termina al día siguiente';
COMMENT ON COLUMN cuadrante_asignaciones.numero_unidad IS 'Número de unidad dentro de la dotación (1, 2, 3...)';
COMMENT ON COLUMN cuadrante_asignaciones.estado IS 'Estado: planificada, confirmada, activa, completada, cancelada';

-- RLS (Row Level Security) - Habilitar
ALTER TABLE cuadrante_asignaciones ENABLE ROW LEVEL SECURITY;

-- Política: Usuarios autenticados pueden ver todas las asignaciones activas
CREATE POLICY "Usuarios autenticados pueden ver asignaciones activas"
  ON cuadrante_asignaciones
  FOR SELECT
  USING (auth.role() = 'authenticated' AND activo = TRUE);

-- Política: Usuarios autenticados pueden insertar asignaciones
CREATE POLICY "Usuarios autenticados pueden crear asignaciones"
  ON cuadrante_asignaciones
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Política: Usuarios autenticados pueden actualizar asignaciones activas
CREATE POLICY "Usuarios autenticados pueden actualizar asignaciones"
  ON cuadrante_asignaciones
  FOR UPDATE
  USING (auth.role() = 'authenticated' AND activo = TRUE)
  WITH CHECK (auth.role() = 'authenticated');

-- Política: Solo usuarios autenticados pueden soft-delete (marcar como inactivo)
CREATE POLICY "Usuarios autenticados pueden soft-delete asignaciones"
  ON cuadrante_asignaciones
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');
