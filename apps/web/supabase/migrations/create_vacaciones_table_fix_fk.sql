-- Corrección del Foreign Key en tabla vacaciones
-- La tabla de personal se llama 'tpersonal' no 'personal'

-- 1. Eliminar el constraint incorrecto
ALTER TABLE public.vacaciones
DROP CONSTRAINT IF EXISTS vacaciones_id_personal_fkey;

-- 2. Eliminar el constraint para aprobado_por si existe
ALTER TABLE public.vacaciones
DROP CONSTRAINT IF EXISTS vacaciones_aprobado_por_fkey;

-- 3. Crear el nuevo constraint apuntando a tpersonal
ALTER TABLE public.vacaciones
ADD CONSTRAINT vacaciones_id_personal_fkey
FOREIGN KEY (id_personal)
REFERENCES public.tpersonal(id)
ON DELETE CASCADE;

-- 4. Crear el constraint para aprobado_por apuntando a tpersonal
ALTER TABLE public.vacaciones
ADD CONSTRAINT vacaciones_aprobado_por_fkey
FOREIGN KEY (aprobado_por)
REFERENCES public.tpersonal(id)
ON DELETE SET NULL;

-- Comentario de la corrección
COMMENT ON CONSTRAINT vacaciones_id_personal_fkey ON public.vacaciones IS 'Referencia corregida a la tabla tpersonal';
COMMENT ON CONSTRAINT vacaciones_aprobado_por_fkey ON public.vacaciones IS 'Referencia corregida a la tabla tpersonal para aprobador';
