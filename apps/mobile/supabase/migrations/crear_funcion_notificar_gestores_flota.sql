-- =====================================================
-- AmbuTrack Mobile - Función para Notificar Gestores de Flota
-- =====================================================
-- Función PostgreSQL para notificar a gestores de flota sobre
-- incidencias de vehículos reportadas desde la app móvil
--
-- ROLES NOTIFICADOS:
-- - admin (Administradores)
-- - jefe_mantenimiento (Jefe de Mantenimiento)
--
-- Ejecutar en: https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr/sql
--
-- =====================================================

CREATE OR REPLACE FUNCTION crear_notificacion_gestores_flota(
  p_tipo TEXT,
  p_titulo TEXT,
  p_mensaje TEXT,
  p_entidad_tipo TEXT DEFAULT NULL,
  p_entidad_id TEXT DEFAULT NULL,
  p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- ⚠️ IMPORTANTE: Bypass RLS para crear notificaciones a otros usuarios
AS $$
DECLARE
  v_usuario RECORD;
  v_count INTEGER := 0;
BEGIN
  -- Buscar usuarios con roles de gestión de flota
  FOR v_usuario IN
    SELECT id, rol, email
    FROM usuarios
    WHERE activo = true
    AND rol IN ('admin', 'jefe_mantenimiento')
  LOOP
    -- Crear notificación para cada gestor
    INSERT INTO tnotificaciones (
      usuario_destino_id,
      tipo,
      titulo,
      mensaje,
      entidad_tipo,
      entidad_id,
      metadata,
      leida,
      fecha_lectura,
      created_at
    ) VALUES (
      v_usuario.id,
      p_tipo,
      p_titulo,
      p_mensaje,
      p_entidad_tipo,
      p_entidad_id,
      p_metadata,
      false,
      NULL,
      NOW()
    );

    v_count := v_count + 1;
    RAISE NOTICE 'Notificación creada para % (rol: %)', v_usuario.email, v_usuario.rol;
  END LOOP;

  RAISE NOTICE '✅ % notificaciones creadas para gestores de flota', v_count;

  -- Si no se encontraron gestores, advertir
  IF v_count = 0 THEN
    RAISE WARNING 'No se encontraron gestores de flota activos para notificar';
  END IF;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION crear_notificacion_gestores_flota IS
  'Crea notificaciones para gestores de flota (admin, jefe_mantenimiento) sobre incidencias de vehículos. Usa SECURITY DEFINER para bypass RLS.';

-- =====================================================
-- VERIFICACIÓN
-- =====================================================

-- Verificar que la función se creó correctamente
SELECT
  routine_name,
  routine_type,
  specific_name
FROM information_schema.routines
WHERE routine_name = 'crear_notificacion_gestores_flota'
ORDER BY routine_name;

-- =====================================================
-- EJEMPLO DE USO (NO EJECUTAR - SOLO REFERENCIA)
-- =====================================================

-- SELECT crear_notificacion_gestores_flota(
--   'incidencia_vehiculo_reportada',
--   '🚨 Nueva Incidencia de Vehículo - Prioridad CRÍTICA',
--   'Juan Pérez reportó: Motor hace ruido extraño. El vehículo presenta un sonido metálico al acelerar.',
--   'incidencia_vehiculo',
--   'uuid-de-la-incidencia',
--   '{"vehiculo_id": "uuid-del-vehiculo", "prioridad": "critica", "tipo": "mecanica"}'::jsonb
-- );

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

-- Confirmar ejecución
DO $$
BEGIN
  RAISE NOTICE '✅ Función crear_notificacion_gestores_flota creada correctamente';
  RAISE NOTICE '📱 Las incidencias de vehículos ahora notificarán a:';
  RAISE NOTICE '   - Administradores (admin)';
  RAISE NOTICE '   - Jefes de Mantenimiento (jefe_mantenimiento)';
END $$;
