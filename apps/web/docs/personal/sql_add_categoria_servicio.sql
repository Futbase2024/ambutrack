-- ============================================
-- Agregar campo 'categoria_servicio' a tabla 'personal'
-- ============================================
-- Este campo indica si el personal trabaja en:
-- - 'urgencias': Servicios de urgencia/emergencia
-- - 'programado': Servicios programados
-- ============================================

-- Agregar columna con valor por defecto 'programado'
ALTER TABLE public.personal
ADD COLUMN IF NOT EXISTS categoria_servicio TEXT NOT NULL DEFAULT 'programado'
CHECK (categoria_servicio IN ('urgencias', 'programado'));

-- Crear índice para filtrar por categoría de servicio
CREATE INDEX IF NOT EXISTS idx_personal_categoria_servicio
ON public.personal(categoria_servicio);

-- Comentario sobre la columna
COMMENT ON COLUMN public.personal.categoria_servicio IS
'Categoría de servicio del personal: urgencias o programado';

-- ============================================
-- Actualizar personal existente (OPCIONAL)
-- ============================================
-- Si quieres asignar categorías a personal existente,
-- descomenta y ajusta estas queries:

/*
-- Ejemplo: Asignar 'urgencias' a personal con cierto puesto
UPDATE public.personal
SET categoria_servicio = 'urgencias'
WHERE puesto_trabajo_id IN (
  SELECT id FROM public.tpuestos
  WHERE nombre ILIKE '%medico%' OR nombre ILIKE '%enfermero%'
);

-- Ejemplo: Asignar 'programado' a conductores
UPDATE public.personal
SET categoria_servicio = 'programado'
WHERE puesto_trabajo_id IN (
  SELECT id FROM public.tpuestos
  WHERE nombre ILIKE '%conductor%'
);
*/

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
