-- =============================================
-- SEGURIDAD A3: funciones SECURITY DEFINER de stock
-- (auto_confirm_user y eliminar_todas_notificaciones_usuario ya validan
--  rol admin / usuario propio: no se tocan)
--
-- registrar_movimiento_stock (app móvil · Caducidades):
--   - Solo usuarios dados de alta en public.usuarios.
--   - El usuario del movimiento es SIEMPRE auth.uid() (p_usuario_id se ignora,
--     se mantiene en la firma para no romper la app).
--   - Corrige bug: insertaba en tipo_movimiento (no existe) → columna tipo,
--     y ajuste_positivo/ajuste_negativo → 'ajuste' (CHECK de la tabla).
--   - Valida tipo y cantidad > 0.
-- transferir_stock_a_vehiculo (web · Almacén):
--   - Solo admin, jefe_mantenimiento y tecnico (roles con módulo Almacén).
--   - Valida cantidad > 0 y registra usuario_id = auth.uid().
-- =============================================

CREATE OR REPLACE FUNCTION public.registrar_movimiento_stock(
  p_vehiculo_id uuid,
  p_producto_id uuid,
  p_tipo character varying,
  p_cantidad integer,
  p_motivo text DEFAULT NULL::text,
  p_lote character varying DEFAULT NULL::character varying,
  p_fecha_caducidad date DEFAULT NULL::date,
  p_usuario_id uuid DEFAULT NULL::uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_usuario UUID := auth.uid();
  v_stock_id UUID;
  v_cantidad_anterior INT;
  v_cantidad_nueva INT;
  v_tipo_tabla VARCHAR;
BEGIN
  IF v_usuario IS NULL OR public.fn_rol_actual() IS NULL THEN
    RAISE EXCEPTION 'Permiso denegado: usuario no autorizado' USING ERRCODE = '42501';
  END IF;

  IF p_tipo NOT IN ('entrada', 'ajuste_positivo', 'salida', 'caducidad',
                    'ajuste_negativo', 'ajuste') THEN
    RAISE EXCEPTION 'Tipo de movimiento no válido: %', p_tipo USING ERRCODE = '22023';
  END IF;

  IF p_cantidad IS NULL OR p_cantidad < 0 OR (p_cantidad = 0 AND p_tipo <> 'ajuste') THEN
    RAISE EXCEPTION 'Cantidad no válida: %', p_cantidad USING ERRCODE = '22023';
  END IF;

  v_tipo_tabla := CASE WHEN p_tipo LIKE 'ajuste%' THEN 'ajuste' ELSE p_tipo END;

  SELECT id, cantidad_actual INTO v_stock_id, v_cantidad_anterior
    FROM stock_vehiculo
   WHERE vehiculo_id = p_vehiculo_id
     AND producto_id = p_producto_id
     AND (lote = p_lote OR (lote IS NULL AND p_lote IS NULL))
   LIMIT 1;

  IF v_stock_id IS NULL THEN
    v_cantidad_anterior := 0;
    INSERT INTO stock_vehiculo (vehiculo_id, producto_id, cantidad_actual, lote, fecha_caducidad)
    VALUES (p_vehiculo_id, p_producto_id, 0, p_lote, p_fecha_caducidad)
    RETURNING id INTO v_stock_id;
  END IF;

  IF p_tipo IN ('entrada', 'ajuste_positivo') THEN
    v_cantidad_nueva := v_cantidad_anterior + p_cantidad;
  ELSIF p_tipo IN ('salida', 'caducidad', 'ajuste_negativo') THEN
    v_cantidad_nueva := GREATEST(0, v_cantidad_anterior - p_cantidad);
  ELSE
    v_cantidad_nueva := p_cantidad; -- ajuste absoluto
  END IF;

  UPDATE stock_vehiculo
     SET cantidad_actual = v_cantidad_nueva,
         fecha_caducidad = COALESCE(p_fecha_caducidad, fecha_caducidad),
         updated_at = NOW(),
         updated_by = v_usuario
   WHERE id = v_stock_id;

  INSERT INTO movimientos_stock (
    stock_vehiculo_id, vehiculo_id, producto_id,
    tipo, cantidad, cantidad_anterior, cantidad_nueva,
    motivo, lote, usuario_id
  ) VALUES (
    v_stock_id, p_vehiculo_id, p_producto_id,
    v_tipo_tabla, p_cantidad, v_cantidad_anterior, v_cantidad_nueva,
    p_motivo, p_lote, v_usuario
  );

  RETURN json_build_object(
    'success', true,
    'stock_id', v_stock_id,
    'cantidad_anterior', v_cantidad_anterior,
    'cantidad_nueva', v_cantidad_nueva
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.transferir_stock_a_vehiculo(
  p_stock_id uuid,
  p_vehiculo_id uuid,
  p_cantidad numeric,
  p_motivo text,
  p_lote text DEFAULT NULL::text,
  p_fecha_caducidad timestamp without time zone DEFAULT NULL::timestamp without time zone
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_stock_actual NUMERIC;
  v_producto_id UUID;
  v_almacen_id UUID;
  v_stock_vehiculo_id UUID;
BEGIN
  IF coalesce(public.fn_rol_actual() IN ('admin', 'jefe_mantenimiento', 'tecnico'), false) = false THEN
    RAISE EXCEPTION 'Permiso denegado: solo personal de almacén puede transferir stock'
      USING ERRCODE = '42501';
  END IF;

  IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
    RAISE EXCEPTION 'Cantidad no válida: %', p_cantidad USING ERRCODE = '22023';
  END IF;

  SELECT cantidad_actual, id_producto, id_almacen
    INTO v_stock_actual, v_producto_id, v_almacen_id
    FROM stock
   WHERE id = p_stock_id AND activo = true
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Stock no encontrado o inactivo: %', p_stock_id;
  END IF;

  IF v_stock_actual < p_cantidad THEN
    RAISE EXCEPTION 'Stock insuficiente. Disponible: %, Solicitado: %', v_stock_actual, p_cantidad;
  END IF;

  UPDATE stock
     SET cantidad_actual = cantidad_actual - p_cantidad,
         updated_at = NOW()
   WHERE id = p_stock_id;

  SELECT id INTO v_stock_vehiculo_id
    FROM stock_vehiculo
   WHERE producto_id = v_producto_id
     AND vehiculo_id = p_vehiculo_id
   LIMIT 1;

  IF FOUND THEN
    UPDATE stock_vehiculo
       SET cantidad_actual = cantidad_actual + p_cantidad::INTEGER,
           updated_at = NOW(),
           updated_by = auth.uid()
     WHERE id = v_stock_vehiculo_id;
  ELSE
    INSERT INTO stock_vehiculo (producto_id, vehiculo_id, cantidad_actual, lote, fecha_caducidad, updated_at, updated_by)
    VALUES (v_producto_id, p_vehiculo_id, p_cantidad::INTEGER, p_lote, p_fecha_caducidad::DATE, NOW(), auth.uid())
    RETURNING id INTO v_stock_vehiculo_id;
  END IF;

  INSERT INTO movimientos_stock (
    stock_vehiculo_id, vehiculo_id, producto_id, tipo, cantidad, motivo,
    vehiculo_destino_id, lote, id_almacen_origen, usuario_id, created_at
  ) VALUES (
    v_stock_vehiculo_id, NULL, v_producto_id, 'salida', p_cantidad::INTEGER, p_motivo,
    p_vehiculo_id, p_lote, v_almacen_id, auth.uid(), NOW()
  );

  RETURN json_build_object(
    'success', true,
    'stock_id', p_stock_id,
    'vehiculo_id', p_vehiculo_id,
    'cantidad_transferida', p_cantidad,
    'stock_almacen_restante', v_stock_actual - p_cantidad,
    'stock_vehiculo_id', v_stock_vehiculo_id
  );
END;
$function$;

REVOKE EXECUTE ON FUNCTION
  public.registrar_movimiento_stock(uuid, uuid, character varying, integer, text, character varying, date, uuid),
  public.transferir_stock_a_vehiculo(uuid, uuid, numeric, text, text, timestamp without time zone)
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION
  public.registrar_movimiento_stock(uuid, uuid, character varying, integer, text, character varying, date, uuid),
  public.transferir_stock_a_vehiculo(uuid, uuid, numeric, text, text, timestamp without time zone)
  TO authenticated, service_role;
