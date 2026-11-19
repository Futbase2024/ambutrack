-- =============================================
-- SEGURIDAD: endurecer funciones de public
-- 1. anon (sin sesión) no puede ejecutar ninguna función salvo get_email_by_dni (login por DNI).
-- 2. Funciones de trigger, de cron y de test: tampoco ejecutables por authenticated vía RPC
--    (los triggers no necesitan EXECUTE para dispararse).
-- 3. search_path fijo en todas las funciones que no lo tenían.
-- =============================================
DO $$
DECLARE
  f RECORD;
  v_sig TEXT;
BEGIN
  FOR f IN
    SELECT p.oid, p.proname,
           pg_get_function_identity_arguments(p.oid) AS args,
           pg_get_function_result(p.oid) AS ret,
           coalesce((SELECT bool_or(c LIKE 'search_path=%') FROM unnest(p.proconfig) c), false) AS has_sp
      FROM pg_proc p
     WHERE p.pronamespace = 'public'::regnamespace
       AND p.prokind = 'f'
       AND NOT EXISTS (SELECT 1 FROM pg_depend d WHERE d.objid = p.oid AND d.deptype = 'e')
  LOOP
    v_sig := format('public.%I(%s)', f.proname, f.args);

    -- 1. Nadie sin sesión, salvo login por DNI
    IF f.proname <> 'get_email_by_dni' THEN
      EXECUTE format('REVOKE EXECUTE ON FUNCTION %s FROM PUBLIC, anon', v_sig);
    END IF;

    -- 2. Triggers / cron / test: solo uso interno
    IF f.ret = 'trigger'
       OR f.proname IN ('test_generar_proximos_lotes', 'test_generar_traslados',
                        'generar_traslados_con_log', 'limpiar_alertas_vistas_antiguas') THEN
      EXECUTE format('REVOKE EXECUTE ON FUNCTION %s FROM authenticated', v_sig);
    ELSIF f.proname <> 'get_email_by_dni' THEN
      EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO authenticated', v_sig);
    END IF;
    EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO service_role', v_sig);

    -- 3. search_path fijo
    IF NOT f.has_sp THEN
      EXECUTE format('ALTER FUNCTION %s SET search_path = public, extensions', v_sig);
    END IF;
  END LOOP;
END $$;

-- Las funciones nuevas que se creen en public no serán ejecutables por anon por defecto
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon;
