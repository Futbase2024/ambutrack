-- =====================================================================
-- 044_items_opcionales_y_camillas.sql
--  1. Nuevo estado 'no_lleva': item OPCIONAL de plantilla con cantidad 0
--     (no es un fallo; antes salía como 'falta').
--  2. Las líneas nuevas de items opcionales nacen a 0 (obligatorios completos).
--  3. Silla sube-escaleras eléctrica (DOT-004, opcional): a 0 en todos los
--     vehículos; quien la tenga registra la cantidad.
--  4. Camilla principal (DOT-001): 6451LWM y 2069NNY no la llevan -> 0 ('falta').
--  Solo se tocan líneas que ningún usuario ha registrado todavía.
-- =====================================================================

BEGIN;

-- 1. Vista de estado (igual que 039 + estado 'no_lleva')
CREATE OR REPLACE VIEW public.v_stock_vehiculo_estado AS
SELECT sv.id,
       sv.vehiculo_id,
       v.matricula,
       v.tipo_vehiculo,
       sv.producto_id,
       p.nombre AS producto_nombre,
       p.nombre_comercial,
       c.codigo AS categoria_codigo,
       c.nombre AS categoria_nombre,
       sv.cantidad_actual,
       COALESCE(pi.cantidad_requerida, sm.cantidad_minima, 0) AS cantidad_minima,
       sv.fecha_caducidad,
       sv.lote,
       sv.ubicacion,
       sv.observaciones,
       CASE
         WHEN sv.cantidad_actual = 0 THEN 'sin_stock'::text
         WHEN sv.cantidad_actual < COALESCE(pi.cantidad_requerida, sm.cantidad_minima, 0) THEN 'bajo'::text
         ELSE 'ok'::text
       END AS estado_stock,
       CASE
         WHEN sv.fecha_caducidad IS NULL THEN 'sin_caducidad'::text
         WHEN sv.fecha_caducidad < CURRENT_DATE THEN 'caducado'::text
         WHEN sv.fecha_caducidad < (CURRENT_DATE + '7 days'::interval) THEN 'critico'::text
         WHEN sv.fecha_caducidad < (CURRENT_DATE + '30 days'::interval) THEN 'proximo'::text
         ELSE 'ok'::text
       END AS estado_caducidad,
       sv.plantilla_item_id,
       sv.origen,
       sv.excluido,
       sv.documento_path,
       sv.documento_nombre,
       pi.plantilla_id,
       pl.nombre AS plantilla_nombre,
       COALESCE(pi.tipo_item, 'material') AS tipo_item,
       COALESCE(pi.obligatorio, false) AS obligatorio,
       COALESCE(pi.requiere_caducidad, p.tiene_caducidad, false) AS requiere_caducidad,
       COALESCE(pi.requiere_adjunto, false) AS requiere_adjunto,
       COALESCE(pi.orden, 9999) AS orden,
       c.orden AS categoria_orden,
       sv.updated_at,
       CASE
         WHEN sv.excluido THEN 'excluido'::text
         WHEN sv.origen = 'plantilla'
              AND (pi.id IS NULL OR NOT pi.activo OR NOT pl.activo) THEN 'fuera_plantilla'::text
         WHEN pi.id IS NOT NULL AND NOT pi.obligatorio AND sv.cantidad_actual = 0 THEN 'no_lleva'::text
         WHEN sv.fecha_caducidad IS NOT NULL AND sv.fecha_caducidad < CURRENT_DATE THEN 'caducado'::text
         WHEN sv.cantidad_actual < COALESCE(pi.cantidad_requerida, 0) THEN 'falta'::text
         WHEN COALESCE(pi.requiere_caducidad, false) AND sv.fecha_caducidad IS NULL THEN 'sin_fecha'::text
         WHEN COALESCE(pi.requiere_adjunto, false) AND sv.documento_path IS NULL THEN 'sin_adjunto'::text
         WHEN sv.fecha_caducidad IS NOT NULL
              AND sv.fecha_caducidad < (CURRENT_DATE + '30 days'::interval) THEN 'proximo'::text
         ELSE 'ok'::text
       END AS estado_dotacion,
       COALESCE(pi.seccion, c.nombre, 'Extras') AS seccion,
       COALESCE(pi.seccion_orden, 999) AS seccion_orden
  FROM stock_vehiculo sv
  JOIN tvehiculos v ON sv.vehiculo_id = v.id
  JOIN productos p ON sv.producto_id = p.id
  LEFT JOIN categorias_equipamiento c ON p.categoria_id = c.id
  LEFT JOIN plantilla_equipamiento_items pi ON pi.id = sv.plantilla_item_id
  LEFT JOIN plantillas_equipamiento pl ON pl.id = pi.plantilla_id
  LEFT JOIN equipamiento_reglamentario_vehiculo sm
         ON sm.producto_id = p.id AND sm.tipo_vehiculo_codigo::text = v.tipo_vehiculo;

-- 2. Líneas nuevas: opcionales a 0, obligatorias completas
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

  INSERT INTO stock_vehiculo (vehiculo_id, producto_id, cantidad_actual, plantilla_item_id, origen, updated_at)
  SELECT v.id, i.producto_id,
         CASE WHEN i.obligatorio THEN i.cantidad_requerida ELSE 0 END,
         i.id, 'plantilla', now()
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

-- 3. Items opcionales sin registrar -> 0 (incluye la silla sube-escaleras)
UPDATE public.stock_vehiculo sv
   SET cantidad_actual = 0
  FROM public.plantilla_equipamiento_items pi
 WHERE pi.id = sv.plantilla_item_id
   AND NOT pi.obligatorio
   AND sv.updated_by IS NULL;

-- 4. Camilla principal: 6451LWM y 2069NNY no la llevan
UPDATE public.stock_vehiculo sv
   SET cantidad_actual = 0
  FROM public.tvehiculos v, public.productos p
 WHERE v.id = sv.vehiculo_id
   AND p.id = sv.producto_id
   AND p.codigo = 'DOT-001'
   AND v.matricula IN ('6451LWM', '2069NNY')
   AND sv.updated_by IS NULL;

COMMIT;
