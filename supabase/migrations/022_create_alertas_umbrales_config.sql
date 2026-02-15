-- ============================================================================
-- Migration 022: Tabla de configuración de umbrales de alertas
-- ============================================================================
-- Propósito: Almacenar la configuración personalizada de umbrales de alertas
-- por cada usuario.
--
-- Tablas:
--   - ambutrack_alertas_umbrales_config: Configuración de umbrales por usuario
--
-- Funciones:
--   - obtener_umbrales_usuario(): Obtener umbrales configurados del usuario
--   - guardar_umbrales_usuario(): Guardar o actualizar umbrales del usuario
--   - resetear_umbrales_usuario(): Resetear a valores por defecto
-- ============================================================================

-- Tabla de configuración de umbrales por usuario
CREATE TABLE IF NOT EXISTS public.ambutrack_alertas_umbrales_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Umbrales de días para cada tipo de alerta
  umbral_seguro INTEGER NOT NULL DEFAULT 30 CHECK (umbral_seguro > 0),
  umbral_itv INTEGER NOT NULL DEFAULT 60 CHECK (umbral_itv > 0),
  umbral_homologacion INTEGER NOT NULL DEFAULT 90 CHECK (umbral_homologacion > 0),
  umbral_mantenimiento INTEGER NOT NULL DEFAULT 7 CHECK (umbral_mantenimiento > 0),

  -- Preferencias de visualización
  mostrar_dialogo_inicio BOOLEAN NOT NULL DEFAULT true,
  mostrar_badge_appbar BOOLEAN NOT NULL DEFAULT true,
  mostrar_card_dashboard BOOLEAN NOT NULL DEFAULT true,

  -- Umbral global para severidad crítica (días)
  umbral_critico_global INTEGER NOT NULL DEFAULT 7 CHECK (umbral_critico_global > 0),

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_umbrales_config_usuario
  ON public.ambutrack_alertas_umbrales_config(usuario_id);

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.actualizar_updated_at_umbrales()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_umbrales_updated_at
  BEFORE UPDATE ON public.ambutrack_alertas_umbrales_config
  FOR EACH ROW
  EXECUTE FUNCTION public.actualizar_updated_at_umbrales();

-- Comentario de tabla
COMMENT ON TABLE public.ambutrack_alertas_umbrales_config IS
  'Configuración personalizada de umbrales de alertas de caducidad por usuario.';

-- ============================================================================
-- FUNCIONES
-- ============================================================================

-- Función para obtener umbrales configurados del usuario
CREATE OR REPLACE FUNCTION public.obtener_umbrales_usuario(
  p_usuario_id UUID
) RETURNS TABLE (
  umbral_seguro INTEGER,
  umbral_itv INTEGER,
  umbral_homologacion INTEGER,
  umbral_mantenimiento INTEGER,
  mostrar_dialogo_inicio BOOLEAN,
  mostrar_badge_appbar BOOLEAN,
  mostrar_card_dashboard BOOLEAN,
  umbral_critico_global INTEGER
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT
    config.umbral_seguro,
    config.umbral_itv,
    config.umbral_homologacion,
    config.umbral_mantenimiento,
    config.mostrar_dialogo_inicio,
    config.mostrar_badge_appbar,
    config.mostrar_card_dashboard,
    config.umbral_critico_global
  FROM public.ambutrack_alertas_umbrales_config config
  WHERE config.usuario_id = p_usuario_id;

  -- Si no hay configuración, retornar valores por defecto
  IF NOT FOUND THEN
    RETURN QUERY
    SELECT
      30::INTEGER as umbral_seguro,
      60::INTEGER as umbral_itv,
      90::INTEGER as umbral_homologacion,
      7::INTEGER as umbral_mantenimiento,
      true::BOOLEAN as mostrar_dialogo_inicio,
      true::BOOLEAN as mostrar_badge_appbar,
      true::BOOLEAN as mostrar_card_dashboard,
      7::INTEGER as umbral_critico_global;
  END IF;
END;
$$;

-- Función para guardar o actualizar umbrales del usuario
CREATE OR REPLACE FUNCTION public.guardar_umbrales_usuario(
  p_usuario_id UUID,
  p_umbral_seguro INTEGER DEFAULT 30,
  p_umbral_itv INTEGER DEFAULT 60,
  p_umbral_homologacion INTEGER DEFAULT 90,
  p_umbral_mantenimiento INTEGER DEFAULT 7,
  p_mostrar_dialogo_inicio BOOLEAN DEFAULT true,
  p_mostrar_badge_appbar BOOLEAN DEFAULT true,
  p_mostrar_card_dashboard BOOLEAN DEFAULT true,
  p_umbral_critico_global INTEGER DEFAULT 7
) RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_config_id UUID;
BEGIN
  INSERT INTO public.ambutrack_alertas_umbrales_config (
    usuario_id,
    umbral_seguro,
    umbral_itv,
    umbral_homologacion,
    umbral_mantenimiento,
    mostrar_dialogo_inicio,
    mostrar_badge_appbar,
    mostrar_card_dashboard,
    umbral_critico_global
  ) VALUES (
    p_usuario_id,
    p_umbral_seguro,
    p_umbral_itv,
    p_umbral_homologacion,
    p_umbral_mantenimiento,
    p_mostrar_dialogo_inicio,
    p_mostrar_badge_appbar,
    p_mostrar_card_dashboard,
    p_umbral_critico_global
  )
  ON CONFLICT (usuario_id) DO UPDATE SET
    umbral_seguro = EXCLUDED.umbral_seguro,
    umbral_itv = EXCLUDED.umbral_itv,
    umbral_homologacion = EXCLUDED.umbral_homologacion,
    umbral_mantenimiento = EXCLUDED.umbral_mantenimiento,
    mostrar_dialogo_inicio = EXCLUDED.mostrar_dialogo_inicio,
    mostrar_badge_appbar = EXCLUDED.mostrar_badge_appbar,
    mostrar_card_dashboard = EXCLUDED.mostrar_card_dashboard,
    umbral_critico_global = EXCLUDED.umbral_critico_global
  RETURNING id INTO v_config_id;

  RETURN v_config_id;
END;
$$;

-- Función para resetear umbrales a valores por defecto
CREATE OR REPLACE FUNCTION public.resetear_umbrales_usuario(
  p_usuario_id UUID
) RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  DELETE FROM public.ambutrack_alertas_umbrales_config
  WHERE usuario_id = p_usuario_id;

  RETURN true;
END;
$$;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Habilitar RLS
ALTER TABLE public.ambutrack_alertas_umbrales_config ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver su propia configuración
CREATE POLICY "Usuarios pueden ver su propia configuración de umbrales"
  ON public.ambutrack_alertas_umbrales_config
  FOR SELECT
  USING (auth.uid() = usuario_id);

-- Política: Los usuarios pueden insertar su propia configuración
CREATE POLICY "Usuarios pueden insertar su propia configuración de umbrales"
  ON public.ambutrack_alertas_umbrales_config
  FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

-- Política: Los usuarios pueden actualizar su propia configuración
CREATE POLICY "Usuarios pueden actualizar su propia configuración de umbrales"
  ON public.ambutrack_alertas_umbrales_config
  FOR UPDATE
  USING (auth.uid() = usuario_id)
  WITH CHECK (auth.uid() = usuario_id);

-- Política: Los usuarios pueden eliminar su propia configuración
CREATE POLICY "Usuarios pueden eliminar su propia configuración de umbrales"
  ON public.ambutrack_alertas_umbrales_config
  FOR DELETE
  USING (auth.uid() = usuario_id);

-- ============================================================================
-- GRANTs
-- ============================================================================

-- Permisos para usuarios autenticados
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.ambutrack_alertas_umbrales_config TO authenticated;

-- Permisos para ejecutar funciones
GRANT EXECUTE ON FUNCTION public.obtener_umbrales_usuario TO authenticated;
GRANT EXECUTE ON FUNCTION public.guardar_umbrales_usuario TO authenticated;
GRANT EXECUTE ON FUNCTION public.resetear_umbrales_usuario TO authenticated;
