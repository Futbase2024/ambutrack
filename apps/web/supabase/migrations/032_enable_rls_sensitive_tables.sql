-- =============================================
-- SEGURIDAD: activar RLS en tablas expuestas sin protección
-- Antes: cualquiera con la anon key podía leer/escribir estas tablas vía API.
-- Después: solo usuarios autenticados (mismo comportamiento para la app,
-- que siempre consulta con sesión iniciada). cron/triggers (owner postgres) no se ven afectados.
-- =============================================

-- 1. tpersonal: ya tenía políticas pero RLS desactivado.
--    Se elimina la lectura anónima (el login por DNI usa get_email_by_dni, SECURITY DEFINER sobre usuarios).
DROP POLICY IF EXISTS anon_select_tpersonal ON public.tpersonal;
ALTER TABLE public.tpersonal ENABLE ROW LEVEL SECURITY;

-- 2. Tablas usadas por la app con sesión: acceso completo para authenticated
DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['formacion_personal', 'incidencias_vehiculos', 'certificaciones', 'cursos']
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', t || '_authenticated_all', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR ALL TO authenticated USING (true) WITH CHECK (true)',
      t || '_authenticated_all', t);
  END LOOP;
END $$;

-- 3. cron_job_logs: logs internos (escribe pg_cron como postgres). Solo lectura para admin.
ALTER TABLE public.cron_job_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS cron_job_logs_select_admin ON public.cron_job_logs;
CREATE POLICY cron_job_logs_select_admin ON public.cron_job_logs
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.usuarios u WHERE u.id = auth.uid() AND u.rol = 'admin'));

-- 4. Vistas: respetar la RLS de quien consulta (antes SECURITY DEFINER filtraba datos a cualquier rol,
--    p.ej. un conductor veía todos los traslados con datos de pacientes en v_traslados_completos)
ALTER VIEW public.vw_alertas_caducidad_activas SET (security_invoker = true);
ALTER VIEW public.v_caducidades_vehiculo_alertas SET (security_invoker = true);
ALTER VIEW public.v_traslados_completos SET (security_invoker = true);
ALTER VIEW public.v_cron_job_recent_runs SET (security_invoker = true);
