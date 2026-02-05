-- =====================================================
-- TRIGGER: generar_traslados_servicio_unico
-- Descripción: Genera traslados automáticamente al crear un servicio ÚNICO
-- Arquitectura:
--   servicios (tipo_recurrencia = 'unico') → traslados (generados automáticamente)
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-01-31
-- =====================================================

-- Función para generar traslados al crear servicio único
CREATE OR REPLACE FUNCTION generar_traslados_servicio_unico()
RETURNS TRIGGER AS $$
DECLARE
  v_traslados_generados INTEGER := 0;
BEGIN
  -- Solo procesar si es tipo_recurrencia = 'unico'
  IF NEW.tipo_recurrencia != 'unico' THEN
    RETURN NEW;
  END IF;

  RAISE NOTICE 'Generando traslados para servicio único: % (fecha: %)', NEW.codigo, NEW.fecha_servicio_inicio;

  -- TRASLADO DE IDA (siempre se crea)
  INSERT INTO traslados (
    id_servicio,           -- ✅ Vinculado directamente a servicios
    id_servicio_recurrente, -- NULL para servicios únicos
    id_paciente,
    tipo_traslado,
    fecha,
    hora_programada,
    trayecto,              -- ✅ Singular: un solo trayecto JSONB
    observaciones,
    generado_automaticamente,
    created_by
  )
  VALUES (
    NEW.id,                -- ID del servicio padre
    NULL,                  -- ✅ NULL porque es servicio único
    NEW.id_paciente,
    'ida',
    NEW.fecha_servicio_inicio,
    NEW.hora_recogida,
    NEW.trayectos,         -- ✅ Lee el JSONB trayectos de servicios como plantilla
    NEW.observaciones,
    true,
    NEW.created_by
  )
  ON CONFLICT (id_servicio_recurrente, id_servicio, fecha, tipo_traslado) DO NOTHING;

  IF FOUND THEN
    v_traslados_generados := v_traslados_generados + 1;
    RAISE NOTICE '✅ Traslado de IDA generado para servicio único %', NEW.codigo;
  END IF;

  -- TRASLADO DE VUELTA (solo si requiere_vuelta = true)
  IF NEW.requiere_vuelta = true THEN
    -- Validar que hora_vuelta esté presente (el trigger de validación ya lo verificó)
    IF NEW.hora_vuelta IS NULL THEN
      RAISE EXCEPTION 'INCONSISTENCIA: requiere_vuelta = true pero hora_vuelta es NULL en servicio %', NEW.codigo;
    END IF;

    INSERT INTO traslados (
      id_servicio,
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
      NULL,                  -- ✅ NULL porque es servicio único
      NEW.id_paciente,
      'vuelta',
      NEW.fecha_servicio_inicio,
      NEW.hora_vuelta,
      NEW.trayectos,         -- El trayecto se invierte en la lógica de la app
      NEW.observaciones,
      true,
      NEW.created_by
    )
    ON CONFLICT (id_servicio_recurrente, id_servicio, fecha, tipo_traslado) DO NOTHING;

    IF FOUND THEN
      v_traslados_generados := v_traslados_generados + 1;
      RAISE NOTICE '✅ Traslado de VUELTA generado para servicio único %', NEW.codigo;
    END IF;
  ELSE
    RAISE NOTICE 'ℹ️ Servicio único % NO requiere vuelta (requiere_vuelta = false)', NEW.codigo;
  END IF;

  RAISE NOTICE 'Generados % traslados para servicio único %', v_traslados_generados, NEW.codigo;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que se ejecuta AFTER INSERT en servicios
DROP TRIGGER IF EXISTS trigger_generar_traslados_unico ON servicios;

CREATE TRIGGER trigger_generar_traslados_unico
  AFTER INSERT ON servicios
  FOR EACH ROW
  WHEN (NEW.tipo_recurrencia = 'unico')  -- ✅ Solo para servicios únicos
  EXECUTE FUNCTION generar_traslados_servicio_unico();

-- Comentarios
COMMENT ON FUNCTION generar_traslados_servicio_unico() IS
'Genera traslados automáticamente al crear un servicio ÚNICO.
Lee el campo trayectos JSONB de la tabla servicios como plantilla.
Crea 1 traslado de IDA (siempre) y opcionalmente 1 traslado de VUELTA si requiere_vuelta = true.
Los traslados se vinculan directamente a servicios.id, NO a servicios_recurrentes.';

-- Refrescar el schema cache
NOTIFY pgrst, 'reload schema';
