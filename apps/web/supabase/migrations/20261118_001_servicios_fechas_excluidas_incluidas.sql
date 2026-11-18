-- =============================================================================
-- Fechas excluidas / incluidas de servicios recurrentes
-- =============================================================================
-- servicios.fechas_excluidas: días en los que NO se deben generar traslados
--   aunque el patrón de recurrencia los incluya.
-- servicios.fechas_incluidas: días extra en los que SÍ se generan traslados
--   aunque el patrón de recurrencia no los incluya.
--
-- Cómo se respetan:
-- 1. Trigger BEFORE INSERT en traslados: descarta traslados automáticos
--    (generados por funciones SQL) en fechas excluidas. Cubre todos los
--    generadores existentes (trigger de servicios_recurrentes,
--    regenerar_traslados_servicio, generar_traslados_periodo, lotes cron).
-- 2. aplicar_fechas_excepcion_servicio(): reconcilia traslados futuros
--    (borra pendientes en fechas excluidas, crea los de fechas incluidas).
--    Se ejecuta al cambiar las fechas en servicios y tras crear un
--    servicio_recurrente (el wizard de edición lo recrea).
-- =============================================================================

ALTER TABLE public.servicios
  ADD COLUMN IF NOT EXISTS fechas_excluidas date[] NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS fechas_incluidas date[] NOT NULL DEFAULT '{}';

ALTER TABLE public.servicios
  DROP CONSTRAINT IF EXISTS ck_servicios_fechas_excepcion_disjuntas;
ALTER TABLE public.servicios
  ADD CONSTRAINT ck_servicios_fechas_excepcion_disjuntas
  CHECK (NOT (fechas_excluidas && fechas_incluidas));

COMMENT ON COLUMN public.servicios.fechas_excluidas IS
  'Fechas en las que no se generan traslados aunque encajen en la recurrencia';
COMMENT ON COLUMN public.servicios.fechas_incluidas IS
  'Fechas extra en las que se generan traslados aunque no encajen en la recurrencia';

-- -----------------------------------------------------------------------------
-- Helper: ¿la recurrencia incluye la fecha? (misma semántica que los generadores)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_recurrencia_incluye_fecha(
  p_tipo text,
  p_dias_semana integer[],
  p_intervalo_semanas integer,
  p_intervalo_dias integer,
  p_dias_mes integer[],
  p_fechas_especificas date[],
  p_inicio date,
  p_fin date,
  p_fecha date
) RETURNS boolean
LANGUAGE sql IMMUTABLE
SET search_path TO 'public'
AS $$
  SELECT CASE
    WHEN p_inicio IS NULL OR p_fecha < p_inicio THEN false
    WHEN p_fin IS NOT NULL AND p_fecha > p_fin THEN false
    WHEN p_tipo = 'unico' THEN p_fecha = p_inicio
    WHEN p_tipo = 'diario' THEN true
    WHEN p_tipo = 'semanal' THEN
      COALESCE(p_dias_semana @> ARRAY[EXTRACT(DOW FROM p_fecha)::int], false)
    WHEN p_tipo = 'semanas_alternas' THEN
      COALESCE(p_dias_semana @> ARRAY[EXTRACT(DOW FROM p_fecha)::int], false)
      AND ((p_fecha - p_inicio) / 7) % GREATEST(COALESCE(p_intervalo_semanas, 1), 1) = 0
    WHEN p_tipo = 'dias_alternos' THEN
      (p_fecha - p_inicio) % GREATEST(COALESCE(p_intervalo_dias, 1), 1) = 0
    WHEN p_tipo = 'mensual' THEN
      COALESCE(p_dias_mes @> ARRAY[EXTRACT(DAY FROM p_fecha)::int], false)
    WHEN p_tipo IN ('especifico', 'fechas_especificas') THEN
      COALESCE(p_fechas_especificas @> ARRAY[p_fecha], false)
    ELSE false
  END;
$$;

-- -----------------------------------------------------------------------------
-- Trigger BEFORE INSERT en traslados: omitir fechas excluidas
-- Solo afecta a inserciones hechas por los generadores SQL (dentro de un
-- trigger o de una función generar_traslados_* / regenerar_traslados_*);
-- los traslados creados manualmente desde la app no se bloquean.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_omitir_traslado_fecha_excluida()
RETURNS trigger
LANGUAGE plpgsql
SET search_path TO 'public'
AS $$
DECLARE
  v_id_servicio uuid;
  v_excluida boolean;
BEGIN
  IF COALESCE(NEW.generado_automaticamente, false) = false THEN
    RETURN NEW;
  END IF;

  IF pg_trigger_depth() <= 1 AND current_query() !~* 'generar_traslados' THEN
    RETURN NEW;
  END IF;

  v_id_servicio := NEW.id_servicio;
  IF v_id_servicio IS NULL AND NEW.id_servicio_recurrente IS NOT NULL THEN
    SELECT sr.id_servicio INTO v_id_servicio
    FROM servicios_recurrentes sr
    WHERE sr.id = NEW.id_servicio_recurrente;
  END IF;

  IF v_id_servicio IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT NEW.fecha = ANY (s.fechas_excluidas) INTO v_excluida
  FROM servicios s
  WHERE s.id = v_id_servicio;

  IF COALESCE(v_excluida, false) THEN
    RETURN NULL;
  END IF;

  RETURN NEW;
END;
$$;

-- Nombre con prefijo "0" para ejecutarse antes que el resto de BEFORE triggers
DROP TRIGGER IF EXISTS trg_0_omitir_traslado_fecha_excluida ON public.traslados;
CREATE TRIGGER trg_0_omitir_traslado_fecha_excluida
  BEFORE INSERT ON public.traslados
  FOR EACH ROW EXECUTE FUNCTION public.fn_omitir_traslado_fecha_excluida();

-- -----------------------------------------------------------------------------
-- Reconciliación de traslados futuros según fechas excluidas/incluidas
-- p_fechas_reactivar: fechas que dejaron de estar excluidas
-- p_fechas_retirar:   fechas que dejaron de estar incluidas
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.aplicar_fechas_excepcion_servicio(
  p_id_servicio uuid,
  p_fechas_reactivar date[] DEFAULT '{}',
  p_fechas_retirar date[] DEFAULT '{}'
) RETURNS TABLE(traslados_eliminados integer, traslados_generados integer)
LANGUAGE plpgsql
SET search_path TO 'public'
AS $$
DECLARE
  v_srv servicios%ROWTYPE;
  v_src RECORD;
  v_id_rec uuid;
  v_hasta date;
  v_fecha date;
  v_fechas date[];
  v_tmp integer;
  v_eliminados integer := 0;
  v_generados integer := 0;
BEGIN
  SELECT * INTO v_srv FROM servicios WHERE id = p_id_servicio;
  IF NOT FOUND THEN
    RETURN QUERY SELECT 0, 0;
    RETURN;
  END IF;

  -- Configuración de origen: servicio_recurrente activo o, si no hay, el servicio
  SELECT sr.id AS id_rec, sr.tipo_recurrencia, sr.dias_semana, sr.intervalo_semanas,
         sr.intervalo_dias, sr.dias_mes, sr.fechas_especificas, sr.fecha_servicio_inicio,
         sr.fecha_servicio_fin, sr.hora_recogida, sr.hora_vuelta, sr.requiere_vuelta,
         sr.id_paciente, sr.id_motivo_traslado, sr.tipo_origen, sr.origen,
         sr.origen_ubicacion_centro, sr.tipo_destino, sr.destino, sr.destino_ubicacion_centro,
         sr.tipo_ambulancia, sr.requiere_acompanante, sr.requiere_silla_ruedas,
         sr.requiere_camilla, sr.requiere_ayuda, sr.prioridad, sr.observaciones,
         sr.observaciones_medicas, sr.traslados_generados_hasta, sr.created_by
  INTO v_src
  FROM servicios_recurrentes sr
  WHERE sr.id_servicio = p_id_servicio AND sr.activo = true
  ORDER BY sr.created_at DESC
  LIMIT 1;

  IF NOT FOUND THEN
    SELECT NULL::uuid AS id_rec, s.tipo_recurrencia, s.dias_semana, s.intervalo_semanas,
           s.intervalo_dias, s.dias_mes, s.fechas_especificas, s.fecha_servicio_inicio,
           s.fecha_servicio_fin, s.hora_recogida, s.hora_vuelta, s.requiere_vuelta,
           s.id_paciente, s.id_motivo_traslado, s.tipo_origen, s.origen,
           s.origen_ubicacion_centro, s.tipo_destino, s.destino, s.destino_ubicacion_centro,
           s.tipo_ambulancia, s.requiere_acompanante, s.requiere_silla_ruedas,
           s.requiere_camilla, s.requiere_ayuda, s.prioridad, s.observaciones,
           s.observaciones_medicas, s.traslados_generados_hasta, s.created_by
    INTO v_src
    FROM servicios s
    WHERE s.id = p_id_servicio;
  END IF;
  v_id_rec := v_src.id_rec;

  -- 1) Eliminar traslados pendientes en fechas excluidas (desde hoy)
  DELETE FROM traslados t
  WHERE (t.id_servicio = p_id_servicio
         OR t.id_servicio_recurrente IN (
           SELECT id FROM servicios_recurrentes WHERE id_servicio = p_id_servicio))
    AND t.fecha >= CURRENT_DATE
    AND t.estado = 'pendiente'
    AND t.fecha = ANY (v_srv.fechas_excluidas);
  GET DIAGNOSTICS v_tmp = ROW_COUNT;
  v_eliminados := v_eliminados + v_tmp;

  -- 2) Fechas que dejan de estar incluidas y no encajan en la recurrencia
  DELETE FROM traslados t
  WHERE (t.id_servicio = p_id_servicio
         OR t.id_servicio_recurrente IN (
           SELECT id FROM servicios_recurrentes WHERE id_servicio = p_id_servicio))
    AND t.fecha >= CURRENT_DATE
    AND t.estado = 'pendiente'
    AND t.fecha = ANY (COALESCE(p_fechas_retirar, '{}'))
    AND NOT (t.fecha = ANY (v_srv.fechas_incluidas))
    AND NOT public.fn_recurrencia_incluye_fecha(
      v_src.tipo_recurrencia, v_src.dias_semana, v_src.intervalo_semanas,
      v_src.intervalo_dias, v_src.dias_mes, v_src.fechas_especificas,
      v_src.fecha_servicio_inicio, v_src.fecha_servicio_fin, t.fecha);
  GET DIAGNOSTICS v_tmp = ROW_COUNT;
  v_eliminados := v_eliminados + v_tmp;

  -- 3) Generar traslados (solo si el servicio está activo)
  IF COALESCE(v_srv.activo, true) = false
     OR upper(COALESCE(v_srv.estado, '')) IN
        ('SUSPENDIDO', 'FINALIZADO', 'ANULADO', 'CANCELADO', 'ELIMINADO')
     OR v_src.hora_recogida IS NULL THEN
    RETURN QUERY SELECT v_eliminados, v_generados;
    RETURN;
  END IF;

  -- Último día ya generado (recurrente o servicio, según qué generador actuó)
  v_hasta := COALESCE(
    GREATEST(v_src.traslados_generados_hasta, v_srv.traslados_generados_hasta),
    CURRENT_DATE - 1
  );

  v_fechas := ARRAY(
    SELECT f FROM (
      SELECT unnest(v_srv.fechas_incluidas) AS f
      UNION
      SELECT r FROM unnest(COALESCE(p_fechas_reactivar, '{}')) AS r
      WHERE r <= v_hasta
        AND public.fn_recurrencia_incluye_fecha(
          v_src.tipo_recurrencia, v_src.dias_semana, v_src.intervalo_semanas,
          v_src.intervalo_dias, v_src.dias_mes, v_src.fechas_especificas,
          v_src.fecha_servicio_inicio, v_src.fecha_servicio_fin, r)
    ) x
    WHERE f >= CURRENT_DATE AND NOT (f = ANY (v_srv.fechas_excluidas))
    ORDER BY f
  );

  FOREACH v_fecha IN ARRAY v_fechas LOOP
    INSERT INTO traslados (
      id_servicio, id_servicio_recurrente, id_paciente, id_motivo_traslado,
      tipo_traslado, fecha, hora_programada,
      tipo_origen, origen, origen_ubicacion_centro,
      tipo_destino, destino, destino_ubicacion_centro,
      tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
      requiere_camilla, requiere_ayuda, prioridad, observaciones, observaciones_medicas,
      estado, generado_automaticamente, created_by
    ) VALUES (
      p_id_servicio, v_id_rec, v_src.id_paciente, v_src.id_motivo_traslado,
      'ida', v_fecha, v_src.hora_recogida,
      v_src.tipo_origen, v_src.origen, v_src.origen_ubicacion_centro,
      v_src.tipo_destino, v_src.destino, v_src.destino_ubicacion_centro,
      v_src.tipo_ambulancia, COALESCE(v_src.requiere_acompanante, false),
      COALESCE(v_src.requiere_silla_ruedas, false), COALESCE(v_src.requiere_camilla, false),
      COALESCE(v_src.requiere_ayuda, false), COALESCE(v_src.prioridad, 5),
      v_src.observaciones, v_src.observaciones_medicas,
      'pendiente', true, v_src.created_by
    ) ON CONFLICT DO NOTHING;
    IF FOUND THEN
      v_generados := v_generados + 1;
    END IF;

    IF v_src.requiere_vuelta = true AND v_src.hora_vuelta IS NOT NULL THEN
      INSERT INTO traslados (
        id_servicio, id_servicio_recurrente, id_paciente, id_motivo_traslado,
        tipo_traslado, fecha, hora_programada,
        tipo_origen, origen, origen_ubicacion_centro,
        tipo_destino, destino, destino_ubicacion_centro,
        tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
        requiere_camilla, requiere_ayuda, prioridad, observaciones, observaciones_medicas,
        estado, generado_automaticamente, created_by
      ) VALUES (
        p_id_servicio, v_id_rec, v_src.id_paciente, v_src.id_motivo_traslado,
        'vuelta', v_fecha, v_src.hora_vuelta,
        v_src.tipo_destino, v_src.destino, v_src.destino_ubicacion_centro,
        v_src.tipo_origen, v_src.origen, v_src.origen_ubicacion_centro,
        v_src.tipo_ambulancia, COALESCE(v_src.requiere_acompanante, false),
        COALESCE(v_src.requiere_silla_ruedas, false), COALESCE(v_src.requiere_camilla, false),
        COALESCE(v_src.requiere_ayuda, false), COALESCE(v_src.prioridad, 5),
        v_src.observaciones, v_src.observaciones_medicas,
        'pendiente', true, v_src.created_by
      ) ON CONFLICT DO NOTHING;
      IF FOUND THEN
        v_generados := v_generados + 1;
      END IF;
    END IF;
  END LOOP;

  RETURN QUERY SELECT v_eliminados, v_generados;
END;
$$;

GRANT EXECUTE ON FUNCTION public.aplicar_fechas_excepcion_servicio(uuid, date[], date[])
  TO authenticated;

-- -----------------------------------------------------------------------------
-- Trigger: al cambiar las fechas del servicio, reconciliar traslados
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_servicios_fechas_excepcion_cambiadas()
RETURNS trigger
LANGUAGE plpgsql
SET search_path TO 'public'
AS $$
BEGIN
  IF NEW.fechas_excluidas IS DISTINCT FROM OLD.fechas_excluidas
     OR NEW.fechas_incluidas IS DISTINCT FROM OLD.fechas_incluidas THEN
    PERFORM public.aplicar_fechas_excepcion_servicio(
      NEW.id,
      ARRAY(SELECT unnest(OLD.fechas_excluidas) EXCEPT SELECT unnest(NEW.fechas_excluidas)),
      ARRAY(SELECT unnest(OLD.fechas_incluidas) EXCEPT SELECT unnest(NEW.fechas_incluidas))
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_servicios_fechas_excepcion ON public.servicios;
CREATE TRIGGER trg_servicios_fechas_excepcion
  AFTER UPDATE OF fechas_excluidas, fechas_incluidas ON public.servicios
  FOR EACH ROW EXECUTE FUNCTION public.fn_servicios_fechas_excepcion_cambiadas();

-- -----------------------------------------------------------------------------
-- Trigger: tras crear un servicio_recurrente (el wizard lo recrea al editar),
-- generar también los traslados de las fechas incluidas.
-- Nombre "trigger_zz_..." para ejecutarse DESPUÉS de trigger_generar_traslados_recurrente.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_servicios_rec_aplicar_fechas_excepcion()
RETURNS trigger
LANGUAGE plpgsql
SET search_path TO 'public'
AS $$
BEGIN
  IF NEW.id_servicio IS NOT NULL THEN
    PERFORM public.aplicar_fechas_excepcion_servicio(NEW.id_servicio);
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_zz_aplicar_fechas_excepcion ON public.servicios_recurrentes;
CREATE TRIGGER trigger_zz_aplicar_fechas_excepcion
  AFTER INSERT ON public.servicios_recurrentes
  FOR EACH ROW EXECUTE FUNCTION public.fn_servicios_rec_aplicar_fechas_excepcion();
