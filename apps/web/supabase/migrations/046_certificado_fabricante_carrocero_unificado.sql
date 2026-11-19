-- =====================================================================
-- 046_certificado_fabricante_carrocero_unificado.sql
-- La hoja oficial de documentación agrupa en una sola fila:
--   "Copia del certificado de conformidad del fabricante y/o carrocero
--    certificando que dicha ambulancia cumple la norma EN 1789:2021"
-- Se unifican DOT-080 (fabricante) y DOT-081 (carrocero) en DOT-080.
-- Solo se eliminan líneas de DOT-081 sin datos registrados (sin PDF,
-- sin fecha y sin modificar por usuarios).
-- =====================================================================

BEGIN;

-- 1. DOT-080 pasa a ser el certificado unificado
UPDATE public.productos
   SET nombre = 'CERTIFICADO CONFORMIDAD FABRICANTE Y/O CARROCERO (EN 1789:2021)',
       updated_at = now()
 WHERE codigo = 'DOT-080';

UPDATE public.plantilla_equipamiento_items i
   SET notas = 'Copia del certificado de conformidad del fabricante y/o carrocero '
               'certificando que la ambulancia cumple la norma EN 1789:2021'
  FROM public.productos p
 WHERE p.id = i.producto_id
   AND p.codigo = 'DOT-080';

-- 2. Quitar las líneas de DOT-081 de los vehículos (sin datos registrados)
DELETE FROM public.stock_vehiculo sv
 USING public.productos p
 WHERE p.id = sv.producto_id
   AND p.codigo = 'DOT-081'
   AND sv.origen = 'plantilla'
   AND sv.updated_by IS NULL
   AND sv.documento_path IS NULL
   AND sv.fecha_caducidad IS NULL;

-- 3. Quitar el item de la plantilla y desactivar el producto
DELETE FROM public.plantilla_equipamiento_items i
 USING public.productos p
 WHERE p.id = i.producto_id
   AND p.codigo = 'DOT-081';

UPDATE public.productos
   SET activo = false,
       updated_at = now()
 WHERE codigo = 'DOT-081';

-- 4. Reordenar la sección de documentación (1..11 sin huecos)
WITH orden AS (
  SELECT i.id, row_number() OVER (PARTITION BY i.plantilla_id ORDER BY i.orden) AS nuevo
    FROM public.plantilla_equipamiento_items i
   WHERE i.seccion_orden = 8
)
UPDATE public.plantilla_equipamiento_items i
   SET orden = o.nuevo
  FROM orden o
 WHERE o.id = i.id;

COMMIT;
