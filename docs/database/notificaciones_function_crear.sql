-- ========================================
-- FUNCIÓN PARA CREAR NOTIFICACIONES A JEFES DE PERSONAL
-- ========================================
-- Esta función permite crear notificaciones para jefes de personal
-- bypassing RLS de forma segura mediante SECURITY DEFINER.
--
-- VENTAJAS:
-- - Cualquier usuario autenticado puede llamarla
-- - Bypass RLS de forma controlada
-- - Lógica centralizada en la base de datos
-- - Previene errores de permisos

-- ========================================
-- 1. ELIMINAR FUNCIÓN EXISTENTE (si existe)
-- ========================================

DROP FUNCTION IF EXISTS crear_notificacion_jefes_personal(
  p_tipo text,
  p_titulo text,
  p_mensaje text,
  p_entidad_tipo text,
  p_entidad_id text,
  p_metadata jsonb
);

-- ========================================
-- 2. CREAR FUNCIÓN CON SECURITY DEFINER
-- ========================================

CREATE OR REPLACE FUNCTION crear_notificacion_jefes_personal(
  p_tipo text,
  p_titulo text,
  p_mensaje text,
  p_entidad_tipo text DEFAULT NULL,
  p_entidad_id text DEFAULT NULL,
  p_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER  -- ⚡ Ejecuta con privilegios del owner, bypass RLS
SET search_path = public
AS $$
DECLARE
  v_jefe RECORD;
  v_empresa_id text;
BEGIN
  -- Obtener empresa_id del usuario autenticado (desde tpersonal)
  SELECT p.empresa_id INTO v_empresa_id
  FROM tpersonal p
  WHERE p.usuario_id = auth.uid()
  LIMIT 1;

  -- Si no se encuentra empresa_id, usar 'ambutrack' por defecto
  IF v_empresa_id IS NULL THEN
    v_empresa_id := 'ambutrack';
  END IF;

  -- Buscar todos los jefes de personal, jefes de tráfico y admins
  FOR v_jefe IN
    SELECT p.usuario_id
    FROM tpersonal p
    WHERE p.categoria IN ('admin', 'jefe_personal', 'jefe_trafico')
      AND p.activo = true
  LOOP
    -- Crear notificación para cada jefe
    INSERT INTO tnotificaciones (
      empresa_id,
      usuario_destino_id,
      tipo,
      titulo,
      mensaje,
      entidad_tipo,
      entidad_id,
      leida,
      fecha_lectura,
      metadata,
      created_at,
      updated_at
    ) VALUES (
      v_empresa_id,
      v_jefe.usuario_id,
      p_tipo,
      p_titulo,
      p_mensaje,
      p_entidad_tipo,
      p_entidad_id,
      false,
      NULL,
      p_metadata,
      now(),
      now()  -- ✅ updated_at debe ser now(), no NULL
    );
  END LOOP;
END;
$$;

-- ========================================
-- 3. PERMISOS - Permitir a usuarios autenticados
-- ========================================

-- Revocar todos los permisos existentes
REVOKE ALL ON FUNCTION crear_notificacion_jefes_personal(text, text, text, text, text, jsonb) FROM PUBLIC;

-- Otorgar permiso de ejecución solo a usuarios autenticados
GRANT EXECUTE ON FUNCTION crear_notificacion_jefes_personal(text, text, text, text, text, jsonb) TO authenticated;

-- ========================================
-- 4. COMENTARIOS Y DOCUMENTACIÓN
-- ========================================

COMMENT ON FUNCTION crear_notificacion_jefes_personal IS
'Crea notificaciones para todos los jefes de personal, jefes de tráfico y administradores activos.
Uso: SELECT crear_notificacion_jefes_personal(
  ''vacacion_solicitada'',
  ''Nueva Solicitud de Vacaciones'',
  ''Juan Pérez ha solicitado 15 días de vacaciones'',
  ''vacacion'',
  ''uuid-vacacion'',
  ''{"dias": 15}''::jsonb
);';

-- ========================================
-- 5. PRUEBA DE LA FUNCIÓN
-- ========================================

-- Para probar (ejecutar como usuario autenticado):
/*
SELECT crear_notificacion_jefes_personal(
  'test_notificacion',
  'Prueba de Notificación',
  'Esta es una prueba del sistema de notificaciones',
  'test',
  'test-id-123',
  '{"test": true}'::jsonb
);

-- Verificar que se crearon las notificaciones
SELECT * FROM tnotificaciones WHERE tipo = 'test_notificacion' ORDER BY created_at DESC;

-- Limpiar notificaciones de prueba
DELETE FROM tnotificaciones WHERE tipo = 'test_notificacion';
*/
