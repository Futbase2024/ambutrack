-- =====================================================
-- FUNCIÓN: Actualizar generar_traslados_periodo
-- Descripción: Extrae ubicaciones_centro del JSONB trayectos y las guarda en columnas dedicadas
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-02-02
-- =====================================================

CREATE OR REPLACE FUNCTION generar_traslados_periodo(
  p_fecha_desde DATE,
  p_fecha_hasta DATE
)
RETURNS TABLE(
  servicios_procesados INTEGER,
  traslados_generados INTEGER,
  traslados_ida INTEGER,
  traslados_vuelta INTEGER,
  servicios_con_error INTEGER,
  errores TEXT[]
) AS $$
DECLARE
  v_servicio RECORD;
  v_fecha_actual DATE;
  v_fecha_inicio_efectiva DATE;
  v_fecha_fin_efectiva DATE;
  v_dia_semana INTEGER;
  v_semana_desde_inicio INTEGER;
  v_dias_desde_inicio INTEGER;
  v_dia_mes INTEGER;
  v_debe_generar BOOLEAN;
  v_trayecto_ida JSONB;
  v_trayecto_vuelta JSONB;
  v_origen_ubicacion_centro TEXT;
  v_destino_ubicacion_centro TEXT;

  v_servicios_procesados INTEGER := 0;
  v_traslados_generados INTEGER := 0;
  v_traslados_ida INTEGER := 0;
  v_traslados_vuelta INTEGER := 0;
  v_servicios_error INTEGER := 0;
  v_errores TEXT[] := ARRAY[]::TEXT[];
BEGIN
  -- Iterar sobre todos los servicios activos que intersectan con el período
  FOR v_servicio IN
    SELECT * FROM servicios s
    WHERE s.activo = true
      AND s.fecha_servicio_inicio <= p_fecha_hasta
      AND (s.fecha_servicio_fin IS NULL OR s.fecha_servicio_fin >= p_fecha_desde)
    ORDER BY s.fecha_servicio_inicio
  LOOP
    BEGIN
      v_servicios_procesados := v_servicios_procesados + 1;

      -- Extraer trayectos del JSONB
      IF jsonb_array_length(v_servicio.trayectos) > 0 THEN
        v_trayecto_ida := v_servicio.trayectos->0;
      ELSE
        v_trayecto_ida := NULL;
      END IF;

      IF jsonb_array_length(v_servicio.trayectos) > 1 THEN
        v_trayecto_vuelta := v_servicio.trayectos->1;
      ELSE
        v_trayecto_vuelta := v_trayecto_ida; -- Usar mismo trayecto invertido si solo hay uno
      END IF;

      -- Determinar el rango efectivo para este servicio
      v_fecha_inicio_efectiva := GREATEST(v_servicio.fecha_servicio_inicio, p_fecha_desde);

      IF v_servicio.fecha_servicio_fin IS NULL THEN
        v_fecha_fin_efectiva := p_fecha_hasta;
      ELSE
        v_fecha_fin_efectiva := LEAST(v_servicio.fecha_servicio_fin, p_fecha_hasta);
      END IF;

      -- Iniciar desde la fecha efectiva
      v_fecha_actual := v_fecha_inicio_efectiva;

      -- Iterar sobre cada día del período
      WHILE v_fecha_actual <= v_fecha_fin_efectiva LOOP
        v_debe_generar := false;

        -- Determinar si se debe generar traslado según tipo_recurrencia
        CASE v_servicio.tipo_recurrencia

          -- ÚNICO: Solo en fecha_servicio_inicio
          WHEN 'unico' THEN
            IF v_fecha_actual = v_servicio.fecha_servicio_inicio THEN
              v_debe_generar := true;
            END IF;

          -- DIARIO: Todos los días
          WHEN 'diario' THEN
            v_debe_generar := true;

          -- SEMANAL: Días específicos de la semana
          WHEN 'semanal' THEN
            v_dia_semana := EXTRACT(DOW FROM v_fecha_actual); -- 0=domingo, 6=sábado
            IF v_servicio.dias_semana @> ARRAY[v_dia_semana] THEN
              v_debe_generar := true;
            END IF;

          -- SEMANAS ALTERNAS: Cada N semanas, en días específicos
          WHEN 'semanas_alternas' THEN
            v_dia_semana := EXTRACT(DOW FROM v_fecha_actual);
            v_semana_desde_inicio := FLOOR((v_fecha_actual - v_servicio.fecha_servicio_inicio) / 7);

            IF (v_semana_desde_inicio % v_servicio.intervalo_semanas) = 0
               AND v_servicio.dias_semana @> ARRAY[v_dia_semana] THEN
              v_debe_generar := true;
            END IF;

          -- DÍAS ALTERNOS: Cada N días
          WHEN 'dias_alternos' THEN
            v_dias_desde_inicio := v_fecha_actual - v_servicio.fecha_servicio_inicio;
            IF (v_dias_desde_inicio % v_servicio.intervalo_dias) = 0 THEN
              v_debe_generar := true;
            END IF;

          -- MENSUAL: Días específicos del mes
          WHEN 'mensual' THEN
            v_dia_mes := EXTRACT(DAY FROM v_fecha_actual);
            IF v_servicio.dias_mes @> ARRAY[v_dia_mes] THEN
              v_debe_generar := true;
            END IF;

          -- ESPECÍFICO: Solo en fechas listadas
          WHEN 'especifico' THEN
            IF v_servicio.fechas_especificas @> ARRAY[v_fecha_actual] THEN
              v_debe_generar := true;
            END IF;

        END CASE;

        -- Si se debe generar, crear traslados
        IF v_debe_generar THEN

          -- Extraer ubicaciones en centro del trayecto de IDA
          IF v_trayecto_ida IS NOT NULL THEN
            v_origen_ubicacion_centro := v_trayecto_ida->>'origen_ubicacion_centro';
            v_destino_ubicacion_centro := v_trayecto_ida->>'destino_ubicacion_centro';
          ELSE
            v_origen_ubicacion_centro := NULL;
            v_destino_ubicacion_centro := NULL;
          END IF;

          -- TRASLADO DE IDA (siempre se crea)
          INSERT INTO traslados (
            id_servicio,
            id_paciente,
            tipo_traslado,
            fecha,
            hora_programada,
            trayecto,
            origen_ubicacion_centro,  -- 🆕 NUEVO CAMPO
            destino_ubicacion_centro, -- 🆕 NUEVO CAMPO
            tipo_ambulancia,
            requiere_acompanante,
            requiere_silla_ruedas,
            requiere_camilla,
            observaciones,
            observaciones_medicas,
            generado_automaticamente,
            prioridad,
            created_by
          )
          VALUES (
            v_servicio.id,
            v_servicio.id_paciente,
            'ida',
            v_fecha_actual,
            v_servicio.hora_recogida,
            v_trayecto_ida,  -- Solo el primer trayecto
            v_origen_ubicacion_centro,  -- 🆕 Ubicación en origen
            v_destino_ubicacion_centro, -- 🆕 Ubicación en destino
            v_servicio.tipo_ambulancia,
            v_servicio.requiere_acompanante,
            v_servicio.requiere_silla_ruedas,
            v_servicio.requiere_camilla,
            v_servicio.observaciones,
            v_servicio.observaciones_medicas,
            true,
            v_servicio.prioridad,
            v_servicio.created_by
          )
          ON CONFLICT (id_servicio, fecha, tipo_traslado) DO NOTHING;

          IF FOUND THEN
            v_traslados_generados := v_traslados_generados + 1;
            v_traslados_ida := v_traslados_ida + 1;
          END IF;

          -- TRASLADO DE VUELTA (solo si requiere_vuelta = true)
          IF v_servicio.requiere_vuelta = true THEN
            -- Extraer ubicaciones del trayecto de VUELTA (o invertir si es el mismo)
            IF v_trayecto_vuelta IS NOT NULL THEN
              IF jsonb_array_length(v_servicio.trayectos) > 1 THEN
                v_origen_ubicacion_centro := v_trayecto_vuelta->>'origen_ubicacion_centro';
                v_destino_ubicacion_centro := v_trayecto_vuelta->>'destino_ubicacion_centro';
              ELSE
                -- Invertir ubicaciones si solo hay un trayecto
                v_origen_ubicacion_centro := v_trayecto_ida->>'destino_ubicacion_centro';
                v_destino_ubicacion_centro := v_trayecto_ida->>'origen_ubicacion_centro';
              END IF;
            ELSE
              v_origen_ubicacion_centro := NULL;
              v_destino_ubicacion_centro := NULL;
            END IF;

            INSERT INTO traslados (
              id_servicio,
              id_paciente,
              tipo_traslado,
              fecha,
              hora_programada,
              trayecto,
              origen_ubicacion_centro,  -- 🆕 NUEVO CAMPO
              destino_ubicacion_centro, -- 🆕 NUEVO CAMPO
              tipo_ambulancia,
              requiere_acompanante,
              requiere_silla_ruedas,
              requiere_camilla,
              observaciones,
              observaciones_medicas,
              generado_automaticamente,
              prioridad,
              created_by
            )
            VALUES (
              v_servicio.id,
              v_servicio.id_paciente,
              'vuelta',
              v_fecha_actual,
              v_servicio.hora_vuelta,
              v_trayecto_vuelta,  -- Segundo trayecto o mismo invertido
              v_origen_ubicacion_centro,  -- 🆕 Ubicación en origen de vuelta
              v_destino_ubicacion_centro, -- 🆕 Ubicación en destino de vuelta
              v_servicio.tipo_ambulancia,
              v_servicio.requiere_acompanante,
              v_servicio.requiere_silla_ruedas,
              v_servicio.requiere_camilla,
              v_servicio.observaciones,
              v_servicio.observaciones_medicas,
              true,
              v_servicio.prioridad,
              v_servicio.created_by
            )
            ON CONFLICT (id_servicio, fecha, tipo_traslado) DO NOTHING;

            IF FOUND THEN
              v_traslados_generados := v_traslados_generados + 1;
              v_traslados_vuelta := v_traslados_vuelta + 1;
            END IF;
          END IF;

        END IF;

        -- Avanzar al siguiente día
        v_fecha_actual := v_fecha_actual + INTERVAL '1 day';
      END LOOP;

      -- Actualizar traslados_generados_hasta en el servicio
      UPDATE servicios
      SET traslados_generados_hasta = v_fecha_fin_efectiva
      WHERE id = v_servicio.id
        AND (traslados_generados_hasta IS NULL OR traslados_generados_hasta < v_fecha_fin_efectiva);

    EXCEPTION
      WHEN OTHERS THEN
        v_servicios_error := v_servicios_error + 1;
        v_errores := array_append(v_errores,
          'Servicio ' || v_servicio.codigo || ': ' || SQLERRM
        );
        RAISE WARNING 'Error procesando servicio %: %', v_servicio.codigo, SQLERRM;
        CONTINUE;
    END;
  END LOOP;

  -- Retornar resumen
  RETURN QUERY SELECT
    v_servicios_procesados,
    v_traslados_generados,
    v_traslados_ida,
    v_traslados_vuelta,
    v_servicios_error,
    v_errores;
END;
$$ LANGUAGE plpgsql;

-- Actualizar comentario de documentación
COMMENT ON FUNCTION generar_traslados_periodo(DATE, DATE) IS
'Genera traslados automáticamente para el período especificado basándose en servicios activos.
Soporta todos los tipos de recurrencia: único, diario, semanal, semanas_alternas, dias_alternos, mensual, especifico.
Evita duplicados mediante ON CONFLICT DO NOTHING.
Actualiza traslados_generados_hasta en cada servicio procesado.
Extrae y guarda ubicaciones_centro del JSONB trayectos en columnas dedicadas:
  - origen_ubicacion_centro (ej: Urgencias, Hab-202)
  - destino_ubicacion_centro (ej: UCI, Sala de Espera)';

-- Refrescar el schema cache
NOTIFY pgrst, 'reload schema';
