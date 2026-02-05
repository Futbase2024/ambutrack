-- =====================================================
-- CONFIGURACIÓN: pg_cron para generación automática de traslados
-- Descripción: Configura job nocturno que mantiene ventana de 14 días
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-01-30
-- =====================================================

-- ⚠️ IMPORTANTE: pg_cron debe estar instalado y habilitado en Supabase
-- Ejecutar como superusuario o desde el dashboard de Supabase

-- Habilitar extensión pg_cron (si no está habilitada)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- =====================================================
-- JOB: Generación Nocturna de Traslados (14 días adelante)
-- =====================================================

-- Eliminar job existente si existe (para re-crear)
SELECT cron.unschedule('generacion-traslados-nocturna');

-- Crear job que se ejecuta cada noche a las 02:00 UTC
SELECT cron.schedule(
  'generacion-traslados-nocturna',              -- Nombre del job
  '0 2 * * *',                                   -- Cron schedule: Cada día a las 02:00 UTC
  $$
  SELECT generar_traslados_periodo(
    CURRENT_DATE,                                -- Desde hoy
    CURRENT_DATE + INTERVAL '14 days'           -- Hasta dentro de 14 días
  );
  $$
);

-- =====================================================
-- JOB: Limpieza de traslados antiguos cancelados (opcional)
-- =====================================================

-- Eliminar traslados cancelados o no realizados más antiguos de 90 días
SELECT cron.unschedule('limpieza-traslados-antiguos');

SELECT cron.schedule(
  'limpieza-traslados-antiguos',
  '0 3 * * 0',                                   -- Cada domingo a las 03:00 UTC
  $$
  DELETE FROM traslados
  WHERE estado IN ('cancelado', 'no_realizado')
    AND fecha < CURRENT_DATE - INTERVAL '90 days';
  $$
);

-- =====================================================
-- JOB: Notificaciones de traslados pendientes de mañana
-- =====================================================

-- Crear función auxiliar para enviar notificaciones
CREATE OR REPLACE FUNCTION notificar_traslados_pendientes()
RETURNS void AS $$
DECLARE
  v_count INTEGER;
BEGIN
  -- Contar traslados pendientes para mañana
  SELECT COUNT(*) INTO v_count
  FROM traslados
  WHERE fecha = CURRENT_DATE + INTERVAL '1 day'
    AND estado IN ('pendiente', 'asignado');

  -- Log para debugging
  RAISE NOTICE 'Traslados pendientes para mañana: %', v_count;

  -- TODO: Aquí se puede agregar lógica para enviar notificaciones
  -- por email, SMS, o push notifications usando servicios de Supabase
END;
$$ LANGUAGE plpgsql;

-- Programar notificación diaria a las 18:00 UTC
SELECT cron.unschedule('notificacion-traslados-manana');

SELECT cron.schedule(
  'notificacion-traslados-manana',
  '0 18 * * *',                                  -- Cada día a las 18:00 UTC
  $$
  SELECT notificar_traslados_pendientes();
  $$
);

-- =====================================================
-- TABLA DE MONITOREO: cron_job_logs
-- =====================================================

-- Crear tabla para logs de ejecución de jobs
CREATE TABLE IF NOT EXISTS cron_job_logs (
  id BIGSERIAL PRIMARY KEY,
  job_name VARCHAR(100) NOT NULL,
  started_at TIMESTAMP NOT NULL DEFAULT now(),
  finished_at TIMESTAMP,
  status VARCHAR(20) DEFAULT 'running',
  servicios_procesados INTEGER,
  traslados_generados INTEGER,
  errores TEXT[],
  execution_time_ms INTEGER,
  error_message TEXT
);

CREATE INDEX idx_cron_logs_job_name ON cron_job_logs(job_name);
CREATE INDEX idx_cron_logs_started_at ON cron_job_logs(started_at DESC);

-- =====================================================
-- FUNCIÓN MEJORADA: generar_traslados_con_log
-- =====================================================

CREATE OR REPLACE FUNCTION generar_traslados_con_log()
RETURNS void AS $$
DECLARE
  v_log_id BIGINT;
  v_start_time TIMESTAMP;
  v_result RECORD;
BEGIN
  v_start_time := now();

  -- Insertar log de inicio
  INSERT INTO cron_job_logs (job_name, started_at, status)
  VALUES ('generacion-traslados-nocturna', v_start_time, 'running')
  RETURNING id INTO v_log_id;

  -- Ejecutar generación de traslados
  SELECT * INTO v_result
  FROM generar_traslados_periodo(
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '14 days'
  );

  -- Actualizar log con resultados
  UPDATE cron_job_logs
  SET
    finished_at = now(),
    status = CASE
      WHEN v_result.servicios_con_error > 0 THEN 'completed_with_errors'
      ELSE 'completed'
    END,
    servicios_procesados = v_result.servicios_procesados,
    traslados_generados = v_result.traslados_generados,
    errores = v_result.errores,
    execution_time_ms = EXTRACT(EPOCH FROM (now() - v_start_time))::INTEGER * 1000
  WHERE id = v_log_id;

  RAISE NOTICE 'Generación completada: % servicios, % traslados generados',
    v_result.servicios_procesados, v_result.traslados_generados;

EXCEPTION
  WHEN OTHERS THEN
    -- Log de error
    UPDATE cron_job_logs
    SET
      finished_at = now(),
      status = 'failed',
      error_message = SQLERRM,
      execution_time_ms = EXTRACT(EPOCH FROM (now() - v_start_time))::INTEGER * 1000
    WHERE id = v_log_id;

    RAISE;
END;
$$ LANGUAGE plpgsql;

-- Actualizar el job para usar la función con logging
SELECT cron.unschedule('generacion-traslados-nocturna');

SELECT cron.schedule(
  'generacion-traslados-nocturna',
  '0 2 * * *',
  $$SELECT generar_traslados_con_log();$$
);

-- =====================================================
-- CONSULTAS ÚTILES PARA MONITOREO
-- =====================================================

-- Ver ejecuciones recientes de jobs
CREATE OR REPLACE VIEW v_cron_job_recent_runs AS
SELECT
  job_name,
  started_at,
  finished_at,
  status,
  servicios_procesados,
  traslados_generados,
  execution_time_ms,
  CASE
    WHEN errores IS NOT NULL AND array_length(errores, 1) > 0
    THEN array_length(errores, 1)
    ELSE 0
  END AS num_errores,
  error_message
FROM cron_job_logs
ORDER BY started_at DESC
LIMIT 50;

-- Ver estadísticas de generación por día
CREATE OR REPLACE VIEW v_estadisticas_generacion_diaria AS
SELECT
  DATE(started_at) AS fecha,
  COUNT(*) AS num_ejecuciones,
  SUM(servicios_procesados) AS total_servicios,
  SUM(traslados_generados) AS total_traslados,
  AVG(execution_time_ms) AS tiempo_promedio_ms,
  COUNT(CASE WHEN status = 'failed' THEN 1 END) AS ejecuciones_fallidas
FROM cron_job_logs
WHERE job_name = 'generacion-traslados-nocturna'
GROUP BY DATE(started_at)
ORDER BY fecha DESC;

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE cron_job_logs IS
'Logs de ejecución de jobs de pg_cron para monitoreo y debugging';

COMMENT ON FUNCTION generar_traslados_con_log() IS
'Wrapper de generar_traslados_periodo que registra logs de ejecución en cron_job_logs';

COMMENT ON VIEW v_cron_job_recent_runs IS
'Vista de las 50 ejecuciones más recientes de jobs con resumen de resultados';

COMMENT ON VIEW v_estadisticas_generacion_diaria IS
'Estadísticas diarias de la generación automática de traslados';

-- =====================================================
-- COMANDOS ÚTILES PARA ADMINISTRACIÓN
-- =====================================================

-- Ver todos los jobs programados:
-- SELECT * FROM cron.job;

-- Ver ejecuciones recientes:
-- SELECT * FROM v_cron_job_recent_runs;

-- Ejecutar manualmente el job de generación:
-- SELECT generar_traslados_con_log();

-- Deshabilitar un job temporalmente:
-- SELECT cron.unschedule('generacion-traslados-nocturna');

-- Re-habilitar un job:
-- (Volver a ejecutar el SELECT cron.schedule(...))

-- Ver logs de ejecuciones con errores:
-- SELECT * FROM cron_job_logs WHERE status IN ('failed', 'completed_with_errors') ORDER BY started_at DESC;
