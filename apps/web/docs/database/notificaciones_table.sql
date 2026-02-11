-- =====================================================
-- AmbuTrack - Sistema de Notificaciones en Tiempo Real
-- =====================================================
-- Script para crear la tabla de notificaciones y configurar RLS
-- Ejecutar en: https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr/sql

-- 1. Crear tabla de notificaciones
CREATE TABLE IF NOT EXISTS tnotificaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id TEXT NOT NULL DEFAULT 'ambutrack',
    usuario_destino_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL CHECK (tipo IN (
        'vacacion_solicitada',      -- Nuevo: solicitud de vacaciones
        'vacacion_aprobada',        -- Nuevo: vacaciones aprobadas
        'vacacion_rechazada',       -- Nuevo: vacaciones rechazadas
        'ausencia_solicitada',      -- Nuevo: solicitud de ausencia
        'ausencia_aprobada',        -- Nuevo: ausencia aprobada
        'ausencia_rechazada',       -- Nuevo: ausencia rechazada
        'cambio_turno',             -- Nuevo: cambio de turno solicitado
        'alerta',                   -- Alertas críticas
        'info'                      -- Información general
    )),
    titulo TEXT NOT NULL,
    mensaje TEXT NOT NULL,
    entidad_tipo TEXT,              -- Tipo de entidad relacionada (ej: 'vacacion', 'ausencia')
    entidad_id TEXT,                -- ID de la entidad relacionada
    leida BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_lectura TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Comentarios para documentación
COMMENT ON TABLE tnotificaciones IS 'Notificaciones en tiempo real para usuarios de AmbuTrack';
COMMENT ON COLUMN tnotificaciones.usuario_destino_id IS 'ID del usuario que recibe la notificación (FK a auth.users)';
COMMENT ON COLUMN tnotificaciones.tipo IS 'Tipo de notificación que determina el icono y color';
COMMENT ON COLUMN tnotificaciones.entidad_tipo IS 'Tipo de entidad relacionada (vacacion, ausencia, etc)';
COMMENT ON COLUMN tnotificaciones.entidad_id IS 'ID de la entidad relacionada para navegación';
COMMENT ON COLUMN tnotificaciones.leida IS 'Indica si el usuario ya leyó la notificación';
COMMENT ON COLUMN tnotificaciones.metadata IS 'Datos adicionales en formato JSON';

-- 3. Crear índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_tnotificaciones_usuario_destino ON tnotificaciones(usuario_destino_id);
CREATE INDEX IF NOT EXISTS idx_tnotificaciones_leida ON tnotificaciones(leida);
CREATE INDEX IF NOT EXISTS idx_tnotificaciones_tipo ON tnotificaciones(tipo);
CREATE INDEX IF NOT EXISTS idx_tnotificaciones_created_at ON tnotificaciones(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tnotificaciones_empresa_usuario_leida ON tnotificaciones(empresa_id, usuario_destino_id, leida);

-- 4. Habilitar Row Level Security (RLS)
ALTER TABLE tnotificaciones ENABLE ROW LEVEL SECURITY;

-- 5. Políticas RLS - Seguridad por filas

-- Los usuarios pueden ver sus propias notificaciones
CREATE POLICY "Usuarios pueden ver sus notificaciones"
    ON tnotificaciones FOR SELECT
    USING (auth.uid() = usuario_destino_id);

-- Los usuarios pueden marcar sus notificaciones como leídas
CREATE POLICY "Usuarios pueden actualizar sus notificaciones"
    ON tnotificaciones FOR UPDATE
    USING (auth.uid() = usuario_destino_id)
    WITH CHECK (auth.uid() = usuario_destino_id);

-- Los administradores y jefes de personal pueden ver todas las notificaciones
CREATE POLICY "Administradores pueden ver todas las notificaciones"
    ON tnotificaciones FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM tpersonal p
            WHERE p.usuario_id = auth.uid()
            AND p.categoria IN ('admin', 'jefe_personal', 'jefe_trafico')
        )
    );

-- Los administradores y jefes de personal pueden insertar notificaciones
CREATE POLICY "Administradores pueden crear notificaciones"
    ON tnotificaciones FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM tpersonal p
            WHERE p.usuario_id = auth.uid()
            AND p.categoria IN ('admin', 'jefe_personal', 'jefe_trafico')
        )
    );

-- 6. Trigger para updated_at automático
CREATE OR REPLACE FUNCTION update_tnotificaciones_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_tnotificaciones_updated_at
    BEFORE UPDATE ON tnotificaciones
    FOR EACH ROW
    EXECUTE FUNCTION update_tnotificaciones_updated_at();

-- 7. Habilitar Realtime para la tabla (crítico para notificaciones en tiempo real)
ALTER PUBLICATION supabase_realtime ADD TABLE tnotificaciones;

-- 8. Función auxiliar para crear notificación
CREATE OR REPLACE FUNCTION crear_notificacion(
    p_usuario_destino_id UUID,
    p_tipo TEXT,
    p_titulo TEXT,
    p_mensaje TEXT,
    p_entidad_tipo TEXT DEFAULT NULL,
    p_entidad_id TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID AS $$
DECLARE
    v_notificacion_id UUID;
BEGIN
    INSERT INTO tnotificaciones (
        usuario_destino_id,
        tipo,
        titulo,
        mensaje,
        entidad_tipo,
        entidad_id,
        metadata
    )
    VALUES (
        p_usuario_destino_id,
        p_tipo,
        p_titulo,
        p_mensaje,
        p_entidad_tipo,
        p_entidad_id,
        p_metadata
    )
    RETURNING id INTO v_notificacion_id;

    RETURN v_notificacion_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Función para notificar a jefes de personal cuando se solicita vacación
CREATE OR REPLACE FUNCTION notificar_jefes_personal_vacacion(
    p_vacacion_id TEXT,
    p_personal_nombre TEXT,
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_dias INT
)
RETURNS void AS $$
DECLARE
    v_jefe RECORD;
BEGIN
    -- Buscar todos los jefes de personal y administradores
    FOR v_jefe IN
        SELECT usuario_id FROM tpersonal
        WHERE categoria IN ('admin', 'jefe_personal', 'jefe_trafico')
        AND activo = true
    LOOP
        PERFORM crear_notificacion(
            v_jefe.usuario_id,
            'vacacion_solicitada',
            'Nueva Solicitud de Vacaciones',
            p_personal_nombre || ' ha solicitado ' || p_dias || ' días de vacaciones (' ||
            TO_CHAR(p_fecha_inicio, 'DD/MM/YYYY') || ' - ' || TO_CHAR(p_fecha_fin, 'DD/MM/YYYY') || ')',
            'vacacion',
            p_vacacion_id,
            jsonb_build_object(
                'personal_nombre', p_personal_nombre,
                'fecha_inicio', p_fecha_inicio,
                'fecha_fin', p_fecha_fin,
                'dias', p_dias
            )
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Trigger automático para notificar cuando se crea una vacación pendiente
CREATE OR REPLACE FUNCTION trigger_notificar_vacacion_creada()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo notificar si la vacación está pendiente
    IF NEW.estado = 'pendiente' THEN
        -- Obtener datos del personal
        PERFORM notificar_jefes_personal_vacacion(
            NEW.id::TEXT,
            (SELECT nombre || ' ' || apellidos FROM tpersonal WHERE id = NEW.id_personal),
            NEW.fecha_inicio::DATE,
            NEW.fecha_fin::DATE,
            NEW.dias_solicitados
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notificar_vacacion_creada
    AFTER INSERT ON vacaciones
    FOR EACH ROW
    EXECUTE FUNCTION trigger_notificar_vacacion_creada();

-- 11. Función para notificar a jefes de personal cuando se solicita una ausencia
CREATE OR REPLACE FUNCTION notificar_jefes_personal_ausencia(
    p_ausencia_id TEXT,
    p_personal_nombre TEXT,
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_motivo TEXT
)
RETURNS void AS $$
DECLARE
    v_jefe RECORD;
BEGIN
    -- Buscar todos los jefes de personal y administradores
    FOR v_jefe IN
        SELECT usuario_id FROM tpersonal
        WHERE categoria IN ('admin', 'jefe_personal', 'jefe_trafico')
        AND activo = true
    LOOP
        PERFORM crear_notificacion(
            v_jefe.usuario_id,
            'ausencia_solicitada',
            'Nueva Solicitud de Ausencia',
            p_personal_nombre || ' ha solicitado una ausencia (' ||
            TO_CHAR(p_fecha_inicio, 'DD/MM/YYYY') || ' - ' || TO_CHAR(p_fecha_fin, 'DD/MM/YYYY') || ')' ||
            CASE WHEN p_motivo IS NOT NULL THEN '. Motivo: ' || p_motivo ELSE '' END,
            'ausencia',
            p_ausencia_id,
            jsonb_build_object(
                'personal_nombre', p_personal_nombre,
                'fecha_inicio', p_fecha_inicio,
                'fecha_fin', p_fecha_fin,
                'motivo', p_motivo
            )
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 12. Trigger automático para notificar cuando se crea una ausencia pendiente
CREATE OR REPLACE FUNCTION trigger_notificar_ausencia_creada()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo notificar si la ausencia está pendiente
    IF NEW.estado = 'pendiente' THEN
        -- Obtener datos del personal
        PERFORM notificar_jefes_personal_ausencia(
            NEW.id::TEXT,
            (SELECT nombre || ' ' || apellidos FROM tpersonal WHERE id = NEW.id_personal),
            NEW.fecha_inicio::DATE,
            NEW.fecha_fin::DATE,
            NEW.motivo
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notificar_ausencia_creada ON ausencias;
CREATE TRIGGER trigger_notificar_ausencia_creada
    AFTER INSERT ON ausencias
    FOR EACH ROW
    EXECUTE FUNCTION trigger_notificar_ausencia_creada();

-- =====================================================
-- VERIFICACIÓN
-- =====================================================

-- Verificar que la tabla se creó correctamente
SELECT COUNT(*) AS "Total notificaciones" FROM tnotificaciones;

-- Verificar políticas RLS
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'tnotificaciones';

-- Verificar que Realtime está habilitado
SELECT * FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'tnotificaciones';
