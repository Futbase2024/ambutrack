-- =====================================================
-- MIGRACIÓN: Auto-poblar origen/destino con domicilio del paciente
-- Fecha: 2026-01-03
-- Descripción: Cuando tipo_origen o tipo_destino es 'domicilio_paciente'
--              y origen/destino está NULL, copiar automáticamente el
--              domicilio_direccion del paciente asociado.
-- =====================================================

-- Función trigger para auto-poblar domicilio del paciente
CREATE OR REPLACE FUNCTION public.trigger_auto_populate_domicilio_paciente()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
  v_domicilio_paciente TEXT;
BEGIN
  -- Si tipo_origen es 'domicilio_paciente' y origen está NULL
  IF NEW.tipo_origen = 'domicilio_paciente' AND (NEW.origen IS NULL OR NEW.origen = '') THEN
    -- Buscar domicilio del paciente
    SELECT domicilio_direccion
    INTO v_domicilio_paciente
    FROM pacientes
    WHERE id = NEW.id_paciente;

    -- Asignar domicilio al campo origen
    IF v_domicilio_paciente IS NOT NULL AND v_domicilio_paciente != '' THEN
      NEW.origen := v_domicilio_paciente;
      RAISE NOTICE '🏠 Auto-poblado origen con domicilio del paciente: %', v_domicilio_paciente;
    END IF;
  END IF;

  -- Si tipo_destino es 'domicilio_paciente' y destino está NULL
  IF NEW.tipo_destino = 'domicilio_paciente' AND (NEW.destino IS NULL OR NEW.destino = '') THEN
    -- Buscar domicilio del paciente
    SELECT domicilio_direccion
    INTO v_domicilio_paciente
    FROM pacientes
    WHERE id = NEW.id_paciente;

    -- Asignar domicilio al campo destino
    IF v_domicilio_paciente IS NOT NULL AND v_domicilio_paciente != '' THEN
      NEW.destino := v_domicilio_paciente;
      RAISE NOTICE '🏠 Auto-poblado destino con domicilio del paciente: %', v_domicilio_paciente;
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;

COMMENT ON FUNCTION trigger_auto_populate_domicilio_paciente() IS
'Trigger BEFORE INSERT/UPDATE en traslados.
Cuando tipo_origen/tipo_destino es domicilio_paciente y el campo origen/destino está NULL,
copia automáticamente el domicilio_direccion del paciente asociado.';

-- Crear trigger BEFORE INSERT OR UPDATE
DROP TRIGGER IF EXISTS trg_auto_populate_domicilio_paciente ON traslados;

CREATE TRIGGER trg_auto_populate_domicilio_paciente
  BEFORE INSERT OR UPDATE ON traslados
  FOR EACH ROW
  EXECUTE FUNCTION trigger_auto_populate_domicilio_paciente();

COMMENT ON TRIGGER trg_auto_populate_domicilio_paciente ON traslados IS
'Auto-pobla origen/destino con domicilio del paciente cuando tipo es domicilio_paciente';

-- Refrescar schema cache
NOTIFY pgrst, 'reload schema';
