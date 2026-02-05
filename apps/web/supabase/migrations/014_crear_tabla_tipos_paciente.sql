-- ==============================================================================
-- TIPOS DE PACIENTE
-- Tabla de tipos de pacientes para clasificar servicios de ambulancia
-- Requerida por: servicios
-- ==============================================================================

-- Crear tabla
CREATE TABLE IF NOT EXISTS ttipos_paciente (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_ttipos_paciente_nombre ON ttipos_paciente(nombre);
CREATE INDEX idx_ttipos_paciente_activo ON ttipos_paciente(activo);

-- Trigger para actualizar updated_at
CREATE TRIGGER update_ttipos_paciente_updated_at
    BEFORE UPDATE ON ttipos_paciente
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE ttipos_paciente ENABLE ROW LEVEL SECURITY;

-- Política: Todos pueden ver (lectura)
CREATE POLICY "Usuarios autenticados pueden ver tipos paciente" ON ttipos_paciente
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política: Solo admins pueden modificar
CREATE POLICY "Admins pueden gestionar tipos paciente" ON ttipos_paciente
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- ==============================================================================
-- DATOS INICIALES - Tipos de Paciente comunes
-- ==============================================================================

INSERT INTO ttipos_paciente (nombre, descripcion) VALUES
    ('PACIENTE GERIÁTRICO', 'Paciente de edad avanzada con necesidades especiales'),
    ('PACIENTE PEDIÁTRICO', 'Paciente menor de edad (niños y adolescentes)'),
    ('PACIENTE CRÍTICO', 'Paciente en estado crítico que requiere atención urgente'),
    ('PACIENTE ESTABLE', 'Paciente con signos vitales estables'),
    ('PACIENTE PSIQUIÁTRICO', 'Paciente con condiciones de salud mental'),
    ('PACIENTE CON MOVILIDAD REDUCIDA', 'Paciente con dificultades de movilidad'),
    ('PACIENTE ONCOLÓGICO', 'Paciente con tratamiento oncológico'),
    ('PACIENTE DIALIZADO', 'Paciente en tratamiento de diálisis'),
    ('PACIENTE TRAUMATOLÓGICO', 'Paciente con lesiones traumatológicas'),
    ('PACIENTE RESPIRATORIO', 'Paciente con problemas respiratorios'),
    ('PACIENTE CARDIOLÓGICO', 'Paciente con afecciones cardíacas'),
    ('PACIENTE INFECCIOSO', 'Paciente con enfermedad infecciosa (requiere aislamiento)'),
    ('PACIENTE OBSTÉTRICO', 'Paciente embarazada o en proceso de parto'),
    ('PACIENTE NEONATAL', 'Recién nacido que requiere transporte especializado'),
    ('PACIENTE CON OBESIDAD MÓRBIDA', 'Paciente con obesidad que requiere equipo especial')
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- COMENTARIOS
-- ==============================================================================
COMMENT ON TABLE ttipos_paciente IS 'Tipos de pacientes para clasificar servicios de ambulancia';
COMMENT ON COLUMN ttipos_paciente.nombre IS 'Nombre del tipo de paciente';
COMMENT ON COLUMN ttipos_paciente.descripcion IS 'Descripción detallada del tipo';
COMMENT ON COLUMN ttipos_paciente.activo IS 'Indica si el tipo está activo o inactivo';

-- ==============================================================================
-- NOTAS
-- ==============================================================================
-- Los tipos de paciente se utilizan para:
-- 1. Clasificar los pacientes según sus necesidades específicas
-- 2. Asignar recursos apropiados (vehículos, personal especializado)
-- 3. Generar estadísticas de servicios por tipo de paciente
-- 4. Planificar y optimizar la operación según el perfil del paciente
