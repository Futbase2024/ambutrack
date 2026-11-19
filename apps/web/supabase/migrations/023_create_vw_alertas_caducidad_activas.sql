-- ==============================================================================
-- AMBUTRACK WEB - Sistema de Alertas de Caducidades
-- Archivo: 023_create_vw_alertas_caducidad_activas.sql
-- Descripción: Vista unificada de alertas de caducidad activas
-- Fecha: 2025-02-15
-- Author: AmbuTrack Development Team
-- ==============================================================================

-- ==============================================================================
-- VISTA: vw_alertas_caducidad_activas
-- Vista unificada que calcula todas las alertas de caducidad activas
-- Consulta vehículos, documentación e ITV en una sola vista
-- ==============================================================================

CREATE OR REPLACE VIEW public.vw_alertas_caducidad_activas AS
WITH
-- ==============================================================================
-- ITV de vehículos
-- ==============================================================================
vehiculos_itv AS (
    SELECT
        v.id AS entidad_id,
        ('VEHICULO:' || v.id) AS entidad_key,
        v.matricula || ' - ' || v.marca || ' ' || v.modelo AS entidad_nombre,
        'itv' AS tipo_alerta,
        COALESCE(v.fecha_itv, '2099-12-31'::DATE) AS fecha_caducidad,
        COALESCE(v.fecha_itv::DATE - CURRENT_DATE, 0) AS dias_restantes,
        'vehiculos' AS tabla_origen
    FROM public.tvehiculos v
    WHERE v.fecha_itv IS NOT NULL
      AND v.estado = 'activo'
      AND v.fecha_itv > CURRENT_DATE
),

-- ==============================================================================
-- Seguros de vehículos
-- ==============================================================================
vehiculos_seguro AS (
    SELECT
        v.id AS entidad_id,
        ('VEHICULO:' || v.id) AS entidad_key,
        v.matricula || ' - ' || v.marca || ' ' || v.modelo AS entidad_nombre,
        'seguro' AS tipo_alerta,
        COALESCE(v.fecha_seguro, '2099-12-31'::DATE) AS fecha_caducidad,
        COALESCE(v.fecha_seguro::DATE - CURRENT_DATE, 0) AS dias_restantes,
        'vehiculos' AS tabla_origen
    FROM public.tvehiculos v
    WHERE v.fecha_seguro IS NOT NULL
      AND v.estado = 'activo'
      AND v.fecha_seguro > CURRENT_DATE
),

-- ==============================================================================
-- Homologaciones sanitarias
-- ==============================================================================
vehiculos_homologacion AS (
    SELECT
        v.id AS entidad_id,
        ('VEHICULO:' || v.id) AS entidad_key,
        v.matricula || ' - ' || v.marca || ' ' || v.modelo AS entidad_nombre,
        'homologacion' AS tipo_alerta,
        COALESCE(v.fecha_homologacion_sanitaria, '2099-12-31'::DATE) AS fecha_caducidad,
        COALESCE(v.fecha_homologacion_sanitaria::DATE - CURRENT_DATE, 0) AS dias_restantes,
        'vehiculos' AS tabla_origen
    FROM public.tvehiculos v
    WHERE v.fecha_homologacion_sanitaria IS NOT NULL
      AND v.estado = 'activo'
      AND v.fecha_homologacion_sanitaria > CURRENT_DATE
),

-- ==============================================================================
-- Documentación de vehículos (seguros, ITV, etc.)
-- ==============================================================================
documentacion_vehiculos AS (
    SELECT
        dv.id AS entidad_id,
        ('DOCUMENTO:' || dv.id) AS entidad_key,
        v.matricula || ' - ' || tdv.nombre AS entidad_nombre,
        CASE
            WHEN tdv.categoria = 'seguro' THEN 'seguro'
            WHEN tdv.codigo IN ('itv', 'homologacion_sanitaria') THEN tdv.codigo
            ELSE 'documentacion'
        END AS tipo_alerta,
        COALESCE(dv.fecha_vencimiento, '2099-12-31'::DATE) AS fecha_caducidad,
        COALESCE(dv.fecha_vencimiento::DATE - CURRENT_DATE, 0) AS dias_restantes,
        'documentacion_vehiculos' AS tabla_origen
    FROM public.ambutrack_documentacion_vehiculos dv
    INNER JOIN public.tvehiculos v ON dv.vehiculo_id = v.id
    INNER JOIN public.ambutrack_tipos_documento_vehiculo tdv ON dv.tipo_documento_id = tdv.id
    WHERE dv.fecha_vencimiento IS NOT NULL
      AND dv.estado IN ('vigente', 'proxima_vencer', 'vencida')
      AND v.estado = 'activo'
),

-- ==============================================================================
-- Mantenimientos programados
-- ==============================================================================
mantenimientos AS (
    SELECT
        m.id AS entidad_id,
        ('MANTENIMIENTO:' || m.id) AS entidad_key,
        'Mantenimiento: ' || v.matricula AS entidad_nombre,
        'mantenimiento' AS tipo_alerta,
        COALESCE(m.fecha_programada, '2099-12-31'::DATE) AS fecha_caducidad,
        COALESCE(m.fecha_programada::DATE - CURRENT_DATE, 0) AS dias_restantes,
        'mantenimientos' AS tabla_origen
    FROM public.ambutrack_mantenimientos m
    INNER JOIN public.tvehiculos v ON m.vehiculo_id = v.id
    WHERE m.fecha_programada IS NOT NULL
      AND m.fecha_programada > CURRENT_DATE
      AND m.estado != 'completado'
      AND v.estado = 'activo'
)

-- ==============================================================================
-- COMBINAR TODAS LAS ALERTAS Y CALCULAR SEVERIDAD
-- ==============================================================================
SELECT
    tipo_alerta,
    entidad_id,
    entidad_key,
    entidad_nombre,
    fecha_caducidad,
    dias_restantes,
    tabla_origen,
    -- Calcular severidad basada en días restantes
    CASE
        WHEN dias_restantes < 7 THEN 'critica'
        WHEN dias_restantes < 30 THEN 'alta'
        WHEN dias_restantes < 60 THEN 'media'
        ELSE 'baja'
    END AS severidad,
    -- Marcar si es crítica (para diálogos iniciales)
    CASE
        WHEN dias_restantes < 7 THEN true
        ELSE false
    END AS es_critica,
    -- Prioridad para ordenamiento
    CASE
        WHEN dias_restantes < 7 THEN 1
        WHEN dias_restantes < 30 THEN 2
        WHEN dias_restantes < 60 THEN 3
        ELSE 4
    END AS prioridad
FROM vehiculos_itv
WHERE dias_restantes <= 60  -- Umbral ITV (configurable por usuario)

UNION ALL

SELECT
    tipo_alerta,
    entidad_id,
    entidad_key,
    entidad_nombre,
    fecha_caducidad,
    dias_restantes,
    tabla_origen,
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
    END AS prioridad
FROM vehiculos_seguro
WHERE dias_restantes <= 30  -- Umbral Seguro (configurable por usuario)

UNION ALL

SELECT
    tipo_alerta,
    entidad_id,
    entidad_key,
    entidad_nombre,
    fecha_caducidad,
    dias_restantes,
    tabla_origen,
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
    END AS prioridad
FROM vehiculos_homologacion
WHERE dias_restantes <= 90  -- Umbral Homologación (configurable por usuario)

UNION ALL

SELECT
    tipo_alerta,
    entidad_id,
    entidad_key,
    entidad_nombre,
    fecha_caducidad,
    dias_restantes,
    tabla_origen,
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
    END AS prioridad
FROM documentacion_vehiculos
WHERE dias_restantes <= 30  -- Umbral documentación (configurable por usuario)

UNION ALL

SELECT
    tipo_alerta,
    entidad_id,
    entidad_key,
    entidad_nombre,
    fecha_caducidad,
    dias_restantes,
    tabla_origen,
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
    END AS prioridad
FROM mantenimientos
WHERE dias_restantes <= 7;  -- Umbral Mantenimiento (configurable por usuario)

-- ==============================================================================
-- COMENTARIOS
-- ==============================================================================

COMMENT ON VIEW public.vw_alertas_caducidad_activas IS
    'Vista unificada de alertas de caducidad activas. Calcula automáticamente días restantes, severidad y prioridad. Filtra por umbrales configurables (ITV: 60d, Seguro: 30d, Homologación: 90d, Mantenimiento: 7d).';

-- ==============================================================================
-- ÍNDICES PARA MEJORAR RENDIMIENTO DE LA VISTA
-- ==============================================================================

-- Nota: Las vistas no pueden tener índices directamente. Los índices se aplican
-- a las tablas subyacentes. Ya existen índices en las tablas de vehículos y
-- documentación. Agregamos algunos índices adicionales si no existen:

CREATE INDEX IF NOT EXISTS idx_vehiculos_itv_fecha
    ON public.tvehiculos(fecha_itv)
    WHERE fecha_itv IS NOT NULL AND estado = 'activo';

CREATE INDEX IF NOT EXISTS idx_vehiculos_seguro_fecha
    ON public.tvehiculos(fecha_seguro)
    WHERE fecha_seguro IS NOT NULL AND estado = 'activo';

CREATE INDEX IF NOT EXISTS idx_vehiculos_homologacion_fecha
    ON public.tvehiculos(fecha_homologacion_sanitaria)
    WHERE fecha_homologacion_sanitaria IS NOT NULL AND estado = 'activo';

-- ==============================================================================
-- FUNCIONES AUXILIARES PARA LA VISTA
-- ==============================================================================

-- Función: Obtener alertas activas filtradas por umbrales personalizados
CREATE OR REPLACE FUNCTION obtener_alertas_activas(
    p_usuario_id UUID DEFAULT NULL,
    p_umbral_seguro INTEGER DEFAULT 30,
    p_umbral_itv INTEGER DEFAULT 60,
    p_umbral_homologacion INTEGER DEFAULT 90,
    p_umbral_mantenimiento INTEGER DEFAULT 7,
    p_incluir_vistas BOOLEAN DEFAULT true
)
RETURNS TABLE (
    tipo_alerta TEXT,
    entidad_id UUID,
    entidad_key TEXT,
    entidad_nombre TEXT,
    fecha_caducidad DATE,
    dias_restantes INTEGER,
    severidad TEXT,
    es_critica BOOLEAN,
    prioridad INTEGER
) AS $$
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
        v.prioridad
    FROM public.vw_alertas_caducidad_activas v
    WHERE
        -- Filtrar por umbrales personalizados
        (
            (v.tipo_alerta = 'seguro' AND v.dias_restantes <= p_umbral_seguro) OR
            (v.tipo_alerta = 'itv' AND v.dias_restantes <= p_umbral_itv) OR
            (v.tipo_alerta = 'homologacion' AND v.dias_restantes <= p_umbral_homologacion) OR
            (v.tipo_alerta = 'mantenimiento' AND v.dias_restantes <= p_umbral_mantenimiento)
        )
        -- Filtrar alertas ya vistas (si se especifica usuario_id y no incluir vistas)
        AND (
            p_incluir_vistas = true OR
            p_usuario_id IS NULL OR
            NOT EXISTS (
                SELECT 1
                FROM public.ambutrack_alertas_caducidad_vistas av
                WHERE av.usuario_id = p_usuario_id
                  AND av.tipo_alerta = v.tipo_alerta
                  AND av.entidad_id = v.entidad_id
                  AND av.fecha_visualizacion = CURRENT_DATE
            )
        )
    ORDER BY v.prioridad ASC, v.dias_restantes ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función: Obtener resumen de alertas por severidad
CREATE OR REPLACE FUNCTION obtener_resumen_alertas()
RETURNS TABLE (
    criticas BIGINT,
    altas BIGINT,
    medias BIGINT,
    bajas BIGINT,
    total BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*) FILTER (WHERE severidad = 'critica')::BIGINT AS criticas,
        COUNT(*) FILTER (WHERE severidad = 'alta')::BIGINT AS altas,
        COUNT(*) FILTER (WHERE severidad = 'media')::BIGINT AS medias,
        COUNT(*) FILTER (WHERE severidad = 'baja')::BIGINT AS bajas,
        COUNT(*)::BIGINT AS total
    FROM public.vw_alertas_caducidad_activas;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función: Obtener alertas críticas (para diálogo inicial)
CREATE OR REPLACE FUNCTION obtener_alertas_criticas(
    p_usuario_id UUID DEFAULT NULL
)
RETURNS TABLE (
    tipo_alerta TEXT,
    entidad_id UUID,
    entidad_key TEXT,
    entidad_nombre TEXT,
    fecha_caducidad DATE,
    dias_restantes INTEGER,
    severidad TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        v.tipo_alerta,
        v.entidad_id,
        v.entidad_key,
        v.entidad_nombre,
        v.fecha_caducidad,
        v.dias_restantes,
        v.severidad
    FROM public.vw_alertas_caducidad_activas v
    WHERE v.es_critica = true
      -- Filtrar alertas ya vistas hoy
      AND (
          p_usuario_id IS NULL OR
          NOT EXISTS (
              SELECT 1
              FROM public.ambutrack_alertas_caducidad_vistas av
              WHERE av.usuario_id = p_usuario_id
                AND av.tipo_alerta = v.tipo_alerta
                AND av.entidad_id = v.entidad_id
                AND av.fecha_visualizacion = CURRENT_DATE
          )
      )
    ORDER BY v.dias_restantes ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- VERIFICACIÓN Y TEST
-- ==============================================================================

DO $$
DECLARE
    v_vista_existe BOOLEAN;
    v_total_alertas BIGINT;
BEGIN
    -- Verificar que la vista existe
    SELECT EXISTS (
        SELECT FROM information_schema.views
        WHERE table_schema = 'public'
        AND table_name = 'vw_alertas_caducidad_activas'
    ) INTO v_vista_existe;

    IF v_vista_existe THEN
        RAISE NOTICE '✅ Vista vw_alertas_caducidad_activas creada correctamente';

        -- Contar alertas activas
        SELECT COUNT(*) INTO v_total_alertas
        FROM public.vw_alertas_caducidad_activas;

        RAISE NOTICE '📊 Total de alertas activas: %', v_total_alertas;
    ELSE
        RAISE EXCEPTION '❌ Error: No se pudo crear la vista vw_alertas_caducidad_activas';
    END IF;

    -- Verificar que la función obtener_alertas_activas existe
    IF EXISTS (
        SELECT FROM pg_proc
        WHERE proname = 'obtener_alertas_activas'
    ) THEN
        RAISE NOTICE '✅ Función obtener_alertas_activas creada correctamente';
    END IF;

    -- Verificar que la función obtener_resumen_alertas existe
    IF EXISTS (
        SELECT FROM pg_proc
        WHERE proname = 'obtener_resumen_alertas'
    ) THEN
        RAISE NOTICE '✅ Función obtener_resumen_alertas creada correctamente';

        -- Test de la función
        SELECT * INTO v_total_alertas FROM obtener_resumen_alertas();
        RAISE NOTICE '🧪 Test de obtener_resumen_alertas: % alertas totales', v_total_alertas;
    END IF;

    -- Verificar que la función obtener_alertas_criticas existe
    IF EXISTS (
        SELECT FROM pg_proc
        WHERE proname = 'obtener_alertas_criticas'
    ) THEN
        RAISE NOTICE '✅ Función obtener_alertas_criticas creada correctamente';
    END IF;
END $$;

-- ==============================================================================
-- FIN DE LA MIGRACIÓN
-- ==============================================================================
-- Estado: Completo
-- Vistas creadas: 1
-- Funciones creadas: 3
-- Índices creados: 3
-- ==============================================================================

-- ==============================================================================
-- EJEMPLOS DE USO
-- ==============================================================================

-- 1. Obtener todas las alertas activas:
-- SELECT * FROM public.vw_alertas_caducidad_activas ORDER BY prioridad, dias_restantes;

-- 2. Obtener resumen de alertas por severidad:
-- SELECT * FROM public.obtener_resumen_alertas();

-- 3. Obtener alertas de un usuario con umbrales personalizados:
-- SELECT * FROM public.obtener_alertas_activas(
--     'uuid-del-usuario'::UUID,
--     30,  -- umbral_seguro
--     60,  -- umbral_itv
--     90,  -- umbral_homologacion
--     7    -- umbral_mantenimiento
-- );

-- 4. Obtener solo alertas críticas (no vistas hoy):
-- SELECT * FROM public.obtener_alertas_criticas('uuid-del-usuario'::UUID);
