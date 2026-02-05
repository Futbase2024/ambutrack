-- Crear tabla vacaciones
CREATE TABLE IF NOT EXISTS public.vacaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_personal UUID NOT NULL REFERENCES public.personal(id) ON DELETE CASCADE,
    fecha_inicio TIMESTAMPTZ NOT NULL,
    fecha_fin TIMESTAMPTZ NOT NULL,
    dias_solicitados INTEGER NOT NULL CHECK (dias_solicitados > 0),
    estado TEXT NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'aprobada', 'rechazada', 'cancelada')),
    observaciones TEXT,
    fecha_solicitud TIMESTAMPTZ DEFAULT NOW(),
    aprobado_por UUID REFERENCES public.personal(id) ON DELETE SET NULL,
    fecha_aprobacion TIMESTAMPTZ,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_vacaciones_id_personal ON public.vacaciones(id_personal);
CREATE INDEX IF NOT EXISTS idx_vacaciones_estado ON public.vacaciones(estado);
CREATE INDEX IF NOT EXISTS idx_vacaciones_fecha_inicio ON public.vacaciones(fecha_inicio);
CREATE INDEX IF NOT EXISTS idx_vacaciones_fecha_fin ON public.vacaciones(fecha_fin);
CREATE INDEX IF NOT EXISTS idx_vacaciones_activo ON public.vacaciones(activo);

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.update_vacaciones_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_vacaciones_updated_at
    BEFORE UPDATE ON public.vacaciones
    FOR EACH ROW
    EXECUTE FUNCTION public.update_vacaciones_updated_at();

-- RLS (Row Level Security) Policies
ALTER TABLE public.vacaciones ENABLE ROW LEVEL SECURITY;

-- Policy: Permitir lectura a usuarios autenticados
CREATE POLICY "Permitir lectura de vacaciones a usuarios autenticados"
    ON public.vacaciones
    FOR SELECT
    TO authenticated
    USING (true);

-- Policy: Permitir inserción a usuarios autenticados
CREATE POLICY "Permitir inserción de vacaciones a usuarios autenticados"
    ON public.vacaciones
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Policy: Permitir actualización a usuarios autenticados
CREATE POLICY "Permitir actualización de vacaciones a usuarios autenticados"
    ON public.vacaciones
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Policy: Permitir eliminación a usuarios autenticados
CREATE POLICY "Permitir eliminación de vacaciones a usuarios autenticados"
    ON public.vacaciones
    FOR DELETE
    TO authenticated
    USING (true);

-- Comentarios de la tabla y columnas
COMMENT ON TABLE public.vacaciones IS 'Gestión de vacaciones anuales del personal';
COMMENT ON COLUMN public.vacaciones.id IS 'Identificador único de la vacación';
COMMENT ON COLUMN public.vacaciones.id_personal IS 'Referencia al personal que solicita las vacaciones';
COMMENT ON COLUMN public.vacaciones.fecha_inicio IS 'Fecha de inicio de las vacaciones';
COMMENT ON COLUMN public.vacaciones.fecha_fin IS 'Fecha de fin de las vacaciones';
COMMENT ON COLUMN public.vacaciones.dias_solicitados IS 'Número de días solicitados';
COMMENT ON COLUMN public.vacaciones.estado IS 'Estado de la solicitud: pendiente, aprobada, rechazada, cancelada';
COMMENT ON COLUMN public.vacaciones.observaciones IS 'Observaciones o comentarios sobre las vacaciones';
COMMENT ON COLUMN public.vacaciones.fecha_solicitud IS 'Fecha en que se realizó la solicitud';
COMMENT ON COLUMN public.vacaciones.aprobado_por IS 'Referencia al personal que aprobó/rechazó la solicitud';
COMMENT ON COLUMN public.vacaciones.fecha_aprobacion IS 'Fecha de aprobación o rechazo';
COMMENT ON COLUMN public.vacaciones.activo IS 'Indica si el registro está activo';
COMMENT ON COLUMN public.vacaciones.created_at IS 'Fecha de creación del registro';
COMMENT ON COLUMN public.vacaciones.updated_at IS 'Fecha de última actualización del registro';
