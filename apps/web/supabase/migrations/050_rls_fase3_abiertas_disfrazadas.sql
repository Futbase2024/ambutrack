-- =============================================
-- SEGURIDAD A2 · Fase 3: tablas con escritura abierta "disfrazada"
-- Políticas del tipo `auth.uid() IS NOT NULL` o `auth.role() = 'authenticated'`
-- equivalen a "cualquier usuario con sesión puede todo". Se sustituyen por
-- reglas por rol. Además:
--   - Vistas vw_alertas_caducidad_activas y v_stock_vehiculo_estado pasan a
--     security_invoker (respetan las reglas del usuario que consulta).
--   - trg_stock_vehiculo_sync_silla (función de trigger) deja de ser ejecutable
--     por anon/authenticated vía RPC.
-- Depende de fn_rol_en() (048) y fn_mi_personal_id() (034).
-- =============================================

CREATE OR REPLACE FUNCTION pg_temp.rls_set(
  p_table TEXT, p_select TEXT, p_insert TEXT, p_update TEXT, p_delete TEXT
) RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT p.polname FROM pg_policy p JOIN pg_class c ON c.oid = p.polrelid
     WHERE c.relnamespace = 'public'::regnamespace AND c.relname = p_table
  LOOP
    EXECUTE format('DROP POLICY %I ON public.%I', r.polname, p_table);
  END LOOP;
  EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', p_table);
  IF p_select IS NOT NULL THEN
    EXECUTE format('CREATE POLICY %I ON public.%I FOR SELECT TO authenticated USING (%s)',
      p_table || '_select', p_table, p_select);
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

DO $$
DECLARE
  cuadrante CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_personal'',''jefe_trafico'',''coordinador''])';
  calendario CONSTANT TEXT :=
    'public.fn_rol_en(ARRAY[''admin'',''jefe_personal'',''jefe_trafico'',''coordinador'',''administrativo''])';
  contratos CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_personal'',''jefe_trafico'',''administrativo''])';
  flota     CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''jefe_mantenimiento'',''tecnico''])';
  flota_r   CONSTANT TEXT :=
    'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''jefe_mantenimiento'',''tecnico'',''coordinador'',''administrativo''])';
  flota_doc CONSTANT TEXT :=
    'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''jefe_mantenimiento'',''tecnico'',''administrativo''])';
  -- La app móvil actualiza el vehículo (km) al reportar una avería
  vehiculo_w CONSTANT TEXT :=
    'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''jefe_mantenimiento'',''tecnico'',''administrativo'',''conductor'',''sanitario''])';
  vehiculo_alta CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''jefe_mantenimiento'',''administrativo''])';
  operativo CONSTANT TEXT :=
    'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''coordinador'',''jefe_mantenimiento'',''tecnico'',''conductor'',''sanitario''])';
  gps_r     CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''coordinador'',''operador'',''jefe_mantenimiento''])';
  borrar_mt CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin'',''jefe_mantenimiento''])';
  maestras  CONSTANT TEXT :=
    'public.fn_rol_en(ARRAY[''admin'',''jefe_trafico'',''jefe_personal'',''coordinador'',''jefe_mantenimiento''])';
  solo_admin CONSTANT TEXT := 'public.fn_rol_en(ARRAY[''admin''])';
  t TEXT;
BEGIN
  -- Cuadrante, dotaciones y bases (lectura para todos: la operativa los consulta)
  FOREACH t IN ARRAY ARRAY['asignaciones_vehiculos_turnos', 'cuadrante_asignaciones', 'dotaciones',
                           'turnos_personal_vehiculos', 'bases'] LOOP
    PERFORM pg_temp.rls_set(t, 'true', cuadrante, cuadrante, cuadrante);
  END LOOP;
  PERFORM pg_temp.rls_set('excepciones_calendario', 'true', calendario, calendario, calendario);

  -- Contratos
  FOREACH t IN ARRAY ARRAY['contratos', 'tcontratos'] LOOP
    PERFORM pg_temp.rls_set(t, contratos, contratos, contratos, contratos);
  END LOOP;

  -- Vehículos
  PERFORM pg_temp.rls_set('tvehiculos', 'true', vehiculo_alta, vehiculo_w,
    'public.fn_rol_en(ARRAY[''admin'',''jefe_mantenimiento''])');
  FOREACH t IN ARRAY ARRAY['tmantenimientos', 'taverias', 'tequipamiento_vehiculo'] LOOP
    PERFORM pg_temp.rls_set(t, flota_r, flota, flota, borrar_mt);
  END LOOP;
  PERFORM pg_temp.rls_set('tdocumentos_vehiculo', flota_doc, flota_doc, flota_doc, borrar_mt);
  -- Consumo de combustible: también lo registra la tripulación
  PERFORM pg_temp.rls_set('tconsumo_combustible', flota_r || ' OR ' || operativo, operativo, flota, borrar_mt);
  -- Historial GPS: lo envía la tripulación; lo consultan Tráfico y Flota; nadie lo modifica
  PERFORM pg_temp.rls_set('thistorial_ubicaciones', gps_r, operativo, solo_admin, solo_admin);

  -- Tablas maestras
  FOREACH t IN ARRAY ARRAY['tcategorias', 'tcentros_hospitalarios', 'tcomunidades', 'tmotivos_cancelacion',
                           'tmotivos_traslado', 'tpoblaciones', 'tpuestos', 'tsit_laboral',
                           'ttipos_traslado', 'tipos_ausencia'] LOOP
    PERFORM pg_temp.rls_set(t, 'true', maestras, maestras, maestras);
  END LOOP;
END $$;

-- Vistas: respetar las reglas del usuario que consulta
ALTER VIEW public.vw_alertas_caducidad_activas SET (security_invoker = on);
ALTER VIEW public.v_stock_vehiculo_estado SET (security_invoker = on);

-- Función de trigger: no debe poder llamarse por RPC
REVOKE EXECUTE ON FUNCTION public.trg_stock_vehiculo_sync_silla() FROM PUBLIC, anon, authenticated;
