-- =============================================
-- Auditoría en más tablas + historial por registro para ellas
--   Triggers fn_audit_row() en: pacientes, historial_medico, ausencias,
--   vacaciones, incidencias, incidencias_vehiculos, servicios_recurrentes,
--   turnos, stock, productos, proveedores.
--   fn_historial_registro: roles autorizados para cada nueva tabla.
-- =============================================

DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['pacientes', 'historial_medico', 'ausencias', 'vacaciones', 'incidencias',
                           'incidencias_vehiculos', 'servicios_recurrentes', 'turnos', 'stock',
                           'productos', 'proveedores'] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS %I ON public.%I', 'trg_audit_' || t, t);
    EXECUTE format(
      'CREATE TRIGGER %I AFTER INSERT OR UPDATE OR DELETE ON public.%I '
      'FOR EACH ROW EXECUTE FUNCTION public.fn_audit_row()',
      'trg_audit_' || t, t);
  END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fn_historial_registro(
  p_tabla TEXT,
  p_registro_id TEXT,
  p_limit INT DEFAULT 100
)
RETURNS SETOF public.audit_log
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_roles TEXT[];
BEGIN
  v_roles := CASE p_tabla
    WHEN 'tvehiculos'            THEN ARRAY['admin','jefe_trafico','jefe_mantenimiento','tecnico','coordinador','administrativo']
    WHEN 'tmantenimientos'       THEN ARRAY['admin','jefe_trafico','jefe_mantenimiento','tecnico']
    WHEN 'titv_revisiones'       THEN ARRAY['admin','jefe_trafico','jefe_mantenimiento','tecnico']
    WHEN 'tordenes_reparacion'   THEN ARRAY['admin','jefe_trafico','jefe_mantenimiento','tecnico']
    WHEN 'ttalleres'             THEN ARRAY['admin','jefe_trafico','jefe_mantenimiento','tecnico']
    WHEN 'incidencias_vehiculos' THEN ARRAY['admin','jefe_trafico','jefe_mantenimiento','tecnico','coordinador']
    WHEN 'traslados'             THEN ARRAY['admin','jefe_trafico','coordinador','administrativo']
    WHEN 'servicios'             THEN ARRAY['admin','jefe_trafico','coordinador','administrativo']
    WHEN 'servicios_recurrentes' THEN ARRAY['admin','jefe_trafico','coordinador','administrativo']
    WHEN 'pacientes'             THEN ARRAY['admin','jefe_trafico','coordinador','administrativo']
    WHEN 'incidencias'           THEN ARRAY['admin','jefe_personal','jefe_trafico','coordinador','administrativo']
    WHEN 'turnos'                THEN ARRAY['admin','jefe_personal','jefe_trafico','coordinador']
    WHEN 'tpersonal'             THEN ARRAY['admin','jefe_personal']
    WHEN 'historial_medico'      THEN ARRAY['admin','jefe_personal']
    WHEN 'ausencias'             THEN ARRAY['admin','jefe_personal']
    WHEN 'vacaciones'            THEN ARRAY['admin','jefe_personal']
    WHEN 'contratos'             THEN ARRAY['admin','jefe_personal','jefe_trafico','administrativo']
    WHEN 'stock'                 THEN ARRAY['admin','jefe_mantenimiento','tecnico']
    WHEN 'productos'             THEN ARRAY['admin','jefe_mantenimiento','tecnico']
    WHEN 'proveedores'           THEN ARRAY['admin','jefe_mantenimiento','tecnico']
    ELSE ARRAY['admin']
  END;

  IF NOT public.fn_rol_en(v_roles) THEN
    RETURN;
  END IF;

  RETURN QUERY
    SELECT a.*
      FROM public.audit_log a
     WHERE a.tabla = p_tabla
       AND a.registro_id = p_registro_id
       AND (a.empresa_id IS NULL
            OR a.empresa_id = (SELECT u.empresa_id FROM public.usuarios u WHERE u.id = auth.uid())
            OR (SELECT u.empresa_id FROM public.usuarios u WHERE u.id = auth.uid()) IS NULL)
     ORDER BY a.created_at DESC
     LIMIT LEAST(GREATEST(p_limit, 1), 500);
END $$;
