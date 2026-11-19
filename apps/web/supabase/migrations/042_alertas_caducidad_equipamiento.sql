-- =====================================================================
-- 042_alertas_caducidad_equipamiento.sql
-- Integra las caducidades de la dotación (stock_vehiculo) en el sistema
-- de alertas: tipo_alerta = 'equipamiento', UNA alerta por vehículo con la
-- caducidad más próxima. Incluye items ya caducados y los que caducan en
-- los próximos 30 días. Excluye líneas excluidas y fuera de plantilla.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 1. Vista: se añade el bloque de equipamiento a la definición actual
--    (idempotente: si ya contiene stock_vehiculo no se toca)
-- ---------------------------------------------------------------------
DO $$
DECLARE
  v_def text := pg_get_viewdef('public.vw_alertas_caducidad_activas'::regclass, true);
BEGIN
  IF position('stock_vehiculo' IN v_def) > 0 THEN
    RAISE NOTICE 'vw_alertas_caducidad_activas ya incluye equipamiento';
    RETURN;
  END IF;

  v_def := rtrim(rtrim(v_def), ';');

  EXECUTE 'CREATE OR REPLACE VIEW public.vw_alertas_caducidad_activas AS ' || v_def || $sql$
UNION ALL
 SELECT 'equipamiento'::text AS tipo_alerta,
    eq.vehiculo_id AS entidad_id,
    'EQUIPAMIENTO:'::text || eq.vehiculo_id AS entidad_key,
    eq.matricula || ' - Equipamiento: ' ||
      CASE WHEN eq.items = 1 THEN eq.primer_item
           ELSE eq.items || ' items (' || eq.primer_item || '...)'
      END AS entidad_nombre,
    eq.fecha_caducidad::timestamp with time zone AS fecha_caducidad,
    eq.dias_restantes,
    'stock_vehiculo'::text AS tabla_origen,
        CASE
            WHEN eq.dias_restantes < 7 THEN 'critica'::text
            WHEN eq.dias_restantes < 30 THEN 'alta'::text
            WHEN eq.dias_restantes < 60 THEN 'media'::text
            ELSE 'baja'::text
        END AS severidad,
    eq.dias_restantes < 7 AS es_critica,
        CASE
            WHEN eq.dias_restantes < 0 THEN 1
            WHEN eq.dias_restantes < 7 THEN 2
            WHEN eq.dias_restantes < 30 THEN 3
            WHEN eq.dias_restantes < 60 THEN 4
            ELSE 5
        END AS prioridad
   FROM ( SELECT sv.vehiculo_id,
            v.matricula,
            count(*)::integer AS items,
            min(sv.fecha_caducidad) AS fecha_caducidad,
            (min(sv.fecha_caducidad) - CURRENT_DATE)::integer AS dias_restantes,
            (array_agg(p.nombre ORDER BY sv.fecha_caducidad, p.nombre))[1] AS primer_item
           FROM stock_vehiculo sv
             JOIN tvehiculos v ON v.id = sv.vehiculo_id
             JOIN productos p ON p.id = sv.producto_id
             LEFT JOIN plantilla_equipamiento_items pi ON pi.id = sv.plantilla_item_id
             LEFT JOIN plantillas_equipamiento pl ON pl.id = pi.plantilla_id
          WHERE sv.fecha_caducidad IS NOT NULL
            AND sv.fecha_caducidad <= (CURRENT_DATE + 30)
            AND NOT sv.excluido
            AND v.activo = true
            AND (sv.origen = 'manual' OR (pi.activo AND pl.activo))
          GROUP BY sv.vehiculo_id, v.matricula) eq
$sql$;
END $$;

-- ---------------------------------------------------------------------
-- 2. obtener_alertas_activas: incluir el tipo 'equipamiento' (30 días)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.obtener_alertas_activas(
  p_usuario_id uuid DEFAULT NULL::uuid,
  p_umbral_seguro integer DEFAULT 90,
  p_umbral_itv integer DEFAULT 90,
  p_umbral_homologacion integer DEFAULT 90,
  p_umbral_mantenimiento integer DEFAULT 90,
  p_incluir_vistas boolean DEFAULT true
)
RETURNS TABLE(
  tipo_alerta text, entidad_id text, entidad_key text, entidad_nombre text,
  fecha_caducidad date, dias_restantes integer, severidad text, tabla_origen text,
  es_critica boolean, prioridad integer
)
LANGUAGE sql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
    SELECT
        v.tipo_alerta::TEXT,
        v.entidad_id::TEXT,
        v.entidad_key::TEXT,
        v.entidad_nombre::TEXT,
        v.fecha_caducidad::DATE,
        v.dias_restantes::INTEGER,
        v.severidad::TEXT,
        v.tabla_origen::TEXT,
        v.es_critica::BOOLEAN,
        v.prioridad::INTEGER
    FROM public.vw_alertas_caducidad_activas v
    WHERE
        (
            (v.tipo_alerta = 'seguro' AND v.dias_restantes <= p_umbral_seguro) OR
            (v.tipo_alerta = 'itv' AND v.dias_restantes <= p_umbral_itv) OR
            (v.tipo_alerta = 'homologacion' AND v.dias_restantes <= p_umbral_homologacion) OR
            (v.tipo_alerta = 'revision_tecnica' AND v.dias_restantes <= p_umbral_itv) OR
            (v.tipo_alerta = 'revision' AND v.dias_restantes <= p_umbral_itv) OR
            (v.tipo_alerta = 'mantenimiento' AND v.dias_restantes <= p_umbral_mantenimiento) OR
            (v.tipo_alerta = 'equipamiento' AND v.dias_restantes <= 30)
        )
        AND (
            p_incluir_vistas = true
            OR p_usuario_id IS NULL
            OR NOT EXISTS (
                SELECT 1 FROM public.ambutrack_alertas_caducidad_vistas av
                WHERE av.usuario_id = p_usuario_id
                    AND av.tipo_alerta = v.tipo_alerta
                    AND av.entidad_id = v.entidad_id
                    AND av.fecha_visualizacion = CURRENT_DATE
            )
        )
    ORDER BY v.prioridad ASC, v.dias_restantes ASC;
$function$;

-- ---------------------------------------------------------------------
-- 3. Alertas vistas: admitir todos los tipos que genera la vista.
--    Antes solo seguro/itv/homologacion/mantenimiento: marcar como vista
--    'revision' o 'revision_tecnica' fallaba (se ignoraba en la app).
-- ---------------------------------------------------------------------
ALTER TABLE public.ambutrack_alertas_caducidad_vistas
  DROP CONSTRAINT IF EXISTS ambutrack_alertas_caducidad_vistas_tipo_alerta_check;

ALTER TABLE public.ambutrack_alertas_caducidad_vistas
  ADD CONSTRAINT ambutrack_alertas_caducidad_vistas_tipo_alerta_check
  CHECK (tipo_alerta = ANY (ARRAY[
    'seguro', 'itv', 'homologacion', 'mantenimiento',
    'revision', 'revision_tecnica', 'equipamiento'
  ]));

COMMIT;
