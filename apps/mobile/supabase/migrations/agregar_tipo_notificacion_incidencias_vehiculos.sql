-- =====================================================
-- AmbuTrack Mobile - Agregar tipos de notificación para incidencias de vehículos
-- =====================================================
-- Script para agregar el tipo 'incidencia_vehiculo_reportada' al constraint
-- de la tabla tnotificaciones
--
-- Ejecutar en: https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr/sql

-- =====================================================
-- 1. ACTUALIZAR CONSTRAINT: Agregar tipo de incidencias de vehículos
-- =====================================================

ALTER TABLE tnotificaciones DROP CONSTRAINT IF EXISTS tnotificaciones_tipo_check;

ALTER TABLE tnotificaciones ADD CONSTRAINT tnotificaciones_tipo_check CHECK (tipo IN (
    -- Tipos existentes
    'vacacion_solicitada',
    'vacacion_aprobada',
    'vacacion_rechazada',
    'ausencia_solicitada',
    'ausencia_aprobada',
    'ausencia_rechazada',
    'cambio_turno',
    'alerta',
    'info',
    -- Tipos de traslados (mobile)
    'traslado_asignado',
    'traslado_desadjudicado',
    'traslado_iniciado',
    'traslado_finalizado',
    'traslado_cancelado',
    'checklist_pendiente',
    -- ⬇️ NUEVO: Tipo para incidencias de vehículos
    'incidencia_vehiculo_reportada'
));

COMMENT ON CONSTRAINT tnotificaciones_tipo_check ON tnotificaciones IS
    'Tipos de notificación: vacaciones, ausencias, turnos, traslados (mobile), checklist, incidencias de vehículos, alertas, info';

-- =====================================================
-- 2. VERIFICACIÓN
-- =====================================================

-- Verificar que el constraint se actualizó correctamente
SELECT
    constraint_name,
    check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'tnotificaciones_tipo_check';

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE '✅ Tipo de notificación "incidencia_vehiculo_reportada" agregado correctamente al constraint';
END $$;
