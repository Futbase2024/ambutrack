-- ==============================================================================
-- AMBUTRACK WEB - Sistema de Alertas de Caducidades
-- Archivo: 021_create_alertas_caducidad_tracking.sql
-- Descripción: Creación de tabla para tracking de alertas vistas por usuario
-- Fecha: 2025-02-15
-- Author: AmbuTrack Development Team
-- ==============================================================================

-- ==============================================================================
-- FUNCIÓN AUXILIAR: Actualizar updated_at automáticamente
-- ==============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column_alertas()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- TABLA: ambutrack_alertas_caducidad_vistas
-- Tracking de alertas que el usuario ya ha visto (para no repetir)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.ambutrack_alertas_caducidad_vistas (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Referencia al usuario
    usuario_id UUID NOT NULL,

    -- Identificación de la alerta
    tipo_alerta TEXT NOT NULL CHECK (tipo_alerta IN ('seguro', 'itv', 'homologacion', 'mantenimiento')),
    entidad_id UUID NOT NULL,

    -- Control de visualización (una vez por día)
    fecha_visualizacion DATE NOT NULL DEFAULT CURRENT_DATE,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraint único para evitar duplicados
    CONSTRAINT unique_alerta_vista
        UNIQUE (usuario_id, tipo_alerta, entidad_id, fecha_visualizacion)
);

-- ==============================================================================
-- ÍNDICES
-- ==============================================================================

-- Índice para búsquedas por usuario y fecha
CREATE INDEX idx_alertas_vistas_usuario_fecha
    ON public.ambutrack_alertas_caducidad_vistas(usuario_id, fecha_visualizacion);

-- Índice para búsquedas por entidad
CREATE INDEX idx_alertas_vistas_entidad
    ON public.ambutrack_alertas_caducidad_vistas(entidad_id);

-- Índice para limpieza de registros antiguos
CREATE INDEX idx_alertas_vistas_created_at
    ON public.ambutrack_alertas_caducidad_vistas(created_at);

-- ==============================================================================
-- COMENTARIOS
-- ==============================================================================

COMMENT ON TABLE public.ambutrack_alertas_caducidad_vistas IS
    'Tracking de alertas de caducidad vistas por cada usuario. Evita mostrar la misma alerta más de una vez por día.';

COMMENT ON COLUMN public.ambutrack_alertas_caducidad_vistas.usuario_id IS
    'ID del usuario que visualizó la alerta (referencia a auth.users)';

COMMENT ON COLUMN public.ambutrack_alertas_caducidad_vistas.tipo_alerta IS
    'Tipo de alerta: seguro, itv, homologacion, mantenimiento';

COMMENT ON COLUMN public.ambutrack_alertas_caducidad_vistas.entidad_id IS
    'ID de la entidad asociada (vehículo, documento, mantenimiento, etc.)';

COMMENT ON COLUMN public.ambutrack_alertas_caducidad_vistas.fecha_visualizacion IS
    'Fecha en que se visualizó la alerta (una vez por día por alerta)';

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ==============================================================================

ALTER TABLE public.ambutrack_alertas_caducidad_vistas ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios pueden ver sus propias alertas vistas
CREATE POLICY "Usuarios pueden ver sus propias alertas vistas"
    ON public.ambutrack_alertas_caducidad_vistas
    FOR SELECT
    TO authenticated
    USING (auth.uid() = usuario_id);

-- Política: Los usuarios pueden insertar sus propias alertas vistas
CREATE POLICY "Usuarios pueden insertar sus propias alertas vistas"
    ON public.ambutrack_alertas_caducidad_vistas
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = usuario_id);

-- Política: Los admins pueden ver todas las alertas vistas
CREATE POLICY "Admins pueden ver todas las alertas vistas"
    ON public.ambutrack_alertas_caducidad_vistas
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.tusuarios
            WHERE id = auth.uid()
            AND rol IN ('admin', 'jefe_mantenimiento', 'gestor_flota')
        )
    );

-- ==============================================================================
-- FUNCIONES AUXILIARES
-- ==============================================================================

-- Función: Marcar una alerta como vista
CREATE OR REPLACE FUNCTION marcar_alerta_vista(
    p_usuario_id UUID,
    p_tipo_alerta TEXT,
    p_entidad_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
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
    DO NOTHING; -- Si ya existe, no hacer nada

    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error al marcar alerta como vista: %', SQLERRM;
        RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función: Verificar si una alerta ya fue vista hoy
CREATE OR REPLACE FUNCTION alerta_fue_vista_hoy(
    p_usuario_id UUID,
    p_tipo_alerta TEXT,
    p_entidad_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.ambutrack_alertas_caducidad_vistas
        WHERE usuario_id = p_usuario_id
          AND tipo_alerta = p_tipo_alerta
          AND entidad_id = p_entidad_id
          AND fecha_visualizacion = CURRENT_DATE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función: Limpiar alertas vistas antiguas (más de 90 días)
CREATE OR REPLACE FUNCTION limpiar_alertas_vistas_antiguas()
RETURNS INTEGER AS $$
DECLARE
    v_registros_eliminados INTEGER;
BEGIN
    DELETE FROM public.ambutrack_alertas_caducidad_vistas
    WHERE created_at < NOW() - INTERVAL '90 days';

    GET DIAGNOSTICS v_registros_eliminados = ROW_COUNT;

    RETURN v_registros_eliminados;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- VERIFICACIÓN Y TEST
-- ==============================================================================

DO $$
DECLARE
    v_tabla_existe BOOLEAN;
BEGIN
    -- Verificar que la tabla existe
    SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'ambutrack_alertas_caducidad_vistas'
    ) INTO v_tabla_existe;

    IF v_tabla_existe THEN
        RAISE NOTICE '✅ Tabla ambutrack_alertas_caducidad_vistas creada exitosamente';
    ELSE
        RAISE EXCEPTION '❌ Error: No se pudo crear la tabla ambutrack_alertas_caducidad_vistas';
    END IF;

    -- Verificar que la función marcar_alerta_vista existe
    IF EXISTS (
        SELECT FROM pg_proc
        WHERE proname = 'marcar_alerta_vista'
    ) THEN
        RAISE NOTICE '✅ Función marcar_alerta_vista creada correctamente';
    END IF;

    -- Verificar que la función alerta_fue_vista_hoy existe
    IF EXISTS (
        SELECT FROM pg_proc
        WHERE proname = 'alerta_fue_vista_hoy'
    ) THEN
        RAISE NOTICE '✅ Función alerta_fue_vista_hoy creada correctamente';
    END IF;

    -- Verificar que la función limpiar_alertas_vistas_antiguas existe
    IF EXISTS (
        SELECT FROM pg_proc
        WHERE proname = 'limpiar_alertas_vistas_antiguas'
    ) THEN
        RAISE NOTICE '✅ Función limpiar_alertas_vistas_antiguas creada correctamente';
    END IF;
END $$;

-- ==============================================================================
-- FIN DE LA MIGRACIÓN
-- ==============================================================================
-- Estado: Completo
-- Tablas creadas: 1
-- Funciones creadas: 3
-- Índices creados: 3
-- Políticas RLS: 3
-- ==============================================================================
