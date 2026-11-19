-- =====================================================================
-- 041_stock_vehiculo_delete_extras.sql
-- stock_vehiculo no tenía política DELETE: no se podían quitar extras.
-- Solo admin / jefe_mantenimiento y solo líneas manuales (las de plantilla se excluyen).
-- =====================================================================

BEGIN;

CREATE POLICY stock_vehiculo_delete_extras ON public.stock_vehiculo
  FOR DELETE TO authenticated
  USING (
    origen = 'manual'
    AND (SELECT public.fn_rol_actual()) IN ('admin', 'jefe_mantenimiento')
  );

COMMIT;
