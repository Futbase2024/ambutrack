-- =====================================================================
-- 038_plantillas_equipamiento.sql
-- Plantillas de equipamiento por tipo de vehículo (Dotación A1/A2, etc.)
-- Plan: apps/web/docs/plans/plantillas_equipamiento_plan.md
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 1. Cabecera de plantilla
-- ---------------------------------------------------------------------
CREATE TABLE public.plantillas_equipamiento (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre         text NOT NULL,
  descripcion    text,
  tipos_vehiculo text[] NOT NULL DEFAULT '{}',  -- valores de tvehiculos.tipo_vehiculo (MAYÚSCULAS)
  fecha_version  date,
  activo         boolean NOT NULL DEFAULT true,
  empresa_id     uuid,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now(),
  created_by     uuid DEFAULT auth.uid() REFERENCES auth.users(id),
  updated_by     uuid REFERENCES auth.users(id)
);

COMMENT ON TABLE public.plantillas_equipamiento IS
  'Plantilla de equipamiento/documentación obligatoria por tipo de vehículo.';

-- ---------------------------------------------------------------------
-- 2. Items de plantilla
-- ---------------------------------------------------------------------
CREATE TABLE public.plantilla_equipamiento_items (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plantilla_id       uuid NOT NULL REFERENCES public.plantillas_equipamiento(id) ON DELETE CASCADE,
  producto_id        uuid NOT NULL REFERENCES public.productos(id) ON DELETE RESTRICT,
  tipo_item          text NOT NULL DEFAULT 'material' CHECK (tipo_item IN ('material', 'documento')),
  cantidad_requerida integer NOT NULL DEFAULT 1 CHECK (cantidad_requerida >= 1),
  obligatorio        boolean NOT NULL DEFAULT true,
  requiere_caducidad boolean NOT NULL DEFAULT false,
  requiere_adjunto   boolean NOT NULL DEFAULT false,
  orden              integer NOT NULL DEFAULT 0,
  notas              text,
  activo             boolean NOT NULL DEFAULT true,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_plantilla_item_producto UNIQUE (plantilla_id, producto_id)
);

CREATE INDEX ix_plantilla_items_plantilla ON public.plantilla_equipamiento_items (plantilla_id);
CREATE INDEX ix_plantilla_items_producto  ON public.plantilla_equipamiento_items (producto_id);

-- ---------------------------------------------------------------------
-- 3. Ampliar stock_vehiculo (línea de equipamiento de cada vehículo)
-- ---------------------------------------------------------------------
ALTER TABLE public.stock_vehiculo
  ADD COLUMN plantilla_item_id uuid
    REFERENCES public.plantilla_equipamiento_items(id) ON DELETE SET NULL,
  ADD COLUMN origen text NOT NULL DEFAULT 'manual' CHECK (origen IN ('plantilla', 'manual')),
  ADD COLUMN excluido boolean NOT NULL DEFAULT false,
  ADD COLUMN documento_path text,     -- ruta en bucket privado 'equipamiento-vehiculos'
  ADD COLUMN documento_nombre text;

CREATE UNIQUE INDEX uq_stock_vehiculo_plantilla_item
  ON public.stock_vehiculo (vehiculo_id, plantilla_item_id)
  WHERE plantilla_item_id IS NOT NULL;

CREATE INDEX ix_stock_vehiculo_vehiculo ON public.stock_vehiculo (vehiculo_id);

-- ---------------------------------------------------------------------
-- 4. Normalización y updated_at
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_plantillas_equipamiento_before()
RETURNS trigger
LANGUAGE plpgsql
SET search_path TO 'public'
AS $$
BEGIN
  NEW.tipos_vehiculo := COALESCE(
    (SELECT array_agg(DISTINCT upper(trim(t))) FROM unnest(NEW.tipos_vehiculo) AS t
      WHERE trim(t) <> ''),
    '{}'::text[]
  );
  NEW.updated_at := now();
  IF TG_OP = 'UPDATE' THEN
    NEW.updated_by := auth.uid();
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_plantillas_equipamiento_before
  BEFORE INSERT OR UPDATE ON public.plantillas_equipamiento
  FOR EACH ROW EXECUTE FUNCTION public.fn_plantillas_equipamiento_before();

CREATE OR REPLACE FUNCTION public.fn_plantilla_items_before()
RETURNS trigger
LANGUAGE plpgsql
SET search_path TO 'public'
AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND NEW.producto_id IS DISTINCT FROM OLD.producto_id THEN
    RAISE EXCEPTION 'No se puede cambiar el producto de un item de plantilla. Desactívalo y crea uno nuevo.';
  END IF;
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_plantilla_items_before
  BEFORE INSERT OR UPDATE ON public.plantilla_equipamiento_items
  FOR EACH ROW EXECUTE FUNCTION public.fn_plantilla_items_before();

-- ---------------------------------------------------------------------
-- 5. Función núcleo: aplicar plantillas a vehículos
--    Filtros opcionales: plantilla, vehículo, item. NULL = todos.
--    Devuelve nº de líneas creadas + adoptadas.
-- ---------------------------------------------------------------------
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
  -- 5.1 Adoptar líneas existentes del mismo producto (sin plantilla) para no duplicar
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

  -- 5.2 Crear las líneas que falten
  INSERT INTO stock_vehiculo (vehiculo_id, producto_id, cantidad_actual, plantilla_item_id, origen, updated_at)
  SELECT v.id, i.producto_id, 0, i.id, 'plantilla', now()
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

-- RPC pública (botón "Reaplicar" en la web) con control de rol
CREATE OR REPLACE FUNCTION public.rpc_aplicar_plantilla_equipamiento(p_plantilla_id uuid)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  IF COALESCE(fn_rol_actual(), '') NOT IN ('admin', 'jefe_mantenimiento') THEN
    RAISE EXCEPTION 'No tienes permisos para aplicar plantillas de equipamiento';
  END IF;
  RETURN fn_aplicar_plantillas_equipamiento(p_plantilla_id, NULL, NULL);
END;
$$;

REVOKE ALL ON FUNCTION public.rpc_aplicar_plantilla_equipamiento(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.rpc_aplicar_plantilla_equipamiento(uuid) TO authenticated;

-- ---------------------------------------------------------------------
-- 6. Propagación automática
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_trg_aplicar_por_item()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  PERFORM fn_aplicar_plantillas_equipamiento(NULL, NULL, NEW.id);
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_plantilla_items_aplicar
  AFTER INSERT OR UPDATE OF activo ON public.plantilla_equipamiento_items
  FOR EACH ROW WHEN (NEW.activo)
  EXECUTE FUNCTION public.fn_trg_aplicar_por_item();

CREATE OR REPLACE FUNCTION public.fn_trg_aplicar_por_plantilla()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  PERFORM fn_aplicar_plantillas_equipamiento(NEW.id, NULL, NULL);
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_plantillas_equipamiento_aplicar
  AFTER INSERT OR UPDATE OF tipos_vehiculo, activo, empresa_id ON public.plantillas_equipamiento
  FOR EACH ROW WHEN (NEW.activo)
  EXECUTE FUNCTION public.fn_trg_aplicar_por_plantilla();

CREATE OR REPLACE FUNCTION public.fn_trg_aplicar_por_vehiculo()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  PERFORM fn_aplicar_plantillas_equipamiento(NULL, NEW.id, NULL);
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_tvehiculos_aplicar_plantillas
  AFTER INSERT OR UPDATE OF tipo_vehiculo, activo, empresa_id ON public.tvehiculos
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_trg_aplicar_por_vehiculo();

REVOKE ALL ON FUNCTION public.fn_trg_aplicar_por_item()      FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.fn_trg_aplicar_por_plantilla() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.fn_trg_aplicar_por_vehiculo()  FROM PUBLIC, anon, authenticated;

-- ---------------------------------------------------------------------
-- 7. Protección: solo admin / jefe_mantenimiento cambian la vinculación
--    (los técnicos sí pueden cambiar cantidad, caducidad, lote, adjunto)
--    Solo se aplica a llamadas directas de la API (roles anon/authenticated);
--    las funciones SECURITY DEFINER y los triggers internos no se ven afectados.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_stock_vehiculo_proteger_plantilla()
RETURNS trigger
LANGUAGE plpgsql
SET search_path TO 'public'
AS $$
BEGIN
  IF current_user IN ('authenticated', 'anon')
     AND COALESCE(fn_rol_actual(), '') NOT IN ('admin', 'jefe_mantenimiento')
     AND (NEW.excluido          IS DISTINCT FROM OLD.excluido
       OR NEW.origen            IS DISTINCT FROM OLD.origen
       OR NEW.plantilla_item_id IS DISTINCT FROM OLD.plantilla_item_id
       OR NEW.vehiculo_id       IS DISTINCT FROM OLD.vehiculo_id
       OR (OLD.plantilla_item_id IS NOT NULL AND NEW.producto_id IS DISTINCT FROM OLD.producto_id))
  THEN
    RAISE EXCEPTION 'Solo administración o jefe de mantenimiento pueden modificar la dotación del vehículo';
  END IF;
  NEW.updated_at := now();
  NEW.updated_by := COALESCE(auth.uid(), NEW.updated_by);
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_stock_vehiculo_proteger_plantilla
  BEFORE UPDATE ON public.stock_vehiculo
  FOR EACH ROW EXECUTE FUNCTION public.fn_stock_vehiculo_proteger_plantilla();

-- ---------------------------------------------------------------------
-- 8. RLS de las tablas nuevas
-- ---------------------------------------------------------------------
ALTER TABLE public.plantillas_equipamiento      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plantilla_equipamiento_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY plantillas_equipamiento_select ON public.plantillas_equipamiento
  FOR SELECT TO authenticated USING (true);
CREATE POLICY plantillas_equipamiento_insert ON public.plantillas_equipamiento
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT fn_rol_actual()) IN ('admin', 'jefe_mantenimiento'));
CREATE POLICY plantillas_equipamiento_update ON public.plantillas_equipamiento
  FOR UPDATE TO authenticated
  USING ((SELECT fn_rol_actual()) IN ('admin', 'jefe_mantenimiento'))
  WITH CHECK ((SELECT fn_rol_actual()) IN ('admin', 'jefe_mantenimiento'));
CREATE POLICY plantillas_equipamiento_delete ON public.plantillas_equipamiento
  FOR DELETE TO authenticated
  USING ((SELECT fn_rol_actual()) = 'admin');

CREATE POLICY plantilla_items_select ON public.plantilla_equipamiento_items
  FOR SELECT TO authenticated USING (true);
CREATE POLICY plantilla_items_insert ON public.plantilla_equipamiento_items
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT fn_rol_actual()) IN ('admin', 'jefe_mantenimiento'));
CREATE POLICY plantilla_items_update ON public.plantilla_equipamiento_items
  FOR UPDATE TO authenticated
  USING ((SELECT fn_rol_actual()) IN ('admin', 'jefe_mantenimiento'))
  WITH CHECK ((SELECT fn_rol_actual()) IN ('admin', 'jefe_mantenimiento'));
CREATE POLICY plantilla_items_delete ON public.plantilla_equipamiento_items
  FOR DELETE TO authenticated
  USING ((SELECT fn_rol_actual()) IN ('admin', 'jefe_mantenimiento'));

-- ---------------------------------------------------------------------
-- 9. Vista de estado: se mantienen las columnas existentes (mismo orden)
--    y se añaden las nuevas al final.
-- ---------------------------------------------------------------------
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
       -- Nuevas columnas (plantillas de equipamiento)
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
         WHEN sv.fecha_caducidad IS NOT NULL AND sv.fecha_caducidad < CURRENT_DATE THEN 'caducado'::text
         WHEN sv.cantidad_actual < COALESCE(pi.cantidad_requerida, 0) THEN 'falta'::text
         WHEN COALESCE(pi.requiere_caducidad, false) AND sv.fecha_caducidad IS NULL THEN 'sin_fecha'::text
         WHEN COALESCE(pi.requiere_adjunto, false) AND sv.documento_path IS NULL THEN 'sin_adjunto'::text
         WHEN sv.fecha_caducidad IS NOT NULL
              AND sv.fecha_caducidad < (CURRENT_DATE + '30 days'::interval) THEN 'proximo'::text
         ELSE 'ok'::text
       END AS estado_dotacion
  FROM stock_vehiculo sv
  JOIN tvehiculos v ON sv.vehiculo_id = v.id
  JOIN productos p ON sv.producto_id = p.id
  JOIN categorias_equipamiento c ON p.categoria_id = c.id
  LEFT JOIN plantilla_equipamiento_items pi ON pi.id = sv.plantilla_item_id
  LEFT JOIN plantillas_equipamiento pl ON pl.id = pi.plantilla_id
  LEFT JOIN equipamiento_reglamentario_vehiculo sm
         ON sm.producto_id = p.id AND sm.tipo_vehiculo_codigo::text = v.tipo_vehiculo;

-- ---------------------------------------------------------------------
-- 10. Bucket privado para adjuntos (certificados, pólizas, fotos)
-- ---------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('equipamiento-vehiculos', 'equipamiento-vehiculos', false, 10485760,
        ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

CREATE POLICY equipamiento_vehiculos_select ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'equipamiento-vehiculos');
CREATE POLICY equipamiento_vehiculos_insert ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'equipamiento-vehiculos');
CREATE POLICY equipamiento_vehiculos_update ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'equipamiento-vehiculos')
  WITH CHECK (bucket_id = 'equipamiento-vehiculos');
CREATE POLICY equipamiento_vehiculos_delete ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'equipamiento-vehiculos'
         AND (SELECT public.fn_rol_actual()) IN ('admin', 'jefe_mantenimiento'));

COMMIT;
