-- =====================================================
-- SCRIPT DE DIAGNÓSTICO: CRON JOB DE TRASLADOS
-- Descripción: Verifica el estado del sistema de generación automática
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-02-16
-- =====================================================

-- =====================================================
-- 1. VERIFICAR SI pg_cron ESTÁ HABILITADO
-- =====================================================
SELECT
  '1. pg_cron habilitado' AS checks,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM pg_extension WHERE extname = 'pg_cron'
    )
    THEN '✅ SÍ - pg_corn está instalado'
    ELSE '❌ NO - pg_cron NO está instalado'
  END AS resultado;

-- =====================================================
-- 2. VERIFICAR SI EL CRON JOB ESTÁ PROGRAMADO
-- =====================================================
SELECT
  '2. Job programado' AS checks,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM cron.job WHERE jobname = 'generacion-traslados-nocturna'
    )
    THEN '✅ SÍ - El job está programado'
    ELSE '❌ NO - El job NO está programado'
  END AS resultado;

-- =====================================================
-- 3. VER DETALLES DEL CRON JOB
-- =====================================================
SELECT
  '3. Detalles del job' AS checks,
  jobname,
  schedule,
  command,
  active,
  nodename,
  nodeport,
  database,
  jobid
FROM cron.job
WHERE jobname = 'generacion-traslados-nocturna';

-- =====================================================
-- 4. VER EJECUCIONES RECIENTES (ÚLTIMAS 10)
-- =====================================================
SELECT
  '4. Últimas 10 ejecuciones' AS checks,
  job_name,
  started_at,
  finished_at,
  status,
  servicios_procesados,
  traslados_generados,
  CASE
    WHEN errores IS NOT NULL AND array_length(errores, 1) > 0
    THEN array_length(errores, 1)
    ELSE 0
  END AS num_errores,
  execution_time_ms,
  error_message
FROM cron_job_logs
WHERE job_name = 'generacion-traslados-nocturna'
ORDER BY started_at DESC
LIMIT 10;

-- =====================================================
-- 5. VER ESTADÍSTICAS DE LOS ÚLTIMOS 7 DÍAS
-- =====================================================
SELECT
  '5. Estadísticas últimos 7 días' AS checks,
  DATE(started_at) AS fecha,
  COUNT(*) AS num_ejecuciones,
  SUM(servicios_procesados) AS total_servicios,
  SUM(traslados_generados) AS total_traslados,
  AVG(execution_time_ms) AS tiempo_promedio_ms,
  COUNT(CASE WHEN status = 'failed' THEN 1 END) AS ejecuciones_fallidas,
  COUNT(CASE WHEN status = 'completed_with_errors' THEN 1 END) AS con_errores
FROM cron_job_logs
WHERE job_name = 'generacion-traslados-nocturna'
  AND started_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(started_at)
ORDER BY fecha DESC;

-- =====================================================
-- 6. VER SERVICIOS ACTIVOS QUE DEBERÍAN GENERAR TRASLADOS
-- =====================================================
SELECT
  '6. Servicios activos (pendientes generar)' AS checks,
  COUNT(*) AS total_servicios_activos,
  COUNT(CASE WHEN traslados_generados_hasta IS NULL THEN 1 END) AS sin_generar,
  COUNT(CASE WHEN traslados_generados_hasta < CURRENT_DATE - INTERVAL '7 days' THEN 1 END) AS actualizados_hace_mas_7_dias,
  COUNT(CASE WHEN traslados_generados_hasta < CURRENT_DATE THEN 1 END) AS con_traslados_atrasados,
  COUNT(CASE WHEN traslados_generados_hasta >= CURRENT_DATE + INTERVAL '14 days' THEN 1 END) AS actualizados_14_dias
FROM servicios
WHERE activo = true
  AND fecha_servicio_inicio <= CURRENT_DATE + INTERVAL '14 days'
  AND (fecha_servicio_fin IS NULL OR fecha_servicio_fin >= CURRENT_DATE);

-- =====================================================
-- 7. DETALLE DE SERVICIOS CON TRASLADOS ATRASADOS
-- =====================================================
SELECT
  '7. Servicios con traslados atrasados' AS checks,
  s.codigo,
  s.tipo_recurrencia,
  s.fecha_servicio_inicio,
  s.fecha_servicio_fin,
  s.traslados_generados_hasta,
  s.activo,
  -- Calcular días de retraso
  CASE
    WHEN s.traslados_generados_hasta IS NULL
    THEN CURRENT_DATE - s.fecha_servicio_inicio
    ELSE CURRENT_DATE - s.traslados_generados_hasta
  END AS dias_retraso,
  -- Próximos traslados que deberían generarse (ejemplo: lunes, miércoles, viernes)
  CASE
    WHEN s.tipo_recurrencia = 'semanal'
    THEN ARRAY(
      SELECT d::DATE
      FROM generate_series(CURRENT_DATE, CURRENT_DATE + INTERVAL '14 days', INTERVAL '1 day') AS d
      WHERE EXTRACT(DOW FROM d) = ANY(s.dias_semana)
      ORDER BY d
      LIMIT 5
    )::TEXT[]
    ELSE NULL
  END AS proximas_fechas_a_generar
FROM servicios s
WHERE s.activo = true
  AND s.fecha_servicio_inicio <= CURRENT_DATE + INTERVAL '14 days'
  AND (s.fecha_servicio_fin IS NULL OR s.fecha_servicio_fin >= CURRENT_DATE)
  AND (
    s.traslados_generados_hasta IS NULL
    OR s.traslados_generados_hasta < CURRENT_DATE
  )
ORDER BY
  CASE
    WHEN s.traslados_generados_hasta IS NULL
    THEN CURRENT_DATE - s.fecha_servicio_inicio
    ELSE CURRENT_DATE - s.traslados_generados_hasta
  END DESC
LIMIT 10;

-- =====================================================
-- 8. CONTAR TRASLADOS POR FECHA (PRÓXIMOS 14 DÍAS)
-- =====================================================
SELECT
  '8. Traslados existentes próximos 14 días' AS checks,
  fecha,
  COUNT(*) AS total_traslados,
  COUNT(CASE WHEN tipo_traslado = 'ida' THEN 1 END) AS ida,
  COUNT(CASE WHEN tipo_traslado = 'vuelta' THEN 1 END) AS vuelta,
  COUNT(CASE WHEN estado = 'pendiente' THEN 1 END) AS pendientes,
  COUNT(CASE WHEN estado = 'asignado' THEN 1 END) AS asignados,
  COUNT(CASE WHEN estado = 'cancelado' THEN 1 END) AS cancelados
FROM traslados
WHERE fecha >= CURRENT_DATE
  AND fecha <= CURRENT_DATE + INTERVAL '14 days'
GROUP BY fecha
ORDER BY fecha;

-- =====================================================
-- 9. VERIFICAR LA FUNCIÓN DE GENERACIÓN
-- =====================================================
SELECT
  '9. Función generar_traslados_periodo' AS checks,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM pg_proc WHERE proname = 'generar_traslados_periodo'
    )
    THEN '✅ SÍ - La función existe'
    ELSE '❌ NO - La función NO existe'
  END AS resultado;

-- =====================================================
-- 10. PROBAR GENERACIÓN MANUAL (PRÓXIMOS 14 DÍAS)
-- =====================================================
-- ⚠️ DESCOMENTAR PARA EJECUTAR MANUALMENTE:
-- SELECT * FROM generar_traslados_periodo(
--   CURRENT_DATE,
--   CURRENT_DATE + INTERVAL '14 days'
-- );

-- =====================================================
-- 11. VERIFICAR PERMISOS DE pg_cron
-- =====================================================
SELECT
  '11. Permisos de pg_cron' AS checks,
  schemaname,
  tablename,
  tableowner,
  hasindexes,
  hasrules,
  hastriggers
FROM pg_tables
WHERE schemaname = 'cron'
  OR tablename IN ('cron_job_logs', 'job_run_details')
ORDER BY schemaname, tablename;

-- =====================================================
-- 12. VER ERRORES RECIENTES EN LOGS
-- =====================================================
SELECT
  '12. Errores recientes' AS checks,
  job_name,
  started_at,
  status,
  error_message,
  errores
FROM cron_job_logs
WHERE job_name = 'generacion-traslados-nocturna'
  AND (status = 'failed' OR status = 'completed_with_errors')
  AND started_at >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY started_at DESC
LIMIT 10;

-- =====================================================
-- RESUMEN EJECUTIVO
-- =====================================================
SELECT
  'RESUMEN EJECUTIVO' AS seccion,
  '========================================' AS separador;

SELECT
  'Servicios activos que necesitan traslados' AS metrica,
  COUNT(*) AS valor
FROM servicios
WHERE activo = true
  AND fecha_servicio_inicio <= CURRENT_DATE + INTERVAL '14 days'
  AND (fecha_servicio_fin IS NULL OR fecha_servicio_fin >= CURRENT_DATE)
  AND (
    traslados_generados_hasta IS NULL
    OR traslados_generados_hasta < CURRENT_DATE
  );

SELECT
  'Traslados existentes próximos 14 días' AS metrica,
  COUNT(*) AS valor
FROM traslados
WHERE fecha >= CURRENT_DATE
  AND fecha <= CURRENT_DATE + INTERVAL '14 days';

SELECT
  'Última ejecución del cron job' AS metrica,
  MAX(started_at) AS valor
FROM cron_job_logs
WHERE job_name = 'generacion-traslados-nocturna';

SELECT
  'Estado de la última ejecución' AS metrica,
  COALESCE(status, 'NUNCA EJECUTADO') AS valor
FROM cron_job_logs
WHERE job_name = 'generacion-traslados-nocturna'
ORDER BY started_at DESC
LIMIT 1;

-- =====================================================
-- COMANDOS ÚTILES (COMENTARIOS)
-- =====================================================
/*
-- Ejecutar manualmente la generación de traslados:
SELECT generar_traslados_con_log();

-- Ver todos los jobs de cron:
SELECT * FROM cron.job;

-- Ver ejecuciones recientes del job:
SELECT * FROM v_cron_job_recent_runs;

-- Programar job si no existe:
SELECT cron.schedule(
  'generacion-traslados-nocturna',
  '0 2 * * *',
  $$SELECT generar_traslados_con_log();$$
);

-- Desprogramar job:
SELECT cron.unschedule('generacion-traslados-nocturna');
*/
