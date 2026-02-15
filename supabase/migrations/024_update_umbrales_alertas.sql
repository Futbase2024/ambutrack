-- ============================================================================
-- Migration 024: Ajustar umbrales de alertas y limpiar vistas previas
-- ============================================================================
-- Actualizar umbrales predeterminados para que el diálogo funcione correctamente
-- y limpiar registros de vistas previas para testing

-- 1. Actualizar umbrales en la tabla de configuración
ALTER TABLE public.ambutrack_alertas_umbrales_config
  ALTER COLUMN umbral_seguro SET DEFAULT 30,
  ALTER COLUMN umbral_itv SET DEFAULT 45,
  ALTER COLUMN umbral_homologacion SET DEFAULT 45,
  ALTER COLUMN umbral_mantenimiento SET DEFAULT 15,
  ALTER COLUMN umbral_critico_global SET DEFAULT 15;

-- 2. Limpiar registros de vistas para testing (opcional - comentar en prod)
-- DELETE FROM public.ambutrack_alertas_caducidad_vistas
-- WHERE fecha_visualizacion = CURRENT_DATE;

-- 3. Crear función para resetear vistas de un usuario
CREATE OR REPLACE FUNCTION public.resetear_vistas_usuario(
  p_usuario_id UUID
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  DELETE FROM public.ambutrack_alertas_caducidad_vistas
  WHERE usuario_id = p_usuario_id;
END;
$$;

-- Grant para la nueva función
GRANT EXECUTE ON FUNCTION public.resetear_vistas_usuario TO authenticated;

-- ============================================================================
-- Comments explicativos
-- ============================================================================

COMMENT ON FUNCTION public.resetear_vistas_usuario IS
'Elimina todos los registros de visualización de alertas para un usuario,
permitiendo que las alertas se muestren nuevamente. Útil para testing.';
