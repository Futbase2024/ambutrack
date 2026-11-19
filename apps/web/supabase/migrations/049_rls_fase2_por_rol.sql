-- =============================================
-- SEGURIDAD A2 · Fase 2: reglas por rol en el resto de tablas abiertas
-- Sustituye las políticas "authenticated USING (true)" por reglas por rol.
-- Depende de fn_rol_actual(), fn_mi_personal_id() (034) y fn_rol_en() (048).
--
-- Grupos:
--   TRAFICO  = admin, jefe_trafico, coordinador
--   FLOTA    = admin, jefe_trafico, jefe_mantenimiento, tecnico
--   ALMACEN  = admin, jefe_mantenimiento, tecnico
--   RRHH     = admin, jefe_personal
--   OPERATIVO (stock de ambulancia) = ALMACEN + jefe_trafico + conductor + sanitario
-- =============================================

-- 1. Helpers ---------------------------------------------------------------

-- ¿El traslado está asignado al usuario actual (conductor o personal asignado)?
CREATE OR REPLACE FUNCTION public.fn_traslado_es_mio(p_traslado_id UUID)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.traslados t
     WHERE t.id = p_traslado_id
       AND (t.id_conductor = public.fn_mi_personal_id()
            OR public.fn_mi_personal_id() = ANY (t.personal_asignado))
  )
$$;
REVOKE EXECUTE ON FUNCTION public.fn_traslado_es_mio(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_traslado_es_mio(UUID) TO authenticated, service_role;

-- Procedimiento temporal: borra las políticas de una tabla (salvo las indicadas)
-- y crea SELECT/INSERT/UPDATE/DELETE con las expresiones dadas (NULL = sin política)
CREATE OR REPLACE FUNCTION pg_temp.rls_set(
  p_table TEXT, p_select TEXT, p_insert TEXT, p_update TEXT, p_delete TEXT,
  p_keep TEXT[] DEFAULT ARRAY[]::TEXT[], p_select_roles TEXT DEFAULT 'authenticated'
) RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT p.polname FROM pg_policy p JOIN pg_class c ON c.oid = p.polrelid
     WHERE c.relnamespace = 'public'::regnamespace AND c.relname = p_table
       AND NOT (p.polname = ANY (p_keep))
  LOOP
    EXECUTE format('DROP POLICY %I ON public.%I', r.polname, p_table);
  END LOOP;
  EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', p_table);
  IF p_select IS NOT NULL THEN
    EXECUTE format('CREATE POLICY %I ON public.%I FOR SELECT TO %s USING (%s)',
      p_table || '_select', p_table, p_select_roles, p_select);
  END IF;
  IF p_insert IS NOT NULL THEN
    EXECUTE format('CREATE POLICY %I ON public.%I FOR INSERT TO authenticated WITH CHECK (%s)',
      p_table || '_insert', p_table, p_insert);
  END IF;
  IF p_update IS NOT NULL THEN
    EXECUTE format('CREATE POLICY %I ON public.%I FOR UPDATE TO authenticated USING (%s) WITH CHECK (%s)',
      p_table || '_update', p_table, p_update, p_update);
  END IF;
  IF p_delete IS NOT NULL THEN
    EXECUTE format('CREATE POLICY %I ON public.%I FOR DELETE TO authenticated USING (%s)',
      p_table || '_delete', p_table, p_delete);
  END IF;
END $$;

-- 2. Reglas ---------------------------------------------------------------
DO $$
DECLARE
  trafico   CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''coordinador''])';
  trafico_r CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''coordinador'',''administrativo'',''operador''])';
  jefes_trf CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico''])';
  flota     CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''jefe_mantenimiento'',''tecnico''])';
  flota_doc CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''jefe_mantenimiento'',''tecnico'',''administrativo''])';
  almacen   CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_mantenimiento'',''tecnico''])';
  almacen_r CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_mantenimiento'',''tecnico'',''jefe_trafico''])';
  operativo CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_mantenimiento'',''tecnico'',''jefe_trafico'',''conductor'',''sanitario''])';
  borrar_mt CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_mantenimiento''])';
  rrhh      CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_personal''])';
  turnos_w  CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_personal'',''jefe_trafico'',''coordinador''])';
  maestras  CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''jefe_personal'',''coordinador'',''jefe_mantenimiento''])';
  solo_admin CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin''])';
  mi_traslado CONSTANT TEXT :=
    '(id_conductor = public.fn_mi_personal_id() OR public.fn_mi_personal_id() = ANY (personal_asignado))';
  t TEXT;
BEGIN
  -- Servicios -----------------------------------------------------------
  PERFORM pg_temp.rls_set('traslados',
    trafico_r || ' OR ' || mi_traslado, trafico, trafico || ' OR ' || mi_traslado, jefes_trf);
  PERFORM pg_temp.rls_set('servicios_recurrentes', trafico_r, trafico, trafico, jefes_trf);
  PERFORM pg_temp.rls_set('servicios_pendientes', trafico_r, trafico, trafico, jefes_trf);
  -- El trigger de cambio de estado inserta aquí con los permisos de quien cambia el estado
  PERFORM pg_temp.rls_set('historial_estados_traslado',
    trafico_r || ' OR public.fn_traslado_es_mio(id_traslado)',
    trafico || ' OR public.fn_traslado_es_mio(id_traslado)',
    solo_admin, solo_admin);

  -- Turnos (lectura para todos: la app muestra los compañeros de la ambulancia)
  PERFORM pg_temp.rls_set('turnos', 'true', turnos_w,
    turnos_w || ' OR "idPersonal" = public.fn_mi_personal_id()::text', turnos_w);
  PERFORM pg_temp.rls_set('plantillas_turnos', 'true', rrhh, rrhh, rrhh);

  -- Taller y documentación de vehículos -------------------------------------
  FOREACH t IN ARRAY ARRAY['tordenes_reparacion', 'trepuestos_orden', 'mantenimiento_electromedicina'] LOOP
    PERFORM pg_temp.rls_set(t, flota, flota, flota, borrar_mt);
  END LOOP;
  PERFORM pg_temp.rls_set('ambutrack_documentacion_vehiculos', flota_doc, flota_doc, flota_doc,
    'public.fn_rol_en(ARRAY[''admin'',''jefe_mantenimiento'',''administrativo''])');

  -- Incidencias de vehículo: cualquiera con sesión reporta; gestiona Flota/Tráfico
  PERFORM pg_temp.rls_set('incidencias_vehiculos', 'true', 'true',
    flota || ' OR ' || trafico
      || ' OR reportado_por = auth.uid() OR reportado_por = public.fn_mi_personal_id()',
    borrar_mt);

  -- Almacén general -------------------------------------------------------
  FOREACH t IN ARRAY ARRAY['almacenes', 'proveedores', 'stock', 'stock_almacen', 'entradas_almacen',
                           'detalle_entradas_almacen', 'transferencias_stock'] LOOP
    PERFORM pg_temp.rls_set(t, almacen_r, almacen, almacen, borrar_mt);
  END LOOP;
  PERFORM pg_temp.rls_set('productos', 'true', almacen, almacen, borrar_mt);
  PERFORM pg_temp.rls_set('stock_vestuario',
    'public.fn_rol_en(ARRAY[''admin'',''jefe_personal'',''jefe_mantenimiento'',''tecnico''])',
    rrhh, rrhh, rrhh);

  -- Stock de ambulancia (tripulación y técnicos revisan y reponen; nunca borran)
  PERFORM pg_temp.rls_set('stock_vehiculo', 'true', operativo, operativo, NULL,
    ARRAY['stock_vehiculo_delete_extras']);
  PERFORM pg_temp.rls_set('movimientos_stock', 'true', operativo, solo_admin, solo_admin);
  FOREACH t IN ARRAY ARRAY['revisiones_mensuales', 'items_revision', 'alertas_stock'] LOOP
    PERFORM pg_temp.rls_set(t, 'true', operativo, operativo, borrar_mt);
  END LOOP;

  -- Formación -------------------------------------------------------------
  FOREACH t IN ARRAY ARRAY['cursos', 'certificaciones'] LOOP
    PERFORM pg_temp.rls_set(t, 'true', rrhh, rrhh, rrhh);
  END LOOP;

  -- Tablas maestras (provincias y tipos de vehículo ya eran legibles sin sesión)
  FOREACH t IN ARRAY ARRAY['tespecialidades', 'tfacultativos', 'tcategorias_vehiculo',
                           'ambutrack_tipos_documento_vehiculo'] LOOP
    PERFORM pg_temp.rls_set(t, 'true', maestras, maestras, maestras);
  END LOOP;
  FOREACH t IN ARRAY ARRAY['tprovincias', 'tipos_vehiculo'] LOOP
    PERFORM pg_temp.rls_set(t, 'true', maestras, maestras, maestras, ARRAY[]::TEXT[], 'anon, authenticated');
  END LOOP;
END $$;
