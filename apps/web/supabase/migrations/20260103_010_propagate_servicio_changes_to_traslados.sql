-- =====================================================
-- MIGRACIÓN: Propagar cambios de servicios_recurrentes a traslados
-- Fecha: 2026-01-03
-- Descripción: Cuando se actualiza origen/destino en servicios_recurrentes,
--              propagar automáticamente a todos los traslados pendientes
--              asociados a ese servicio.
-- =====================================================

-- Función trigger para propagar cambios a traslados
CREATE OR REPLACE FUNCTION public.trigger_propagar_cambios_servicio_a_traslados()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
  v_traslados_actualizados INTEGER := 0;
  v_domicilio_paciente TEXT;
BEGIN
  -- Solo propagar si hay cambios relevantes en origen/destino
  IF (OLD.tipo_origen IS DISTINCT FROM NEW.tipo_origen) OR
     (OLD.origen IS DISTINCT FROM NEW.origen) OR
     (OLD.tipo_destino IS DISTINCT FROM NEW.tipo_destino) OR
     (OLD.destino IS DISTINCT FROM NEW.destino) THEN

    -- Actualizar traslados de IDA pendientes
    UPDATE traslados
    SET
      tipo_origen = NEW.tipo_origen,
      tipo_destino = NEW.tipo_destino,
      updated_at = NOW()
    WHERE id_servicio_recurrente = NEW.id
      AND tipo_traslado = 'ida'
      AND estado IN ('pendiente', 'asignado'); -- Solo traslados no iniciados

    GET DIAGNOSTICS v_traslados_actualizados = ROW_COUNT;

    -- Actualizar traslados de VUELTA pendientes (origen y destino invertidos)
    UPDATE traslados
    SET
      tipo_origen = NEW.tipo_destino,  -- INVERTIDO
      tipo_destino = NEW.tipo_origen,  -- INVERTIDO
      updated_at = NOW()
    WHERE id_servicio_recurrente = NEW.id
      AND tipo_traslado = 'vuelta'
      AND estado IN ('pendiente', 'asignado');

    GET DIAGNOSTICS v_traslados_actualizados = v_traslados_actualizados + ROW_COUNT;

    -- IMPORTANTE: Después de actualizar tipo_origen/tipo_destino,
    -- el trigger trg_auto_populate_domicilio_paciente se ejecutará
    -- automáticamente para cada UPDATE y poblará origen/destino
    -- con el domicilio del paciente si tipo='domicilio_paciente'

    RAISE NOTICE '🔄 Propagados cambios de servicio % a % traslados pendientes', NEW.codigo, v_traslados_actualizados;

  END IF;

  RETURN NEW;
END;
$function$;

COMMENT ON FUNCTION trigger_propagar_cambios_servicio_a_traslados() IS
'Trigger AFTER UPDATE en servicios_recurrentes.
Cuando se modifican tipo_origen/tipo_destino, propaga los cambios
a todos los traslados pendientes/asignados (no iniciados).
El trigger trg_auto_populate_domicilio_paciente se encarga luego
de poblar origen/destino con el domicilio real del paciente.';

-- Crear trigger AFTER UPDATE
DROP TRIGGER IF EXISTS trg_propagar_cambios_servicio_a_traslados ON servicios_recurrentes;

CREATE TRIGGER trg_propagar_cambios_servicio_a_traslados
  AFTER UPDATE ON servicios_recurrentes
  FOR EACH ROW
  EXECUTE FUNCTION trigger_propagar_cambios_servicio_a_traslados();

COMMENT ON TRIGGER trg_propagar_cambios_servicio_a_traslados ON servicios_recurrentes IS
'Propaga cambios de tipo_origen/tipo_destino a traslados pendientes/asignados';

-- Refrescar schema cache
NOTIFY pgrst, 'reload schema';
