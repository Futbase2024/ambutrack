-- 063: Arreglos en la generación automática de traslados
--
-- 1) El cron "generar-traslados-diarios" (01:00) llamaba a
--    generar_traslados_proximos_lotes(), que inserta en la columna "trayecto"
--    (no existe en traslados) y fallaba todas las noches. La generación real la
--    hace el cron "generacion-traslados-nocturna" (02:00, generar_traslados_con_log),
--    así que se desprograma el cron roto.
-- 2) generar_traslados_recurrente() comparaba el estado con 'suspendido' en
--    minúsculas, pero la app guarda 'SUSPENDIDO': un servicio suspendido seguía
--    generando traslados al recrear su recurrencia. Se compara sin mayúsculas.

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'generar-traslados-diarios') THEN
    PERFORM cron.unschedule('generar-traslados-diarios');
  END IF;
END $$;

DO $$
DECLARE
  v_def TEXT;
BEGIN
  SELECT pg_get_functiondef('public.generar_traslados_recurrente()'::regprocedure) INTO v_def;
  IF position('IF v_estado_servicio = ''suspendido'' THEN' IN v_def) > 0 THEN
    v_def := replace(
      v_def,
      'IF v_estado_servicio = ''suspendido'' THEN',
      'IF upper(coalesce(v_estado_servicio, '''')) = ''SUSPENDIDO'' THEN'
    );
    EXECUTE v_def;
  END IF;
END $$;
