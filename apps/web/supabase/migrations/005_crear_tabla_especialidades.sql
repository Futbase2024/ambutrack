-- ==============================================================================
-- AmbuTrack Web - Tabla Especialidades Médicas
-- Gestión de especialidades médicas y certificaciones
-- ==============================================================================

-- ==============================================================================
-- TABLA: tespecialidades
-- Catálogo de especialidades médicas y certificaciones profesionales
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tespecialidades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    requiere_certificacion BOOLEAN NOT NULL DEFAULT true,
    tipo_especialidad TEXT NOT NULL DEFAULT 'medica',
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Validación de tipo_especialidad
    CONSTRAINT check_tipo_especialidad CHECK (
        tipo_especialidad IN ('medica', 'quirurgica', 'diagnostica', 'apoyo', 'enfermeria', 'tecnica')
    )
);

-- Índices para mejorar el rendimiento de búsquedas
CREATE INDEX idx_tespecialidades_nombre ON tespecialidades(nombre);
CREATE INDEX idx_tespecialidades_tipo ON tespecialidades(tipo_especialidad);
CREATE INDEX idx_tespecialidades_activo ON tespecialidades(activo);

-- Trigger para actualizar updated_at automáticamente
CREATE TRIGGER update_tespecialidades_updated_at
    BEFORE UPDATE ON tespecialidades
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================================
-- COMENTARIOS DESCRIPTIVOS
-- ==============================================================================
COMMENT ON TABLE tespecialidades IS 'Tabla maestra de especialidades médicas y certificaciones profesionales';
COMMENT ON COLUMN tespecialidades.id IS 'Identificador único de la especialidad (UUID)';
COMMENT ON COLUMN tespecialidades.nombre IS 'Nombre completo de la especialidad';
COMMENT ON COLUMN tespecialidades.descripcion IS 'Descripción detallada de la especialidad';
COMMENT ON COLUMN tespecialidades.requiere_certificacion IS 'Indica si requiere certificación específica';
COMMENT ON COLUMN tespecialidades.tipo_especialidad IS 'Tipo: medica, quirurgica, diagnostica, apoyo, enfermeria, tecnica';
COMMENT ON COLUMN tespecialidades.activo IS 'Indica si la especialidad está activa en el sistema';
COMMENT ON COLUMN tespecialidades.created_at IS 'Fecha de creación del registro';
COMMENT ON COLUMN tespecialidades.updated_at IS 'Fecha de última actualización del registro';

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ==============================================================================
ALTER TABLE tespecialidades ENABLE ROW LEVEL SECURITY;

-- Política: Permitir lectura a usuarios autenticados
CREATE POLICY "Permitir lectura de tespecialidades a usuarios autenticados"
    ON tespecialidades
    FOR SELECT
    TO authenticated
    USING (true);

-- Política: Permitir inserción a usuarios autenticados
CREATE POLICY "Permitir inserción de tespecialidades a usuarios autenticados"
    ON tespecialidades
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Política: Permitir actualización a usuarios autenticados
CREATE POLICY "Permitir actualización de tespecialidades a usuarios autenticados"
    ON tespecialidades
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Política: Permitir eliminación a usuarios autenticados
CREATE POLICY "Permitir eliminación de tespecialidades a usuarios autenticados"
    ON tespecialidades
    FOR DELETE
    TO authenticated
    USING (true);

-- ==============================================================================
-- DATOS INICIALES (SEED)
-- ==============================================================================
INSERT INTO tespecialidades (nombre, descripcion, requiere_certificacion, tipo_especialidad, activo)
VALUES
    -- Especialidades Médicas
    ('Medicina de Urgencias', 'Atención de emergencias y situaciones críticas', true, 'medica', true),
    ('Medicina Interna', 'Diagnóstico y tratamiento de enfermedades internas', true, 'medica', true),
    ('Cardiología', 'Especialidad en corazón y sistema cardiovascular', true, 'medica', true),
    ('Pediatría', 'Atención médica de niños y adolescentes', true, 'medica', true),
    ('Geriatría', 'Atención médica de adultos mayores', true, 'medica', true),

    -- Especialidades Quirúrgicas
    ('Traumatología', 'Tratamiento de lesiones del sistema musculoesquelético', true, 'quirurgica', true),
    ('Cirugía General', 'Procedimientos quirúrgicos generales', true, 'quirurgica', true),
    ('Neurocirugía', 'Cirugía del sistema nervioso', true, 'quirurgica', true),

    -- Especialidades Diagnósticas
    ('Radiología', 'Diagnóstico por imagen', true, 'diagnostica', true),
    ('Laboratorio Clínico', 'Análisis de muestras biológicas', true, 'diagnostica', true),

    -- Especialidades de Apoyo
    ('Anestesiología', 'Administración de anestesia y manejo del dolor', true, 'apoyo', true),
    ('Farmacia Hospitalaria', 'Gestión de medicamentos', true, 'apoyo', true),

    -- Enfermería
    ('Enfermería', 'Cuidados de enfermería general', true, 'enfermeria', true),
    ('Enfermería de Urgencias', 'Enfermería especializada en emergencias', true, 'enfermeria', true),
    ('Enfermería de UCI', 'Cuidados intensivos', true, 'enfermeria', true),
    ('Auxiliar de Enfermería', 'Apoyo en cuidados de enfermería', false, 'enfermeria', true),

    -- Técnicos
    ('Técnico en Emergencias Sanitarias', 'Atención prehospitalaria y traslados', true, 'tecnica', true),
    ('Técnico en Radiología', 'Operación de equipos de radiodiagnóstico', true, 'tecnica', true),
    ('Técnico de Laboratorio', 'Apoyo en análisis de laboratorio', true, 'tecnica', true),
    ('Conductor de Ambulancia', 'Conducción de vehículos sanitarios', true, 'tecnica', true)
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- VERIFICACIÓN
-- ==============================================================================
-- Verificar que la tabla se creó correctamente
DO $$
BEGIN
    IF EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'tespecialidades'
    ) THEN
        RAISE NOTICE '✅ Tabla tespecialidades creada exitosamente';
        RAISE NOTICE '📊 Total de especialidades insertadas: %', (SELECT COUNT(*) FROM tespecialidades);
    ELSE
        RAISE EXCEPTION '❌ Error: No se pudo crear la tabla tespecialidades';
    END IF;
END $$;
