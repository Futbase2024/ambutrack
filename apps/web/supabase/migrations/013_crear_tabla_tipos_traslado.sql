-- ==============================================================================
-- TIPOS DE TRASLADO
-- Tabla de tipos de servicios de ambulancia según su naturaleza
-- Requerida por: servicios
-- ==============================================================================

-- Crear tabla
CREATE TABLE IF NOT EXISTS ttipos_traslado (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_ttipos_traslado_nombre ON ttipos_traslado(nombre);
CREATE INDEX idx_ttipos_traslado_activo ON ttipos_traslado(activo);

-- Trigger para actualizar updated_at
CREATE TRIGGER update_ttipos_traslado_updated_at
    BEFORE UPDATE ON ttipos_traslado
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE ttipos_traslado ENABLE ROW LEVEL SECURITY;

-- Política: Todos pueden ver (lectura)
CREATE POLICY "Usuarios autenticados pueden ver tipos traslado" ON ttipos_traslado
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política: Solo admins pueden modificar
CREATE POLICY "Admins pueden gestionar tipos traslado" ON ttipos_traslado
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- ==============================================================================
-- DATOS INICIALES - Tipos de Traslado comunes
-- ==============================================================================

INSERT INTO ttipos_traslado (nombre, descripcion) VALUES
    ('Urgente', 'Traslado de emergencia con prioridad máxima'),
    ('Programado', 'Traslado planificado con cita previa'),
    ('Inter-Hospitalario', 'Traslado entre centros sanitarios'),
    ('Alta Médica', 'Traslado del paciente de vuelta a su domicilio tras alta'),
    ('Consulta Externa', 'Traslado para asistir a consulta médica ambulatoria'),
    ('Diálisis', 'Traslado específico para tratamiento de diálisis'),
    ('Oncológico', 'Traslado para tratamientos oncológicos (quimio, radio)'),
    ('Traslado Internacional', 'Traslado entre países o repatriaciones'),
    ('Traslado Aéreo', 'Traslado en helicóptero o avión medicalizado'),
    ('Neonatal', 'Traslado especializado de recién nacidos')
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- COMENTARIOS
-- ==============================================================================
COMMENT ON TABLE ttipos_traslado IS 'Tipos de servicios de ambulancia según su naturaleza';
COMMENT ON COLUMN ttipos_traslado.nombre IS 'Nombre del tipo de traslado';
COMMENT ON COLUMN ttipos_traslado.descripcion IS 'Descripción detallada del tipo';
COMMENT ON COLUMN ttipos_traslado.activo IS 'Indica si el tipo está activo o inactivo';

-- ==============================================================================
-- NOTAS
-- ==============================================================================
-- Los tipos de traslado se utilizan para:
-- 1. Clasificar los servicios según su naturaleza y urgencia
-- 2. Asignar recursos apropiados (vehículos, personal)
-- 3. Generar estadísticas de servicios por tipo
-- 4. Planificar y optimizar la operación
