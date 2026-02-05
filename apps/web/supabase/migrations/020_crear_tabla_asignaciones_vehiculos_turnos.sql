-- =====================================================
-- AMBUTRACK - MIGRACIÓN: Tabla de Asignaciones Vehículos-Turnos
-- Archivo: 020_crear_tabla_asignaciones_vehiculos_turnos.sql
-- Descripción: Creación de tabla para asignaciones de vehículos a turnos/dotaciones
-- Fecha: 2025-12-22
-- =====================================================

-- =====================================================
-- TABLA: asignaciones_vehiculos_turnos
-- =====================================================
CREATE TABLE IF NOT EXISTS public.asignaciones_vehiculos_turnos (
    -- IDENTIFICACIÓN
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- FECHA DE LA ASIGNACIÓN
    fecha DATE NOT NULL,

    -- RELACIONES
    vehiculo_id UUID NOT NULL,
    dotacion_id UUID NOT NULL,
    turno_id UUID NOT NULL,

    -- DESTINOS OPCIONALES
    hospital_id UUID,
    base_id UUID,

    -- ESTADO Y METADATA
    estado TEXT NOT NULL DEFAULT 'planificada' CHECK (estado IN ('planificada', 'activa', 'completada', 'cancelada')),
    observaciones TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    metadata JSONB,

    -- AUDITORÍA
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- CONSTRAINTS
    CONSTRAINT unique_vehiculo_fecha UNIQUE (vehiculo_id, fecha, turno_id)
);

-- =====================================================
-- ÍNDICES
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_asignaciones_fecha ON public.asignaciones_vehiculos_turnos(fecha);
CREATE INDEX IF NOT EXISTS idx_asignaciones_vehiculo ON public.asignaciones_vehiculos_turnos(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_asignaciones_dotacion ON public.asignaciones_vehiculos_turnos(dotacion_id);
CREATE INDEX IF NOT EXISTS idx_asignaciones_turno ON public.asignaciones_vehiculos_turnos(turno_id);
CREATE INDEX IF NOT EXISTS idx_asignaciones_hospital ON public.asignaciones_vehiculos_turnos(hospital_id);
CREATE INDEX IF NOT EXISTS idx_asignaciones_base ON public.asignaciones_vehiculos_turnos(base_id);
CREATE INDEX IF NOT EXISTS idx_asignaciones_estado ON public.asignaciones_vehiculos_turnos(estado);
CREATE INDEX IF NOT EXISTS idx_asignaciones_activo ON public.asignaciones_vehiculos_turnos(activo);

-- =====================================================
-- TRIGGER: updated_at automático
-- =====================================================
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_asignaciones_vehiculos_turnos_updated_at
    BEFORE UPDATE ON public.asignaciones_vehiculos_turnos
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================
-- RLS (Row Level Security)
-- =====================================================
ALTER TABLE public.asignaciones_vehiculos_turnos ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios autenticados pueden leer todas las asignaciones
CREATE POLICY "Usuarios autenticados pueden leer asignaciones"
    ON public.asignaciones_vehiculos_turnos
    FOR SELECT
    TO authenticated
    USING (true);

-- Política: Los usuarios autenticados pueden crear asignaciones
CREATE POLICY "Usuarios autenticados pueden crear asignaciones"
    ON public.asignaciones_vehiculos_turnos
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Política: Los usuarios autenticados pueden actualizar asignaciones
CREATE POLICY "Usuarios autenticados pueden actualizar asignaciones"
    ON public.asignaciones_vehiculos_turnos
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Política: Los usuarios autenticados pueden eliminar asignaciones
CREATE POLICY "Usuarios autenticados pueden eliminar asignaciones"
    ON public.asignaciones_vehiculos_turnos
    FOR DELETE
    TO authenticated
    USING (true);

-- =====================================================
-- COMENTARIOS
-- =====================================================
COMMENT ON TABLE public.asignaciones_vehiculos_turnos IS 'Asignaciones de vehículos a turnos/dotaciones específicas';
COMMENT ON COLUMN public.asignaciones_vehiculos_turnos.id IS 'Identificador único de la asignación';
COMMENT ON COLUMN public.asignaciones_vehiculos_turnos.fecha IS 'Fecha de la asignación';
COMMENT ON COLUMN public.asignaciones_vehiculos_turnos.vehiculo_id IS 'ID del vehículo asignado';
COMMENT ON COLUMN public.asignaciones_vehiculos_turnos.dotacion_id IS 'ID de la dotación';
COMMENT ON COLUMN public.asignaciones_vehiculos_turnos.turno_id IS 'ID del turno específico';
COMMENT ON COLUMN public.asignaciones_vehiculos_turnos.hospital_id IS 'ID del hospital de destino (opcional)';
COMMENT ON COLUMN public.asignaciones_vehiculos_turnos.base_id IS 'ID de la base de origen (opcional)';
COMMENT ON COLUMN public.asignaciones_vehiculos_turnos.estado IS 'Estado de la asignación: planificada, activa, completada, cancelada';
COMMENT ON COLUMN public.asignaciones_vehiculos_turnos.observaciones IS 'Observaciones o notas adicionales';
COMMENT ON COLUMN public.asignaciones_vehiculos_turnos.activo IS 'Indica si la asignación está activa';
COMMENT ON COLUMN public.asignaciones_vehiculos_turnos.metadata IS 'Información adicional en formato JSON';
COMMENT ON COLUMN public.asignaciones_vehiculos_turnos.created_at IS 'Fecha de creación del registro';
COMMENT ON COLUMN public.asignaciones_vehiculos_turnos.updated_at IS 'Fecha de última actualización';
