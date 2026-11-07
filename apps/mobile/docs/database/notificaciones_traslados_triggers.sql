-- =====================================================
-- AmbuTrack Mobile - Triggers de Notificaciones para Traslados
-- =====================================================
-- Script para crear triggers que notifican automáticamente al personal
-- cuando se les asigna o desadjudica un traslado
--
-- Ejecutar en: https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr/sql

-- =====================================================
-- 1. ACTUALIZAR TABLA: Agregar nuevos tipos de notificación
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
    -- ⬇️ NUEVOS TIPOS PARA TRASLADOS (MOBILE)
    'traslado_asignado',
    'traslado_desadjudicado',
    'traslado_iniciado',
    'traslado_finalizado',
    'traslado_cancelado',
    'checklist_pendiente'
));

COMMENT ON CONSTRAINT tnotificaciones_tipo_check ON tnotificaciones IS
    'Tipos de notificación: vacaciones, ausencias, turnos, traslados (mobile), checklist, alertas, info';

-- =====================================================
-- 2. FUNCIÓN: Notificar al personal cuando se le asigna un traslado
-- =====================================================

CREATE OR REPLACE FUNCTION notificar_traslado_asignado()
RETURNS TRIGGER AS $$
DECLARE
    v_conductor_usuario_id UUID;
    v_conductor_nombre TEXT;
    v_tes_usuario_id UUID;
    v_tes_nombre TEXT;
    v_origen TEXT;
    v_destino TEXT;
    v_numero_servicio TEXT;
BEGIN
    -- Obtener información del traslado
    v_origen := COALESCE(NEW.origen, 'Origen no especificado');
    v_destino := COALESCE(NEW.destino, 'Destino no especificado');
    v_numero_servicio := COALESCE(NEW.codigo, 'S/N');

    -- ===== NOTIFICAR AL CONDUCTOR =====
    IF NEW.id_conductor IS NOT NULL THEN
        -- Obtener usuario_id y nombre del conductor
        SELECT p.usuario_id, CONCAT(p.nombre, ' ', p.apellidos)
        INTO v_conductor_usuario_id, v_conductor_nombre
        FROM tpersonal p
        WHERE p.id = NEW.id_conductor AND p.activo = true;

        -- Crear notificación si el conductor tiene usuario_id
        IF v_conductor_usuario_id IS NOT NULL THEN
            INSERT INTO tnotificaciones (
                usuario_destino_id,
                tipo,
                titulo,
                mensaje,
                entidad_tipo,
                entidad_id,
                metadata
            ) VALUES (
                v_conductor_usuario_id,
                'traslado_asignado',
                '🚑 Nuevo Traslado Asignado',
                'Se te ha asignado el servicio #' || v_numero_servicio || ' | ' || v_origen || ' → ' || v_destino,
                'traslado',
                NEW.id::TEXT,
                jsonb_build_object(
                    'servicio_id', NEW.id,
                    'numero_servicio', v_numero_servicio,
                    'origen', v_origen,
                    'destino', v_destino,
                    'rol', 'conductor'
                )
            );

            RAISE NOTICE 'Notificación creada para conductor: % (usuario: %)', v_conductor_nombre, v_conductor_usuario_id;
        END IF;
    END IF;

    -- ===== NOTIFICAR AL PERSONAL SANITARIO (TES) =====
    -- personal_asignado es un ARRAY, notificar solo a los NUEVOS miembros
    IF NEW.personal_asignado IS NOT NULL AND array_length(NEW.personal_asignado, 1) > 0 THEN
        -- Iterar solo sobre IDs que están en NEW pero NO estaban en OLD
        FOR v_tes_usuario_id, v_tes_nombre IN
            SELECT p.usuario_id, CONCAT(p.nombre, ' ', p.apellidos)
            FROM unnest(NEW.personal_asignado) AS personal_id
            JOIN tpersonal p ON p.id = personal_id
            WHERE p.activo = true
            AND p.usuario_id IS NOT NULL
            -- Solo notificar si es nuevo (no estaba en OLD)
            AND (OLD.personal_asignado IS NULL OR NOT (personal_id = ANY(OLD.personal_asignado)))
        LOOP
            -- Crear notificación para cada TES nuevo
            INSERT INTO tnotificaciones (
                usuario_destino_id,
                tipo,
                titulo,
                mensaje,
                entidad_tipo,
                entidad_id,
                metadata
            ) VALUES (
                v_tes_usuario_id,
                'traslado_asignado',
                '🚑 Nuevo Traslado Asignado',
                'Se te ha asignado el servicio #' || v_numero_servicio || ' | ' || v_origen || ' → ' || v_destino,
                'traslado',
                NEW.id::TEXT,
                jsonb_build_object(
                    'servicio_id', NEW.id,
                    'numero_servicio', v_numero_servicio,
                    'origen', v_origen,
                    'destino', v_destino,
                    'rol', 'tes'
                )
            );

            RAISE NOTICE 'Notificación creada para TES: % (usuario: %)', v_tes_nombre, v_tes_usuario_id;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION notificar_traslado_asignado() IS
    'Notifica automáticamente al conductor y TES cuando se les asigna un nuevo traslado';

-- =====================================================
-- 3. FUNCIÓN: Notificar al personal cuando se le desadjudica un traslado
-- =====================================================

CREATE OR REPLACE FUNCTION notificar_traslado_desadjudicado()
RETURNS TRIGGER AS $$
DECLARE
    v_usuario_id UUID;
    v_nombre TEXT;
    v_numero_servicio TEXT;
    v_rol TEXT;
BEGIN
    v_numero_servicio := COALESCE(OLD.codigo, 'S/N');

    -- ===== CONDUCTOR DESADJUDICADO =====
    IF OLD.id_conductor IS NOT NULL AND NEW.id_conductor IS NULL THEN
        -- Obtener usuario_id y nombre del conductor
        SELECT p.usuario_id, CONCAT(p.nombre, ' ', p.apellidos)
        INTO v_usuario_id, v_nombre
        FROM tpersonal p
        WHERE p.id = OLD.id_conductor;

        -- Crear notificación si el conductor tiene usuario_id
        IF v_usuario_id IS NOT NULL THEN
            INSERT INTO tnotificaciones (
                usuario_destino_id,
                tipo,
                titulo,
                mensaje,
                entidad_tipo,
                entidad_id,
                metadata
            ) VALUES (
                v_usuario_id,
                'traslado_desadjudicado',
                '❌ Traslado Desadjudicado',
                'Has sido desasignado del servicio #' || v_numero_servicio,
                'traslado',
                OLD.id::TEXT,
                jsonb_build_object(
                    'servicio_id', OLD.id,
                    'numero_servicio', v_numero_servicio,
                    'rol', 'conductor'
                )
            );

            RAISE NOTICE 'Notificación de desadjudicación creada para conductor: % (usuario: %)', v_nombre, v_usuario_id;
        END IF;
    END IF;

    -- ===== PERSONAL SANITARIO DESADJUDICADO =====
    -- Detectar personal removido del array comparando OLD y NEW
    IF OLD.personal_asignado IS NOT NULL THEN
        -- Iterar sobre el personal que estaba en OLD pero no está en NEW
        FOR v_usuario_id, v_nombre IN
            SELECT p.usuario_id, CONCAT(p.nombre, ' ', p.apellidos)
            FROM unnest(OLD.personal_asignado) AS old_personal_id
            JOIN tpersonal p ON p.id = old_personal_id
            WHERE p.activo = true
            AND p.usuario_id IS NOT NULL
            AND (NEW.personal_asignado IS NULL OR NOT (old_personal_id = ANY(NEW.personal_asignado)))
        LOOP
            -- Crear notificación de desadjudicación
            INSERT INTO tnotificaciones (
                usuario_destino_id,
                tipo,
                titulo,
                mensaje,
                entidad_tipo,
                entidad_id,
                metadata
            ) VALUES (
                v_usuario_id,
                'traslado_desadjudicado',
                '❌ Traslado Desadjudicado',
                'Has sido desasignado del servicio #' || v_numero_servicio,
                'traslado',
                OLD.id::TEXT,
                jsonb_build_object(
                    'servicio_id', OLD.id,
                    'numero_servicio', v_numero_servicio,
                    'rol', 'tes'
                )
            );

            RAISE NOTICE 'Notificación de desadjudicación creada para TES: % (usuario: %)', v_nombre, v_usuario_id;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION notificar_traslado_desadjudicado() IS
    'Notifica automáticamente al conductor o TES cuando se le desadjudica un traslado';

-- =====================================================
-- 4. TRIGGER: Asignación de traslado (INSERT)
-- =====================================================

DROP TRIGGER IF EXISTS trigger_notificar_traslado_asignado_insert ON traslados;

CREATE TRIGGER trigger_notificar_traslado_asignado_insert
    AFTER INSERT ON traslados
    FOR EACH ROW
    WHEN (
        -- Disparar si se crea un traslado con conductor o personal asignado
        NEW.id_conductor IS NOT NULL
        OR (NEW.personal_asignado IS NOT NULL AND array_length(NEW.personal_asignado, 1) > 0)
    )
    EXECUTE FUNCTION notificar_traslado_asignado();

COMMENT ON TRIGGER trigger_notificar_traslado_asignado_insert ON traslados IS
    'Dispara notificación cuando se crea un traslado con conductor o TES asignado';

-- =====================================================
-- 5. TRIGGER: Asignación de traslado (UPDATE)
-- =====================================================

DROP TRIGGER IF EXISTS trigger_notificar_traslado_asignado_update ON traslados;

CREATE TRIGGER trigger_notificar_traslado_asignado_update
    AFTER UPDATE OF id_conductor, personal_asignado ON traslados
    FOR EACH ROW
    WHEN (
        -- Disparar si se asigna un conductor nuevo (de NULL a valor o cambio de conductor)
        (OLD.id_conductor IS NULL AND NEW.id_conductor IS NOT NULL)
        OR (OLD.id_conductor IS NOT NULL AND NEW.id_conductor IS NOT NULL AND OLD.id_conductor <> NEW.id_conductor)
        -- O si cambia el array de personal_asignado (agregados o modificaciones)
        OR (OLD.personal_asignado IS DISTINCT FROM NEW.personal_asignado)
    )
    EXECUTE FUNCTION notificar_traslado_asignado();

COMMENT ON TRIGGER trigger_notificar_traslado_asignado_update ON traslados IS
    'Dispara notificación cuando se actualiza conductor o TES de un traslado';

-- =====================================================
-- 6. TRIGGER: Desadjudicación de traslado
-- =====================================================

DROP TRIGGER IF EXISTS trigger_notificar_traslado_desadjudicado ON traslados;

CREATE TRIGGER trigger_notificar_traslado_desadjudicado
    AFTER UPDATE OF id_conductor, personal_asignado ON traslados
    FOR EACH ROW
    WHEN (
        -- Disparar si se elimina un conductor (de valor a NULL)
        (OLD.id_conductor IS NOT NULL AND NEW.id_conductor IS NULL)
        -- O si cambia el array de personal (para detectar eliminaciones)
        OR (OLD.personal_asignado IS DISTINCT FROM NEW.personal_asignado)
    )
    EXECUTE FUNCTION notificar_traslado_desadjudicado();

COMMENT ON TRIGGER trigger_notificar_traslado_desadjudicado ON traslados IS
    'Dispara notificación cuando se desadjudica conductor o TES de un traslado';

-- =====================================================
-- 7. VERIFICACIÓN
-- =====================================================

-- Verificar que los triggers se crearon correctamente
SELECT
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE trigger_name IN (
    'trigger_notificar_traslado_asignado_insert',
    'trigger_notificar_traslado_asignado_update',
    'trigger_notificar_traslado_desadjudicado'
)
ORDER BY trigger_name;

-- Verificar que la tabla tiene los nuevos tipos
SELECT
    constraint_name,
    check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'tnotificaciones_tipo_check';

-- =====================================================
-- 8. PRUEBA MANUAL (Opcional)
-- =====================================================

-- Descomentar para probar:

-- Obtener un traslado de prueba
-- SELECT id, numero_servicio, conductor_id, tes_id FROM traslados LIMIT 1;

-- Asignar conductor (reemplazar IDs por valores reales)
-- UPDATE traslados
-- SET conductor_id = 'ID_DEL_CONDUCTOR_AQUI'
-- WHERE id = 'ID_DEL_TRASLADO_AQUI';

-- Verificar que se creó la notificación
-- SELECT * FROM tnotificaciones
-- WHERE entidad_id = 'ID_DEL_TRASLADO_AQUI'
-- ORDER BY created_at DESC;

-- Desadjudicar conductor
-- UPDATE traslados
-- SET conductor_id = NULL
-- WHERE id = 'ID_DEL_TRASLADO_AQUI';

-- Verificar notificación de desadjudicación
-- SELECT * FROM tnotificaciones
-- WHERE entidad_id = 'ID_DEL_TRASLADO_AQUI'
-- ORDER BY created_at DESC;

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

RAISE NOTICE '✅ Triggers de notificaciones para traslados creados correctamente';
