-- =====================================================
-- MIGRACIÓN: Agregar recogida_festivos a pacientes
-- Descripción: Añade columna faltante para indicar si el paciente tiene recogida en festivos
-- Fecha: 2025-01-30
-- =====================================================

-- Agregar columna recogida_festivos
ALTER TABLE public.pacientes
ADD COLUMN IF NOT EXISTS recogida_festivos BOOLEAN DEFAULT FALSE;

-- Comentario
COMMENT ON COLUMN public.pacientes.recogida_festivos IS 'Indica si el paciente tiene recogida en días festivos';
