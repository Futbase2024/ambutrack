-- ==============================================================================
-- AMBUTRACK WEB - Fix: alertas de mantenimiento deben incluir HOY y vencidos
-- Archivo: 025_fix_vw_alertas_mantenimiento_hoy.sql
-- Fecha: 2026-06-16
-- ==============================================================================
--
-- PROBLEMA:
-- El CTE 'mantenimientos' de vw_alertas_caducidad_activas filtraba con
--   m.fecha_programada > CURRENT_DATE   (estrictamente mayor)
-- lo que EXCLUÍA el día de hoy y los vencidos. Así, un mantenimiento que
-- vence HOY desaparecía del badge del dashboard en lugar de mostrarse en
-- rojo ("VENCE HOY"). El resto de CTEs (ITV, seguro, documentación, ...)
-- sí permiten vencidos/hoy vía sus estados; solo mantenimiento fallaba.
--
-- SOLUCIÓN:
-- Cambiar '>' por '>=' en el filtro del CTE mantenimientos, de modo que
-- fecha_programada = CURRENT_DATE (hoy) y los vencidos no completados
-- entren en la vista y se marquen como severidad 'critica' / es_critica.
--
-- Es seguro y reversible: basta con volver a dejar '>' para revertir.
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
-- ITV y Revisiones programadas (desde titv_revisiones)
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
      AND tr.estado IN ('pendiente', 'vencida')
      AND v.activo = true
),

-- ==============================================================================
-- Mantenimientos programados  (🔥 FIX: '>=' en vez de '>' para incluir HOY)
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
      AND m.fecha_programada >= CURRENT_DATE   -- ✅ FIX: incluye HOY y vencidos
      AND m.estado != 'completado'
      AND v.activo = true
)

SELECT
    tipo_alerta, entidad_id, entidad_key, entidad_nombre,
    fecha_caducidad, dias_restantes, tabla_origen,
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
FROM vehiculos_itv
WHERE dias_restantes <= 60

UNION ALL

SELECT
    tipo_alerta, entidad_id, entidad_key, entidad_nombre,
    fecha_caducidad, dias_restantes, tabla_origen,
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
WHERE dias_restantes <= 30

UNION ALL

SELECT
    tipo_alerta, entidad_id, entidad_key, entidad_nombre,
    fecha_caducidad, dias_restantes, tabla_origen,
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
WHERE dias_restantes <= 90

UNION ALL

SELECT
    tipo_alerta, entidad_id, entidad_key, entidad_nombre,
    fecha_caducidad, dias_restantes, tabla_origen,
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
WHERE dias_restantes <= 30

UNION ALL

SELECT
    tipo_alerta, entidad_id, entidad_key, entidad_nombre,
    fecha_caducidad, dias_restantes, tabla_origen,
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
WHERE dias_restantes <= 60

UNION ALL

SELECT
    tipo_alerta, entidad_id, entidad_key, entidad_nombre,
    fecha_caducidad, dias_restantes, tabla_origen,
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
WHERE dias_restantes <= 7;

COMMENT ON VIEW public.vw_alertas_caducidad_activas IS
    'Vista unificada de alertas de caducidad activas. Incluye vehículos (ITV, seguros, homologaciones), documentación, ITV/Revisiones programadas (titv_revisiones) y mantenimientos. El CTE mantenimientos usa fecha_programada >= CURRENT_DATE para incluir el día de hoy y los vencidos. Umbrales: ITV 60d, Seguro 30d, Homologación 90d, ITV Revisiones 60d, Mantenimiento 7d.';
