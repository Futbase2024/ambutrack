-- =============================================
-- C1: seguimiento GPS en tiempo real de la flota
--
-- - fn_registrar_ubicacion (app móvil): la tripulación solo envía coordenadas;
--   el vehículo se deduce de su turno de hoy, así que nadie puede enviar
--   posiciones de una ambulancia que no es la suya.
-- - fn_ultimas_ubicaciones (web): última posición de cada vehículo
--   (SECURITY INVOKER: se aplican las reglas de lectura de la tabla).
-- - Índice (vehiculo_id, timestamp) para el recorrido del día y Realtime.
-- =============================================

CREATE INDEX IF NOT EXISTS idx_thistorial_ubicaciones_vehiculo_ts
  ON public.thistorial_ubicaciones (vehiculo_id, "timestamp" DESC);

-- Vehículo del turno de hoy del usuario actual (NULL si no tiene)
CREATE OR REPLACE FUNCTION public.fn_mi_vehiculo_hoy()
RETURNS UUID LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT nullif(t."idVehiculo"::text, '')::uuid
    FROM public.turnos t
   WHERE t."idPersonal" = public.fn_mi_personal_id()::text
     AND coalesce(t.activo, true)
     AND t."idVehiculo" IS NOT NULL
     AND (t."fechaInicio" AT TIME ZONE 'Europe/Madrid')::date <= (now() AT TIME ZONE 'Europe/Madrid')::date
     AND (t."fechaFin" AT TIME ZONE 'Europe/Madrid')::date >= (now() AT TIME ZONE 'Europe/Madrid')::date
   ORDER BY t."fechaInicio" DESC
   LIMIT 1
$$;

CREATE OR REPLACE FUNCTION public.fn_registrar_ubicacion(
  p_latitud NUMERIC,
  p_longitud NUMERIC,
  p_velocidad_kmh NUMERIC DEFAULT NULL,
  p_precision_metros NUMERIC DEFAULT NULL,
  p_direccion_grados NUMERIC DEFAULT NULL,
  p_servicio_id UUID DEFAULT NULL
)
RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_vehiculo UUID := public.fn_mi_vehiculo_hoy();
  v_empresa UUID;
  v_id UUID;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Permiso denegado' USING ERRCODE = '42501';
  END IF;
  IF v_vehiculo IS NULL THEN
    RAISE EXCEPTION 'No tienes un vehículo asignado en tu turno de hoy' USING ERRCODE = 'P0002';
  END IF;
  IF p_latitud NOT BETWEEN -90 AND 90 OR p_longitud NOT BETWEEN -180 AND 180 THEN
    RAISE EXCEPTION 'Coordenadas no válidas' USING ERRCODE = '22023';
  END IF;

  SELECT u.empresa_id INTO v_empresa FROM public.usuarios u WHERE u.id = auth.uid();

  INSERT INTO public.thistorial_ubicaciones (
    vehiculo_id, "timestamp", latitud, longitud, velocidad_kmh, precision_metros,
    direccion_grados, en_servicio, servicio_id, empresa_id
  ) VALUES (
    v_vehiculo, now(), p_latitud, p_longitud, p_velocidad_kmh, p_precision_metros,
    p_direccion_grados, p_servicio_id IS NOT NULL, p_servicio_id,
    coalesce(v_empresa, '00000000-0000-0000-0000-000000000001'::uuid)
  )
  RETURNING id INTO v_id;
  RETURN v_id;
END $$;

CREATE OR REPLACE FUNCTION public.fn_ultimas_ubicaciones()
RETURNS TABLE (
  vehiculo_id UUID, matricula TEXT, tipo_vehiculo TEXT, clasificacion TEXT,
  "timestamp" TIMESTAMPTZ, latitud NUMERIC, longitud NUMERIC,
  velocidad_kmh NUMERIC, en_servicio BOOLEAN
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = public AS $$
  SELECT DISTINCT ON (u.vehiculo_id)
         u.vehiculo_id, v.matricula, v.tipo_vehiculo, v.clasificacion,
         u."timestamp", u.latitud, u.longitud, u.velocidad_kmh, coalesce(u.en_servicio, false)
    FROM public.thistorial_ubicaciones u
    JOIN public.tvehiculos v ON v.id = u.vehiculo_id
   WHERE u."timestamp" > now() - interval '7 days'
   ORDER BY u.vehiculo_id, u."timestamp" DESC
$$;

REVOKE EXECUTE ON FUNCTION public.fn_mi_vehiculo_hoy(), public.fn_ultimas_ubicaciones(),
  public.fn_registrar_ubicacion(NUMERIC, NUMERIC, NUMERIC, NUMERIC, NUMERIC, UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_mi_vehiculo_hoy(), public.fn_ultimas_ubicaciones(),
  public.fn_registrar_ubicacion(NUMERIC, NUMERIC, NUMERIC, NUMERIC, NUMERIC, UUID) TO authenticated, service_role;

-- Realtime (respeta las reglas de lectura de la tabla)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
     WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'thistorial_ubicaciones'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.thistorial_ubicaciones;
  END IF;
END $$;
