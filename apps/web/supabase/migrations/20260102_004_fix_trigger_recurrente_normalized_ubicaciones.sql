-- =====================================================
-- MIGRACIÓN: Actualizar trigger de servicios recurrentes para campos normalizados
-- Descripción: Actualiza generar_traslados_recurrente() para usar campos normalizados
--              (tipo_origen, origen, origen_ubicacion_centro, etc.) en lugar de hardcodear valores
-- Autor: Sistema AmbuTrack
-- Fecha: 2026-01-02
-- Dependencias: 20260102_003_add_ubicacion_centro_to_servicios_recurrentes.sql
-- =====================================================

CREATE OR REPLACE FUNCTION generar_traslados_recurrente()
RETURNS TRIGGER AS $$
DECLARE
  v_fecha_actual DATE;
  v_fecha_fin DATE;
  v_contador INTEGER := 0;
  v_codigo_traslado VARCHAR;
  v_dia_semana INTEGER;
  v_dias_generados INTEGER := 0;
  v_max_dias INTEGER := 14; -- ✅ Solo 14 días inicialmente
BEGIN
  -- ✅ Determinar fecha final: 14 días desde fecha_inicio (o fecha_fin si es menor)
  IF NEW.fecha_servicio_fin IS NOT NULL THEN
    v_fecha_fin := LEAST(NEW.fecha_servicio_fin, NEW.fecha_servicio_inicio + INTERVAL '14 days');
  ELSE
    v_fecha_fin := NEW.fecha_servicio_inicio + INTERVAL '14 days';
  END IF;

  v_fecha_actual := NEW.fecha_servicio_inicio;

  RAISE NOTICE '🔧 Generando traslados recurrentes desde % hasta % (máx %d días)',
    NEW.fecha_servicio_inicio, v_fecha_fin, v_max_dias;

  -- ⚠️ NOTA: tipo_recurrencia 'unico' se maneja en generar_traslados_servicio_unico()
  -- Esta función solo maneja: diario, semanal, dias_alternos, fechas_especificas, mensual

  -- Generar traslados según tipo de recurrencia
  CASE NEW.tipo_recurrencia

    -- ==== SERVICIO DIARIO ====
    WHEN 'diario' THEN
      WHILE v_fecha_actual <= v_fecha_fin AND v_dias_generados < v_max_dias LOOP
        v_codigo_traslado := 'TRA-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '-' || v_contador;
        v_contador := v_contador + 1;

        -- Traslado de IDA (usa campos normalizados de servicios_recurrentes)
        INSERT INTO traslados (
          codigo, id_servicio_recurrente, id_paciente,
          tipo_traslado, fecha, hora_programada,
          tipo_origen,              -- ✅ Campo normalizado
          origen,                   -- ✅ Campo normalizado
          origen_ubicacion_centro,  -- ✅ NUEVO: Ubicación en centro
          tipo_destino,             -- ✅ Campo normalizado
          destino,                  -- ✅ Campo normalizado
          destino_ubicacion_centro, -- ✅ NUEVO: Ubicación en centro
          tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
          requiere_camilla, prioridad, observaciones, observaciones_medicas,
          estado, generado_automaticamente, created_at, updated_at
        ) VALUES (
          v_codigo_traslado, NEW.id, NEW.id_paciente,
          'ida', v_fecha_actual, NEW.hora_recogida,
          NEW.tipo_origen,              -- ✅ Copia directa
          NEW.origen,                   -- ✅ Copia directa
          NEW.origen_ubicacion_centro,  -- ✅ Copia directa (puede ser NULL)
          NEW.tipo_destino,             -- ✅ Copia directa
          NEW.destino,                  -- ✅ Copia directa
          NEW.destino_ubicacion_centro, -- ✅ Copia directa (puede ser NULL)
          NEW.tipo_ambulancia, COALESCE(NEW.requiere_acompanante, false),
          COALESCE(NEW.requiere_silla_ruedas, false),
          COALESCE(NEW.requiere_camilla, false), COALESCE(NEW.prioridad, 5),
          NEW.observaciones, NEW.observaciones_medicas,
          'pendiente', true, NOW(), NOW()
        );

        -- Traslado de VUELTA si corresponde (INVERTIR origen ↔ destino)
        IF NEW.requiere_vuelta AND NEW.hora_vuelta IS NOT NULL THEN
          v_codigo_traslado := 'TRA-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '-' || v_contador;
          v_contador := v_contador + 1;

          INSERT INTO traslados (
            codigo, id_servicio_recurrente, id_paciente,
            tipo_traslado, fecha, hora_programada,
            tipo_origen,              -- ✅ INVERTIDO
            origen,                   -- ✅ INVERTIDO
            origen_ubicacion_centro,  -- ✅ INVERTIDO
            tipo_destino,             -- ✅ INVERTIDO
            destino,                  -- ✅ INVERTIDO
            destino_ubicacion_centro, -- ✅ INVERTIDO
            tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
            requiere_camilla, prioridad, observaciones, observaciones_medicas,
            estado, generado_automaticamente, created_at, updated_at
          ) VALUES (
            v_codigo_traslado, NEW.id, NEW.id_paciente,
            'vuelta', v_fecha_actual, NEW.hora_vuelta,
            NEW.tipo_destino,             -- ✅ INVERTIDO
            NEW.destino,                  -- ✅ INVERTIDO
            NEW.destino_ubicacion_centro, -- ✅ INVERTIDO
            NEW.tipo_origen,              -- ✅ INVERTIDO
            NEW.origen,                   -- ✅ INVERTIDO
            NEW.origen_ubicacion_centro,  -- ✅ INVERTIDO
            NEW.tipo_ambulancia, COALESCE(NEW.requiere_acompanante, false),
            COALESCE(NEW.requiere_silla_ruedas, false),
            COALESCE(NEW.requiere_camilla, false), COALESCE(NEW.prioridad, 5),
            NEW.observaciones, NEW.observaciones_medicas,
            'pendiente', true, NOW(), NOW()
          );
        END IF;

        v_dias_generados := v_dias_generados + 1;
        v_fecha_actual := v_fecha_actual + INTERVAL '1 day';
      END LOOP;

    -- ==== SERVICIO SEMANAL ====
    WHEN 'semanal' THEN
      WHILE v_fecha_actual <= v_fecha_fin AND v_dias_generados < v_max_dias LOOP
        v_dia_semana := EXTRACT(DOW FROM v_fecha_actual);

        IF NEW.dias_semana @> ARRAY[v_dia_semana] THEN
          v_codigo_traslado := 'TRA-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '-' || v_contador;
          v_contador := v_contador + 1;

          INSERT INTO traslados (
            codigo, id_servicio_recurrente, id_paciente,
            tipo_traslado, fecha, hora_programada,
            tipo_origen, origen, origen_ubicacion_centro,
            tipo_destino, destino, destino_ubicacion_centro,
            tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
            requiere_camilla, prioridad, observaciones, observaciones_medicas,
            estado, generado_automaticamente, created_at, updated_at
          ) VALUES (
            v_codigo_traslado, NEW.id, NEW.id_paciente,
            'ida', v_fecha_actual, NEW.hora_recogida,
            NEW.tipo_origen, NEW.origen, NEW.origen_ubicacion_centro,
            NEW.tipo_destino, NEW.destino, NEW.destino_ubicacion_centro,
            NEW.tipo_ambulancia, COALESCE(NEW.requiere_acompanante, false),
            COALESCE(NEW.requiere_silla_ruedas, false),
            COALESCE(NEW.requiere_camilla, false), COALESCE(NEW.prioridad, 5),
            NEW.observaciones, NEW.observaciones_medicas,
            'pendiente', true, NOW(), NOW()
          );

          IF NEW.requiere_vuelta AND NEW.hora_vuelta IS NOT NULL THEN
            v_codigo_traslado := 'TRA-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '-' || v_contador;
            v_contador := v_contador + 1;

            INSERT INTO traslados (
              codigo, id_servicio_recurrente, id_paciente,
              tipo_traslado, fecha, hora_programada,
              tipo_origen, origen, origen_ubicacion_centro,
              tipo_destino, destino, destino_ubicacion_centro,
              tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
              requiere_camilla, prioridad, observaciones, observaciones_medicas,
              estado, generado_automaticamente, created_at, updated_at
            ) VALUES (
              v_codigo_traslado, NEW.id, NEW.id_paciente,
              'vuelta', v_fecha_actual, NEW.hora_vuelta,
              NEW.tipo_destino, NEW.destino, NEW.destino_ubicacion_centro,  -- INVERTIDO
              NEW.tipo_origen, NEW.origen, NEW.origen_ubicacion_centro,      -- INVERTIDO
              NEW.tipo_ambulancia, COALESCE(NEW.requiere_acompanante, false),
              COALESCE(NEW.requiere_silla_ruedas, false),
              COALESCE(NEW.requiere_camilla, false), COALESCE(NEW.prioridad, 5),
              NEW.observaciones, NEW.observaciones_medicas,
              'pendiente', true, NOW(), NOW()
            );
          END IF;

          v_dias_generados := v_dias_generados + 1;
        END IF;

        v_fecha_actual := v_fecha_actual + INTERVAL '1 day';
      END LOOP;

    -- ==== DÍAS ALTERNOS ====
    WHEN 'dias_alternos' THEN
      WHILE v_fecha_actual <= v_fecha_fin AND v_dias_generados < v_max_dias LOOP
        v_codigo_traslado := 'TRA-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '-' || v_contador;
        v_contador := v_contador + 1;

        INSERT INTO traslados (
          codigo, id_servicio_recurrente, id_paciente,
          tipo_traslado, fecha, hora_programada,
          tipo_origen, origen, origen_ubicacion_centro,
          tipo_destino, destino, destino_ubicacion_centro,
          tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
          requiere_camilla, prioridad, observaciones, observaciones_medicas,
          estado, generado_automaticamente, created_at, updated_at
        ) VALUES (
          v_codigo_traslado, NEW.id, NEW.id_paciente,
          'ida', v_fecha_actual, NEW.hora_recogida,
          NEW.tipo_origen, NEW.origen, NEW.origen_ubicacion_centro,
          NEW.tipo_destino, NEW.destino, NEW.destino_ubicacion_centro,
          NEW.tipo_ambulancia, COALESCE(NEW.requiere_acompanante, false),
          COALESCE(NEW.requiere_silla_ruedas, false),
          COALESCE(NEW.requiere_camilla, false), COALESCE(NEW.prioridad, 5),
          NEW.observaciones, NEW.observaciones_medicas,
          'pendiente', true, NOW(), NOW()
        );

        IF NEW.requiere_vuelta AND NEW.hora_vuelta IS NOT NULL THEN
          v_codigo_traslado := 'TRA-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '-' || v_contador;
          v_contador := v_contador + 1;

          INSERT INTO traslados (
            codigo, id_servicio_recurrente, id_paciente,
            tipo_traslado, fecha, hora_programada,
            tipo_origen, origen, origen_ubicacion_centro,
            tipo_destino, destino, destino_ubicacion_centro,
            tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
            requiere_camilla, prioridad, observaciones, observaciones_medicas,
            estado, generado_automaticamente, created_at, updated_at
          ) VALUES (
            v_codigo_traslado, NEW.id, NEW.id_paciente,
            'vuelta', v_fecha_actual, NEW.hora_vuelta,
            NEW.tipo_destino, NEW.destino, NEW.destino_ubicacion_centro,  -- INVERTIDO
            NEW.tipo_origen, NEW.origen, NEW.origen_ubicacion_centro,      -- INVERTIDO
            NEW.tipo_ambulancia, COALESCE(NEW.requiere_acompanante, false),
            COALESCE(NEW.requiere_silla_ruedas, false),
            COALESCE(NEW.requiere_camilla, false), COALESCE(NEW.prioridad, 5),
            NEW.observaciones, NEW.observaciones_medicas,
            'pendiente', true, NOW(), NOW()
          );
        END IF;

        v_dias_generados := v_dias_generados + 1;
        -- Saltar N días (intervalo_dias)
        v_fecha_actual := v_fecha_actual + (COALESCE(NEW.intervalo_dias, 2) || ' days')::INTERVAL;
      END LOOP;

    -- ==== FECHAS ESPECÍFICAS ====
    WHEN 'fechas_especificas' THEN
      IF NEW.fechas_especificas IS NOT NULL THEN
        FOREACH v_fecha_actual IN ARRAY NEW.fechas_especificas LOOP
          IF v_fecha_actual <= v_fecha_fin THEN
            v_codigo_traslado := 'TRA-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '-' || v_contador;
            v_contador := v_contador + 1;

            INSERT INTO traslados (
              codigo, id_servicio_recurrente, id_paciente,
              tipo_traslado, fecha, hora_programada,
              tipo_origen, origen, origen_ubicacion_centro,
              tipo_destino, destino, destino_ubicacion_centro,
              tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
              requiere_camilla, prioridad, observaciones, observaciones_medicas,
              estado, generado_automaticamente, created_at, updated_at
            ) VALUES (
              v_codigo_traslado, NEW.id, NEW.id_paciente,
              'ida', v_fecha_actual, NEW.hora_recogida,
              NEW.tipo_origen, NEW.origen, NEW.origen_ubicacion_centro,
              NEW.tipo_destino, NEW.destino, NEW.destino_ubicacion_centro,
              NEW.tipo_ambulancia, COALESCE(NEW.requiere_acompanante, false),
              COALESCE(NEW.requiere_silla_ruedas, false),
              COALESCE(NEW.requiere_camilla, false), COALESCE(NEW.prioridad, 5),
              NEW.observaciones, NEW.observaciones_medicas,
              'pendiente', true, NOW(), NOW()
            );

            IF NEW.requiere_vuelta AND NEW.hora_vuelta IS NOT NULL THEN
              v_codigo_traslado := 'TRA-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '-' || v_contador;
              v_contador := v_contador + 1;

              INSERT INTO traslados (
                codigo, id_servicio_recurrente, id_paciente,
                tipo_traslado, fecha, hora_programada,
                tipo_origen, origen, origen_ubicacion_centro,
                tipo_destino, destino, destino_ubicacion_centro,
                tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
                requiere_camilla, prioridad, observaciones, observaciones_medicas,
                estado, generado_automaticamente, created_at, updated_at
              ) VALUES (
                v_codigo_traslado, NEW.id, NEW.id_paciente,
                'vuelta', v_fecha_actual, NEW.hora_vuelta,
                NEW.tipo_destino, NEW.destino, NEW.destino_ubicacion_centro,  -- INVERTIDO
                NEW.tipo_origen, NEW.origen, NEW.origen_ubicacion_centro,      -- INVERTIDO
                NEW.tipo_ambulancia, COALESCE(NEW.requiere_acompanante, false),
                COALESCE(NEW.requiere_silla_ruedas, false),
                COALESCE(NEW.requiere_camilla, false), COALESCE(NEW.prioridad, 5),
                NEW.observaciones, NEW.observaciones_medicas,
                'pendiente', true, NOW(), NOW()
              );
            END IF;
          END IF;
        END LOOP;
      END IF;

    -- ==== MENSUAL ====
    WHEN 'mensual' THEN
      WHILE v_fecha_actual <= v_fecha_fin AND v_dias_generados < v_max_dias LOOP
        IF NEW.dias_mes @> ARRAY[EXTRACT(DAY FROM v_fecha_actual)::INTEGER] THEN
          v_codigo_traslado := 'TRA-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '-' || v_contador;
          v_contador := v_contador + 1;

          INSERT INTO traslados (
            codigo, id_servicio_recurrente, id_paciente,
            tipo_traslado, fecha, hora_programada,
            tipo_origen, origen, origen_ubicacion_centro,
            tipo_destino, destino, destino_ubicacion_centro,
            tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
            requiere_camilla, prioridad, observaciones, observaciones_medicas,
            estado, generado_automaticamente, created_at, updated_at
          ) VALUES (
            v_codigo_traslado, NEW.id, NEW.id_paciente,
            'ida', v_fecha_actual, NEW.hora_recogida,
            NEW.tipo_origen, NEW.origen, NEW.origen_ubicacion_centro,
            NEW.tipo_destino, NEW.destino, NEW.destino_ubicacion_centro,
            NEW.tipo_ambulancia, COALESCE(NEW.requiere_acompanante, false),
            COALESCE(NEW.requiere_silla_ruedas, false),
            COALESCE(NEW.requiere_camilla, false), COALESCE(NEW.prioridad, 5),
            NEW.observaciones, NEW.observaciones_medicas,
            'pendiente', true, NOW(), NOW()
          );

          IF NEW.requiere_vuelta AND NEW.hora_vuelta IS NOT NULL THEN
            v_codigo_traslado := 'TRA-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '-' || v_contador;
            v_contador := v_contador + 1;

            INSERT INTO traslados (
              codigo, id_servicio_recurrente, id_paciente,
              tipo_traslado, fecha, hora_programada,
              tipo_origen, origen, origen_ubicacion_centro,
              tipo_destino, destino, destino_ubicacion_centro,
              tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas,
              requiere_camilla, prioridad, observaciones, observaciones_medicas,
              estado, generado_automaticamente, created_at, updated_at
            ) VALUES (
              v_codigo_traslado, NEW.id, NEW.id_paciente,
              'vuelta', v_fecha_actual, NEW.hora_vuelta,
              NEW.tipo_destino, NEW.destino, NEW.destino_ubicacion_centro,  -- INVERTIDO
              NEW.tipo_origen, NEW.origen, NEW.origen_ubicacion_centro,      -- INVERTIDO
              NEW.tipo_ambulancia, COALESCE(NEW.requiere_acompanante, false),
              COALESCE(NEW.requiere_silla_ruedas, false),
              COALESCE(NEW.requiere_camilla, false), COALESCE(NEW.prioridad, 5),
              NEW.observaciones, NEW.observaciones_medicas,
              'pendiente', true, NOW(), NOW()
            );
          END IF;

          v_dias_generados := v_dias_generados + 1;
        END IF;

        v_fecha_actual := v_fecha_actual + INTERVAL '1 day';
      END LOOP;
  END CASE;

  -- ✅ Actualizar traslados_generados_hasta con la fecha real generada
  UPDATE servicios_recurrentes
  SET traslados_generados_hasta = v_fecha_fin
  WHERE id = NEW.id;

  RAISE NOTICE '✅ Traslados recurrentes generados: % (hasta %)', v_contador, v_fecha_fin;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generar_traslados_recurrente() IS
'Genera traslados automáticamente al crear servicios_recurrentes.
Usa campos normalizados:
- tipo_origen, origen, origen_ubicacion_centro
- tipo_destino, destino, destino_ubicacion_centro
Para traslados de VUELTA, invierte origen ↔ destino.
Genera máximo 14 días de traslados inicialmente.';

-- Refrescar el schema cache
NOTIFY pgrst, 'reload schema';
