-- =====================================================================
-- 043_dotacion_completa_por_defecto.sql
-- Decisión: se presupone que cada ambulancia lleva TODA la dotación de su
-- plantilla. El técnico solo registra caducidades y corrige lo que falte.
--  1. Líneas de plantilla aún sin registrar (cantidad 0 y nunca modificadas
--     por un usuario): cantidad_actual = cantidad_requerida.
--  2. Nuevas líneas (nuevo item / nuevo vehículo): nacen con la cantidad
--     requerida en vez de 0.
-- =====================================================================

BEGIN;

-- 1. Líneas existentes
UPDATE public.stock_vehiculo sv
   SET cantidad_actual = pi.cantidad_requerida
  FROM public.plantilla_equipamiento_items pi
 WHERE pi.id = sv.plantilla_item_id
   AND sv.origen = 'plantilla'
   AND sv.cantidad_actual = 0
   AND sv.updated_by IS NULL;

-- 2. Función de aplicación: las líneas nuevas nacen completas
CREATE OR REPLACE FUNCTION public.fn_aplicar_plantillas_equipamiento(
  p_plantilla_id uuid DEFAULT NULL,
  p_vehiculo_id  uuid DEFAULT NULL,
  p_item_id      uuid DEFAULT NULL
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_adoptadas integer := 0;
  v_creadas   integer := 0;
BEGIN
  -- Adoptar líneas existentes del mismo producto (sin plantilla) para no duplicar
  WITH candidatos AS (
    SELECT DISTINCT ON (v.id, i.id) sv.id AS stock_id, i.id AS item_id
    FROM plantilla_equipamiento_items i
    JOIN plantillas_equipamiento p ON p.id = i.plantilla_id
    JOIN tvehiculos v
      ON upper(v.tipo_vehiculo) = ANY (p.tipos_vehiculo)
     AND (p.empresa_id IS NULL OR p.empresa_id = v.empresa_id)
    JOIN stock_vehiculo sv
      ON sv.vehiculo_id = v.id
     AND sv.producto_id = i.producto_id
     AND sv.plantilla_item_id IS NULL
    WHERE p.activo AND i.activo
      AND COALESCE(v.activo, true)
      AND (p_plantilla_id IS NULL OR p.id = p_plantilla_id)
      AND (p_vehiculo_id  IS NULL OR v.id = p_vehiculo_id)
      AND (p_item_id      IS NULL OR i.id = p_item_id)
      AND NOT EXISTS (
        SELECT 1 FROM stock_vehiculo x
        WHERE x.vehiculo_id = v.id AND x.plantilla_item_id = i.id
      )
    ORDER BY v.id, i.id, sv.fecha_caducidad NULLS LAST, sv.id
  )
  UPDATE stock_vehiculo sv
     SET plantilla_item_id = c.item_id,
         origen            = 'plantilla',
         updated_at        = now()
    FROM candidatos c
   WHERE sv.id = c.stock_id;
  GET DIAGNOSTICS v_adoptadas = ROW_COUNT;

  -- Crear las líneas que falten, con la dotación completa
  INSERT INTO stock_vehiculo (vehiculo_id, producto_id, cantidad_actual, plantilla_item_id, origen, updated_at)
  SELECT v.id, i.producto_id, i.cantidad_requerida, i.id, 'plantilla', now()
  FROM plantilla_equipamiento_items i
  JOIN plantillas_equipamiento p ON p.id = i.plantilla_id
  JOIN tvehiculos v
    ON upper(v.tipo_vehiculo) = ANY (p.tipos_vehiculo)
   AND (p.empresa_id IS NULL OR p.empresa_id = v.empresa_id)
  WHERE p.activo AND i.activo
    AND COALESCE(v.activo, true)
    AND (p_plantilla_id IS NULL OR p.id = p_plantilla_id)
    AND (p_vehiculo_id  IS NULL OR v.id = p_vehiculo_id)
    AND (p_item_id      IS NULL OR i.id = p_item_id)
  ON CONFLICT (vehiculo_id, plantilla_item_id) WHERE plantilla_item_id IS NOT NULL
  DO NOTHING;
  GET DIAGNOSTICS v_creadas = ROW_COUNT;

  RETURN v_adoptadas + v_creadas;
END;
$$;

REVOKE ALL ON FUNCTION public.fn_aplicar_plantillas_equipamiento(uuid, uuid, uuid)
  FROM PUBLIC, anon, authenticated;

COMMIT;
