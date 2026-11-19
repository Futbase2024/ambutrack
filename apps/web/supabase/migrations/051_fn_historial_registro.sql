-- =============================================
-- D3: historial de cambios de un registro (pestaña "Historial" de las fichas)
--
-- audit_log solo lo lee el admin (contiene datos completos y emails). Esta
-- función devuelve el historial de UN registro a los roles que gestionan el
-- módulo de esa tabla. Para cualquier otra tabla o rol devuelve 0 filas.
-- Depende de fn_rol_en() (048).
-- =============================================

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
    WHEN 'tvehiculos'          THEN ARRAY['admin','jefe_trafico','jefe_mantenimiento','tecnico','coordinador','administrativo']
    WHEN 'tmantenimientos'     THEN ARRAY['admin','jefe_trafico','jefe_mantenimiento','tecnico']
    WHEN 'titv_revisiones'     THEN ARRAY['admin','jefe_trafico','jefe_mantenimiento','tecnico']
    WHEN 'tordenes_reparacion' THEN ARRAY['admin','jefe_trafico','jefe_mantenimiento','tecnico']
    WHEN 'ttalleres'           THEN ARRAY['admin','jefe_trafico','jefe_mantenimiento','tecnico']
    WHEN 'traslados'           THEN ARRAY['admin','jefe_trafico','coordinador','administrativo']
    WHEN 'servicios'           THEN ARRAY['admin','jefe_trafico','coordinador','administrativo']
    WHEN 'tpersonal'           THEN ARRAY['admin','jefe_personal']
    WHEN 'contratos'           THEN ARRAY['admin','jefe_personal','jefe_trafico','administrativo']
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

REVOKE EXECUTE ON FUNCTION public.fn_historial_registro(TEXT, TEXT, INT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_historial_registro(TEXT, TEXT, INT) TO authenticated, service_role;
