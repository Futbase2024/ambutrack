-- =============================================
-- SEGURIDAD: datos personales por rol (fuente de verdad: usuarios.rol)
-- Regla de negocio: un empleado (conductor, sanitario, técnico…) solo ve SUS datos.
--   - Ven a toda la plantilla: admin, jefe_personal, jefe_trafico, coordinador,
--     administrativo, operador, jefe_mantenimiento.
--   - Editan: admin, jefe_personal.
--   - Historial médico: solo admin, jefe_personal y el propio empleado.
--   - Solicitudes (ausencias/vacaciones): el empleado crea las suyas y solo puede
--     modificarlas/borrarlas mientras estén pendientes.
-- Sustituye las políticas anteriores (basadas en usuario_roles, incompleta, y
-- políticas "authenticated USING (true)" que dejaban todo abierto).
-- =============================================

-- 1. Funciones auxiliares (SECURITY DEFINER: evitan recursión de RLS)
CREATE OR REPLACE FUNCTION public.fn_rol_actual()
RETURNS TEXT LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT rol FROM public.usuarios WHERE id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.fn_mi_personal_id()
RETURNS UUID LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT id FROM public.tpersonal WHERE usuario_id = auth.uid() LIMIT 1
$$;

CREATE OR REPLACE FUNCTION public.fn_es_gestor_personal()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT coalesce(public.fn_rol_actual() IN ('admin', 'jefe_personal'), false)
$$;

CREATE OR REPLACE FUNCTION public.fn_puede_ver_personal()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT coalesce(public.fn_rol_actual() IN (
    'admin', 'jefe_personal', 'jefe_trafico', 'coordinador',
    'administrativo', 'operador', 'jefe_mantenimiento'), false)
$$;

REVOKE EXECUTE ON FUNCTION public.fn_rol_actual(), public.fn_mi_personal_id(),
  public.fn_es_gestor_personal(), public.fn_puede_ver_personal() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_rol_actual(), public.fn_mi_personal_id(),
  public.fn_es_gestor_personal(), public.fn_puede_ver_personal() TO authenticated, service_role;

-- 2. Borrar todas las políticas existentes de las tablas afectadas
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT p.polname, c.relname
      FROM pg_policy p JOIN pg_class c ON c.oid = p.polrelid
     WHERE c.relnamespace = 'public'::regnamespace
       AND c.relname IN ('tpersonal', 'historial_medico', 'ausencias', 'vacaciones',
                         'formacion_personal', 'vestuario', 'equipamiento_personal')
  LOOP
    EXECUTE format('DROP POLICY %I ON public.%I', r.polname, r.relname);
  END LOOP;
END $$;

-- 3. tpersonal
ALTER TABLE public.tpersonal ENABLE ROW LEVEL SECURITY;
CREATE POLICY tpersonal_select ON public.tpersonal FOR SELECT TO authenticated
  USING (usuario_id = auth.uid() OR public.fn_puede_ver_personal());
CREATE POLICY tpersonal_insert ON public.tpersonal FOR INSERT TO authenticated
  WITH CHECK (public.fn_es_gestor_personal());
CREATE POLICY tpersonal_update ON public.tpersonal FOR UPDATE TO authenticated
  USING (public.fn_es_gestor_personal()) WITH CHECK (public.fn_es_gestor_personal());
CREATE POLICY tpersonal_delete ON public.tpersonal FOR DELETE TO authenticated
  USING (public.fn_es_gestor_personal());

-- 4. historial_medico (dato de salud: solo gestores de personal y el propio empleado)
ALTER TABLE public.historial_medico ENABLE ROW LEVEL SECURITY;
CREATE POLICY historial_medico_select ON public.historial_medico FOR SELECT TO authenticated
  USING (personal_id::text = public.fn_mi_personal_id()::text OR public.fn_es_gestor_personal());
CREATE POLICY historial_medico_write ON public.historial_medico FOR ALL TO authenticated
  USING (public.fn_es_gestor_personal()) WITH CHECK (public.fn_es_gestor_personal());

-- 5. Datos de personal con lectura para mandos (personal_id → tpersonal)
DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['vestuario', 'equipamiento_personal'] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR SELECT TO authenticated '
      'USING (personal_id::text = public.fn_mi_personal_id()::text OR public.fn_puede_ver_personal())',
      t || '_select', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR ALL TO authenticated '
      'USING (public.fn_es_gestor_personal()) WITH CHECK (public.fn_es_gestor_personal())',
      t || '_write', t);
  END LOOP;
END $$;

-- formacion_personal.personal_id → usuarios.id
ALTER TABLE public.formacion_personal ENABLE ROW LEVEL SECURITY;
CREATE POLICY formacion_personal_select ON public.formacion_personal FOR SELECT TO authenticated
  USING (personal_id::text = auth.uid()::text OR public.fn_puede_ver_personal());
CREATE POLICY formacion_personal_write ON public.formacion_personal FOR ALL TO authenticated
  USING (public.fn_es_gestor_personal()) WITH CHECK (public.fn_es_gestor_personal());

-- 6. Solicitudes: ausencias y vacaciones (id_personal → tpersonal)
DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['ausencias', 'vacaciones'] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR SELECT TO authenticated '
      'USING (id_personal::text = public.fn_mi_personal_id()::text OR public.fn_puede_ver_personal())',
      t || '_select', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR INSERT TO authenticated '
      'WITH CHECK (public.fn_es_gestor_personal() '
      '  OR (id_personal::text = public.fn_mi_personal_id()::text AND lower(estado) = ''pendiente''))',
      t || '_insert', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR UPDATE TO authenticated '
      'USING (public.fn_es_gestor_personal() '
      '  OR (id_personal::text = public.fn_mi_personal_id()::text AND lower(estado) = ''pendiente'')) '
      'WITH CHECK (public.fn_es_gestor_personal() '
      '  OR (id_personal::text = public.fn_mi_personal_id()::text AND lower(estado) = ''pendiente''))',
      t || '_update', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR DELETE TO authenticated '
      'USING (public.fn_es_gestor_personal() '
      '  OR (id_personal::text = public.fn_mi_personal_id()::text AND lower(estado) = ''pendiente''))',
      t || '_delete', t);
  END LOOP;
END $$;
