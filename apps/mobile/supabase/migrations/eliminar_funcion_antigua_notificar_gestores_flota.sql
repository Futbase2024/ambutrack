-- =====================================================
-- AmbuTrack Mobile - Eliminar Función Antigua Notificar Gestores
-- =====================================================
-- Elimina la versión antigua de la función (sin parámetro excluir_usuario_id)
-- para resolver el conflicto de overloading ambiguo
--
-- ERROR RESUELTO:
-- "Could not choose the best candidate function between..."
--
-- Ejecutar en: https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr/sql
--
-- =====================================================

-- Verificar funciones existentes ANTES de eliminar
DO $$
BEGIN
  RAISE NOTICE '📋 Funciones crear_notificacion_gestores_flota existentes ANTES:';
END $$;

SELECT
  routine_name,
  routine_type,
  specific_name,
  pg_get_function_arguments(p.oid) as argumentos
FROM information_schema.routines r
JOIN pg_proc p ON p.proname = r.routine_name
WHERE routine_name = 'crear_notificacion_gestores_flota'
ORDER BY routine_name;

-- =====================================================
-- ELIMINAR FUNCIÓN ANTIGUA (sin p_excluir_usuario_id)
-- =====================================================

DROP FUNCTION IF EXISTS public.crear_notificacion_gestores_flota(
  p_tipo TEXT,
  p_titulo TEXT,
  p_mensaje TEXT,
  p_entidad_tipo TEXT,
  p_entidad_id TEXT,
  p_metadata JSONB
);

-- =====================================================
-- VERIFICACIÓN POST-ELIMINACIÓN
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Función antigua eliminada correctamente';
  RAISE NOTICE '📋 Funciones crear_notificacion_gestores_flota existentes DESPUÉS:';
END $$;

SELECT
  routine_name,
  routine_type,
  specific_name,
  pg_get_function_arguments(p.oid) as argumentos
FROM information_schema.routines r
JOIN pg_proc p ON p.proname = r.routine_name
WHERE routine_name = 'crear_notificacion_gestores_flota'
ORDER BY routine_name;

-- Verificar que solo quede UNA función (con 7 parámetros incluyendo p_excluir_usuario_id)
DO $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM information_schema.routines
  WHERE routine_name = 'crear_notificacion_gestores_flota';

  IF v_count = 1 THEN
    RAISE NOTICE '✅ Éxito: Solo existe UNA versión de la función (con p_excluir_usuario_id)';
  ELSIF v_count = 0 THEN
    RAISE EXCEPTION '❌ Error: No existe ninguna función crear_notificacion_gestores_flota';
  ELSE
    RAISE EXCEPTION '❌ Error: Todavía existen % versiones de la función', v_count;
  END IF;
END $$;

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

-- Confirmar ejecución
DO $$
BEGIN
  RAISE NOTICE '✅ Migración completada exitosamente';
  RAISE NOTICE '📱 La función crear_notificacion_gestores_flota ahora es única';
  RAISE NOTICE '🔧 El overloading ambiguo ha sido resuelto';
  RAISE NOTICE '👉 La app móvil puede ahora enviar notificaciones con exclusión de usuario';
END $$;
