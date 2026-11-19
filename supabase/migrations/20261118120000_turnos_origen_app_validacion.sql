-- =====================================================================
-- Turnos creados desde la app móvil + validación por coordinación
-- =====================================================================
-- Caso de uso: un trabajador inicia turno en el móvil sin tener turno
-- planificado en el cuadrante. La app crea el turno con origen 'app' y
-- validado = false. Coordinación lo revisa y lo valida desde la web.
-- =====================================================================

ALTER TABLE public.turnos
  ADD COLUMN IF NOT EXISTS origen text NOT NULL DEFAULT 'cuadrante',
  ADD COLUMN IF NOT EXISTS validado boolean NOT NULL DEFAULT true;

ALTER TABLE public.turnos
  DROP CONSTRAINT IF EXISTS turnos_origen_check;
ALTER TABLE public.turnos
  ADD CONSTRAINT turnos_origen_check CHECK (origen IN ('cuadrante', 'app'));

COMMENT ON COLUMN public.turnos.origen IS
  'Origen del turno: cuadrante (planificado en web) o app (creado por el trabajador al iniciar turno)';
COMMENT ON COLUMN public.turnos.validado IS
  'false = turno creado desde la app pendiente de validar por coordinación';

CREATE INDEX IF NOT EXISTS idx_turnos_pendientes_validar
  ON public.turnos (validado)
  WHERE validado = false AND activo = true;

-- El trabajador puede crear SU PROPIO turno, solo como origen app y sin validar
DROP POLICY IF EXISTS turnos_insert_propio_app ON public.turnos;
CREATE POLICY turnos_insert_propio_app ON public.turnos
  FOR INSERT TO authenticated
  WITH CHECK (
    "idPersonal" = (fn_mi_personal_id())::text
    AND origen = 'app'
    AND validado = false
  );

-- Solo coordinación puede validar o cambiar el origen de un turno
CREATE OR REPLACE FUNCTION public.fn_turnos_proteger_validacion()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF (NEW.validado IS DISTINCT FROM OLD.validado
      OR NEW.origen IS DISTINCT FROM OLD.origen)
     AND NOT fn_rol_en(ARRAY['admin', 'jefe_personal', 'jefe_trafico', 'coordinador']) THEN
    RAISE EXCEPTION 'Solo coordinación puede validar turnos o cambiar su origen'
      USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_turnos_proteger_validacion ON public.turnos;
CREATE TRIGGER trg_turnos_proteger_validacion
  BEFORE UPDATE ON public.turnos
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_turnos_proteger_validacion();
