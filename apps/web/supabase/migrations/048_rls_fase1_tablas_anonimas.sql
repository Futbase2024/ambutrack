-- =============================================
-- SEGURIDAD A2 · Fase 1: tablas escribibles sin iniciar sesión (rol public/anon)
--   incidencias, ttalleres, tproveedores_taller → reglas por rol (solo authenticated)
--   tnotificaciones INSERT → solo authenticated
-- Depende de fn_rol_actual() (migración 034).
-- =============================================

-- Helper genérico: ¿el rol del usuario actual está en la lista?
CREATE OR REPLACE FUNCTION public.fn_rol_en(p_roles TEXT[])
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT coalesce(public.fn_rol_actual() = ANY (p_roles), false)
$$;
REVOKE EXECUTE ON FUNCTION public.fn_rol_en(TEXT[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_rol_en(TEXT[]) TO authenticated, service_role;

-- Borrar políticas existentes de las 3 tablas
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT p.polname, c.relname
      FROM pg_policy p JOIN pg_class c ON c.oid = p.polrelid
     WHERE c.relnamespace = 'public'::regnamespace
       AND c.relname IN ('incidencias', 'ttalleres', 'tproveedores_taller')
  LOOP
    EXECUTE format('DROP POLICY %I ON public.%I', r.polname, r.relname);
  END LOOP;
END $$;

-- incidencias (módulo Incidencias de la web; la app móvil no la usa)
ALTER TABLE public.incidencias ENABLE ROW LEVEL SECURITY;
CREATE POLICY incidencias_select ON public.incidencias FOR SELECT TO authenticated
  USING (public.fn_rol_en(ARRAY['admin','jefe_personal','jefe_trafico','coordinador','administrativo']));
CREATE POLICY incidencias_insert ON public.incidencias FOR INSERT TO authenticated
  WITH CHECK (public.fn_rol_en(ARRAY['admin','jefe_personal','jefe_trafico','coordinador','administrativo']));
CREATE POLICY incidencias_update ON public.incidencias FOR UPDATE TO authenticated
  USING (public.fn_rol_en(ARRAY['admin','jefe_personal','jefe_trafico','coordinador','administrativo']))
  WITH CHECK (public.fn_rol_en(ARRAY['admin','jefe_personal','jefe_trafico','coordinador','administrativo']));
CREATE POLICY incidencias_delete ON public.incidencias FOR DELETE TO authenticated
  USING (public.fn_rol_en(ARRAY['admin','jefe_personal','jefe_trafico']));

-- Catálogos de taller (lectura para cualquier usuario con sesión; gestión: Flota/Taller)
DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['ttalleres', 'tproveedores_taller'] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR SELECT TO authenticated USING (true)', t || '_select', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR INSERT TO authenticated '
      'WITH CHECK (public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''jefe_mantenimiento'',''tecnico'']))',
      t || '_insert', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR UPDATE TO authenticated '
      'USING (public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''jefe_mantenimiento'',''tecnico''])) '
      'WITH CHECK (public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''jefe_mantenimiento'',''tecnico'']))',
      t || '_update', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR DELETE TO authenticated '
      'USING (public.fn_rol_en(ARRAY[''admin'',''jefe_mantenimiento'']))',
      t || '_delete', t);
  END LOOP;
END $$;

-- tnotificaciones: la creación abierta pasa de public (incluye anon) a authenticated
DROP POLICY IF EXISTS insert_notifications ON public.tnotificaciones;
CREATE POLICY insert_notifications ON public.tnotificaciones FOR INSERT TO authenticated
  WITH CHECK (true);
