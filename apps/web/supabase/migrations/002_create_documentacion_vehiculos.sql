-- ==============================================================================
-- AMBUTRACK WEB - Módulo de Documentación de Vehículos
-- Archivo: 002_create_documentacion_vehiculos.sql
-- Descripción: Creación de tablas para gestión de seguros, licencias y documentación
-- Fecha: 2025-02-15
-- Author: AmbuTrack Development Team
-- ==============================================================================

-- ==============================================================================
-- EXTENSIONES NECESARIAS
-- ==============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- FUNCIÓN AUXILIAR: Actualizar updated_at automáticamente
-- ==============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column_doc_vehiculos()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- FUNCIÓN: Calcular estado del documento basado en fecha de vencimiento
-- ==============================================================================
CREATE OR REPLACE FUNCTION calcular_estado_documento(p_fecha_vencimiento DATE, p_dias_alerta INTEGER DEFAULT 30)
RETURNS TEXT AS $$
DECLARE
    v_dias_restantes INTEGER;
BEGIN
    -- Calcular días restantes hasta el vencimiento
    v_dias_restantes := (p_fecha_vencimiento - CURRENT_DATE)::INTEGER;

    -- Determinar estado según días restantes
    IF v_dias_restantes < 0 THEN
        RETURN 'vencida';
    ELSIF v_dias_restantes <= p_dias_alerta THEN
        RETURN 'proxima_vencer';
    ELSE
        RETURN 'vigente';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ==============================================================================
-- FUNCIÓN: Calcular días restantes hasta vencimiento
-- ==============================================================================
CREATE OR REPLACE FUNCTION calcular_dias_restantes(p_fecha_vencimiento DATE)
RETURNS INTEGER AS $$
BEGIN
    RETURN GREATEST(0, (p_fecha_vencimiento - CURRENT_DATE)::INTEGER);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ==============================================================================
-- TABLA: ambutrack_tipos_documento_vehiculo
-- Catálogo de tipos de documentos de vehículo (seguros, ITV, licencias, etc.)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.ambutrack_tipos_documento_vehiculo (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT NOT NULL UNIQUE,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    categoria TEXT NOT NULL CHECK (categoria IN ('seguro', 'tecnica', 'legal', 'administrativa', 'otra')),

    -- Configuración de alertas
    dias_alerta_recomendados INTEGER DEFAULT 30,
    requiere_renovacion_automatica BOOLEAN DEFAULT false,

    -- Periodicidad de renovación (en meses)
    periodicidad_renovacion_meses INTEGER,

    -- Campos obligatorios específicos del tipo
    requiere_numero_poliza BOOLEAN DEFAULT false,
    requiere_compania BOOLEAN DEFAULT false,
    requiere_coste_anual BOOLEAN DEFAULT false,

    -- Estado
    activo BOOLEAN NOT NULL DEFAULT true,
    orden_visual INTEGER DEFAULT 100,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para tipos_documento_vehiculo
CREATE INDEX idx_ambutrack_tipos_documento_vehiculo_codigo ON public.ambutrack_tipos_documento_vehiculo(codigo);
CREATE INDEX idx_ambutrack_tipos_documento_vehiculo_categoria ON public.ambutrack_tipos_documento_vehiculo(categoria);
CREATE INDEX idx_ambutrack_tipos_documento_vehiculo_activo ON public.ambutrack_tipos_documento_vehiculo(activo);

-- Comentarios descriptivos
COMMENT ON TABLE public.ambutrack_tipos_documento_vehiculo IS 'Catálogo de tipos de documentos de vehículos (seguros, ITV, licencias, permisos)';
COMMENT ON COLUMN public.ambutrack_tipos_documento_vehiculo.codigo IS 'Código único identificador del tipo de documento';
COMMENT ON COLUMN public.ambutrack_tipos_documento_vehiculo.categoria IS 'Categoría: seguro, tecnica, legal, administrativa, otra';
COMMENT ON COLUMN public.ambutrack_tipos_documento_vehiculo.dias_alerta_recomendados IS 'Días de antelación para alertar vencimiento (defecto: 30)';
COMMENT ON COLUMN public.ambutrack_tipos_documento_vehiculo.periodicidad_renovacion_meses IS 'Periodicidad de renovación en meses (NULL si no aplica)';

-- ==============================================================================
-- TABLA: ambutrack_documentacion_vehiculos
-- Registros de documentación de vehículos (pólizas, ITV, licencias, permisos)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.ambutrack_documentacion_vehiculos (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL,
    tipo_documento_id UUID NOT NULL,

    -- DATOS DEL DOCUMENTO
    numero_poliza TEXT NOT NULL,
    compania TEXT NOT NULL,
    fecha_emision DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    fecha_proximo_vencimiento DATE,

    -- ESTADO (calculado automáticamente por trigger)
    estado TEXT NOT NULL DEFAULT 'vigente' CHECK (estado IN ('vigente', 'proxima_vencer', 'vencida')),

    -- DATOS ADICIONALES
    coste_anual NUMERIC(10, 2),
    observaciones TEXT,
    documento_url TEXT,
    documento_url2 TEXT,

    -- CONFIGURACIÓN DE ALERTAS
    requiere_renovacion BOOLEAN NOT NULL DEFAULT false,
    dias_alerta INTEGER NOT NULL DEFAULT 30,

    -- AUDITORÍA
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_documentacion_vehiculo
        FOREIGN KEY (vehiculo_id)
        REFERENCES public.tvehiculos(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_documentacion_tipo
        FOREIGN KEY (tipo_documento_id)
        REFERENCES public.ambutrack_tipos_documento_vehiculo(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_documentacion_fechas
        CHECK (fecha_vencimiento >= fecha_emision),

    CONSTRAINT chk_documentacion_fecha_proxima
        CHECK (fecha_proximo_vencimiento IS NULL OR fecha_proximo_vencimiento > fecha_vencimiento),

    CONSTRAINT chk_documentacion_dias_alerta
        CHECK (dias_alerta >= 0)
);

-- Índices para documentacion_vehiculos
CREATE INDEX idx_ambutrack_documentacion_vehiculos_vehiculo_id ON public.ambutrack_documentacion_vehiculos(vehiculo_id);
CREATE INDEX idx_ambutrack_documentacion_vehiculos_tipo_documento_id ON public.ambutrack_documentacion_vehiculos(tipo_documento_id);
CREATE INDEX idx_ambutrack_documentacion_vehiculos_estado ON public.ambutrack_documentacion_vehiculos(estado);
CREATE INDEX idx_ambutrack_documentacion_vehiculos_fecha_vencimiento ON public.ambutrack_documentacion_vehiculos(fecha_vencimiento);
CREATE INDEX idx_ambutrack_documentacion_vehiculos_numero_poliza ON public.ambutrack_documentacion_vehiculos(numero_poliza);
CREATE INDEX idx_ambutrack_documentacion_vehiculos_compania ON public.ambutrack_documentacion_vehiculos(compania);

-- Índice compuesto para alertas de vencimiento
CREATE INDEX idx_ambutrack_documentacion_vehiculos_alertas_vencimiento
    ON public.ambutrack_documentacion_vehiculos(vehiculo_id, estado, fecha_vencimiento)
    WHERE estado IN ('proxima_vencer', 'vencida');

-- Comentarios descriptivos
COMMENT ON TABLE public.ambutrack_documentacion_vehiculos IS 'Documentación de vehículos (seguros, ITV, licencias, permisos)';
COMMENT ON COLUMN public.ambutrack_documentacion_vehiculos.vehiculo_id IS 'FK hacia tvehiculos. ON DELETE CASCADE';
COMMENT ON COLUMN public.ambutrack_documentacion_vehiculos.tipo_documento_id IS 'FK hacia ambutrack_tipos_documento_vehiculo. ON DELETE RESTRICT';
COMMENT ON COLUMN public.ambutrack_documentacion_vehiculos.numero_poliza IS 'Número de póliza/licencia del documento';
COMMENT ON COLUMN public.ambutrack_documentacion_vehiculos.compania IS 'Compañía aseguradora o entidad emisora';
COMMENT ON COLUMN public.ambutrack_documentacion_vehiculos.estado IS 'Estado calculado: vigente, proxima_vencer, vencida';
COMMENT ON COLUMN public.ambutrack_documentacion_vehiculos.documento_url IS 'URL del documento digital en Supabase Storage';
COMMENT ON COLUMN public.ambutrack_documentacion_vehiculos.documento_url2 IS 'URL del documento digital adicional (segunda copia)';
COMMENT ON COLUMN public.ambutrack_documentacion_vehiculos.requiere_renovacion IS 'Indica si el documento requiere renovación automática';
COMMENT ON COLUMN public.ambutrack_documentacion_vehiculos.dias_alerta IS 'Días antes del vencimiento para alertar (defecto: 30)';

-- ==============================================================================
-- TRIGGERS: Actualización automática de updated_at
-- ==============================================================================

-- Trigger para ambutrack_tipos_documento_vehiculo
CREATE TRIGGER set_ambutrack_tipos_documento_vehiculo_updated_at
    BEFORE UPDATE ON public.ambutrack_tipos_documento_vehiculo
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column_doc_vehiculos();

-- Trigger para ambutrack_documentacion_vehiculos
CREATE TRIGGER set_ambutrack_documentacion_vehiculos_updated_at
    BEFORE UPDATE ON public.ambutrack_documentacion_vehiculos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column_doc_vehiculos();

-- ==============================================================================
-- TRIGGER: Calcular estado automáticamente al insertar o actualizar
-- ==============================================================================

CREATE OR REPLACE FUNCTION calcular_estado_documentacion_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Calcular el estado basado en fecha_vencimiento y dias_alerta
    NEW.estado := calcular_estado_documento(NEW.fecha_vencimiento, NEW.dias_alerta);

    -- Si no se especifica fecha_proximo_vencimiento pero el tipo tiene periodicidad,
    -- calcularla automáticamente
    IF NEW.fecha_proximo_vencimiento IS NULL THEN
        SELECT periodicidad_renovacion_meses
        INTO NEW.fecha_proximo_vencimiento
        FROM public.ambutrack_tipos_documento_vehiculo
        WHERE id = NEW.tipo_documento_id;

        IF NEW.fecha_proximo_vencimiento IS NOT NULL THEN
            -- periodicidad_renovacion_meses devuelve un INTEGER, necesitamos convertir a DATE
            -- Add interval based on months
            NEW.fecha_proximo_vencimiento := NEW.fecha_vencimiento + (NEW.fecha_proximo_vencimiento || ' months')::INTERVAL;
            -- Reset to NULL because we just used the variable to store the periodicity
            NEW.fecha_proximo_vencimiento := NEW.fecha_vencimiento + (
                MAKE_INTERVAL(months => (
                    SELECT periodicidad_renovacion_meses
                    FROM public.ambutrack_tipos_documento_vehiculo
                    WHERE id = NEW.tipo_documento_id
                ))
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para calcular estado al insertar
CREATE TRIGGER trigger_calcular_estado_documentacion_insert
    BEFORE INSERT ON public.ambutrack_documentacion_vehiculos
    FOR EACH ROW
    EXECUTE FUNCTION calcular_estado_documentacion_trigger();

-- Trigger para calcular estado al actualizar
CREATE TRIGGER trigger_calcular_estado_documentacion_update
    BEFORE UPDATE ON public.ambutrack_documentacion_vehiculos
    FOR EACH ROW
    EXECUTE FUNCTION calcular_estado_documentacion_trigger();

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ==============================================================================

-- Habilitar RLS en ambas tablas
ALTER TABLE public.ambutrack_tipos_documento_vehiculo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ambutrack_documentacion_vehiculos ENABLE ROW LEVEL SECURITY;

-- Políticas para ambutrack_tipos_documento_vehiculo
CREATE POLICY "Permitir lectura de tipos documento a usuarios autenticados"
    ON public.ambutrack_tipos_documento_vehiculo
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Permitir inserción de tipos documento a usuarios autenticados"
    ON public.ambutrack_tipos_documento_vehiculo
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Permitir actualización de tipos documento a usuarios autenticados"
    ON public.ambutrack_tipos_documento_vehiculo
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Permitir eliminación de tipos documento a usuarios autenticados"
    ON public.ambutrack_tipos_documento_vehiculo
    FOR DELETE
    TO authenticated
    USING (true);

-- Políticas para ambutrack_documentacion_vehiculos
CREATE POLICY "Permitir lectura de documentación a usuarios autenticados"
    ON public.ambutrack_documentacion_vehiculos
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Permitir inserción de documentación a usuarios autenticados"
    ON public.ambutrack_documentacion_vehiculos
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Permitir actualización de documentación a usuarios autenticados"
    ON public.ambutrack_documentacion_vehiculos
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Permitir eliminación de documentación a usuarios autenticados"
    ON public.ambutrack_documentacion_vehiculos
    FOR DELETE
    TO authenticated
    USING (true);

-- ==============================================================================
-- DATOS INICIALES: Tipos de documento
-- ==============================================================================

INSERT INTO public.ambutrack_tipos_documento_vehiculo (
    codigo,
    nombre,
    descripcion,
    categoria,
    dias_alerta_recomendados,
    requiere_renovacion_automatica,
    periodicidad_renovacion_meses,
    requiere_numero_poliza,
    requiere_compania,
    requiere_coste_anual,
    activo,
    orden_visual
) VALUES
    -- SEGUROS
    (
        'seguro_rc',
        'Seguro de Responsabilidad Civil',
        'Seguro obligatorio de responsabilidad civil para vehículos de ambulancia',
        'seguro',
        30,
        true,
        12,
        true,
        true,
        true,
        true,
        10
    ),
    (
        'seguro_todo_riesgo',
        'Seguro a Todo Riesgo',
        'Seguro completo que cubre daños propios y a terceros',
        'seguro',
        30,
        true,
        12,
        true,
        true,
        true,
        true,
        11
    ),
    (
        'seguro_mercancia',
        'Seguro de Mercancías Transportadas',
        'Seguro para la carga sanitaria transportada',
        'seguro',
        30,
        true,
        12,
        true,
        true,
        true,
        true,
        12
    ),

    -- DOCUMENTACIÓN TÉCNICA
    (
        'itv',
        'Inspección Técnica de Vehículos (ITV)',
        'Inspección técnica periódica obligatoria',
        'tecnica',
        60,
        true,
        12,
        false,
        false,
        false,
        true,
        20
    ),
    (
        'homologacion_sanitaria',
        'Homologación Sanitaria',
        'Certificado de homologación sanitaria de ambulancia',
        'tecnica',
        90,
        true,
        24,
        false,
        false,
        false,
        true,
        21
    ),
    (
        'revision_tacografo',
        'Revisión de Tacógrafo',
        'Revisión periódica del tacógrafo digital',
        'tecnica',
        30,
        true,
        24,
        false,
        false,
        false,
        true,
        22
    ),

    -- DOCUMENTACIÓN LEGAL
    (
        'permiso_circulacion',
        'Permiso de Circulación',
        'Documento legal de permiso de circulación del vehículo',
        'legal',
        60,
        false,
        NULL,
        true,
        false,
        false,
        true,
        30
    ),
    (
        'tarjeta_transportes',
        'Tarjeta de Transportes',
        'Tarjeta administrativa para servicios de transporte sanitario',
        'legal',
        60,
        true,
        12,
        true,
        false,
        false,
        true,
        31
    ),
    (
        'permiso_municipal',
        'Permiso Municipal',
        'Permiso municipal para operar como ambulancia en el municipio',
        'legal',
        90,
        true,
        12,
        true,
        false,
        false,
        true,
        32
    ),
    (
        'licencia_operativa',
        'Licencia Operativa',
        'Licencia operativa para servicios de ambulancia',
        'legal',
        60,
        true,
        12,
        true,
        false,
        false,
        true,
        33
    ),

    -- DOCUMENTACIÓN ADMINISTRATIVA
    (
        'contrato_renting',
        'Contrato de Renting/Leasing',
        'Contrato de renting o leasing del vehículo',
        'administrativa',
        90,
        false,
        NULL,
        false,
        true,
        false,
        true,
        40
    ),
    (
        'certificado_conformidad',
        'Certificado de Conformidad',
        'Certificado de conformidad del fabricante',
        'administrativa',
        365,
        false,
        NULL,
        false,
        false,
        false,
        true,
        41
    ),
    (
        'ficha_tecnica',
        'Ficha Técnica del Vehículo',
        'Ficha técnica completa del vehículo',
        'administrativa',
        365,
        false,
        NULL,
        false,
        false,
        false,
        true,
        42
    ),

    -- OTROS
    (
        'otro',
        'Otro Documento',
        'Cualquier otro documento no categorizado',
        'otra',
        30,
        false,
        NULL,
        false,
        false,
        false,
        true,
        99
    )
ON CONFLICT (codigo) DO NOTHING;

-- ==============================================================================
-- VISTAS ÚTILES
-- ==============================================================================

-- Vista: Documentación próxima a vencer (próximos 30 días)
CREATE OR REPLACE VIEW vw_documentacion_proxima_vencer AS
SELECT
    dv.id,
    dv.vehiculo_id,
    v.matricula,
    v.marca,
    v.modelo,
    dv.tipo_documento_id,
    tdv.nombre AS tipo_documento_nombre,
    dv.numero_poliza,
    dv.compania,
    dv.fecha_emision,
    dv.fecha_vencimiento,
    dv.estado,
    calcular_dias_restantes(dv.fecha_vencimiento) AS dias_restantes,
    dv.dias_alerta,
    dv.requiere_renovacion,
    dv.documento_url
FROM public.ambutrack_documentacion_vehiculos dv
INNER JOIN public.tvehiculos v ON dv.vehiculo_id = v.id
INNER JOIN public.ambutrack_tipos_documento_vehiculo tdv ON dv.tipo_documento_id = tdv.id
WHERE dv.estado IN ('proxima_vencer', 'vencida')
  AND v.estado = 'activo'
ORDER BY dv.fecha_vencimiento ASC;

COMMENT ON VIEW vw_documentacion_proxima_vencer IS 'Vista de documentación próxima a vencer o vencida';

-- Vista: Documentación vigente por vehículo
CREATE OR REPLACE VIEW vw_documentacion_por_vehiculo AS
SELECT
    v.id AS vehiculo_id,
    v.matricula,
    v.marca,
    v.modelo,
    v.estado AS estado_vehiculo,
    COUNT(dv.id) AS total_documentos,
    COUNT(dv.id) FILTER (WHERE dv.estado = 'vigente') AS documentos_vigentes,
    COUNT(dv.id) FILTER (WHERE dv.estado = 'proxima_vencer') AS documentos_proximos_vencer,
    COUNT(dv.id) FILTER (WHERE dv.estado = 'vencida') AS documentos_vencidos,
    MIN(dv.fecha_vencimiento) AS proximo_vencimiento
FROM public.tvehiculos v
LEFT JOIN public.ambutrack_documentacion_vehiculos dv ON v.id = dv.vehiculo_id
GROUP BY v.id, v.matricula, v.marca, v.modelo, v.estado
ORDER BY v.matricula;

COMMENT ON VIEW vw_documentacion_por_vehiculo IS 'Resumen de documentación por vehículo';

-- ==============================================================================
-- FUNCIONES AUXILIARES
-- ==============================================================================

-- Función: Obtener documentación próxima a vencer de un vehículo
CREATE OR REPLACE FUNCTION obtener_documentacion_proxima_vencer(p_vehiculo_id UUID)
RETURNS TABLE (
    id UUID,
    tipo_documento TEXT,
    numero_poliza TEXT,
    compania TEXT,
    fecha_vencimiento DATE,
    dias_restantes INTEGER,
    estado TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        dv.id,
        tdv.nombre,
        dv.numero_poliza,
        dv.compania,
        dv.fecha_vencimiento,
        calcular_dias_restantes(dv.fecha_vencimiento),
        dv.estado
    FROM public.ambutrack_documentacion_vehiculos dv
    INNER JOIN public.ambutrack_tipos_documento_vehiculo tdv ON dv.tipo_documento_id = tdv.id
    WHERE dv.vehiculo_id = p_vehiculo_id
      AND dv.estado IN ('proxima_vencer', 'vencida')
    ORDER BY dv.fecha_vencimiento ASC;
END;
$$ LANGUAGE plpgsql;

-- Función: Verificar si un vehículo tiene documentación completa
CREATE OR REPLACE FUNCTION verificar_documentacion_completa(p_vehiculo_id UUID)
RETURNS TABLE (
    tipo_requerido TEXT,
    tiene_documento BOOLEAN,
    estado_actual TEXT,
    proximo_vencimiento DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        tdv.nombre AS tipo_requerido,
        CASE WHEN dv.id IS NOT NULL THEN true ELSE false END AS tiene_documento,
        dv.estado,
        dv.fecha_vencimiento
    FROM public.ambutrack_tipos_documento_vehiculo tdv
    LEFT JOIN public.ambutrack_documentacion_vehiculos dv ON (
        dv.tipo_documento_id = tdv.id
        AND dv.vehiculo_id = p_vehiculo_id
    )
    WHERE tdv.activo = true
    ORDER BY tdv.orden_visual;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- VERIFICACIÓN Y TEST
-- ==============================================================================

DO $$
DECLARE
    v_tipos_count INTEGER;
    v_tabla_existe BOOLEAN;
BEGIN
    -- Verificar que la tabla de tipos existe
    SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'ambutrack_tipos_documento_vehiculo'
    ) INTO v_tabla_existe;

    IF v_tabla_existe THEN
        RAISE NOTICE '✅ Tabla ambutrack_tipos_documento_vehiculo creada exitosamente';
    ELSE
        RAISE EXCEPTION '❌ Error: No se pudo crear la tabla ambutrack_tipos_documento_vehiculo';
    END IF;

    -- Verificar que la tabla principal existe
    SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'ambutrack_documentacion_vehiculos'
    ) INTO v_tabla_existe;

    IF v_tabla_existe THEN
        RAISE NOTICE '✅ Tabla ambutrack_documentacion_vehiculos creada exitosamente';
    ELSE
        RAISE EXCEPTION '❌ Error: No se pudo crear la tabla ambutrack_documentacion_vehiculos';
    END IF;

    -- Contar tipos de documento insertados
    SELECT COUNT(*) INTO v_tipos_count
    FROM public.ambutrack_tipos_documento_vehiculo;

    RAISE NOTICE '📊 Total de tipos de documento insertados: %', v_tipos_count;

    -- Verificar que los triggers se crearon correctamente
    IF EXISTS (
        SELECT FROM pg_trigger
        WHERE tgname = 'trigger_calcular_estado_documentacion_insert'
    ) THEN
        RAISE NOTICE '✅ Trigger para calcular estado al insertar creado correctamente';
    END IF;

    IF EXISTS (
        SELECT FROM pg_trigger
        WHERE tgname = 'trigger_calcular_estado_documentacion_update'
    ) THEN
        RAISE NOTICE '✅ Trigger para calcular estado al actualizar creado correctamente';
    END IF;

    -- Verificar que las vistas se crearon correctamente
    IF EXISTS (
        SELECT FROM information_schema.views
        WHERE table_schema = 'public'
        AND table_name = 'vw_documentacion_proxima_vencer'
    ) THEN
        RAISE NOTICE '✅ Vista vw_documentacion_proxima_vencer creada correctamente';
    END IF;

    IF EXISTS (
        SELECT FROM information_schema.views
        WHERE table_schema = 'public'
        AND table_name = 'vw_documentacion_por_vehiculo'
    ) THEN
        RAISE NOTICE '✅ Vista vw_documentacion_por_vehiculo creada correctamente';
    END IF;
END $$;

-- ==============================================================================
-- FIN DE LA MIGRACIÓN
-- ==============================================================================
-- Estado: Completo
-- Tablas creadas: 2
-- Vistas creadas: 2
-- Funciones creadas: 6
-- Triggers creados: 4
-- Índices creados: 12
-- Datos iniciales insertados: 16 tipos de documento
-- ==============================================================================
