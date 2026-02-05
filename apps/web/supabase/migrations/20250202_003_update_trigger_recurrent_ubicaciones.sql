-- =====================================================
-- TRIGGER: Actualizar generar_traslados_al_crear_servicio_recurrente
-- Descripción: Extrae ubicaciones_centro del JSONB trayectos y las guarda en columnas dedicadas
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-02-02
-- =====================================================

-- Función actualizada para generar traslados al crear servicio recurrente
CREATE OR REPLACE FUNCTION generar_traslados_al_crear_servicio_recurrente()
RETURNS TRIGGER AS $$
DECLARE
  v_fecha_actual DATE;
  v_fecha_fin_efectiva DATE;
  v_dia_semana INTEGER;
  v_semana_desde_inicio INTEGER;
  v_dias_desde_inicio INTEGER;
  v_dia_mes INTEGER;
  v_debe_generar BOOLEAN;
  v_traslados_generados INTEGER := 0;
  v_trayecto_ida JSONB;
  v_trayecto_vuelta JSONB;
  v_origen_ubicacion_centro TEXT;
  v_destino_ubicacion_centro TEXT;
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

  -- Extraer trayectos del JSONB
  IF jsonb_array_length(NEW.trayectos) > 0 THEN
    v_trayecto_ida := NEW.trayectos->0;
  END IF;

  IF jsonb_array_length(NEW.trayectos) > 1 THEN
    v_trayecto_vuelta := NEW.trayectos->1;
  ELSE
    v_trayecto_vuelta := v_trayecto_ida; -- Usar mismo trayecto invertido si solo hay uno
  END IF;

  -- Iterar sobre cada día del período
  WHILE v_fecha_actual <= v_fecha_fin_efectiva LOOP
    v_debe_generar := false;

    -- Determinar si se debe generar traslado según tipo_recurrencia
    CASE NEW.tipo_recurrencia

      -- ÚNICO: Solo en fecha_servicio_inicio
      WHEN 'unico' THEN
        IF v_fecha_actual = NEW.fecha_servicio_inicio THEN
          v_debe_generar := true;
        END IF;

      -- DIARIO: Todos los días
      WHEN 'diario' THEN
        v_debe_generar := true;

      -- SEMANAL: Días específicos de la semana
      WHEN 'semanal' THEN
        v_dia_semana := EXTRACT(DOW FROM v_fecha_actual);
        IF NEW.dias_semana @> ARRAY[v_dia_semana] THEN
          v_debe_generar := true;
        END IF;

      -- SEMANAS ALTERNAS: Cada N semanas, en días específicos
      WHEN 'semanas_alternas' THEN
        v_dia_semana := EXTRACT(DOW FROM v_fecha_actual);
        v_semana_desde_inicio := FLOOR((v_fecha_actual - NEW.fecha_servicio_inicio) / 7);

        IF (v_semana_desde_inicio % NEW.intervalo_semanas) = 0
           AND NEW.dias_semana @> ARRAY[v_dia_semana] THEN
          v_debe_generar := true;
        END IF;

      -- DÍAS ALTERNOS: Cada N días
      WHEN 'dias_alternos' THEN
        v_dias_desde_inicio := v_fecha_actual - NEW.fecha_servicio_inicio;
        IF (v_dias_desde_inicio % NEW.intervalo_dias) = 0 THEN
          v_debe_generar := true;
        END IF;

      -- MENSUAL: Días específicos del mes
      WHEN 'mensual' THEN
        v_dia_mes := EXTRACT(DAY FROM v_fecha_actual);
        IF NEW.dias_mes @> ARRAY[v_dia_mes] THEN
          v_debe_generar := true;
        END IF;

      -- ESPECÍFICO: Solo en fechas listadas
      WHEN 'especifico' THEN
        IF NEW.fechas_especificas @> ARRAY[v_fecha_actual] THEN
          v_debe_generar := true;
        END IF;

    END CASE;

    -- Si se debe generar, crear traslados
    IF v_debe_generar THEN

      -- Extraer ubicaciones en centro del trayecto de IDA
      v_origen_ubicacion_centro := v_trayecto_ida->>'origen_ubicacion_centro';
      v_destino_ubicacion_centro := v_trayecto_ida->>'destino_ubicacion_centro';

      -- TRASLADO DE IDA (siempre se crea)
      INSERT INTO traslados (
        id_servicio_recurrente,
        id_paciente,
        tipo_traslado,
        fecha,
        hora_programada,
        trayecto,
        origen_ubicacion_centro,  -- 🆕 NUEVO CAMPO
        destino_ubicacion_centro, -- 🆕 NUEVO CAMPO
        observaciones,
        generado_automaticamente,
        created_by
      )
      VALUES (
        NEW.id,
        NEW.id_paciente,
        'ida',
        v_fecha_actual,
        NEW.hora_recogida,
        v_trayecto_ida,  -- Solo el primer trayecto
        v_origen_ubicacion_centro,  -- 🆕 Ubicación en origen
        v_destino_ubicacion_centro, -- 🆕 Ubicación en destino
        NEW.observaciones,
        true,
        NEW.created_by
      )
      ON CONFLICT (id_servicio_recurrente, fecha, tipo_traslado) DO NOTHING;

      IF FOUND THEN
        v_traslados_generados := v_traslados_generados + 1;
      END IF;

      -- TRASLADO DE VUELTA (solo si requiere_vuelta = true)
      IF NEW.requiere_vuelta = true THEN
        -- Extraer ubicaciones del trayecto de VUELTA (o invertir si es el mismo)
        IF jsonb_array_length(NEW.trayectos) > 1 THEN
          v_origen_ubicacion_centro := v_trayecto_vuelta->>'origen_ubicacion_centro';
          v_destino_ubicacion_centro := v_trayecto_vuelta->>'destino_ubicacion_centro';
        ELSE
          -- Invertir ubicaciones si solo hay un trayecto
          v_origen_ubicacion_centro := v_trayecto_ida->>'destino_ubicacion_centro';
          v_destino_ubicacion_centro := v_trayecto_ida->>'origen_ubicacion_centro';
        END IF;

        INSERT INTO traslados (
          id_servicio_recurrente,
          id_paciente,
          tipo_traslado,
          fecha,
          hora_programada,
          trayecto,
          origen_ubicacion_centro,  -- 🆕 NUEVO CAMPO
          destino_ubicacion_centro, -- 🆕 NUEVO CAMPO
          observaciones,
          generado_automaticamente,
          created_by
        )
        VALUES (
          NEW.id,
          NEW.id_paciente,
          'vuelta',
          v_fecha_actual,
          NEW.hora_vuelta,
          v_trayecto_vuelta,  -- Segundo trayecto o mismo invertido
          v_origen_ubicacion_centro,  -- 🆕 Ubicación en origen de vuelta
          v_destino_ubicacion_centro, -- 🆕 Ubicación en destino de vuelta
          NEW.observaciones,
          true,
          NEW.created_by
        )
        ON CONFLICT (id_servicio_recurrente, fecha, tipo_traslado) DO NOTHING;

        IF FOUND THEN
          v_traslados_generados := v_traslados_generados + 1;
        END IF;
      END IF;

    END IF;

    -- Avanzar al siguiente día
    v_fecha_actual := v_fecha_actual + INTERVAL '1 day';
  END LOOP;

  -- Actualizar traslados_generados_hasta
  NEW.traslados_generados_hasta := v_fecha_fin_efectiva;

  RAISE NOTICE 'Generados % traslados para servicio recurrente %', v_traslados_generados, NEW.codigo;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- El trigger ya está creado, solo necesitamos reemplazar la función
COMMENT ON FUNCTION generar_traslados_al_crear_servicio_recurrente() IS
'Genera traslados automáticamente al crear un servicio recurrente.
Crea traslados para los próximos 30 días (o hasta fecha_servicio_fin si es menor).
Soporta todos los tipos de recurrencia: único, diario, semanal, semanas_alternas, dias_alternos, mensual, especifico.
Extrae y guarda ubicaciones_centro del JSONB trayectos en columnas dedicadas:
  - origen_ubicacion_centro (ej: Urgencias, Hab-202)
  - destino_ubicacion_centro (ej: UCI, Sala de Espera)';

-- Refrescar el schema cache
NOTIFY pgrst, 'reload schema';
