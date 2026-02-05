-- =====================================================
-- AMBUTRACK - MIGRACIÓN: Tablas de Vehículos
-- Archivo: 001_crear_tablas_vehiculos.sql
-- Descripción: Creación de todas las tablas relacionadas con gestión de vehículos
-- Fecha: 2025-12-15
-- =====================================================

-- =====================================================
-- EXTENSIONES NECESARIAS
-- =====================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLA PRINCIPAL: tvehiculos
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tvehiculos (
    -- SECCIÓN 1: IDENTIFICACIÓN Y DATOS BÁSICOS
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matricula TEXT NOT NULL UNIQUE,
    numero_interno TEXT,
    alias TEXT,
    tipo_vehiculo TEXT NOT NULL,
    categoria TEXT NOT NULL,
    clasificacion TEXT,

    -- SECCIÓN 2: DATOS DEL FABRICANTE
    marca TEXT NOT NULL,
    modelo TEXT NOT NULL,
    version TEXT,
    anio_fabricacion INTEGER NOT NULL,
    numero_bastidor TEXT NOT NULL UNIQUE,
    numero_motor TEXT,
    color TEXT,
    potencia_cv INTEGER,
    cilindrada INTEGER,
    tipo_combustible TEXT,
    transmision TEXT,
    traccion TEXT,

    -- SECCIÓN 3: ESTADO Y OPERATIVIDAD
    estado TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo', 'mantenimiento', 'reparacion', 'baja')),
    disponible BOOLEAN NOT NULL DEFAULT true,
    en_servicio BOOLEAN NOT NULL DEFAULT false,
    operativo BOOLEAN NOT NULL DEFAULT true,
    motivo_baja TEXT,
    fecha_baja TIMESTAMPTZ,
    prioridad_asignacion INTEGER CHECK (prioridad_asignacion BETWEEN 1 AND 5),

    -- SECCIÓN 4: CAPACIDADES Y EQUIPAMIENTO
    capacidad_pasajeros INTEGER,
    capacidad_camilla INTEGER,
    capacidad_carga_kg NUMERIC(10, 2),
    equipamiento JSONB,
    tiene_soporte_vital BOOLEAN DEFAULT false,
    tiene_desfibrilador BOOLEAN DEFAULT false,
    tiene_oxigeno BOOLEAN DEFAULT false,
    tiene_climatizacion BOOLEAN DEFAULT false,
    tiene_gps BOOLEAN DEFAULT false,
    tiene_comunicaciones BOOLEAN DEFAULT false,

    -- SECCIÓN 5: KILOMETRAJE Y CONSUMO
    km_actual NUMERIC(10, 2) NOT NULL DEFAULT 0,
    km_inicial NUMERIC(10, 2),
    km_ultimo_servicio NUMERIC(10, 2),
    km_promedio_mensual NUMERIC(10, 2),
    consumo_promedio_l100km NUMERIC(5, 2),
    capacidad_deposito NUMERIC(6, 2),

    -- SECCIÓN 6: GEOLOCALIZACIÓN
    ubicacion_actual TEXT,
    latitud NUMERIC(10, 8),
    longitud NUMERIC(11, 8),
    ultima_actualizacion_gps TIMESTAMPTZ,
    base_asignada_id UUID,
    base_asignada_nombre TEXT,
    zona_cobertura TEXT,

    -- SECCIÓN 7: FECHAS Y ADQUISICIÓN
    fecha_adquisicion DATE,
    fecha_primera_matriculacion DATE,
    fecha_puesta_servicio DATE,
    precio_adquisicion NUMERIC(12, 2),
    valor_actual_estimado NUMERIC(12, 2),
    tipo_adquisicion TEXT CHECK (tipo_adquisicion IN ('compra', 'renting', 'leasing')),
    empresa_renting TEXT,
    numero_contrato_renting TEXT,
    fecha_fin_contrato DATE,
    cuota_mensual_renting NUMERIC(10, 2),

    -- SECCIÓN 8: MANTENIMIENTO PREVENTIVO
    ultimo_mantenimiento DATE,
    proximo_mantenimiento DATE,
    km_proximo_mantenimiento INTEGER,
    intervalo_mantenimiento_km INTEGER,
    intervalo_mantenimiento_meses INTEGER,
    tipo_mantenimiento_proximo TEXT,
    taller_asignado TEXT,
    costo_mantenimiento_estimado NUMERIC(10, 2),

    -- SECCIÓN 9: ITV Y REVISIONES TÉCNICAS
    ultima_itv DATE,
    proxima_itv DATE NOT NULL,
    resultado_ultima_itv TEXT CHECK (resultado_ultima_itv IN ('favorable', 'desfavorable', 'negativa')),
    observaciones_itv TEXT,
    estacion_itv TEXT,
    ultima_revision_tacografo DATE,
    proxima_revision_tacografo DATE,

    -- SECCIÓN 10: SEGUROS Y DOCUMENTACIÓN
    compania_seguro TEXT,
    numero_poliza TEXT,
    tipo_seguro TEXT,
    fecha_inicio_seguro DATE,
    fecha_vencimiento_seguro DATE NOT NULL,
    prima_anual_seguro NUMERIC(10, 2),
    tiene_seguro_mercancia BOOLEAN DEFAULT false,
    numero_permiso_circulacion TEXT,
    tarjeta_itv TEXT,

    -- SECCIÓN 11: AVERÍAS E INCIDENCIAS
    numero_averias_total INTEGER DEFAULT 0,
    fecha_ultima_averia DATE,
    km_ultima_averia NUMERIC(10, 2),
    gravedad_ultima_averia TEXT CHECK (gravedad_ultima_averia IN ('leve', 'moderada', 'grave', 'critica')),
    costo_reparaciones_total NUMERIC(12, 2) DEFAULT 0,
    costo_reparaciones_anio_actual NUMERIC(12, 2) DEFAULT 0,

    -- SECCIÓN 12: NEUMÁTICOS
    tipo_neumaticos TEXT,
    medida_neumaticos TEXT,
    fecha_ultimo_cambio_neumaticos DATE,
    km_ultimo_cambio_neumaticos NUMERIC(10, 2),
    proveedor_neumaticos TEXT,

    -- SECCIÓN 13: TASAS E IMPUESTOS
    impuesto_circulacion_anual NUMERIC(10, 2),
    fecha_pago_impuesto DATE,
    peajes_estimados_anuales NUMERIC(10, 2),
    otros_impuestos JSONB,

    -- SECCIÓN 14: HOMOLOGACIONES Y CERTIFICACIONES
    homologacion_sanitaria TEXT NOT NULL,
    fecha_homologacion DATE,
    fecha_vencimiento_homologacion DATE NOT NULL,
    organismo_homologador TEXT,
    certificado_conformidad TEXT,
    normativa_aplicable TEXT,

    -- SECCIÓN 15: SERVICIOS Y ESTADÍSTICAS
    servicios_realizados_total INTEGER DEFAULT 0,
    servicios_mes_actual INTEGER DEFAULT 0,
    servicios_anio_actual INTEGER DEFAULT 0,
    horas_servicio_total NUMERIC(10, 2) DEFAULT 0,
    horas_servicio_mes NUMERIC(10, 2) DEFAULT 0,
    tasa_utilizacion NUMERIC(5, 2) CHECK (tasa_utilizacion BETWEEN 0 AND 100),
    km_ultimo_mes NUMERIC(10, 2),

    -- SECCIÓN 16: CONTROL Y AUDITORÍA
    empresa_id UUID NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT true,
    observaciones TEXT,
    notas_internas TEXT,
    tags TEXT[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,

    -- SECCIÓN 17: DOCUMENTOS ADJUNTOS
    foto_vehiculo_url TEXT,
    fotos_adicionales JSONB,
    documentos JSONB,
    manual_usuario_url TEXT,
    ficha_tecnica_url TEXT
);

-- Índices para tvehiculos
CREATE INDEX idx_tvehiculos_matricula ON public.tvehiculos(matricula);
CREATE INDEX idx_tvehiculos_estado ON public.tvehiculos(estado);
CREATE INDEX idx_tvehiculos_empresa_id ON public.tvehiculos(empresa_id);
CREATE INDEX idx_tvehiculos_disponible ON public.tvehiculos(disponible);
CREATE INDEX idx_tvehiculos_en_servicio ON public.tvehiculos(en_servicio);
CREATE INDEX idx_tvehiculos_tipo_vehiculo ON public.tvehiculos(tipo_vehiculo);
CREATE INDEX idx_tvehiculos_proxima_itv ON public.tvehiculos(proxima_itv);
CREATE INDEX idx_tvehiculos_fecha_vencimiento_seguro ON public.tvehiculos(fecha_vencimiento_seguro);
CREATE INDEX idx_tvehiculos_latitud_longitud ON public.tvehiculos(latitud, longitud) WHERE latitud IS NOT NULL AND longitud IS NOT NULL;

-- Comentarios en la tabla
COMMENT ON TABLE public.tvehiculos IS 'Tabla principal de vehículos de AmbuTrack';
COMMENT ON COLUMN public.tvehiculos.estado IS 'Estados: activo, mantenimiento, reparacion, baja';
COMMENT ON COLUMN public.tvehiculos.equipamiento IS 'Array JSON con equipamiento médico instalado';


-- =====================================================
-- TABLA: tmantenimientos
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tmantenimientos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES public.tvehiculos(id) ON DELETE CASCADE,

    -- Datos del mantenimiento
    fecha DATE NOT NULL,
    km_vehiculo NUMERIC(10, 2) NOT NULL,
    tipo_mantenimiento TEXT NOT NULL CHECK (tipo_mantenimiento IN ('basico', 'completo', 'especial', 'urgente')),
    descripcion TEXT NOT NULL,
    trabajos_realizados TEXT,

    -- Taller
    taller TEXT,
    mecanico_responsable TEXT,
    numero_orden TEXT,

    -- Costos
    costo_mano_obra NUMERIC(10, 2),
    costo_repuestos NUMERIC(10, 2),
    costo_total NUMERIC(10, 2) NOT NULL,

    -- Estado
    estado TEXT NOT NULL DEFAULT 'programado' CHECK (estado IN ('programado', 'en_proceso', 'completado', 'cancelado')),
    fecha_programada DATE,
    fecha_inicio TIMESTAMPTZ,
    fecha_fin TIMESTAMPTZ,
    tiempo_inoperativo_horas NUMERIC(6, 2),

    -- Próximo mantenimiento
    proximo_km_sugerido INTEGER,
    proxima_fecha_sugerida DATE,

    -- Documentos
    archivos JSONB,
    factura_url TEXT,

    -- Auditoría
    empresa_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID
);

CREATE INDEX idx_tmantenimientos_vehiculo_id ON public.tmantenimientos(vehiculo_id);
CREATE INDEX idx_tmantenimientos_fecha ON public.tmantenimientos(fecha);
CREATE INDEX idx_tmantenimientos_estado ON public.tmantenimientos(estado);
CREATE INDEX idx_tmantenimientos_empresa_id ON public.tmantenimientos(empresa_id);

COMMENT ON TABLE public.tmantenimientos IS 'Registro de mantenimientos preventivos y correctivos';


-- =====================================================
-- TABLA: taverias
-- =====================================================
CREATE TABLE IF NOT EXISTS public.taverias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES public.tvehiculos(id) ON DELETE CASCADE,

    -- Datos de la avería
    fecha_averia TIMESTAMPTZ NOT NULL,
    km_vehiculo NUMERIC(10, 2) NOT NULL,
    ubicacion_averia TEXT,
    latitud NUMERIC(10, 8),
    longitud NUMERIC(11, 8),

    -- Descripción
    titulo TEXT NOT NULL,
    descripcion TEXT NOT NULL,
    gravedad TEXT NOT NULL CHECK (gravedad IN ('leve', 'moderada', 'grave', 'critica')),
    categoria TEXT,
    sistema_afectado TEXT,

    -- Estado
    estado TEXT NOT NULL DEFAULT 'reportada' CHECK (estado IN ('reportada', 'en_diagnostico', 'en_reparacion', 'reparada', 'no_reparable')),
    requiere_grua BOOLEAN DEFAULT false,
    vehiculo_inmovilizado BOOLEAN DEFAULT false,

    -- Reparación
    taller TEXT,
    fecha_inicio_reparacion TIMESTAMPTZ,
    fecha_fin_reparacion TIMESTAMPTZ,
    tiempo_reparacion_horas NUMERIC(6, 2),
    diagnostico TEXT,
    trabajos_realizados TEXT,
    repuestos_utilizados JSONB,

    -- Costos
    costo_reparacion NUMERIC(10, 2),
    costo_grua NUMERIC(10, 2),
    costo_total NUMERIC(10, 2),
    cubierto_seguro BOOLEAN DEFAULT false,

    -- Personal
    conductor_reportante TEXT,
    mecanico_responsable TEXT,

    -- Documentos
    fotos JSONB,
    documentos JSONB,

    -- Auditoría
    empresa_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID
);

CREATE INDEX idx_taverias_vehiculo_id ON public.taverias(vehiculo_id);
CREATE INDEX idx_taverias_fecha_averia ON public.taverias(fecha_averia);
CREATE INDEX idx_taverias_gravedad ON public.taverias(gravedad);
CREATE INDEX idx_taverias_estado ON public.taverias(estado);
CREATE INDEX idx_taverias_empresa_id ON public.taverias(empresa_id);

COMMENT ON TABLE public.taverias IS 'Registro de averías e incidencias de vehículos';


-- =====================================================
-- TABLA: titv_revisiones
-- =====================================================
CREATE TABLE IF NOT EXISTS public.titv_revisiones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES public.tvehiculos(id) ON DELETE CASCADE,

    -- Datos de la inspección
    tipo TEXT NOT NULL CHECK (tipo IN ('itv', 'revision_tecnica', 'tacografo', 'homologacion')),
    fecha DATE NOT NULL,
    km_vehiculo NUMERIC(10, 2),

    -- Estación/Centro
    estacion TEXT,
    inspector TEXT,
    numero_inspeccion TEXT,

    -- Resultado
    resultado TEXT NOT NULL CHECK (resultado IN ('favorable', 'favorable_defectos_leves', 'desfavorable', 'negativa')),
    defectos_leves JSONB,
    defectos_graves JSONB,
    defectos_muy_graves JSONB,
    observaciones TEXT,

    -- Próxima inspección
    proxima_fecha DATE NOT NULL,
    intervalo_meses INTEGER,

    -- Costos
    costo NUMERIC(10, 2),

    -- Documentos
    certificado_url TEXT,
    informe_url TEXT,
    fotos JSONB,

    -- Auditoría
    empresa_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID
);

CREATE INDEX idx_titv_revisiones_vehiculo_id ON public.titv_revisiones(vehiculo_id);
CREATE INDEX idx_titv_revisiones_fecha ON public.titv_revisiones(fecha);
CREATE INDEX idx_titv_revisiones_tipo ON public.titv_revisiones(tipo);
CREATE INDEX idx_titv_revisiones_resultado ON public.titv_revisiones(resultado);
CREATE INDEX idx_titv_revisiones_proxima_fecha ON public.titv_revisiones(proxima_fecha);
CREATE INDEX idx_titv_revisiones_empresa_id ON public.titv_revisiones(empresa_id);

COMMENT ON TABLE public.titv_revisiones IS 'Registro de ITVs y revisiones técnicas';


-- =====================================================
-- TABLA: tconsumo_combustible
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tconsumo_combustible (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES public.tvehiculos(id) ON DELETE CASCADE,

    -- Datos de repostaje
    fecha TIMESTAMPTZ NOT NULL,
    km_vehiculo NUMERIC(10, 2) NOT NULL,

    -- Combustible
    tipo_combustible TEXT NOT NULL,
    litros NUMERIC(8, 2) NOT NULL,
    precio_litro NUMERIC(6, 3),
    costo_total NUMERIC(10, 2) NOT NULL,

    -- Estación
    estacion TEXT,
    ubicacion TEXT,

    -- Cálculos
    km_recorridos_desde_ultimo NUMERIC(10, 2),
    consumo_l100km NUMERIC(5, 2),

    -- Tarjeta/Pago
    metodo_pago TEXT,
    numero_tarjeta_combustible TEXT,
    numero_ticket TEXT,

    -- Conductor
    conductor_id UUID,
    conductor_nombre TEXT,

    -- Documentos
    ticket_url TEXT,

    -- Auditoría
    empresa_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID
);

CREATE INDEX idx_tconsumo_combustible_vehiculo_id ON public.tconsumo_combustible(vehiculo_id);
CREATE INDEX idx_tconsumo_combustible_fecha ON public.tconsumo_combustible(fecha);
CREATE INDEX idx_tconsumo_combustible_empresa_id ON public.tconsumo_combustible(empresa_id);

COMMENT ON TABLE public.tconsumo_combustible IS 'Registro de consumo y repostajes de combustible';


-- =====================================================
-- TABLA: tequipamiento_vehiculo
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tequipamiento_vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES public.tvehiculos(id) ON DELETE CASCADE,

    -- Equipo
    nombre_equipo TEXT NOT NULL,
    tipo_equipo TEXT,
    marca TEXT,
    modelo TEXT,
    numero_serie TEXT,

    -- Cantidad y estado
    cantidad INTEGER NOT NULL DEFAULT 1,
    estado TEXT NOT NULL DEFAULT 'operativo' CHECK (estado IN ('operativo', 'mantenimiento', 'averiado', 'baja')),

    -- Fechas
    fecha_instalacion DATE,
    fecha_fabricacion DATE,
    fecha_caducidad DATE,
    fecha_ultima_revision DATE,
    proxima_revision DATE,

    -- Ubicación en vehículo
    ubicacion_vehiculo TEXT,
    es_fijo BOOLEAN DEFAULT true,
    es_desechable BOOLEAN DEFAULT false,

    -- Certificaciones
    certificaciones JSONB,
    normativa_aplicable TEXT,

    -- Observaciones
    observaciones TEXT,

    -- Auditoría
    empresa_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID
);

CREATE INDEX idx_tequipamiento_vehiculo_vehiculo_id ON public.tequipamiento_vehiculo(vehiculo_id);
CREATE INDEX idx_tequipamiento_vehiculo_estado ON public.tequipamiento_vehiculo(estado);
CREATE INDEX idx_tequipamiento_vehiculo_fecha_caducidad ON public.tequipamiento_vehiculo(fecha_caducidad);
CREATE INDEX idx_tequipamiento_vehiculo_empresa_id ON public.tequipamiento_vehiculo(empresa_id);

COMMENT ON TABLE public.tequipamiento_vehiculo IS 'Inventario de equipamiento médico de vehículos';


-- =====================================================
-- TABLA: thistorial_ubicaciones
-- =====================================================
CREATE TABLE IF NOT EXISTS public.thistorial_ubicaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES public.tvehiculos(id) ON DELETE CASCADE,

    -- Ubicación
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    latitud NUMERIC(10, 8) NOT NULL,
    longitud NUMERIC(11, 8) NOT NULL,
    altitud NUMERIC(8, 2),
    precision_metros NUMERIC(6, 2),

    -- Movimiento
    velocidad_kmh NUMERIC(6, 2),
    direccion_grados NUMERIC(5, 2),

    -- Estado del vehículo
    en_servicio BOOLEAN DEFAULT false,
    servicio_id UUID,
    motor_encendido BOOLEAN,

    -- Dirección
    direccion_texto TEXT,
    zona TEXT,

    -- Auditoría (simplificada para este caso)
    empresa_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_thistorial_ubicaciones_vehiculo_id ON public.thistorial_ubicaciones(vehiculo_id);
CREATE INDEX idx_thistorial_ubicaciones_timestamp ON public.thistorial_ubicaciones(timestamp);
CREATE INDEX idx_thistorial_ubicaciones_empresa_id ON public.thistorial_ubicaciones(empresa_id);
CREATE INDEX idx_thistorial_ubicaciones_coords ON public.thistorial_ubicaciones(latitud, longitud);

COMMENT ON TABLE public.thistorial_ubicaciones IS 'Historial de ubicaciones GPS de vehículos';


-- =====================================================
-- TABLA: tdocumentos_vehiculo
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tdocumentos_vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES public.tvehiculos(id) ON DELETE CASCADE,

    -- Tipo de documento
    tipo_documento TEXT NOT NULL CHECK (tipo_documento IN (
        'permiso_circulacion',
        'seguro',
        'itv',
        'ficha_tecnica',
        'homologacion',
        'contrato_renting',
        'factura_compra',
        'manual_usuario',
        'certificado_equipamiento',
        'otro'
    )),
    categoria TEXT,

    -- Documento
    nombre TEXT NOT NULL,
    descripcion TEXT,
    numero_documento TEXT,

    -- Archivo
    url TEXT NOT NULL,
    tipo_archivo TEXT,
    tamano_bytes BIGINT,

    -- Fechas
    fecha_emision DATE,
    fecha_vencimiento DATE,

    -- Estado
    estado TEXT DEFAULT 'vigente' CHECK (estado IN ('vigente', 'vencido', 'proximo_vencer', 'anulado')),
    requiere_renovacion BOOLEAN DEFAULT false,

    -- Notificaciones
    notificar_vencimiento BOOLEAN DEFAULT true,
    dias_aviso_vencimiento INTEGER DEFAULT 30,

    -- Auditoría
    empresa_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID
);

CREATE INDEX idx_tdocumentos_vehiculo_vehiculo_id ON public.tdocumentos_vehiculo(vehiculo_id);
CREATE INDEX idx_tdocumentos_vehiculo_tipo_documento ON public.tdocumentos_vehiculo(tipo_documento);
CREATE INDEX idx_tdocumentos_vehiculo_fecha_vencimiento ON public.tdocumentos_vehiculo(fecha_vencimiento);
CREATE INDEX idx_tdocumentos_vehiculo_estado ON public.tdocumentos_vehiculo(estado);
CREATE INDEX idx_tdocumentos_vehiculo_empresa_id ON public.tdocumentos_vehiculo(empresa_id);

COMMENT ON TABLE public.tdocumentos_vehiculo IS 'Documentación digital de vehículos';


-- =====================================================
-- TRIGGERS: Actualización automática de updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para tvehiculos
CREATE TRIGGER set_tvehiculos_updated_at
    BEFORE UPDATE ON public.tvehiculos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para tmantenimientos
CREATE TRIGGER set_tmantenimientos_updated_at
    BEFORE UPDATE ON public.tmantenimientos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para taverias
CREATE TRIGGER set_taverias_updated_at
    BEFORE UPDATE ON public.taverias
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para titv_revisiones
CREATE TRIGGER set_titv_revisiones_updated_at
    BEFORE UPDATE ON public.titv_revisiones
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para tconsumo_combustible
CREATE TRIGGER set_tconsumo_combustible_updated_at
    BEFORE UPDATE ON public.tconsumo_combustible
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para tequipamiento_vehiculo
CREATE TRIGGER set_tequipamiento_vehiculo_updated_at
    BEFORE UPDATE ON public.tequipamiento_vehiculo
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para tdocumentos_vehiculo
CREATE TRIGGER set_tdocumentos_vehiculo_updated_at
    BEFORE UPDATE ON public.tdocumentos_vehiculo
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE public.tvehiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tmantenimientos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taverias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.titv_revisiones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tconsumo_combustible ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tequipamiento_vehiculo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.thistorial_ubicaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tdocumentos_vehiculo ENABLE ROW LEVEL SECURITY;

-- Políticas para tvehiculos
CREATE POLICY "Los usuarios pueden ver vehículos de su empresa"
    ON public.tvehiculos FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden insertar vehículos en su empresa"
    ON public.tvehiculos FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden actualizar vehículos de su empresa"
    ON public.tvehiculos FOR UPDATE
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden eliminar vehículos de su empresa"
    ON public.tvehiculos FOR DELETE
    USING (auth.uid() IS NOT NULL);

-- Políticas para tmantenimientos
CREATE POLICY "Los usuarios pueden ver mantenimientos de su empresa"
    ON public.tmantenimientos FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden insertar mantenimientos en su empresa"
    ON public.tmantenimientos FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden actualizar mantenimientos de su empresa"
    ON public.tmantenimientos FOR UPDATE
    USING (auth.uid() IS NOT NULL);

-- Políticas para taverias
CREATE POLICY "Los usuarios pueden ver averías de su empresa"
    ON public.taverias FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden insertar averías en su empresa"
    ON public.taverias FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden actualizar averías de su empresa"
    ON public.taverias FOR UPDATE
    USING (auth.uid() IS NOT NULL);

-- Políticas para titv_revisiones
CREATE POLICY "Los usuarios pueden ver revisiones de su empresa"
    ON public.titv_revisiones FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden insertar revisiones en su empresa"
    ON public.titv_revisiones FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden actualizar revisiones de su empresa"
    ON public.titv_revisiones FOR UPDATE
    USING (auth.uid() IS NOT NULL);

-- Políticas para tconsumo_combustible
CREATE POLICY "Los usuarios pueden ver consumo de su empresa"
    ON public.tconsumo_combustible FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden insertar consumo en su empresa"
    ON public.tconsumo_combustible FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden actualizar consumo de su empresa"
    ON public.tconsumo_combustible FOR UPDATE
    USING (auth.uid() IS NOT NULL);

-- Políticas para tequipamiento_vehiculo
CREATE POLICY "Los usuarios pueden ver equipamiento de su empresa"
    ON public.tequipamiento_vehiculo FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden insertar equipamiento en su empresa"
    ON public.tequipamiento_vehiculo FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden actualizar equipamiento de su empresa"
    ON public.tequipamiento_vehiculo FOR UPDATE
    USING (auth.uid() IS NOT NULL);

-- Políticas para thistorial_ubicaciones
CREATE POLICY "Los usuarios pueden ver ubicaciones de su empresa"
    ON public.thistorial_ubicaciones FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden insertar ubicaciones en su empresa"
    ON public.thistorial_ubicaciones FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Políticas para tdocumentos_vehiculo
CREATE POLICY "Los usuarios pueden ver documentos de su empresa"
    ON public.tdocumentos_vehiculo FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden insertar documentos en su empresa"
    ON public.tdocumentos_vehiculo FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden actualizar documentos de su empresa"
    ON public.tdocumentos_vehiculo FOR UPDATE
    USING (auth.uid() IS NOT NULL);


-- =====================================================
-- FUNCIONES AUXILIARES
-- =====================================================

-- Función para calcular el consumo promedio
CREATE OR REPLACE FUNCTION calcular_consumo_promedio(p_vehiculo_id UUID)
RETURNS NUMERIC AS $$
DECLARE
    v_consumo_promedio NUMERIC;
BEGIN
    SELECT AVG(consumo_l100km) INTO v_consumo_promedio
    FROM public.tconsumo_combustible
    WHERE vehiculo_id = p_vehiculo_id
      AND consumo_l100km IS NOT NULL
      AND fecha > NOW() - INTERVAL '6 months';

    RETURN COALESCE(v_consumo_promedio, 0);
END;
$$ LANGUAGE plpgsql;

-- Función para obtener km promedio mensual
CREATE OR REPLACE FUNCTION calcular_km_promedio_mensual(p_vehiculo_id UUID)
RETURNS NUMERIC AS $$
DECLARE
    v_km_promedio NUMERIC;
    v_meses_activo INTEGER;
BEGIN
    SELECT EXTRACT(MONTH FROM AGE(NOW(), fecha_puesta_servicio))
    INTO v_meses_activo
    FROM public.tvehiculos
    WHERE id = p_vehiculo_id;

    IF v_meses_activo > 0 THEN
        SELECT (km_actual - COALESCE(km_inicial, 0)) / v_meses_activo
        INTO v_km_promedio
        FROM public.tvehiculos
        WHERE id = p_vehiculo_id;
    ELSE
        v_km_promedio := 0;
    END IF;

    RETURN COALESCE(v_km_promedio, 0);
END;
$$ LANGUAGE plpgsql;

-- Función para verificar alertas de vencimiento
CREATE OR REPLACE FUNCTION verificar_alertas_vehiculo(p_vehiculo_id UUID)
RETURNS TABLE(
    tipo_alerta TEXT,
    descripcion TEXT,
    fecha_vencimiento DATE,
    dias_restantes INTEGER,
    criticidad TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        'ITV'::TEXT,
        'Vencimiento de ITV'::TEXT,
        v.proxima_itv,
        (v.proxima_itv - CURRENT_DATE)::INTEGER,
        CASE
            WHEN v.proxima_itv < CURRENT_DATE THEN 'critica'
            WHEN v.proxima_itv <= CURRENT_DATE + INTERVAL '30 days' THEN 'alta'
            WHEN v.proxima_itv <= CURRENT_DATE + INTERVAL '60 days' THEN 'media'
            ELSE 'baja'
        END::TEXT
    FROM public.tvehiculos v
    WHERE v.id = p_vehiculo_id

    UNION ALL

    SELECT
        'SEGURO'::TEXT,
        'Vencimiento de seguro'::TEXT,
        v.fecha_vencimiento_seguro,
        (v.fecha_vencimiento_seguro - CURRENT_DATE)::INTEGER,
        CASE
            WHEN v.fecha_vencimiento_seguro < CURRENT_DATE THEN 'critica'
            WHEN v.fecha_vencimiento_seguro <= CURRENT_DATE + INTERVAL '30 days' THEN 'alta'
            WHEN v.fecha_vencimiento_seguro <= CURRENT_DATE + INTERVAL '60 days' THEN 'media'
            ELSE 'baja'
        END::TEXT
    FROM public.tvehiculos v
    WHERE v.id = p_vehiculo_id

    UNION ALL

    SELECT
        'HOMOLOGACION'::TEXT,
        'Vencimiento de homologación sanitaria'::TEXT,
        v.fecha_vencimiento_homologacion,
        (v.fecha_vencimiento_homologacion - CURRENT_DATE)::INTEGER,
        CASE
            WHEN v.fecha_vencimiento_homologacion < CURRENT_DATE THEN 'critica'
            WHEN v.fecha_vencimiento_homologacion <= CURRENT_DATE + INTERVAL '30 days' THEN 'alta'
            WHEN v.fecha_vencimiento_homologacion <= CURRENT_DATE + INTERVAL '60 days' THEN 'media'
            ELSE 'baja'
        END::TEXT
    FROM public.tvehiculos v
    WHERE v.id = p_vehiculo_id;
END;
$$ LANGUAGE plpgsql;

-- Función para calcular distancia entre dos puntos (Haversine simplificado)
CREATE OR REPLACE FUNCTION calcular_distancia_km(
    lat1 NUMERIC,
    lon1 NUMERIC,
    lat2 NUMERIC,
    lon2 NUMERIC
)
RETURNS NUMERIC AS $$
DECLARE
    radio_tierra NUMERIC := 6371; -- Radio de la Tierra en km
    dlat NUMERIC;
    dlon NUMERIC;
    a NUMERIC;
    c NUMERIC;
BEGIN
    -- Convertir grados a radianes
    dlat := radians(lat2 - lat1);
    dlon := radians(lon2 - lon1);

    -- Fórmula de Haversine
    a := sin(dlat/2) * sin(dlat/2) +
         cos(radians(lat1)) * cos(radians(lat2)) *
         sin(dlon/2) * sin(dlon/2);
    c := 2 * atan2(sqrt(a), sqrt(1-a));

    RETURN radio_tierra * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;


-- =====================================================
-- FIN DE LA MIGRACIÓN
-- =====================================================

COMMENT ON SCHEMA public IS 'AmbuTrack - Sistema de gestión de ambulancias';
