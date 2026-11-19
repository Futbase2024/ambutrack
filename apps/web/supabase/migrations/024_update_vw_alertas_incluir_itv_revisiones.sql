-- ==============================================================================
-- AMBUTRACK WEB - Actualización Vista de Alertas de Caducidades
-- Archivo: 024_update_vw_alertas_incluir_itv_revisiones.sql
-- Descripción: Incluye ITV/Revisiones de la tabla titv_revisiones en las alertas
-- Fecha: 2026-02-15
-- Author: AmbuTrack Development Team
-- ==============================================================================

-- ==============================================================================
-- PROBLEMA IDENTIFICADO:
-- La vista vw_alertas_caducidad_activas NO incluye las ITV/Revisiones
-- de la tabla titv_revisiones, solo lee de:
--   - tvehiculos.fecha_itv (fecha de ITV del vehículo)
--   - ambutrack_documentacion_vehiculos (documentación general)
--
-- SOLUCIÓN:
-- Agregar un nuevo CTE para incluir titv_revisiones con sus estados
-- pendiente, realizada, vencida, cancelada
-- ==============================================================================

CREATE OR REPLACE VIEW public.vw_alertas_caducidad_activas AS
WITH
-- ==============================================================================
-- ITV de vehículos (desde tvehiculos.proxima_itv)
-- ==============================================================================
vehiculos_itv AS (
    SELECT
        v.id AS entidad_id,
        ('VEHICULO:' || v.id) AS entidad_key,
        v.matricula || ' - ' || v.marca || ' ' || v.modelo AS entidad_nombre,
        'itv' AS tipo_alerta,
        COALESCE(v.proxima_itv, '2099-12-31'::DATE) AS fecha_caducidad,
        COALESCE(v.proxima_itv::DATE - CURRENT_DATE, 0) AS dias_restantes,
        'vehiculos' AS tabla_origen
    FROM public.tvehiculos v
    WHERE v.proxima_itv IS NOT NULL
      AND v.activo = true
      AND v.proxima_itv > CURRENT_DATE
),

-- ==============================================================================
-- Seguros de vehículos (desde tvehiculos.fecha_vencimiento_seguro)
-- ==============================================================================
vehiculos_seguro AS (
    SELECT
        v.id AS entidad_id,
        ('VEHICULO:' || v.id) AS entidad_key,
        v.matricula || ' - ' || v.marca || ' ' || v.modelo AS entidad_nombre,
        'seguro' AS tipo_alerta,
        COALESCE(v.fecha_vencimiento_seguro, '2099-12-31'::DATE) AS fecha_caducidad,
        COALESCE(v.fecha_vencimiento_seguro::DATE - CURRENT_DATE, 0) AS dias_restantes,
        'vehiculos' AS tabla_origen
    FROM public.tvehiculos v
    WHERE v.fecha_vencimiento_seguro IS NOT NULL
      AND v.activo = true
      AND v.fecha_vencimiento_seguro > CURRENT_DATE
),

-- ==============================================================================
-- Homologaciones sanitarias (desde tvehiculos.fecha_vencimiento_homologacion)
-- ==============================================================================
vehiculos_homologacion AS (
    SELECT
        v.id AS entidad_id,
        ('VEHICULO:' || v.id) AS entidad_key,
        v.matricula || ' - ' || v.marca || ' ' || v.modelo AS entidad_nombre,
        'homologacion' AS tipo_alerta,
        COALESCE(v.fecha_vencimiento_homologacion, '2099-12-31'::DATE) AS fecha_caducidad,
        COALESCE(v.fecha_vencimiento_homologacion::DATE - CURRENT_DATE, 0) AS dias_restantes,
        'vehiculos' AS tabla_origen
    FROM public.tvehiculos v
    WHERE v.fecha_vencimiento_homologacion IS NOT NULL
      AND v.activo = true
      AND v.fecha_vencimiento_homologacion > CURRENT_DATE
),

-- ==============================================================================
-- Documentación de vehículos (seguros, ITV, etc. desde ambutrack_documentacion_vehiculos)
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
      AND v.activo = true
),

-- ==============================================================================
-- 🔥 NUEVO: ITV y Revisiones programadas (desde titv_revisiones)
-- ==============================================================================
itv_revisiones_programadas AS (
    SELECT
        tr.id AS entidad_id,
        ('ITV_REVISION:' || tr.id) AS entidad_key,
        v.matricula || ' - ' || tr.tipo AS entidad_nombre,
        CASE tr.tipo
            WHEN 'itv' THEN 'itv'
            WHEN 'revision_tecnica' THEN 'revision_tecnica'
            WHEN 'homologacion' THEN 'homologacion'
            ELSE 'revision'
        END AS tipo_alerta,
        COALESCE(tr.fecha_vencimiento, '2099-12-31'::DATE) AS fecha_caducidad,
        COALESCE(tr.fecha_vencimiento::DATE - CURRENT_DATE, 0) AS dias_restantes,
        'titv_revisiones' AS tabla_origen
    FROM public.titv_revisiones tr
    INNER JOIN public.tvehiculos v ON tr.vehiculo_id = v.id
    WHERE tr.fecha_vencimiento IS NOT NULL
      AND tr.estado IN ('pendiente', 'vencida')  -- ✅ Estados específicos de titv_revisiones
      AND v.activo = true
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
    FROM public.tmantenimientos m
    INNER JOIN public.tvehiculos v ON m.vehiculo_id = v.id
    WHERE m.fecha_programada IS NOT NULL
      AND m.fecha_programada > CURRENT_DATE
      AND m.estado != 'completado'
      AND v.activo = true
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
        WHEN dias_restantes < 0 THEN 'critica'  -- ✅ Vencida
        WHEN dias_restantes < 7 THEN 'critica'
        WHEN dias_restantes < 30 THEN 'alta'
        WHEN dias_restantes < 60 THEN 'media'
        ELSE 'baja'
    END AS severidad,
    -- Marcar si es crítica (para diálogos iniciales)
    CASE
        WHEN dias_restantes < 0 THEN true  -- ✅ Vencida
        WHEN dias_restantes < 7 THEN true
        ELSE false
    END AS es_critica,
    -- Prioridad para ordenamiento
    CASE
        WHEN dias_restantes < 0 THEN 1  -- ✅ Vencida
        WHEN dias_restantes < 7 THEN 2
        WHEN dias_restantes < 30 THEN 3
        WHEN dias_restantes < 60 THEN 4
        ELSE 5
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
        WHEN dias_restantes < 0 THEN 'critica'
        WHEN dias_restantes < 7 THEN 'critica'
        WHEN dias_restantes < 30 THEN 'alta'
        WHEN dias_restantes < 60 THEN 'media'
        ELSE 'baja'
    END AS severidad,
    CASE
        WHEN dias_restantes < 0 THEN true
        WHEN dias_restantes < 7 THEN true
        ELSE false
    END AS es_critica,
    CASE
        WHEN dias_restantes < 0 THEN 1
        WHEN dias_restantes < 7 THEN 2
        WHEN dias_restantes < 30 THEN 3
        WHEN dias_restantes < 60 THEN 4
        ELSE 5
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
        WHEN dias_restantes < 0 THEN 'critica'
        WHEN dias_restantes < 7 THEN 'critica'
        WHEN dias_restantes < 30 THEN 'alta'
        WHEN dias_restantes < 60 THEN 'media'
        ELSE 'baja'
    END AS severidad,
    CASE
        WHEN dias_restantes < 0 THEN true
        WHEN dias_restantes < 7 THEN true
        ELSE false
    END AS es_critica,
    CASE
        WHEN dias_restantes < 0 THEN 1
        WHEN dias_restantes < 7 THEN 2
        WHEN dias_restantes < 30 THEN 3
        WHEN dias_restantes < 60 THEN 4
        ELSE 5
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
        WHEN dias_restantes < 0 THEN 'critica'
        WHEN dias_restantes < 7 THEN 'critica'
        WHEN dias_restantes < 30 THEN 'alta'
        WHEN dias_restantes < 60 THEN 'media'
        ELSE 'baja'
    END AS severidad,
    CASE
        WHEN dias_restantes < 0 THEN true
        WHEN dias_restantes < 7 THEN true
        ELSE false
    END AS es_critica,
    CASE
        WHEN dias_restantes < 0 THEN 1
        WHEN dias_restantes < 7 THEN 2
        WHEN dias_restantes < 30 THEN 3
        WHEN dias_restantes < 60 THEN 4
        ELSE 5
    END AS prioridad
FROM documentacion_vehiculos
WHERE dias_restantes <= 30  -- Umbral documentación (configurable por usuario)

UNION ALL

-- ==============================================================================
-- 🔥 NUEVO UNION ALL: Incluir ITV/Revisiones programadas
-- ==============================================================================
SELECT
    tipo_alerta,
    entidad_id,
    entidad_key,
    entidad_nombre,
    fecha_caducidad,
    dias_restantes,
    tabla_origen,
    CASE
        WHEN dias_restantes < 0 THEN 'critica'
        WHEN dias_restantes < 7 THEN 'critica'
        WHEN dias_restantes < 30 THEN 'alta'
        WHEN dias_restantes < 60 THEN 'media'
        ELSE 'baja'
    END AS severidad,
    CASE
        WHEN dias_restantes < 0 THEN true
        WHEN dias_restantes < 7 THEN true
        ELSE false
    END AS es_critica,
    CASE
        WHEN dias_restantes < 0 THEN 1
        WHEN dias_restantes < 7 THEN 2
        WHEN dias_restantes < 30 THEN 3
        WHEN dias_restantes < 60 THEN 4
        ELSE 5
    END AS prioridad
FROM itv_revisiones_programadas
WHERE dias_restantes <= 60  -- Umbral ITV revisiones (configurable por usuario)

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
        WHEN dias_restantes < 0 THEN 'critica'
        WHEN dias_restantes < 7 THEN 'critica'
        WHEN dias_restantes < 30 THEN 'alta'
        WHEN dias_restantes < 60 THEN 'media'
        ELSE 'baja'
    END AS severidad,
    CASE
        WHEN dias_restantes < 0 THEN true
        WHEN dias_restantes < 7 THEN true
        ELSE false
    END AS es_critica,
    CASE
        WHEN dias_restantes < 0 THEN 1
        WHEN dias_restantes < 7 THEN 2
        WHEN dias_restantes < 30 THEN 3
        WHEN dias_restantes < 60 THEN 4
        ELSE 5
    END AS prioridad
FROM mantenimientos
WHERE dias_restantes <= 7;  -- Umbral Mantenimiento (configurable por usuario)

-- ==============================================================================
-- COMENTARIOS
-- ==============================================================================

COMMENT ON VIEW public.vw_alertas_caducidad_activas IS
    'Vista unificada de alertas de caducidad activas. Incluye vehículos (ITV, seguros, homologaciones), documentación, ITV/Revisiones programadas (titv_revisiones) y mantenimientos. Filtra por umbrales configurables (ITV: 60d, Seguro: 30d, Homologación: 90d, ITV Revisiones: 60d, Mantenimiento: 7d).';

-- ==============================================================================
-- VERIFICACIÓN
-- ==============================================================================

DO $$
DECLARE
    v_vista_existe BOOLEAN;
    v_total_alertas BIGINT;
    v_alertas_itv_revisiones BIGINT;
BEGIN
    -- Verificar que la vista existe
    SELECT EXISTS (
        SELECT FROM information_schema.views
        WHERE table_schema = 'public'
        AND table_name = 'vw_alertas_caducidad_activas'
    ) INTO v_vista_existe;

    IF v_vista_existe THEN
        RAISE NOTICE '✅ Vista vw_alertas_caducidad_activas actualizada correctamente';

        -- Contar alertas activas totales
        SELECT COUNT(*) INTO v_total_alertas
        FROM public.vw_alertas_caducidad_activas;

        RAISE NOTICE '📊 Total de alertas activas: %', v_total_alertas;

        -- Contar alertas de ITV/Revisiones específicamente
        SELECT COUNT(*) INTO v_alertas_itv_revisiones
        FROM public.vw_alertas_caducidad_activas
        WHERE tabla_origen = 'titv_revisiones';

        RAISE NOTICE '🔍 Alertas de ITV/Revisiones (titv_revisiones): %', v_alertas_itv_revisiones;
    ELSE
        RAISE EXCEPTION '❌ Error: No se pudo actualizar la vista vw_alertas_caducidad_activas';
    END IF;
END $$;

-- ==============================================================================
-- FIN DE LA MIGRACIÓN
-- ==============================================================================
-- Estado: Completo
-- Vista modificada: vw_alertas_caducidad_activas
-- Cambios: Agregado CTE itv_revisiones_programadas + UNION ALL
-- Estados filtrados de titv_revisiones: pendiente, vencida
-- ==============================================================================

-- ==============================================================================
-- TEST QUERY PARA VERIFICAR
-- ==============================================================================
-- Descomentar para probar:
-- SELECT * FROM public.vw_alertas_caducidad_activas
-- WHERE tabla_origen = 'titv_revisiones'
-- ORDER BY dias_restantes ASC;
