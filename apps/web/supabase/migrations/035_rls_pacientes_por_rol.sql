-- =============================================
-- SEGURIDAD A1: pacientes (dato de salud, RGPD art. 9)
-- Regla de negocio:
--   - Ven y gestionan todos los pacientes: admin, jefe_trafico, coordinador,
--     administrativo (alta/edición desde la central).
--   - operador: solo lectura de todos.
--   - Borrar: solo admin y jefe_trafico.
--   - Tripulación (conductor, sanitario…): solo lectura de los pacientes de
--     traslados en los que figura como conductor o en personal_asignado.
--   - Resto de roles (técnico, jefe_mantenimiento, jefe_personal…): sin acceso.
-- Depende de fn_rol_actual() y fn_mi_personal_id() (migración 034).
-- =============================================

-- 1. Funciones auxiliares (SECURITY DEFINER: evitan recursión con RLS de traslados)
CREATE OR REPLACE FUNCTION public.fn_puede_ver_pacientes()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT coalesce(public.fn_rol_actual() IN (
    'admin', 'jefe_trafico', 'coordinador', 'administrativo', 'operador'), false)
$$;

CREATE OR REPLACE FUNCTION public.fn_puede_editar_pacientes()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT coalesce(public.fn_rol_actual() IN (
    'admin', 'jefe_trafico', 'coordinador', 'administrativo'), false)
$$;

CREATE OR REPLACE FUNCTION public.fn_puede_borrar_pacientes()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT coalesce(public.fn_rol_actual() IN ('admin', 'jefe_trafico'), false)
$$;

-- ¿El paciente está en algún traslado asignado al usuario actual?
-- Tripulación = id_conductor (tpersonal.id) o personal_asignado (uuid[] de tpersonal.id).
CREATE OR REPLACE FUNCTION public.fn_paciente_asignado_a_mi(p_paciente_id UUID)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1
      FROM public.traslados t
     WHERE t.id_paciente = p_paciente_id
       AND (
         t.id_conductor = public.fn_mi_personal_id()
         OR public.fn_mi_personal_id() = ANY (t.personal_asignado)
       )
  )
$$;

REVOKE EXECUTE ON FUNCTION public.fn_puede_ver_pacientes(), public.fn_puede_editar_pacientes(),
  public.fn_puede_borrar_pacientes(), public.fn_paciente_asignado_a_mi(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_puede_ver_pacientes(), public.fn_puede_editar_pacientes(),
  public.fn_puede_borrar_pacientes(), public.fn_paciente_asignado_a_mi(UUID)
  TO authenticated, service_role;

-- 2. Índices para que la comprobación por traslado sea rápida
CREATE INDEX IF NOT EXISTS idx_traslados_id_paciente ON public.traslados(id_paciente);

-- 3. Borrar todas las políticas existentes de pacientes ("authenticated USING (true)")
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT p.polname
      FROM pg_policy p JOIN pg_class c ON c.oid = p.polrelid
     WHERE c.relnamespace = 'public'::regnamespace AND c.relname = 'pacientes'
  LOOP
    EXECUTE format('DROP POLICY %I ON public.pacientes', r.polname);
  END LOOP;
END $$;

-- 4. Políticas nuevas
ALTER TABLE public.pacientes ENABLE ROW LEVEL SECURITY;

CREATE POLICY pacientes_select ON public.pacientes FOR SELECT TO authenticated
  USING (public.fn_puede_ver_pacientes() OR public.fn_paciente_asignado_a_mi(id));

CREATE POLICY pacientes_insert ON public.pacientes FOR INSERT TO authenticated
  WITH CHECK (public.fn_puede_editar_pacientes());

CREATE POLICY pacientes_update ON public.pacientes FOR UPDATE TO authenticated
  USING (public.fn_puede_editar_pacientes()) WITH CHECK (public.fn_puede_editar_pacientes());

CREATE POLICY pacientes_delete ON public.pacientes FOR DELETE TO authenticated
  USING (public.fn_puede_borrar_pacientes());
