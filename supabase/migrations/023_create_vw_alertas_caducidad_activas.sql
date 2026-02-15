-- ============================================================================
-- Migration 023: Vista de alertas de caducidad activas y funciones RPC
-- ============================================================================
-- Propósito: Vista unificada que combina todas las fuentes de alertas de
-- caducidad (vehículos, documentación, ITV, mantenimiento) y calcula
-- automáticamente días restantes, severidad y prioridad.
--
-- Objetos:
--   - vw_alertas_caducidad_activas: Vista unificada de alertas
--
-- Funciones RPC:
--   - obtener_alertas_activas(): Obtener alertas filtradas por umbrales
--   - obtener_resumen_alertas(): Obtener resumen agrupado por severidad
--   - obtener_alertas_criticas(): Obtener solo alertas críticas
-- ============================================================================

-- ============================================================================
-- VISTA UNIFICADA DE ALERTAS DE CADUCIDAD ACTIVAS
-- ============================================================================

CREATE OR REPLACE VIEW public.vw_alertas_caducidad_activAS AS
WITH
-- ============================================================================
-- CTEs para cada fuente de alertas
-- ============================================================================

-- Vehículos con ITV próxima a vencer
vehiculos_itv AS (
  SELECT
    v.id AS vehiculo_id,
    v.matricula || ' - ' || v.marca || ' ' || v.modelo AS entidad_nombre,
    'itv' AS tipo_alerta,
    v.proxima_itv AS fecha_caducidad,
    COALESCE(
      (v.proxima_itv - CURRENT_DATE)::INTEGER,
      0
    ) AS dias_restantes,
    'VEHICULO:' || v.id AS entidad_key
  FROM public.tvehiculos v
  WHERE v.proxima_itv IS NOT NULL
    AND v.activo = true
    AND v.proxima_itv > CURRENT_DATE  -- Solo ITV futuras
),

-- Vehículos con seguro próximo a vencer
vehiculos_seguro AS (
  SELECT
    v.id AS vehiculo_id,
    v.matricula || ' - ' || v.marca || ' ' || v.modelo AS entidad_nombre,
    'seguro' AS tipo_alerta,
    v.fecha_vencimiento_seguro AS fecha_caducidad,
    COALESCE(
      (v.fecha_vencimiento_seguro - CURRENT_DATE)::INTEGER,
      0
    ) AS dias_restantes,
    'VEHICULO:' || v.id AS entidad_key
  FROM public.tvehiculos v
  WHERE v.fecha_vencimiento_seguro IS NOT NULL
    AND v.activo = true
    AND v.fecha_vencimiento_seguro > CURRENT_DATE
),

-- Vehículos con homologación próxima a vencer
vehiculos_homologacion AS (
  SELECT
    v.id AS vehiculo_id,
    v.matricula || ' - ' || v.marca || ' ' || v.modelo AS entidad_nombre,
    'homologacion' AS tipo_alerta,
    v.fecha_vencimiento_homologacion AS fecha_caducidad,
    COALESCE(
      (v.fecha_vencimiento_homologacion - CURRENT_DATE)::INTEGER,
      0
    ) AS dias_restantes,
    'VEHICULO:' || v.id AS entidad_key
  FROM public.tvehiculos v
  WHERE v.fecha_vencimiento_homologacion IS NOT NULL
    AND v.activo = true
    AND v.fecha_vencimiento_homologacion > CURRENT_DATE
),

-- Vehículos con mantenimiento próximo
vehiculos_mantenimiento AS (
  SELECT
    v.id AS vehiculo_id,
    v.matricula || ' - ' || v.marca || ' ' || v.modelo AS entidad_nombre,
    'mantenimiento' AS tipo_alerta,
    v.proximo_mantenimiento AS fecha_caducidad,
    COALESCE(
      (v.proximo_mantenimiento - CURRENT_DATE)::INTEGER,
      0
    ) AS dias_restantes,
    'VEHICULO:' || v.id AS entidad_key
  FROM public.tvehiculos v
  WHERE v.proximo_mantenimiento IS NOT NULL
    AND v.activo = true
    AND v.proximo_mantenimiento > CURRENT_DATE
)

-- ============================================================================
-- SELECT principal que combina todas las fuentes
-- ============================================================================
SELECT
  tipo_alerta,
  vehiculo_id::TEXT AS entidad_id,
  entidad_key,
  entidad_nombre,
  fecha_caducidad::TIMESTAMPTZ AS fecha_caducidad,
  dias_restantes,

  -- Calcular severidad basada en días restantes
  CASE
    WHEN dias_restantes < 7 THEN 'critica'
    WHEN dias_restantes < 30 THEN 'alta'
    WHEN dias_restantes < 60 THEN 'media'
    ELSE 'baja'
  END AS severidad,

  -- Marcar si es crítica
  CASE
    WHEN dias_restantes < 7 THEN true
    ELSE false
  END AS es_critica,

  -- Calcular prioridad para ordenamiento (1 = más alta)
  CASE
    WHEN dias_restantes < 7 THEN 1  -- Crítica
    WHEN dias_restantes < 30 THEN 2 -- Alta
    WHEN dias_restantes < 60 THEN 3 -- Media
    ELSE 4                          -- Baja
  END AS prioridad,

  -- Origen de datos
  'tvehiculos' AS tabla_origen

FROM vehiculos_itv

UNION ALL

SELECT
  tipo_alerta,
  vehiculo_id::TEXT AS entidad_id,
  entidad_key,
  entidad_nombre,
  fecha_caducidad::TIMESTAMPTZ AS fecha_caducidad,
  dias_restantes,
  CASE
    WHEN dias_restantes < 7 THEN 'critica'
    WHEN dias_restantes < 30 THEN 'alta'
    WHEN dias_restantes < 60 THEN 'media'
    ELSE 'baja'
  END AS severidad,
  CASE
    WHEN dias_restantes < 7 THEN true
    ELSE false
  END AS es_critica,
  CASE
    WHEN dias_restantes < 7 THEN 1
    WHEN dias_restantes < 30 THEN 2
    WHEN dias_restantes < 60 THEN 3
    ELSE 4
  END AS prioridad,
  'tvehiculos' AS tabla_origen
FROM vehiculos_seguro

UNION ALL

SELECT
  tipo_alerta,
  vehiculo_id::TEXT AS entidad_id,
  entidad_key,
  entidad_nombre,
  fecha_caducidad::TIMESTAMPTZ AS fecha_caducidad,
  dias_restantes,
  CASE
    WHEN dias_restantes < 7 THEN 'critica'
    WHEN dias_restantes < 30 THEN 'alta'
    WHEN dias_restantes < 60 THEN 'media'
    ELSE 'baja'
  END AS severidad,
  CASE
    WHEN dias_restantes < 7 THEN true
    ELSE false
  END AS es_critica,
  CASE
    WHEN dias_restantes < 7 THEN 1
    WHEN dias_restantes < 30 THEN 2
    WHEN dias_restantes < 60 THEN 3
    ELSE 4
  END AS prioridad,
  'tvehiculos' AS tabla_origen
FROM vehiculos_homologacion

UNION ALL

SELECT
  tipo_alerta,
  vehiculo_id::TEXT AS entidad_id,
  entidad_key,
  entidad_nombre,
  fecha_caducidad::TIMESTAMPTZ AS fecha_caducidad,
  dias_restantes,
  CASE
    WHEN dias_restantes < 7 THEN 'critica'
    WHEN dias_restantes < 30 THEN 'alta'
    WHEN dias_restantes < 60 THEN 'media'
    ELSE 'baja'
  END AS severidad,
  CASE
    WHEN dias_restantes < 7 THEN true
    ELSE false
  END AS es_critica,
  CASE
    WHEN dias_restantes < 7 THEN 1
    WHEN dias_restantes < 30 THEN 2
    WHEN dias_restantes < 60 THEN 3
    ELSE 4
  END AS prioridad,
  'tvehiculos' AS tabla_origen
FROM vehiculos_mantenimiento

-- Filtrar por umbrales por defecto (90 días máximo)
WHERE dias_restantes <= 90

ORDER BY prioridad ASC, dias_restantes ASC;

-- Comentario de vista
COMMENT ON VIEW public.vw_alertas_caducidad_activas IS
  'Vista unificada de alertas de caducidad de vehículos (ITV, seguros, homologaciones, mantenimientos). Calcula automáticamente severidad, días restantes y prioridad.';

-- ============================================================================
-- FUNCIONES RPC PARA CONSUMO DESDE LA APP
-- ============================================================================

-- Función RPC: Obtener alertas activas con filtros
CREATE OR REPLACE FUNCTION public.obtener_alertas_activas(
  p_usuario_id UUID DEFAULT NULL,
  p_umbral_seguro INTEGER DEFAULT 90,
  p_umbral_itv INTEGER DEFAULT 90,
  p_umbral_homologacion INTEGER DEFAULT 90,
  p_umbral_mantenimiento INTEGER DEFAULT 90,
  p_incluir_vistas BOOLEAN DEFAULT true
) RETURNS TABLE (
  tipo_alerta TEXT,
  entidad_id TEXT,
  entidad_key TEXT,
  entidad_nombre TEXT,
  fecha_caducidad TIMESTAMPTZ,
  dias_restantes INTEGER,
  severidad TEXT,
  es_critica BOOLEAN,
  prioridad INTEGER,
  tabla_origen TEXT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT
    v.tipo_alerta,
    v.entidad_id,
    v.entidad_key,
    v.entidad_nombre,
    v.fecha_caducidad,
    v.dias_restantes,
    v.severidad,
    v.es_critica,
    v.prioridad,
    v.tabla_origen
  FROM public.vw_alertas_caducidad_activas v
  WHERE
    -- Filtrar por umbral específico según tipo
    (
      (v.tipo_alerta = 'seguro' AND v.dias_restantes <= p_umbral_seguro) OR
      (v.tipo_alerta = 'itv' AND v.dias_restantes <= p_umbral_itv) OR
      (v.tipo_alerta = 'homologacion' AND v.dias_restantes <= p_umbral_homologacion) OR
      (v.tipo_alerta = 'mantenimiento' AND v.dias_restantes <= p_umbral_mantenimiento)
    )
    -- Excluir alertas ya vistas hoy si se solicita
    AND (
      p_incluir_vistas = true
      OR p_usuario_id IS NULL
      OR NOT EXISTS (
        SELECT 1 FROM public.ambutrack_alertas_caducidad_vistas av
        WHERE av.usuario_id = p_usuario_id
          AND av.entidad_key = v.entidad_key
          AND av.fecha_visualizacion = CURRENT_DATE
      )
    )
  ORDER BY v.prioridad ASC, v.dias_restantes ASC;
END;
$$;

-- Función RPC: Obtener resumen de alertas agrupado por severidad
CREATE OR REPLACE FUNCTION public.obtener_resumen_alertas(
  p_usuario_id UUID DEFAULT NULL,
  p_umbral_seguro INTEGER DEFAULT 90,
  p_umbral_itv INTEGER DEFAULT 90,
  p_umbral_homologacion INTEGER DEFAULT 90,
  p_umbral_mantenimiento INTEGER DEFAULT 90
) RETURNS TABLE (
  criticas BIGINT,
  altas BIGINT,
  medias BIGINT,
  bajas BIGINT,
  total BIGINT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  WITH alertas AS (
    SELECT * FROM public.obtener_alertas_activas(
      p_usuario_id,
      p_umbral_seguro,
      p_umbral_itv,
      p_umbral_homologacion,
      p_umbral_mantenimiento,
      true
    )
  )
  SELECT
    COUNT(*) FILTER (WHERE severidad = 'critica')::BIGINT AS criticas,
    COUNT(*) FILTER (WHERE severidad = 'alta')::BIGINT AS altas,
    COUNT(*) FILTER (WHERE severidad = 'media')::BIGINT AS medias,
    COUNT(*) FILTER (WHERE severidad = 'baja')::BIGINT AS bajas,
    COUNT(*)::BIGINT AS total
  FROM alertas;
END;
$$;

-- Función RPC: Obtener solo alertas críticas
CREATE OR REPLACE FUNCTION public.obtener_alertas_criticas(
  p_usuario_id UUID DEFAULT NULL
) RETURNS TABLE (
  tipo_alerta TEXT,
  entidad_id TEXT,
  entidad_key TEXT,
  entidad_nombre TEXT,
  fecha_caducidad TIMESTAMPTZ,
  dias_restantes INTEGER,
  severidad TEXT,
  es_critica BOOLEAN,
  prioridad INTEGER,
  tabla_origen TEXT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT
    v.tipo_alerta,
    v.entidad_id,
    v.entidad_key,
    v.entidad_nombre,
    v.fecha_caducidad,
    v.dias_restantes,
    v.severidad,
    v.es_critica,
    v.prioridad,
    v.tabla_origen
  FROM public.vw_alertas_caducidad_activas v
  WHERE v.es_critica = true
    -- Excluir alertas ya vistas hoy
    AND (
      p_usuario_id IS NULL
      OR NOT EXISTS (
        SELECT 1 FROM public.ambutrack_alertas_caducidad_vistas av
        WHERE av.usuario_id = p_usuario_id
          AND av.entidad_key = v.entidad_key
          AND av.fecha_visualizacion = CURRENT_DATE
      )
    )
  ORDER BY v.dias_restantes ASC;
END;
$$;

-- ============================================================================
-- GRANTs
-- ============================================================================

-- Permisos para consultar la vista
GRANT SELECT ON public.vw_alertas_caducidad_activas TO authenticated;

-- Permisos para ejecutar funciones RPC
GRANT EXECUTE ON FUNCTION public.obtener_alertas_activas TO authenticated;
GRANT EXECUTE ON FUNCTION public.obtener_resumen_alertas TO authenticated;
GRANT EXECUTE ON FUNCTION public.obtener_alertas_criticas TO authenticated;
