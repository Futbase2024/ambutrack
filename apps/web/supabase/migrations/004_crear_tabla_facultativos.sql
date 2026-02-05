-- ==============================================================================
-- AmbuTrack Web - Tabla Facultativos
-- Gestión de médicos y facultativos
-- ==============================================================================

-- ==============================================================================
-- TABLA: tfacultativos
-- Gestión de médicos, facultativos y profesionales sanitarios
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tfacultativos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    apellidos TEXT NOT NULL,
    num_colegiado TEXT,
    especialidad TEXT,
    telefono TEXT,
    email TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para mejorar el rendimiento de búsquedas
CREATE INDEX idx_tfacultativos_apellidos ON tfacultativos(apellidos);
CREATE INDEX idx_tfacultativos_num_colegiado ON tfacultativos(num_colegiado);
CREATE INDEX idx_tfacultativos_activo ON tfacultativos(activo);

-- Trigger para actualizar updated_at automáticamente
CREATE TRIGGER update_tfacultativos_updated_at
    BEFORE UPDATE ON tfacultativos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================================
-- COMENTARIOS DESCRIPTIVOS
-- ==============================================================================
COMMENT ON TABLE tfacultativos IS 'Tabla de facultativos y médicos del sistema';
COMMENT ON COLUMN tfacultativos.id IS 'Identificador único del facultativo (UUID)';
COMMENT ON COLUMN tfacultativos.nombre IS 'Nombre del facultativo';
COMMENT ON COLUMN tfacultativos.apellidos IS 'Apellidos del facultativo';
COMMENT ON COLUMN tfacultativos.num_colegiado IS 'Número de colegiado profesional';
COMMENT ON COLUMN tfacultativos.especialidad IS 'Especialidad médica del facultativo';
COMMENT ON COLUMN tfacultativos.telefono IS 'Teléfono de contacto';
COMMENT ON COLUMN tfacultativos.email IS 'Correo electrónico';
COMMENT ON COLUMN tfacultativos.activo IS 'Indica si el facultativo está activo en el sistema';
COMMENT ON COLUMN tfacultativos.created_at IS 'Fecha de creación del registro';
COMMENT ON COLUMN tfacultativos.updated_at IS 'Fecha de última actualización del registro';

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ==============================================================================
ALTER TABLE tfacultativos ENABLE ROW LEVEL SECURITY;

-- Política: Permitir lectura a usuarios autenticados
CREATE POLICY "Permitir lectura de tfacultativos a usuarios autenticados"
    ON tfacultativos
    FOR SELECT
    TO authenticated
    USING (true);

-- Política: Permitir inserción a usuarios autenticados
CREATE POLICY "Permitir inserción de tfacultativos a usuarios autenticados"
    ON tfacultativos
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Política: Permitir actualización a usuarios autenticados
CREATE POLICY "Permitir actualización de tfacultativos a usuarios autenticados"
    ON tfacultativos
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Política: Permitir eliminación a usuarios autenticados
CREATE POLICY "Permitir eliminación de tfacultativos a usuarios autenticados"
    ON tfacultativos
    FOR DELETE
    TO authenticated
    USING (true);

-- ==============================================================================
-- DATOS INICIALES DE EJEMPLO
-- ==============================================================================
INSERT INTO tfacultativos (nombre, apellidos, num_colegiado, especialidad, telefono, email, activo)
VALUES
    ('Carlos', 'García López', '28/1234567', 'Medicina de Urgencias', '612345678', 'carlos.garcia@hospital.com', true),
    ('María', 'Martínez Fernández', '28/2345678', 'Medicina Interna', '623456789', 'maria.martinez@hospital.com', true),
    ('José', 'Rodríguez Sánchez', '28/3456789', 'Cardiología', '634567890', 'jose.rodriguez@hospital.com', true),
    ('Ana', 'López Pérez', '28/4567890', 'Traumatología', '645678901', 'ana.lopez@hospital.com', true),
    ('David', 'González Ruiz', '28/5678901', 'Pediatría', '656789012', 'david.gonzalez@hospital.com', true)
ON CONFLICT DO NOTHING;

-- ==============================================================================
-- VERIFICACIÓN
-- ==============================================================================
-- Verificar que la tabla se creó correctamente
DO $$
BEGIN
    IF EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'tfacultativos'
    ) THEN
        RAISE NOTICE '✅ Tabla tfacultativos creada exitosamente';
    ELSE
        RAISE EXCEPTION '❌ Error: No se pudo crear la tabla tfacultativos';
    END IF;
END $$;
