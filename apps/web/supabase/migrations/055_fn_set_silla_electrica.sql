-- Marca o quita la silla eléctrica de uno o varios vehículos modificando su stock
-- (producto 'SILLA SUBE-ESCALERAS ELÉCTRICA'). tvehiculos.tiene_silla_electrica
-- se recalcula solo con el trigger trg_stock_vehiculo_sync_silla.
--
-- SECURITY INVOKER: se aplican las políticas RLS de stock_vehiculo del usuario.
--   p_tiene = true  -> deja 1 unidad en la primera fila no excluida (o crea una fila manual)
--   p_tiene = false -> deja a 0 todas las filas de silla del vehículo
CREATE OR REPLACE FUNCTION public.fn_set_silla_electrica(p_vehiculo_ids uuid[], p_tiene boolean)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path TO 'public'
AS $function$
DECLARE
  v_producto uuid;
  v_vehiculo uuid;
  v_fila uuid;
BEGIN
  SELECT id INTO v_producto
    FROM productos
   WHERE upper(nombre) = 'SILLA SUBE-ESCALERAS ELÉCTRICA'
   LIMIT 1;
  IF v_producto IS NULL THEN
    RAISE EXCEPTION 'No existe el producto SILLA SUBE-ESCALERAS ELÉCTRICA';
  END IF;

  FOREACH v_vehiculo IN ARRAY p_vehiculo_ids LOOP
    IF p_tiene THEN
      SELECT id INTO v_fila
        FROM stock_vehiculo
       WHERE vehiculo_id = v_vehiculo AND producto_id = v_producto AND NOT excluido
       ORDER BY (plantilla_item_id IS NULL), updated_at DESC NULLS LAST
       LIMIT 1;
      IF v_fila IS NULL THEN
        INSERT INTO stock_vehiculo (vehiculo_id, producto_id, cantidad_actual, origen)
        VALUES (v_vehiculo, v_producto, 1, 'manual');
      ELSE
        UPDATE stock_vehiculo
           SET cantidad_actual = 1
         WHERE id = v_fila AND cantidad_actual < 1;
      END IF;
    ELSE
      UPDATE stock_vehiculo
         SET cantidad_actual = 0
       WHERE vehiculo_id = v_vehiculo AND producto_id = v_producto AND cantidad_actual <> 0;
    END IF;
  END LOOP;
END;
$function$;

REVOKE ALL ON FUNCTION public.fn_set_silla_electrica(uuid[], boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_set_silla_electrica(uuid[], boolean) TO authenticated;
