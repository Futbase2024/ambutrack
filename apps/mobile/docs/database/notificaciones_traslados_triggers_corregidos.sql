-- =====================================================
-- AmbuTrack Mobile - Triggers de Notificaciones CORREGIDOS
-- =====================================================
-- Script FINAL con JOIN a tabla pacientes
--
-- PROBLEMA IDENTIFICADO:
-- - La tabla traslados NO tiene campo paciente_nombre
-- - Solo tiene id_paciente (UUID)
-- - La solución es hacer JOIN con la tabla pacientes
--
-- CAMBIOS PRINCIPALES:
-- ✅ JOIN con tabla pacientes para obtener nombre completo
-- ✅ TO_CHAR para formatear hora (en lugar de SUBSTRING)
-- ✅ Acceso a campos existentes: origen, destino (TEXT)
--
-- EJECUTADO EN SUPABASE: 2026-02-10 vía MCP

-- =====================================================
-- 1. FUNCIÓN CORREGIDA: Notificar asignación de traslado
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
    -- ⬇️ CAMPOS OBTENIDOS VIA JOIN
    v_paciente_nombre TEXT;
    v_hora_programada TEXT;
    v_mensaje_profesional TEXT;
BEGIN
    -- Obtener información básica del traslado
    v_numero_servicio := COALESCE(NEW.codigo, 'S/N');

    -- ⬇️ OBTENER DATOS DEL PACIENTE DESDE TABLA pacientes (JOIN)
    SELECT CONCAT_WS(' ', p.nombre, p.primer_apellido, p.segundo_apellido)
    INTO v_paciente_nombre
    FROM pacientes p
    WHERE p.id = NEW.id_paciente;

    v_paciente_nombre := COALESCE(v_paciente_nombre, 'Paciente no especificado');

    -- ⬇️ OBTENER ORIGEN Y DESTINO (campos TEXT existentes en traslados)
    v_origen := COALESCE(
        CASE
            WHEN NEW.origen IS NOT NULL AND LENGTH(TRIM(NEW.origen)) > 0
            THEN NEW.origen
            ELSE 'Origen no especificado'
        END
    );

    v_destino := COALESCE(
        CASE
            WHEN NEW.destino IS NOT NULL AND LENGTH(TRIM(NEW.destino)) > 0
            THEN NEW.destino
            ELSE 'Destino no especificado'
        END
    );

    -- ⬇️ FORMATEAR HORA CON TO_CHAR (tipo TIME)
    v_hora_programada := COALESCE(
        TO_CHAR(NEW.hora_programada, 'HH24:MI'),
        'Hora no especificada'
    );

    -- ⬇️ CONSTRUIR MENSAJE PROFESIONAL
    v_mensaje_profesional :=
        'Paciente: ' || v_paciente_nombre ||
        ' | ' || v_origen || ' → ' || v_destino ||
        ' | Hora: ' || v_hora_programada;

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
                'Nuevo Traslado Asignado',
                v_mensaje_profesional,
                'traslado',
                NEW.id::TEXT,
                jsonb_build_object(
                    'servicio_id', NEW.id,
                    'numero_servicio', v_numero_servicio,
                    'paciente_nombre', v_paciente_nombre,
                    'origen', v_origen,
                    'destino', v_destino,
                    'hora_programada', v_hora_programada,
                    'rol', 'conductor'
                )
            );

            RAISE NOTICE 'Notificación creada para conductor: % (usuario: %)', v_conductor_nombre, v_conductor_usuario_id;
        END IF;
    END IF;

    -- ===== NOTIFICAR AL PERSONAL SANITARIO (TES) =====
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
                'Nuevo Traslado Asignado',
                v_mensaje_profesional,
                'traslado',
                NEW.id::TEXT,
                jsonb_build_object(
                    'servicio_id', NEW.id,
                    'numero_servicio', v_numero_servicio,
                    'paciente_nombre', v_paciente_nombre,
                    'origen', v_origen,
                    'destino', v_destino,
                    'hora_programada', v_hora_programada,
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
    'Notifica automáticamente al conductor y TES cuando se les asigna un nuevo traslado (con JOIN a tabla pacientes - versión corregida)';

-- =====================================================
-- 2. FUNCIÓN CORREGIDA: Notificar desadjudicación
-- =====================================================

CREATE OR REPLACE FUNCTION notificar_traslado_desadjudicado()
RETURNS TRIGGER AS $$
DECLARE
    v_usuario_id UUID;
    v_nombre TEXT;
    v_numero_servicio TEXT;
    -- ⬇️ CAMPOS OBTENIDOS VIA JOIN
    v_paciente_nombre TEXT;
    v_origen TEXT;
    v_destino TEXT;
    v_hora_programada TEXT;
    v_mensaje_profesional TEXT;
BEGIN
    v_numero_servicio := COALESCE(OLD.codigo, 'S/N');

    -- ⬇️ OBTENER DATOS DEL PACIENTE DESDE TABLA pacientes (JOIN con OLD)
    SELECT CONCAT_WS(' ', p.nombre, p.primer_apellido, p.segundo_apellido)
    INTO v_paciente_nombre
    FROM pacientes p
    WHERE p.id = OLD.id_paciente;

    v_paciente_nombre := COALESCE(v_paciente_nombre, 'Paciente no especificado');

    v_origen := COALESCE(
        CASE
            WHEN OLD.origen IS NOT NULL AND LENGTH(TRIM(OLD.origen)) > 0
            THEN OLD.origen
            ELSE 'Origen no especificado'
        END
    );

    v_destino := COALESCE(
        CASE
            WHEN OLD.destino IS NOT NULL AND LENGTH(TRIM(OLD.destino)) > 0
            THEN OLD.destino
            ELSE 'Destino no especificado'
        END
    );

    v_hora_programada := COALESCE(
        TO_CHAR(OLD.hora_programada, 'HH24:MI'),
        'Hora no especificada'
    );

    -- ⬇️ MENSAJE PROFESIONAL PARA DESADJUDICACIÓN
    v_mensaje_profesional :=
        'Traslado desasignado | Paciente: ' || v_paciente_nombre ||
        ' | ' || v_origen || ' → ' || v_destino ||
        ' | Hora: ' || v_hora_programada;

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
                'Traslado Desasignado',
                v_mensaje_profesional,
                'traslado',
                OLD.id::TEXT,
                jsonb_build_object(
                    'servicio_id', OLD.id,
                    'numero_servicio', v_numero_servicio,
                    'paciente_nombre', v_paciente_nombre,
                    'origen', v_origen,
                    'destino', v_destino,
                    'hora_programada', v_hora_programada,
                    'rol', 'conductor'
                )
            );

            RAISE NOTICE 'Notificación de desadjudicación creada para conductor: % (usuario: %)', v_nombre, v_usuario_id;
        END IF;
    END IF;

    -- ===== PERSONAL SANITARIO DESADJUDICADO =====
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
                'Traslado Desasignado',
                v_mensaje_profesional,
                'traslado',
                OLD.id::TEXT,
                jsonb_build_object(
                    'servicio_id', OLD.id,
                    'numero_servicio', v_numero_servicio,
                    'paciente_nombre', v_paciente_nombre,
                    'origen', v_origen,
                    'destino', v_destino,
                    'hora_programada', v_hora_programada,
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
    'Notifica automáticamente al conductor o TES cuando se le desadjudica un traslado (con JOIN a tabla pacientes - versión corregida)';

-- =====================================================
-- 3. VERIFICACIÓN
-- =====================================================

-- Verificar que las funciones se actualizaron correctamente
SELECT
    routine_name,
    routine_type,
    last_altered
FROM information_schema.routines
WHERE routine_name IN (
    'notificar_traslado_asignado',
    'notificar_traslado_desadjudicado'
)
ORDER BY routine_name;

-- Verificar triggers existentes
SELECT
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE event_object_table = 'traslados'
  AND trigger_name LIKE '%notificar%'
ORDER BY trigger_name;

-- =====================================================
-- 4. ESTRUCTURA DE DATOS VERIFICADA
-- =====================================================

-- Tabla traslados:
-- - id (UUID)
-- - codigo (VARCHAR) - Código del servicio
-- - id_paciente (UUID) - FK a tabla pacientes
-- - origen (TEXT) - Dirección de origen
-- - destino (TEXT) - Dirección de destino
-- - hora_programada (TIME) - Hora del traslado
-- - id_conductor (UUID) - FK a tpersonal
-- - personal_asignado (ARRAY UUID) - Array de IDs de personal sanitario

-- Tabla pacientes:
-- - id (UUID)
-- - nombre (VARCHAR)
-- - primer_apellido (VARCHAR)
-- - segundo_apellido (VARCHAR)

-- =====================================================
-- 5. RESULTADO ESPERADO
-- =====================================================

-- Notificación de asignación:
-- Título: "Nuevo Traslado Asignado"
-- Mensaje: "Paciente: JUAN GARCÍA LÓPEZ | Hospital Central → Domicilio Calle Mayor 123 | Hora: 09:30"

-- Notificación de desasignación:
-- Título: "Traslado Desasignado"
-- Mensaje: "Traslado desasignado | Paciente: JUAN GARCÍA LÓPEZ | Hospital Central → Domicilio Calle Mayor 123 | Hora: 09:30"

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Triggers de notificaciones CORREGIDOS y actualizados';
    RAISE NOTICE '📱 Los mensajes ahora usan JOIN con tabla pacientes';
    RAISE NOTICE '💡 Formato: "Paciente: [NOMBRE] | [ORIGEN] → [DESTINO] | Hora: [HH:MM]"';
    RAISE NOTICE '🔧 Problema resuelto: campo paciente_nombre no existe en traslados';
END $$;
