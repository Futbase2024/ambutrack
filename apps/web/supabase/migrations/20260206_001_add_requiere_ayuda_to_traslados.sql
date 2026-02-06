-- =====================================================
-- MIGRACIÓN: Agregar campo requiere_ayuda a traslados y normalizar servicios
-- Problema: La tabla traslados no tiene el campo requiere_ayuda
--           La tabla servicios tiene 'requiere_ayudante' pero Flutter usa 'requiere_ayuda'
-- Solución:
--   1. Agregar alias/columna requiere_ayuda a servicios (si no existe)
--   2. Agregar columna requiere_ayuda a traslados
--   3. Actualizar función generar_traslados_periodo
-- Fecha: 2026-02-06
-- =====================================================

-- =====================================================
-- PASO 0: Normalizar nombre de columna en servicios
-- (Si existe requiere_ayudante, crear requiere_ayuda como alias)
-- =====================================================
DO $$
BEGIN
  -- Verificar si existe requiere_ayuda en servicios
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'servicios' AND column_name = 'requiere_ayuda'
  ) THEN
    -- Si existe requiere_ayudante, renombrarlo a requiere_ayuda
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'servicios' AND column_name = 'requiere_ayudante'
    ) THEN
      ALTER TABLE servicios RENAME COLUMN requiere_ayudante TO requiere_ayuda;
      RAISE NOTICE 'Columna requiere_ayudante renombrada a requiere_ayuda en servicios';
    ELSE
      -- Si no existe ninguna, crear la columna
      ALTER TABLE servicios ADD COLUMN requiere_ayuda BOOLEAN DEFAULT false;
      RAISE NOTICE 'Columna requiere_ayuda creada en servicios';
    END IF;
  END IF;
END $$;

COMMENT ON COLUMN servicios.requiere_ayuda IS 'Indica si el servicio requiere ayuda adicional de personal';

-- =====================================================
-- PASO 1: Agregar columna requiere_ayuda a traslados
-- =====================================================
ALTER TABLE traslados
ADD COLUMN IF NOT EXISTS requiere_ayuda BOOLEAN DEFAULT false;

COMMENT ON COLUMN traslados.requiere_ayuda IS 'Indica si el traslado requiere ayuda adicional de personal';

-- =====================================================
-- PASO 2: Actualizar función generar_traslados_periodo
-- para incluir requiere_ayuda
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
            v_dia_semana := EXTRACT(DOW FROM v_fecha_actual);
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

          -- TRASLADO DE IDA (siempre se crea)
          INSERT INTO traslados (
            id_servicio,
            id_paciente,
            id_motivo_traslado,
            tipo_traslado,
            fecha,
            hora_programada,
            tipo_origen,
            origen,
            tipo_destino,
            destino,
            origen_ubicacion_centro,
            destino_ubicacion_centro,
            tipo_ambulancia,
            requiere_acompanante,
            requiere_silla_ruedas,
            requiere_camilla,
            requiere_ayuda,          -- ✅ NUEVO: Campo agregado
            observaciones,
            observaciones_medicas,
            generado_automaticamente,
            prioridad,
            created_by
          )
          VALUES (
            v_servicio.id,
            v_servicio.id_paciente,
            v_servicio.id_motivo_traslado,
            'ida',
            v_fecha_actual,
            v_servicio.hora_recogida,
            v_servicio.tipo_origen,
            v_servicio.origen,
            v_servicio.tipo_destino,
            v_servicio.destino,
            v_servicio.origen_ubicacion_centro,
            v_servicio.destino_ubicacion_centro,
            v_servicio.tipo_ambulancia,
            v_servicio.requiere_acompanante,
            v_servicio.requiere_silla_ruedas,
            v_servicio.requiere_camilla,
            v_servicio.requiere_ayuda,  -- ✅ NUEVO: Propagar desde servicios
            v_servicio.observaciones,
            v_servicio.observaciones_medicas,
            true,
            v_servicio.prioridad,
            v_servicio.created_by
          )
          ON CONFLICT (id_servicio_recurrente, id_servicio, fecha, tipo_traslado) DO NOTHING;

          IF FOUND THEN
            v_traslados_generados := v_traslados_generados + 1;
            v_traslados_ida := v_traslados_ida + 1;
          END IF;

          -- TRASLADO DE VUELTA (solo si requiere_vuelta = true)
          IF v_servicio.requiere_vuelta = true THEN
            INSERT INTO traslados (
              id_servicio,
              id_paciente,
              id_motivo_traslado,
              tipo_traslado,
              fecha,
              hora_programada,
              tipo_origen,
              origen,
              tipo_destino,
              destino,
              origen_ubicacion_centro,
              destino_ubicacion_centro,
              tipo_ambulancia,
              requiere_acompanante,
              requiere_silla_ruedas,
              requiere_camilla,
              requiere_ayuda,          -- ✅ NUEVO
              observaciones,
              observaciones_medicas,
              generado_automaticamente,
              prioridad,
              created_by
            )
            VALUES (
              v_servicio.id,
              v_servicio.id_paciente,
              v_servicio.id_motivo_traslado,
              'vuelta',
              v_fecha_actual,
              v_servicio.hora_vuelta,
              v_servicio.tipo_destino,        -- Invertir: Origen = Destino de IDA
              v_servicio.destino,
              v_servicio.tipo_origen,         -- Invertir: Destino = Origen de IDA
              v_servicio.origen,
              v_servicio.destino_ubicacion_centro,
              v_servicio.origen_ubicacion_centro,
              v_servicio.tipo_ambulancia,
              v_servicio.requiere_acompanante,
              v_servicio.requiere_silla_ruedas,
              v_servicio.requiere_camilla,
              v_servicio.requiere_ayuda,      -- ✅ NUEVO: Propagar desde servicios
              v_servicio.observaciones,
              v_servicio.observaciones_medicas,
              true,
              v_servicio.prioridad,
              v_servicio.created_by
            )
            ON CONFLICT (id_servicio_recurrente, id_servicio, fecha, tipo_traslado) DO NOTHING;

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

COMMENT ON FUNCTION generar_traslados_periodo(DATE, DATE) IS
'Genera traslados automáticamente para el período especificado basándose en servicios activos.
Propaga todos los campos de requisitos (requiere_ayuda, requiere_silla_ruedas, requiere_camilla, requiere_acompanante) desde servicios a traslados.
Soporta todos los tipos de recurrencia: único, diario, semanal, semanas_alternas, dias_alternos, mensual, especifico.
Evita duplicados mediante ON CONFLICT DO NOTHING.';

-- =====================================================
-- PASO 3: Actualizar traslados existentes copiando
-- requiere_ayuda desde sus servicios padre
-- =====================================================
UPDATE traslados t
SET requiere_ayuda = s.requiere_ayuda
FROM servicios s
WHERE t.id_servicio = s.id
  AND t.requiere_ayuda IS DISTINCT FROM s.requiere_ayuda;

-- Refrescar schema cache
NOTIFY pgrst, 'reload schema';
