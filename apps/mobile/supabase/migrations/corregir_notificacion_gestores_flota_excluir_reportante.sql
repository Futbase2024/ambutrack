-- =====================================================
-- AmbuTrack Mobile - Corregir Función Notificar Gestores de Flota
-- =====================================================
-- Actualizar la función para EXCLUIR al usuario que reporta la incidencia
-- de recibir su propia notificación
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
  p_metadata JSONB DEFAULT '{}'::jsonb,
  p_excluir_usuario_id UUID DEFAULT NULL  -- ⬅️ NUEVO PARÁMETRO: Usuario a excluir
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
  -- EXCLUYENDO al usuario que reportó (si se proporciona)
  FOR v_usuario IN
    SELECT id, rol, email
    FROM usuarios
    WHERE activo = true
    AND rol IN ('admin', 'jefe_mantenimiento')
    AND (p_excluir_usuario_id IS NULL OR id != p_excluir_usuario_id)  -- ⬅️ NUEVO: Excluir reportante
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

  -- Mostrar información sobre exclusión
  IF p_excluir_usuario_id IS NOT NULL THEN
    RAISE NOTICE '✅ Usuario excluido de notificación: %', p_excluir_usuario_id;
  END IF;

  RAISE NOTICE '✅ % notificaciones creadas para gestores de flota', v_count;

  -- Si no se encontraron gestores, advertir
  IF v_count = 0 THEN
    RAISE WARNING 'No se encontraron gestores de flota activos para notificar (excluido: %)', p_excluir_usuario_id;
  END IF;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION crear_notificacion_gestores_flota IS
  'Crea notificaciones para gestores de flota (admin, jefe_mantenimiento) sobre incidencias de vehículos. Usa SECURITY DEFINER para bypass RLS. Permite excluir al usuario que reporta para evitar auto-notificaciones.';

-- =====================================================
-- VERIFICACIÓN
-- =====================================================

-- Verificar que la función se actualizó correctamente
SELECT
  routine_name,
  routine_type,
  specific_name
FROM information_schema.routines
WHERE routine_name = 'crear_notificacion_gestores_flota'
ORDER BY routine_name;

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

-- Confirmar ejecución
DO $$
BEGIN
  RAISE NOTICE '✅ Función crear_notificacion_gestores_flota actualizada correctamente';
  RAISE NOTICE '📱 Ahora EXCLUYE al usuario que reporta la incidencia de recibir su propia notificación';
  RAISE NOTICE '   - Administradores (admin)';
  RAISE NOTICE '   - Jefes de Mantenimiento (jefe_mantenimiento)';
END $$;
