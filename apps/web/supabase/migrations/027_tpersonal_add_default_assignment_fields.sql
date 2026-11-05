-- Add optional default assignment fields to tpersonal
-- These fields store the person's default assignment for shift (turno) creation
-- When creating a turno, the system can pre-fill from these defaults

ALTER TABLE tpersonal
  ADD COLUMN contrato_asignado_id UUID REFERENCES contratos(id) ON DELETE SET NULL,
  ADD COLUMN base_id UUID REFERENCES bases(id) ON DELETE SET NULL,
  ADD COLUMN dotacion_id UUID REFERENCES dotaciones(id) ON DELETE SET NULL,
  ADD COLUMN vehiculo_id UUID REFERENCES tvehiculos(id) ON DELETE SET NULL;

COMMENT ON COLUMN tpersonal.contrato_asignado_id IS 'FK contratos - contrato hospital/cliente por defecto para turnos';
COMMENT ON COLUMN tpersonal.base_id IS 'FK bases - base por defecto para turnos';
COMMENT ON COLUMN tpersonal.dotacion_id IS 'FK dotaciones - dotacion por defecto para turnos';
COMMENT ON COLUMN tpersonal.vehiculo_id IS 'FK tvehiculos - vehiculo por defecto para turnos';
