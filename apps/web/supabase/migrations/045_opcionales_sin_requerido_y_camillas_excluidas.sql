-- =====================================================================
-- 045_opcionales_sin_requerido_y_camillas_excluidas.sql
--  1. Items opcionales y líneas excluidas: cantidad requerida 0 en la vista
--     (la silla sube-escaleras no se exige en ningún vehículo).
--  2. Camilla principal en 6451LWM y 2069NNY: no les corresponde ->
--     excluida de su dotación (estado 'excluido', no 'falta').
-- =====================================================================

BEGIN;

-- 1. Vista (igual que 044, cambia solo cantidad_minima)
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
       CASE
         WHEN sv.excluido OR (pi.id IS NOT NULL AND NOT pi.obligatorio) THEN 0
         ELSE COALESCE(pi.cantidad_requerida, sm.cantidad_minima, 0)
       END AS cantidad_minima,
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

-- 2. Camillas de 6451LWM y 2069NNY: excluidas de la dotación
UPDATE public.stock_vehiculo sv
   SET excluido = true,
       cantidad_actual = 0
  FROM public.tvehiculos v, public.productos p
 WHERE v.id = sv.vehiculo_id
   AND p.id = sv.producto_id
   AND p.codigo = 'DOT-001'
   AND v.matricula IN ('6451LWM', '2069NNY');

COMMIT;
