-- ============================================================================
-- Migration 021: Tabla de tracking de alertas vistas
-- ============================================================================
-- Propósito: Registrar qué alertas ha visto cada usuario para evitar
-- mostrar la misma alerta más de una vez por día.
--
-- Tablas:
--   - ambutrack_alertas_caducidad_vistas: Registro de visualizaciones
--
-- Funciones:
--   - marcar_alerta_vista(): Registrar una alerta como vista
--   - alerta_fue_vista_hoy(): Verificar si una alerta fue vista hoy
--   - limpiar_alertas_vistas_antiguas(): Limpieza de registros antiguos
-- ============================================================================

-- Tabla de tracking de alertas vistas
CREATE TABLE IF NOT EXISTS public.ambutrack_alertas_caducidad_vistas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tipo_alerta TEXT NOT NULL CHECK (tipo_alerta IN ('seguro', 'itv', 'homologacion', 'mantenimiento')),
  entidad_id UUID NOT NULL,
  entidad_key TEXT NOT NULL GENERATED ALWAYS AS (tipo_alerta || ':' || entidad_id) STORED,
  fecha_visualizacion DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Constraint único: una alerta solo puede marcarse como vista una vez por día por usuario
  CONSTRAINT unique_alerta_vista UNIQUE (usuario_id, tipo_alerta, entidad_id, fecha_visualizacion)
);

-- Índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_alertas_vistas_usuario_fecha
  ON public.ambutrack_alertas_caducidad_vistas(usuario_id, fecha_visualizacion DESC);

CREATE INDEX IF NOT EXISTS idx_alertas_vistas_entidad
  ON public.ambutrack_alertas_caducidad_vistas(entidad_key, fecha_visualizacion DESC);

-- Comentario de tabla
COMMENT ON TABLE public.ambutrack_alertas_caducidad_vistas IS
  'Registro de alertas de caducidad vistas por cada usuario. Evita mostrar la misma alerta más de una vez por día.';

-- ============================================================================
-- FUNCIONES
-- ============================================================================

-- Función para marcar una alerta como vista
CREATE OR REPLACE FUNCTION public.marcar_alerta_vista(
  p_usuario_id UUID,
  p_tipo_alerta TEXT,
  p_entidad_id UUID
) RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_registro_id UUID;
BEGIN
  -- Insertar o actualizar el registro de visualización
  INSERT INTO public.ambutrack_alertas_caducidad_vistas (
    usuario_id,
    tipo_alerta,
    entidad_id,
    fecha_visualizacion
  ) VALUES (
    p_usuario_id,
    p_tipo_alerta,
    p_entidad_id,
    CURRENT_DATE
  )
  ON CONFLICT (usuario_id, tipo_alerta, entidad_id, fecha_visualizacion)
  DO UPDATE SET created_at = NOW()
  RETURNING id INTO v_registro_id;

  RETURN v_registro_id;
END;
$$;

-- Función para verificar si una alerta fue vista hoy
CREATE OR REPLACE FUNCTION public.alerta_fue_vista_hoy(
  p_usuario_id UUID,
  p_tipo_alerta TEXT,
  p_entidad_id UUID
) RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_vista_hoy BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM public.ambutrack_alertas_caducidad_vistas
    WHERE usuario_id = p_usuario_id
      AND tipo_alerta = p_tipo_alerta
      AND entidad_id = p_entidad_id
      AND fecha_visualizacion = CURRENT_DATE
  ) INTO v_vista_hoy;

  RETURN v_vista_hoy;
END;
$$;

-- Función para limpiar alertas vistas antiguas (más de 30 días)
CREATE OR REPLACE FUNCTION public.limpiar_alertas_vistas_antiguas()
RETURNS INT LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_registros_eliminados INT;
BEGIN
  -- Eliminar registros de visualización de más de 30 días
  DELETE FROM public.ambutrack_alertas_caducidad_vistas
  WHERE fecha_visualizacion < CURRENT_DATE - INTERVAL '30 days';

  GET DIAGNOSTICS v_registros_eliminados = ROW_COUNT;

  RETURN v_registros_eliminados;
END;
$$;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Habilitar RLS
ALTER TABLE public.ambutrack_alertas_caducidad_vistas ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propias visualizaciones
CREATE POLICY "Usuarios pueden ver sus propias alertas vistas"
  ON public.ambutrack_alertas_caducidad_vistas
  FOR SELECT
  USING (auth.uid() = usuario_id);

-- Política: Los usuarios pueden insertar sus propias visualizaciones
CREATE POLICY "Usuarios pueden insertar sus propias alertas vistas"
  ON public.ambutrack_alertas_caducidad_vistas
  FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

-- Política: Los usuarios pueden actualizar sus propias visualizaciones
CREATE POLICY "Usuarios pueden actualizar sus propias alertas vistas"
  ON public.ambutrack_alertas_caducidad_vistas
  FOR UPDATE
  USING (auth.uid() = usuario_id)
  WITH CHECK (auth.uid() = usuario_id);

-- ============================================================================
-- GRANTs
-- ============================================================================

-- Permisos para usuarios autenticados
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.ambutrack_alertas_caducidad_vistas TO authenticated;

-- Permisos para ejecutar funciones
GRANT EXECUTE ON FUNCTION public.marcar_alerta_vista TO authenticated;
GRANT EXECUTE ON FUNCTION public.alerta_fue_vista_hoy TO authenticated;
GRANT EXECUTE ON FUNCTION public.limpiar_alertas_vistas_antiguas TO authenticated;
