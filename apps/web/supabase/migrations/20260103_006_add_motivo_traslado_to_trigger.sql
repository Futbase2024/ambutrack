-- =====================================================
-- MIGRACIÓN: Agregar id_motivo_traslado al trigger generar_traslados_recurrente
-- Descripción: El trigger crea traslados pero faltaba propagar id_motivo_traslado
-- Fecha: 2026-01-03
-- Problema: Los traslados se crean sin id_motivo_traslado, aunque exista en servicios_recurrentes
-- Solución: Agregar NEW.id_motivo_traslado en los INSERT de traslados
-- =====================================================

CREATE OR REPLACE FUNCTION public.generar_traslados_recurrente()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
  v_fecha_actual DATE;
  v_fecha_fin_efectiva DATE;
  v_dia_semana INTEGER;
  v_dias_desde_inicio INTEGER;
  v_dia_mes INTEGER;
  v_debe_generar BOOLEAN;
  v_traslados_generados INTEGER := 0;
BEGIN
  -- Determinar fecha fin efectiva (30 días por defecto para el primer lote)
  IF NEW.fecha_servicio_fin IS NULL THEN
    v_fecha_fin_efectiva := NEW.fecha_servicio_inicio + INTERVAL '30 days';
  ELSE
    v_fecha_fin_efectiva := LEAST(
      NEW.fecha_servicio_fin,
      NEW.fecha_servicio_inicio + INTERVAL '30 days'
    );
  END IF;

  -- Iniciar desde fecha_servicio_inicio
  v_fecha_actual := NEW.fecha_servicio_inicio;

  -- Iterar sobre cada día del período
  WHILE v_fecha_actual <= v_fecha_fin_efectiva LOOP
    v_debe_generar := false;

    -- Determinar si se debe generar traslado según tipo_recurrencia
    CASE NEW.tipo_recurrencia

      -- DIARIO: Todos los días
      WHEN 'diario' THEN
        v_debe_generar := true;

      -- SEMANAL: Días específicos de la semana
      WHEN 'semanal' THEN
        v_dia_semana := EXTRACT(DOW FROM v_fecha_actual);
        IF NEW.dias_semana @> ARRAY[v_dia_semana] THEN
          v_debe_generar := true;
        END IF;

      -- DÍAS ALTERNOS: Cada N días
      WHEN 'dias_alternos' THEN
        v_dias_desde_inicio := v_fecha_actual - NEW.fecha_servicio_inicio;
        IF (v_dias_desde_inicio % NEW.intervalo_dias) = 0 THEN
          v_debe_generar := true;
        END IF;

      -- ESPECÍFICO: Solo en fechas listadas
      WHEN 'fechas_especificas' THEN
        IF NEW.fechas_especificas @> ARRAY[v_fecha_actual] THEN
          v_debe_generar := true;
        END IF;

      -- MENSUAL: Días específicos del mes
      WHEN 'mensual' THEN
        v_dia_mes := EXTRACT(DAY FROM v_fecha_actual);
        IF NEW.dias_mes @> ARRAY[v_dia_mes] THEN
          v_debe_generar := true;
        END IF;

    END CASE;

    -- Si se debe generar, crear traslados
    IF v_debe_generar THEN

      -- TRASLADO DE IDA (siempre se crea)
      -- ✅ NO generar código manualmente, dejar que trigger_generar_codigo_traslado_v2 lo haga
      INSERT INTO traslados (
        id_servicio_recurrente, id_paciente, id_motivo_traslado,
        tipo_traslado, fecha, hora_programada,
        tipo_origen, origen, origen_ubicacion_centro,
        tipo_destino, destino, destino_ubicacion_centro,
        tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
        requiere_camilla, prioridad, observaciones, observaciones_medicas,
        estado, generado_automaticamente, created_at, updated_at
      ) VALUES (
        NEW.id, NEW.id_paciente, NEW.id_motivo_traslado,
        'ida', v_fecha_actual, NEW.hora_recogida,
        NEW.tipo_origen, NEW.origen, NEW.origen_ubicacion_centro,
        NEW.tipo_destino, NEW.destino, NEW.destino_ubicacion_centro,
        NEW.tipo_ambulancia, COALESCE(NEW.requiere_acompanante, false),
        COALESCE(NEW.requiere_silla_ruedas, false),
        COALESCE(NEW.requiere_camilla, false), COALESCE(NEW.prioridad, 5),
        NEW.observaciones, NEW.observaciones_medicas,
        'pendiente', true, NOW(), NOW()
      );

      v_traslados_generados := v_traslados_generados + 1;

      -- TRASLADO DE VUELTA (solo si requiere_vuelta = true)
      IF NEW.requiere_vuelta = true THEN
        -- ✅ NO generar código manualmente, dejar que trigger_generar_codigo_traslado_v2 lo haga
        INSERT INTO traslados (
          id_servicio_recurrente, id_paciente, id_motivo_traslado,
          tipo_traslado, fecha, hora_programada,
          tipo_origen, origen, origen_ubicacion_centro,
          tipo_destino, destino, destino_ubicacion_centro,
          tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
          requiere_camilla, prioridad, observaciones, observaciones_medicas,
          estado, generado_automaticamente, created_at, updated_at
        ) VALUES (
          NEW.id, NEW.id_paciente, NEW.id_motivo_traslado,
          'vuelta', v_fecha_actual, NEW.hora_vuelta,
          NEW.tipo_destino, NEW.destino, NEW.destino_ubicacion_centro,  -- ✅ INVERTIDO
          NEW.tipo_origen, NEW.origen, NEW.origen_ubicacion_centro,      -- ✅ INVERTIDO
          NEW.tipo_ambulancia, COALESCE(NEW.requiere_acompanante, false),
          COALESCE(NEW.requiere_silla_ruedas, false),
          COALESCE(NEW.requiere_camilla, false), COALESCE(NEW.prioridad, 5),
          NEW.observaciones, NEW.observaciones_medicas,
          'pendiente', true, NOW(), NOW()
        );

        v_traslados_generados := v_traslados_generados + 1;
      END IF;

    END IF;

    -- Avanzar al siguiente día
    v_fecha_actual := v_fecha_actual + INTERVAL '1 day';
  END LOOP;

  -- Actualizar traslados_generados_hasta
  UPDATE servicios_recurrentes
  SET traslados_generados_hasta = v_fecha_fin_efectiva
  WHERE id = NEW.id;

  RAISE NOTICE 'Generados % traslados para servicio recurrente %', v_traslados_generados, NEW.codigo;

  RETURN NEW;
END;
$function$;

COMMENT ON FUNCTION generar_traslados_recurrente() IS
'Genera traslados automáticamente al crear un servicio recurrente.
INCLUYE id_motivo_traslado para propagar el motivo de traslado.
Los códigos de traslados NO se generan aquí, se delegan al trigger
BEFORE INSERT trigger_generar_codigo_traslado que usa UUID.
Esto evita duplicados cuando se generan múltiples traslados simultáneamente.';

-- Refrescar schema cache
NOTIFY pgrst, 'reload schema';
