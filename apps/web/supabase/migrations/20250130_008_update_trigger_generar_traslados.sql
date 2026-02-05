-- =====================================================
-- TRIGGER: generar_traslados_al_crear_servicio_recurrente
-- Descripción: Genera traslados automáticamente al crear un servicio recurrente
-- Arquitectura:
--   servicios → servicios_recurrentes → traslados (generados automáticamente)
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-01-30
-- =====================================================

-- Función para generar traslados al crear servicio recurrente
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

      -- TRASLADO DE IDA (siempre se crea)
      INSERT INTO traslados (
        id_servicio_recurrente,
        id_paciente,
        tipo_traslado,
        fecha,
        hora_programada,
        trayecto,
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
        NEW.trayectos,
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
        INSERT INTO traslados (
          id_servicio_recurrente,
          id_paciente,
          tipo_traslado,
          fecha,
          hora_programada,
          trayecto,
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
          NEW.trayectos, -- El trayecto se invierte en la lógica de la app
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

-- Trigger que se ejecuta al insertar en servicios_recurrentes
DROP TRIGGER IF EXISTS trigger_generar_traslados_servicio_rec ON servicios_recurrentes;

CREATE TRIGGER trigger_generar_traslados_servicio_rec
  AFTER INSERT ON servicios_recurrentes
  FOR EACH ROW
  EXECUTE FUNCTION generar_traslados_al_crear_servicio_recurrente();

-- Comentarios
COMMENT ON FUNCTION generar_traslados_al_crear_servicio_recurrente() IS
'Genera traslados automáticamente al crear un servicio recurrente.
Crea traslados para los próximos 30 días (o hasta fecha_servicio_fin si es menor).
Soporta todos los tipos de recurrencia: único, diario, semanal, semanas_alternas, dias_alternos, mensual, especifico.';

-- Refrescar el schema cache
NOTIFY pgrst, 'reload schema';
