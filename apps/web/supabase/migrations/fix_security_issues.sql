-- ============================================================================
-- SCRIPT DE CORRECCIÓN DE PROBLEMAS DE SEGURIDAD - AmbuTrack
-- Fecha: 2025-01-01
-- Proyecto: ycmopmnrhrpnnzkvnihr
-- ============================================================================
-- Este script corrige los 4 errores críticos identificados por Supabase Security Advisor
-- ============================================================================

-- ============================================================================
-- PRIORIDAD 1: HABILITAR RLS EN TABLAS CRÍTICAS
-- ============================================================================
-- Las siguientes tablas están expuestas públicamente SIN Row Level Security
-- Esto es un riesgo CRÍTICO de seguridad

-- 1.1 Habilitar RLS en tabla servicios
ALTER TABLE public.servicios ENABLE ROW LEVEL SECURITY;

-- 1.2 Habilitar RLS en tabla servicios_recurrentes
ALTER TABLE public.servicios_recurrentes ENABLE ROW LEVEL SECURITY;

-- 1.3 Habilitar RLS en tabla traslados
ALTER TABLE public.traslados ENABLE ROW LEVEL SECURITY;

-- 1.4 Habilitar RLS en tabla historial_estados_traslado
ALTER TABLE public.historial_estados_traslado ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PRIORIDAD 1.5: CREAR POLÍTICAS RLS BÁSICAS (TEMPORALES)
-- ============================================================================
-- IMPORTANTE: Estas políticas permiten acceso a usuarios autenticados
-- Deberás ajustarlas según tu lógica de negocio específica

-- Políticas para servicios
CREATE POLICY "servicios_select_authenticated"
  ON public.servicios
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "servicios_insert_authenticated"
  ON public.servicios
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "servicios_update_authenticated"
  ON public.servicios
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "servicios_delete_authenticated"
  ON public.servicios
  FOR DELETE
  TO authenticated
  USING (true);

-- Políticas para servicios_recurrentes
CREATE POLICY "servicios_recurrentes_select_authenticated"
  ON public.servicios_recurrentes
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "servicios_recurrentes_insert_authenticated"
  ON public.servicios_recurrentes
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "servicios_recurrentes_update_authenticated"
  ON public.servicios_recurrentes
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "servicios_recurrentes_delete_authenticated"
  ON public.servicios_recurrentes
  FOR DELETE
  TO authenticated
  USING (true);

-- Políticas para traslados
CREATE POLICY "traslados_select_authenticated"
  ON public.traslados
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "traslados_insert_authenticated"
  ON public.traslados
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "traslados_update_authenticated"
  ON public.traslados
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "traslados_delete_authenticated"
  ON public.traslados
  FOR DELETE
  TO authenticated
  USING (true);

-- Políticas para historial_estados_traslado
CREATE POLICY "historial_estados_traslado_select_authenticated"
  ON public.historial_estados_traslado
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "historial_estados_traslado_insert_authenticated"
  ON public.historial_estados_traslado
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "historial_estados_traslado_update_authenticated"
  ON public.historial_estados_traslado
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "historial_estados_traslado_delete_authenticated"
  ON public.historial_estados_traslado
  FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- PRIORIDAD 2: CORREGIR VISTA QUE EXPONE auth.users
-- ============================================================================
-- La vista v_usuarios_con_roles está exponiendo datos sensibles de auth.users
-- Solución: Recrear la vista sin exponer campos sensibles

-- Primero eliminamos la vista actual
DROP VIEW IF EXISTS public.v_usuarios_con_roles;

-- Recreamos la vista SIN campos sensibles de auth.users
-- SOLO exponemos: id, email, created_at
-- NO exponemos: encrypted_password, email_confirmed_at, confirmation_token, etc.
CREATE OR REPLACE VIEW public.v_usuarios_con_roles
WITH (security_invoker = true) -- ⚠️ IMPORTANTE: Usar security_invoker en lugar de security_definer
AS
SELECT
    au.id,
    au.email,
    au.created_at as auth_created_at,
    -- Campos de la tabla usuarios (si existe)
    u.nombre,
    u.apellidos,
    u.activo,
    -- Campos de roles (agregar según tu estructura)
    r.nombre as rol_nombre,
    r.descripcion as rol_descripcion
FROM auth.users au
LEFT JOIN public.usuarios u ON au.id = u.id_auth_user
LEFT JOIN public.usuarios_roles ur ON u.id = ur.id_usuario
LEFT JOIN public.roles r ON ur.id_rol = r.id;

-- Otorgar permisos SOLO a usuarios autenticados
GRANT SELECT ON public.v_usuarios_con_roles TO authenticated;
REVOKE SELECT ON public.v_usuarios_con_roles FROM anon;

-- ============================================================================
-- PRIORIDAD 3: CORREGIR VISTAS CON SECURITY DEFINER
-- ============================================================================
-- Las vistas con SECURITY DEFINER ejecutan con permisos del creador
-- Solución: Recrear con security_invoker = true

-- 3.1 Vista v_resumen_alertas_vehiculo
DROP VIEW IF EXISTS public.v_resumen_alertas_vehiculo CASCADE;

CREATE OR REPLACE VIEW public.v_resumen_alertas_vehiculo
WITH (security_invoker = true)
AS
-- NOTA: Reemplaza este SELECT con tu lógica actual de la vista
SELECT
    v.id as vehiculo_id,
    v.matricula,
    COUNT(*) FILTER (WHERE a.resuelta = false) as alertas_pendientes,
    COUNT(*) FILTER (WHERE a.resuelta = true) as alertas_resueltas,
    MAX(a.fecha_alerta) as ultima_alerta
FROM public.vehiculos v
LEFT JOIN public.alertas_vehiculo a ON v.id = a.id_vehiculo
GROUP BY v.id, v.matricula;

GRANT SELECT ON public.v_resumen_alertas_vehiculo TO authenticated;

-- 3.2 Vista v_stock_vehiculo_estado
DROP VIEW IF EXISTS public.v_stock_vehiculo_estado CASCADE;

CREATE OR REPLACE VIEW public.v_stock_vehiculo_estado
WITH (security_invoker = true)
AS
-- NOTA: Reemplaza este SELECT con tu lógica actual de la vista
SELECT
    v.id as vehiculo_id,
    v.matricula,
    p.id as producto_id,
    p.nombre as producto_nombre,
    sv.cantidad_actual,
    sv.cantidad_minima,
    CASE
        WHEN sv.cantidad_actual <= sv.cantidad_minima THEN 'BAJO'
        WHEN sv.cantidad_actual <= (sv.cantidad_minima * 1.5) THEN 'MEDIO'
        ELSE 'OK'
    END as estado_stock
FROM public.vehiculos v
LEFT JOIN public.stock_vehiculo sv ON v.id = sv.id_vehiculo
LEFT JOIN public.productos p ON sv.id_producto = p.id;

GRANT SELECT ON public.v_stock_vehiculo_estado TO authenticated;

-- ============================================================================
-- PRIORIDAD 4: CONFIGURAR search_path EN FUNCIONES
-- ============================================================================
-- Todas las funciones deben tener search_path configurado para evitar
-- ataques de path hijacking

-- Lista de funciones a corregir (primeras 10 como ejemplo)
-- Ejecuta ALTER FUNCTION para cada una

ALTER FUNCTION public.update_historial_medico_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_servicios_rec_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.generar_codigo_servicio_rec()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_vestuario_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_stock_vestuario_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_servicios_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.generar_codigo_servicio()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.registrar_movimiento_stock()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.generar_alertas_stock()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.handle_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.validar_servicios_recurrencia()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.validar_servicios_rec_recurrencia()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_traslados_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.generar_codigo_traslado()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.transferir_stock_a_vehiculo()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.registrar_cambio_estado_traslado()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.generar_traslados_servicio_unico(uuid, uuid, uuid[], uuid, timestamp with time zone, timestamp with time zone)
  SET search_path = public, pg_temp;

ALTER FUNCTION public.generar_traslados_periodo(timestamp with time zone, timestamp with time zone, integer)
  SET search_path = public, pg_temp;

ALTER FUNCTION public.cambiar_estado_traslado(uuid, text, text)
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_proveedores_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_stock_almacen_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_entradas_almacen_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.validar_estado_traslado()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.obtener_estados_disponibles(text)
  SET search_path = public, pg_temp;

ALTER FUNCTION public.test_generar_traslados()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.generar_numero_entrada()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.generar_numero_transferencia()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.generar_traslados_al_crear_servicio()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_tipos_ausencia_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.actualizar_stock_desde_entrada()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_ausencias_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.calcular_precio_total_stock()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.generar_traslados_al_crear_servicio_recurrente()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_vacaciones_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.generar_traslados_proximos_lotes(integer, integer)
  SET search_path = public, pg_temp;

ALTER FUNCTION public.test_generar_proximos_lotes()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_pacientes_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.check_user_permission(uuid, text)
  SET search_path = public, pg_temp;

ALTER FUNCTION public.get_user_modules(uuid)
  SET search_path = public, pg_temp;

ALTER FUNCTION public.get_user_permissions_summary(uuid)
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_updated_at_column()
  SET search_path = public, pg_temp;

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================
-- Ejecuta estos queries para verificar que todo está correcto

-- Verificar RLS habilitado
SELECT
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN ('servicios', 'servicios_recurrentes', 'traslados', 'historial_estados_traslado')
ORDER BY tablename;

-- Verificar políticas creadas
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename IN ('servicios', 'servicios_recurrentes', 'traslados', 'historial_estados_traslado')
ORDER BY tablename, policyname;

-- Verificar vistas con security_invoker
SELECT
    schemaname,
    viewname,
    viewowner
FROM pg_views
WHERE schemaname = 'public'
    AND viewname IN ('v_usuarios_con_roles', 'v_resumen_alertas_vehiculo', 'v_stock_vehiculo_estado');

-- ============================================================================
-- NOTAS IMPORTANTES
-- ============================================================================
-- 1. Las políticas RLS creadas son BÁSICAS y permiten acceso a todos los usuarios autenticados
--    Debes ajustarlas según tu lógica de negocio (roles, permisos, etc.)
--
-- 2. Las vistas v_resumen_alertas_vehiculo y v_stock_vehiculo_estado tienen queries de EJEMPLO
--    Reemplázalas con tu lógica actual
--
-- 3. Después de ejecutar este script, verifica en Supabase Dashboard:
--    - Authentication > Policies (debe mostrar las políticas creadas)
--    - Database > Tables (RLS debe estar enabled)
--
-- 4. Para habilitar protección de contraseñas filtradas:
--    - Ve a Authentication > Password Settings en Supabase Dashboard
--    - Activa "Leaked Password Protection"
--
-- 5. TESTING RECOMENDADO:
--    - Prueba con usuario autenticado (debe funcionar)
--    - Prueba con usuario anon (debe fallar en tablas con RLS)
--    - Verifica que la app sigue funcionando correctamente
-- ============================================================================
