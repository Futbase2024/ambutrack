-- =====================================================
-- MIGRACIÓN: Agregar provincia_id y localidad_id a pacientes
-- Descripción: Añade columnas para vincular pacientes con provincias y localidades
-- Fecha: 2025-01-30
-- =====================================================

-- Agregar columna provincia_id
ALTER TABLE public.pacientes
ADD COLUMN IF NOT EXISTS provincia_id UUID REFERENCES public.tprovincias(id) ON DELETE SET NULL;

-- Agregar columna localidad_id
ALTER TABLE public.pacientes
ADD COLUMN IF NOT EXISTS localidad_id UUID REFERENCES public.tpoblaciones(id) ON DELETE SET NULL;

-- Crear índices para mejorar el rendimiento de consultas
CREATE INDEX IF NOT EXISTS idx_pacientes_provincia ON public.pacientes(provincia_id);
CREATE INDEX IF NOT EXISTS idx_pacientes_localidad ON public.pacientes(localidad_id);

-- Comentarios
COMMENT ON COLUMN public.pacientes.provincia_id IS 'Provincia del domicilio del paciente (FK a tprovincias)';
COMMENT ON COLUMN public.pacientes.localidad_id IS 'Localidad del domicilio del paciente (FK a tpoblaciones)';
