-- ==============================================================================
-- AMBUTRACK WEB - Sistema de Alertas de Caducidades
-- Archivo: 022_create_alertas_umbrales_config.sql
-- Descripción: Creación de tabla para configuración personalizada de umbrales
-- Fecha: 2025-02-15
-- Author: AmbuTrack Development Team
-- ==============================================================================

-- ==============================================================================
-- TABLA: ambutrack_alertas_umbrales_config
-- Configuración personalizada de umbrales de alerta por usuario
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.ambutrack_alertas_umbrales_config (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID UNIQUE NOT NULL,

    -- UMBRALES DE ALERTA (en días)
    umbral_seguro INTEGER NOT NULL DEFAULT 30 CHECK (umbral_seguro > 0),
    umbral_itv INTEGER NOT NULL DEFAULT 60 CHECK (umbral_itv > 0),
    umbral_homologacion INTEGER NOT NULL DEFAULT 90 CHECK (umbral_homologacion > 0),
    umbral_mantenimiento INTEGER NOT NULL DEFAULT 7 CHECK (umbral_mantenimiento > 0),

    -- PREFERENCIAS DE VISUALIZACIÓN
    mostrar_dialogo_inicio BOOLEAN NOT NULL DEFAULT true,
    mostrar_badge_appbar BOOLEAN NOT NULL DEFAULT true,
    mostrar_card_dashboard BOOLEAN NOT NULL DEFAULT true,

    -- CONFIGURACIÓN ADICIONAL
    umbral_critico_global INTEGER NOT NULL DEFAULT 7 CHECK (umbral_critico_global > 0),

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT fk_usuario_config
        FOREIGN KEY (usuario_id)
        REFERENCES public.tusuarios(id)
        ON DELETE CASCADE
);

-- ==============================================================================
-- ÍNDICES
-- ==============================================================================

-- Índice único ya existe por UNIQUE constraint
CREATE INDEX idx_alertas_umbrales_usuario
    ON public.ambutrack_alertas_umbrales_config(usuario_id);

-- ==============================================================================
-- COMENTARIOS
-- ==============================================================================

COMMENT ON TABLE public.ambutrack_alertas_umbrales_config IS
    'Configuración personalizada de umbrales de alerta por usuario. Si un usuario no tiene configuración, se usan los valores por defecto.';

COMMENT ON COLUMN public.ambutrack_alertas_umbrales_config.usuario_id IS
    'ID del usuario (referencia a tusuarios). UNIQUE: un solo registro por usuario';

COMMENT ON COLUMN public.ambutrack_alertas_umbrales_config.umbral_seguro IS
    'Días de antelación para alertar sobre vencimiento de seguros (defecto: 30)';

COMMENT ON COLUMN public.ambutrack_alertas_umbrales_config.umbral_itv IS
    'Días de antelación para alertar sobre vencimiento de ITV (defecto: 60)';

COMMENT ON COLUMN public.ambutrack_alertas_umbrales_config.umbral_homologacion IS
    'Días de antelación para alertar sobre vencimiento de homologación sanitaria (defecto: 90)';

COMMENT ON COLUMN public.ambutrack_alertas_umbrales_config.umbral_mantenimiento IS
    'Días de antelación para alertar sobre mantenimientos pendientes (defecto: 7)';

COMMENT ON COLUMN public.ambutrack_alertas_umbrales_config.mostrar_dialogo_inicio IS
    'Mostrar diálogo de alertas críticas al iniciar sesión (defecto: true)';

COMMENT ON COLUMN public.ambutrack_alertas_umbrales_config.mostrar_badge_appbar IS
    'Mostrar badge con contador de alertas en el AppBar (defecto: true)';

COMMENT ON COLUMN public.ambutrack_alertas_umbrales_config.mostrar_card_dashboard IS
    'Mostrar card con resumen de alertas en el Dashboard (defecto: true)';

COMMENT ON COLUMN public.ambutrack_alertas_umbrales_config.umbral_critico_global IS
    'Días restantes para considerar una alerta como crítica (defecto: 7)';

-- ==============================================================================
-- TRIGGERS
-- ==============================================================================

-- Trigger para actualizar updated_at automáticamente
CREATE TRIGGER trigger_alertas_umbrales_updated_at
    BEFORE UPDATE ON public.ambutrack_alertas_umbrales_config
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column_alertas();

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ==============================================================================

ALTER TABLE public.ambutrack_alertas_umbrales_config ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios pueden ver su propia configuración
CREATE POLICY "Usuarios pueden ver su configuración"
    ON public.ambutrack_alertas_umbrales_config
    FOR SELECT
    TO authenticated
    USING (auth.uid() = usuario_id);

-- Política: Los usuarios pueden insertar su configuración
CREATE POLICY "Usuarios pueden insertar su configuración"
    ON public.ambutrack_alertas_umbrales_config
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = usuario_id);

-- Política: Los usuarios pueden actualizar su configuración
CREATE POLICY "Usuarios pueden actualizar su configuración"
    ON public.ambutrack_alertas_umbrales_config
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = usuario_id)
    WITH CHECK (auth.uid() = usuario_id);

-- ==============================================================================
-- FUNCIONES AUXILIARES
-- ==============================================================================

-- Función: Obtener configuración de umbrales de un usuario (con defaults)
CREATE OR REPLACE FUNCTION obtener_umbrales_usuario(p_usuario_id UUID)
RETURNS TABLE (
    umbral_seguro INTEGER,
    umbral_itv INTEGER,
    umbral_homologacion INTEGER,
    umbral_mantenimiento INTEGER,
    umbral_critico_global INTEGER,
    mostrar_dialogo_inicio BOOLEAN,
    mostrar_badge_appbar BOOLEAN,
    mostrar_card_dashboard BOOLEAN
) AS $$
BEGIN
    -- Si el usuario tiene configuración personalizada, usarla
    IF EXISTS (SELECT 1 FROM public.ambutrack_alertas_umbrales_config WHERE usuario_id = p_usuario_id) THEN
        RETURN QUERY
        SELECT
            umbral_seguro,
            umbral_itv,
            umbral_homologacion,
            umbral_mantenimiento,
            umbral_critico_global,
            mostrar_dialogo_inicio,
            mostrar_badge_appbar,
            mostrar_card_dashboard
        FROM public.ambutrack_alertas_umbrales_config
        WHERE usuario_id = p_usuario_id;
    ELSE
        -- Si no tiene configuración, usar valores por defecto
        RETURN QUERY
        SELECT
            30,  -- umbral_seguro
            60,  -- umbral_itv
            90,  -- umbral_homologacion
            7,   -- umbral_mantenimiento
            7,   -- umbral_critico_global
            true, -- mostrar_dialogo_inicio
            true, -- mostrar_badge_appbar
            true  -- mostrar_card_dashboard;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función: Actualizar o insertar configuración de umbrales
CREATE OR REPLACE FUNCTION guardar_umbrales_usuario(
    p_usuario_id UUID,
    p_umbral_seguro INTEGER DEFAULT 30,
    p_umbral_itv INTEGER DEFAULT 60,
    p_umbral_homologacion INTEGER DEFAULT 90,
    p_umbral_mantenimiento INTEGER DEFAULT 7,
    p_mostrar_dialogo_inicio BOOLEAN DEFAULT true,
    p_mostrar_badge_appbar BOOLEAN DEFAULT true,
    p_mostrar_card_dashboard BOOLEAN DEFAULT true,
    p_umbral_critico_global INTEGER DEFAULT 7
)
RETURNS BOOLEAN AS $$
BEGIN
    INSERT INTO public.ambutrack_alertas_umbrales_config (
        usuario_id,
        umbral_seguro,
        umbral_itv,
        umbral_homologacion,
        umbral_mantenimiento,
        mostrar_dialogo_inicio,
        mostrar_badge_appbar,
        mostrar_card_dashboard,
        umbral_critico_global
    ) VALUES (
        p_usuario_id,
        p_umbral_seguro,
        p_umbral_itv,
        p_umbral_homologacion,
        p_umbral_mantenimiento,
        p_mostrar_dialogo_inicio,
        p_mostrar_badge_appbar,
        p_mostrar_card_dashboard,
        p_umbral_critico_global
    )
    ON CONFLICT (usuario_id) DO UPDATE SET
        umbral_seguro = EXCLUDED.umbral_seguro,
        umbral_itv = EXCLUDED.umbral_itv,
        umbral_homologacion = EXCLUDED.umbral_homologacion,
        umbral_mantenimiento = EXCLUDED.umbral_mantenimiento,
        mostrar_dialogo_inicio = EXCLUDED.mostrar_dialogo_inicio,
        mostrar_badge_appbar = EXCLUDED.mostrar_badge_appbar,
        mostrar_card_dashboard = EXCLUDED.mostrar_card_dashboard,
        umbral_critico_global = EXCLUDED.umbral_critico_global,
        updated_at = NOW();

    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error al guardar configuración de umbrales: %', SQLERRM;
        RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función: Restablecer configuración de un usuario a valores por defecto
CREATE OR REPLACE FUNCTION resetear_umbrales_usuario(p_usuario_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM public.ambutrack_alertas_umbrales_config
    WHERE usuario_id = p_usuario_id;

    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error al resetear configuración de umbrales: %', SQLERRM;
        RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- DATOS INICIALES
-- ==============================================================================

-- No hay datos iniciales necesarios. Los usuarios usarán los valores por defecto
-- hasta que personalicen su configuración.

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
        AND table_name = 'ambutrack_alertas_umbrales_config'
    ) INTO v_tabla_existe;

    IF v_tabla_existe THEN
        RAISE NOTICE '✅ Tabla ambutrack_alertas_umbrales_config creada exitosamente';
    ELSE
        RAISE EXCEPTION '❌ Error: No se pudo crear la tabla ambutrack_alertas_umbrales_config';
    END IF;

    -- Verificar que la función obtener_umbrales_usuario existe
    IF EXISTS (
        SELECT FROM pg_proc
        WHERE proname = 'obtener_umbrales_usuario'
    ) THEN
        RAISE NOTICE '✅ Función obtener_umbrales_usuario creada correctamente';
    END IF;

    -- Verificar que la función guardar_umbrales_usuario existe
    IF EXISTS (
        SELECT FROM pg_proc
        WHERE proname = 'guardar_umbrales_usuario'
    ) THEN
        RAISE NOTICE '✅ Función guardar_umbrales_usuario creada correctamente';
    END IF;

    -- Verificar que la función resetear_umbrales_usuario existe
    IF EXISTS (
        SELECT FROM pg_proc
        WHERE proname = 'resetear_umbrales_usuario'
    ) THEN
        RAISE NOTICE '✅ Función resetear_umbrales_usuario creada correctamente';
    END IF;

    -- Test de la función obtener_umbrales_usuario con un UUID dummy
    RAISE NOTICE '🧪 Test: Obteniendo umbrales por defecto (usuario sin config)';
    PERFORM * FROM obtener_umbrales_usuario('00000000-0000-0000-0000-000000000000'::UUID);
    RAISE NOTICE '✅ Test de función obtener_umbrales_usuario completado';
END $$;

-- ==============================================================================
-- FIN DE LA MIGRACIÓN
-- ==============================================================================
-- Estado: Completo
-- Tablas creadas: 1
-- Funciones creadas: 3
-- Índices creados: 1
-- Triggers creados: 1
-- Políticas RLS: 3
-- ==============================================================================
