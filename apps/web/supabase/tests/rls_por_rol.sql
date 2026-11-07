-- =============================================================================
-- Tests de seguridad (RLS) de AmbuTrack
--
-- Ejecutar contra la base de datos (no modifica nada: todo va en una
-- transacción que se deshace al final):
--   psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f apps/web/supabase/tests/rls_por_rol.sql
--
-- Si algún caso falla, termina con ERROR y la lista de fallos.
-- Los casos por rol usan un usuario real de cada rol (public.usuarios); si no
-- existe usuario para un rol, sus casos se omiten.
-- =============================================================================
BEGIN;

CREATE TEMP TABLE _resultado (caso TEXT, ok BOOLEAN, detalle TEXT) ON COMMIT DROP;

-- ---------------------------------------------------------------- helpers ----
CREATE FUNCTION pg_temp.check(p_caso TEXT, p_ok BOOLEAN, p_detalle TEXT DEFAULT '')
RETURNS VOID LANGUAGE sql AS $$
  INSERT INTO _resultado VALUES (p_caso, coalesce(p_ok, false), p_detalle)
$$;

CREATE FUNCTION pg_temp.usuario(p_rol TEXT) RETURNS UUID LANGUAGE sql AS $$
  SELECT id FROM public.usuarios WHERE rol = p_rol ORDER BY id LIMIT 1
$$;

-- Ejecuta una consulta COUNT(*) como el usuario indicado (NULL = anónimo)
CREATE FUNCTION pg_temp.ve(p_uid UUID, p_sql TEXT) RETURNS INT LANGUAGE plpgsql AS $$
DECLARE n INT;
BEGIN
  IF p_uid IS NULL THEN
    PERFORM set_config('request.jwt.claims', '{"role":"anon"}', true);
    SET LOCAL ROLE anon;
  ELSE
    PERFORM set_config('request.jwt.claims', json_build_object('sub', p_uid, 'role', 'authenticated')::text, true);
    SET LOCAL ROLE authenticated;
  END IF;
  BEGIN
    EXECUTE p_sql INTO n;
  EXCEPTION WHEN insufficient_privilege THEN n := 0;
  END;
  RESET ROLE;
  RETURN n;
END $$;

-- Ejecuta un UPDATE/INSERT/DELETE como el usuario y devuelve filas afectadas
-- (-1 si la base de datos lo rechaza). Los cambios se deshacen al final.
CREATE FUNCTION pg_temp.edita(p_uid UUID, p_sql TEXT) RETURNS INT LANGUAGE plpgsql AS $$
DECLARE n INT;
BEGIN
  IF p_uid IS NULL THEN
    PERFORM set_config('request.jwt.claims', '{"role":"anon"}', true);
    SET LOCAL ROLE anon;
  ELSE
    PERFORM set_config('request.jwt.claims', json_build_object('sub', p_uid, 'role', 'authenticated')::text, true);
    SET LOCAL ROLE authenticated;
  END IF;
  BEGIN
    EXECUTE p_sql;
    GET DIAGNOSTICS n = ROW_COUNT;
  EXCEPTION WHEN OTHERS THEN n := -1;
  END;
  RESET ROLE;
  RETURN n;
END $$;

CREATE FUNCTION pg_temp.total(p_tabla TEXT) RETURNS INT LANGUAGE plpgsql AS $$
DECLARE n INT;
BEGIN
  EXECUTE format('SELECT count(*) FROM public.%I', p_tabla) INTO n;
  RETURN n;
END $$;

-- ------------------------------------------------------- estructurales -------
DO $$
DECLARE r RECORD;
BEGIN
  -- 1. Todas las tablas de public tienen RLS activado
  FOR r IN
    SELECT c.relname FROM pg_class c
     WHERE c.relnamespace = 'public'::regnamespace AND c.relkind = 'r' AND NOT c.relrowsecurity
  LOOP
    PERFORM pg_temp.check('rls_activado:' || r.relname, false, 'tabla sin RLS');
  END LOOP;

  -- 2. Ninguna escritura abierta (true / auth.uid() IS NOT NULL / auth.role()='authenticated')
  --    salvo las intencionadas: reportar averías y crear notificaciones (solo con sesión)
  FOR r IN
    SELECT tablename, policyname, cmd, roles::text AS roles FROM pg_policies
     WHERE schemaname = 'public' AND cmd <> 'SELECT'
       AND lower(coalesce(qual, 'true')) ~ '^\(?\s*(true|auth\.uid\(\) is not null|auth\.role\(\) = ''authenticated''::text)\s*\)?$'
       AND lower(coalesce(with_check, 'true')) ~ '^\(?\s*(true|auth\.uid\(\) is not null|auth\.role\(\) = ''authenticated''::text)\s*\)?$'
       AND NOT (tablename = 'incidencias_vehiculos' AND cmd = 'INSERT' AND roles = '{authenticated}')
       AND NOT (tablename = 'tnotificaciones' AND cmd = 'INSERT' AND roles = '{authenticated}')
  LOOP
    PERFORM pg_temp.check('escritura_abierta:' || r.tablename, false, r.policyname || ' ' || r.cmd || ' ' || r.roles);
  END LOOP;

  -- 3. Ninguna política de escritura para anónimos
  FOR r IN
    SELECT tablename, policyname, cmd FROM pg_policies
     WHERE schemaname = 'public' AND cmd <> 'SELECT' AND 'anon' = ANY (roles)
  LOOP
    PERFORM pg_temp.check('escritura_anon:' || r.tablename, false, r.policyname || ' ' || r.cmd);
  END LOOP;

  -- 4. Funciones SECURITY DEFINER ejecutables sin sesión: solo el login por DNI
  FOR r IN
    SELECT p.proname FROM pg_proc p
     WHERE p.pronamespace = 'public'::regnamespace AND p.prosecdef
       AND has_function_privilege('anon', p.oid, 'EXECUTE')
       AND p.proname NOT IN ('get_email_by_dni')
       AND p.prorettype <> 'trigger'::regtype
  LOOP
    PERFORM pg_temp.check('definer_anon:' || r.proname, false, 'ejecutable sin sesión');
  END LOOP;

  PERFORM pg_temp.check('estructurales_ejecutados', true);
END $$;

-- ------------------------------------------------------------- anónimo -------
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['pacientes', 'traslados', 'tpersonal', 'historial_medico', 'incidencias', 'ttalleres',
                           'tvehiculos', 'stock', 'contratos', 'turnos', 'audit_log'] LOOP
    PERFORM pg_temp.check('anon_no_ve:' || t, pg_temp.ve(NULL, format('SELECT count(*) FROM public.%I', t)) = 0);
  END LOOP;
  PERFORM pg_temp.check('anon_no_edita:incidencias',
    pg_temp.edita(NULL, 'UPDATE public.incidencias SET id = id') <= 0);
  PERFORM pg_temp.check('anon_no_edita:ttalleres',
    pg_temp.edita(NULL, 'UPDATE public.ttalleres SET id = id') <= 0);
END $$;

-- ------------------------------------------------------------ conductor ------
DO $$
DECLARE
  u UUID := pg_temp.usuario('conductor');
  mi_personal UUID;
  mis_traslados INT;
  mis_pacientes INT;
  mis_turnos INT;
BEGIN
  IF u IS NULL THEN
    PERFORM pg_temp.check('conductor_omitido', true, 'no hay usuario conductor');
    RETURN;
  END IF;
  SELECT id INTO mi_personal FROM public.tpersonal WHERE usuario_id = u LIMIT 1;
  SELECT count(*) INTO mis_traslados FROM public.traslados
   WHERE id_conductor = mi_personal OR mi_personal = ANY (personal_asignado);
  SELECT count(DISTINCT id_paciente) INTO mis_pacientes FROM public.traslados
   WHERE id_paciente IS NOT NULL AND (id_conductor = mi_personal OR mi_personal = ANY (personal_asignado));
  SELECT count(*) INTO mis_turnos FROM public.turnos WHERE "idPersonal" = mi_personal::text;

  PERFORM pg_temp.check('conductor_ve_solo_sus_traslados',
    pg_temp.ve(u, 'SELECT count(*) FROM public.traslados') = mis_traslados);
  PERFORM pg_temp.check('conductor_edita_solo_sus_traslados',
    pg_temp.edita(u, 'UPDATE public.traslados SET id = id') = mis_traslados);
  PERFORM pg_temp.check('conductor_ve_solo_pacientes_de_sus_traslados',
    pg_temp.ve(u, 'SELECT count(*) FROM public.pacientes') = mis_pacientes);
  PERFORM pg_temp.check('conductor_no_edita_pacientes',
    pg_temp.edita(u, 'UPDATE public.pacientes SET id = id') <= 0);
  PERFORM pg_temp.check('conductor_edita_solo_sus_turnos',
    pg_temp.edita(u, 'UPDATE public.turnos SET id = id') = mis_turnos);
  PERFORM pg_temp.check('conductor_ve_turnos_de_todos',
    pg_temp.ve(u, 'SELECT count(*) FROM public.turnos') = pg_temp.total('turnos'));
  PERFORM pg_temp.check('conductor_ve_solo_su_ficha_personal',
    pg_temp.ve(u, 'SELECT count(*) FROM public.tpersonal') <= 1);
  PERFORM pg_temp.check('conductor_no_ve_historial_medico_ajeno',
    pg_temp.ve(u, format('SELECT count(*) FROM public.historial_medico WHERE personal_id::text <> %L',
                         coalesce(mi_personal::text, ''))) = 0);
  PERFORM pg_temp.check('conductor_no_ve_contratos',
    pg_temp.ve(u, 'SELECT count(*) FROM public.contratos') = 0);
  PERFORM pg_temp.check('conductor_no_ve_almacen',
    pg_temp.ve(u, 'SELECT count(*) FROM public.stock') = 0);
  PERFORM pg_temp.check('conductor_no_edita_productos',
    pg_temp.edita(u, 'UPDATE public.productos SET id = id') <= 0);
  PERFORM pg_temp.check('conductor_no_ve_auditoria',
    pg_temp.ve(u, 'SELECT count(*) FROM public.audit_log') = 0);
  PERFORM pg_temp.check('conductor_no_ve_historial_vehiculos',
    pg_temp.ve(u, format('SELECT count(*) FROM public.fn_historial_registro(''tvehiculos'', %L)',
      (SELECT registro_id FROM public.audit_log WHERE tabla = 'tvehiculos' LIMIT 1))) = 0);
  PERFORM pg_temp.check('conductor_no_transfiere_stock',
    pg_temp.edita(u, 'SELECT public.transferir_stock_a_vehiculo(gen_random_uuid(), gen_random_uuid(), 1, ''test'')') = -1);
END $$;

-- -------------------------------------------------------- jefe_personal ------
DO $$
DECLARE u UUID := pg_temp.usuario('jefe_personal');
BEGIN
  IF u IS NULL THEN
    PERFORM pg_temp.check('jefe_personal_omitido', true, 'no hay usuario jefe_personal');
    RETURN;
  END IF;
  PERFORM pg_temp.check('jefe_personal_ve_toda_la_plantilla',
    pg_temp.ve(u, 'SELECT count(*) FROM public.tpersonal') = pg_temp.total('tpersonal'));
  PERFORM pg_temp.check('jefe_personal_edita_turnos',
    pg_temp.edita(u, 'UPDATE public.turnos SET id = id') = pg_temp.total('turnos'));
  PERFORM pg_temp.check('jefe_personal_no_ve_pacientes',
    pg_temp.ve(u, 'SELECT count(*) FROM public.pacientes') = 0);
  PERFORM pg_temp.check('jefe_personal_no_ve_traslados',
    pg_temp.ve(u, 'SELECT count(*) FROM public.traslados') = 0);
  PERFORM pg_temp.check('jefe_personal_no_edita_vehiculos',
    pg_temp.edita(u, 'UPDATE public.tvehiculos SET id = id') <= 0);
END $$;

-- --------------------------------------------------- jefe_mantenimiento ------
DO $$
DECLARE u UUID := pg_temp.usuario('jefe_mantenimiento');
BEGIN
  IF u IS NULL THEN
    PERFORM pg_temp.check('jefe_mantenimiento_omitido', true, 'no hay usuario jefe_mantenimiento');
    RETURN;
  END IF;
  PERFORM pg_temp.check('jefe_mant_ve_almacen',
    pg_temp.ve(u, 'SELECT count(*) FROM public.stock') = pg_temp.total('stock'));
  PERFORM pg_temp.check('jefe_mant_edita_vehiculos',
    pg_temp.edita(u, 'UPDATE public.tvehiculos SET id = id') = pg_temp.total('tvehiculos'));
  PERFORM pg_temp.check('jefe_mant_no_ve_pacientes',
    pg_temp.ve(u, 'SELECT count(*) FROM public.pacientes') = 0);
  PERFORM pg_temp.check('jefe_mant_no_ve_traslados',
    pg_temp.ve(u, 'SELECT count(*) FROM public.traslados') = 0);
  PERFORM pg_temp.check('jefe_mant_no_ve_contratos',
    pg_temp.ve(u, 'SELECT count(*) FROM public.contratos') = 0);
END $$;

-- --------------------------------------------------------- jefe_trafico ------
DO $$
DECLARE u UUID := pg_temp.usuario('jefe_trafico');
BEGIN
  IF u IS NULL THEN
    PERFORM pg_temp.check('jefe_trafico_omitido', true, 'no hay usuario jefe_trafico');
    RETURN;
  END IF;
  PERFORM pg_temp.check('jefe_trafico_ve_todos_los_traslados',
    pg_temp.ve(u, 'SELECT count(*) FROM public.traslados') = pg_temp.total('traslados'));
  PERFORM pg_temp.check('jefe_trafico_ve_todos_los_pacientes',
    pg_temp.ve(u, 'SELECT count(*) FROM public.pacientes') = pg_temp.total('pacientes'));
  PERFORM pg_temp.check('jefe_trafico_no_edita_almacen',
    pg_temp.edita(u, 'UPDATE public.stock SET id = id') <= 0);
  PERFORM pg_temp.check('jefe_trafico_ve_historial_vehiculos',
    pg_temp.ve(u, format('SELECT count(*) FROM public.fn_historial_registro(''tvehiculos'', %L)',
      (SELECT registro_id FROM public.audit_log WHERE tabla = 'tvehiculos' LIMIT 1))) > 0);
  PERFORM pg_temp.check('jefe_trafico_no_ve_historial_medico',
    pg_temp.ve(u, 'SELECT count(*) FROM public.historial_medico') = 0);
END $$;

-- ---------------------------------------------------------------- admin ------
DO $$
DECLARE u UUID := pg_temp.usuario('admin');
  t TEXT;
BEGIN
  IF u IS NULL THEN
    PERFORM pg_temp.check('admin_omitido', true, 'no hay usuario admin');
    RETURN;
  END IF;
  FOREACH t IN ARRAY ARRAY['pacientes', 'traslados', 'tpersonal', 'tvehiculos', 'stock', 'contratos'] LOOP
    PERFORM pg_temp.check('admin_ve_todo:' || t,
      pg_temp.ve(u, format('SELECT count(*) FROM public.%I', t)) = pg_temp.total(t));
  END LOOP;
END $$;

-- ------------------------------------------------------------- resumen -------
DO $$
DECLARE
  fallos TEXT;
  n_ok INT;
BEGIN
  SELECT count(*) FILTER (WHERE ok) INTO n_ok FROM _resultado;
  SELECT string_agg(caso || CASE WHEN detalle <> '' THEN ' (' || detalle || ')' ELSE '' END, E'\n  - ')
    INTO fallos FROM _resultado WHERE NOT ok;
  IF fallos IS NOT NULL THEN
    RAISE EXCEPTION E'RLS: % casos OK, FALLOS:\n  - %', n_ok, fallos;
  END IF;
  RAISE NOTICE 'RLS: % casos OK, 0 fallos', n_ok;
END $$;

ROLLBACK;
