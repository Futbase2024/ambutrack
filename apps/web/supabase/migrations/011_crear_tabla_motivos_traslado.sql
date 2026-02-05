-- ==============================================================================
-- MOTIVOS DE TRASLADO
-- Tabla de motivos por los cuales se realiza un traslado de pacientes
-- Requerida por: servicios
-- ==============================================================================

-- Crear tabla
CREATE TABLE IF NOT EXISTS tmotivos_traslado (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_tmotivos_traslado_nombre ON tmotivos_traslado(nombre);
CREATE INDEX idx_tmotivos_traslado_activo ON tmotivos_traslado(activo);

-- Trigger para actualizar updated_at
CREATE TRIGGER update_tmotivos_traslado_updated_at
    BEFORE UPDATE ON tmotivos_traslado
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE tmotivos_traslado ENABLE ROW LEVEL SECURITY;

-- Política: Todos pueden ver (lectura)
CREATE POLICY "Usuarios autenticados pueden ver motivos traslado" ON tmotivos_traslado
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política: Solo admins pueden modificar
CREATE POLICY "Admins pueden gestionar motivos traslado" ON tmotivos_traslado
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- ==============================================================================
-- DATOS INICIALES - Motivos de Traslado comunes
-- ==============================================================================

INSERT INTO tmotivos_traslado (nombre, descripcion) VALUES
    ('Consulta Médica', 'Traslado para asistir a consulta médica programada'),
    ('Urgencia', 'Traslado de urgencia por emergencia médica'),
    ('Diálisis', 'Traslado para sesión de diálisis programada'),
    ('Radioterapia', 'Traslado para sesión de radioterapia'),
    ('Quimioterapia', 'Traslado para sesión de quimioterapia'),
    ('Rehabilitación', 'Traslado para sesión de fisioterapia o rehabilitación'),
    ('Pruebas Diagnósticas', 'Traslado para realizar pruebas médicas (TAC, resonancia, análisis, etc.)'),
    ('Intervención Quirúrgica', 'Traslado para cirugía programada'),
    ('Hospitalización', 'Traslado para ingreso hospitalario'),
    ('Alta Hospitalaria', 'Traslado de regreso a domicilio tras alta médica'),
    ('Traslado entre Centros', 'Traslado de un centro sanitario a otro'),
    ('Revisión Médica', 'Traslado para revisión o seguimiento médico'),
    ('Tratamiento Ambulatorio', 'Traslado para recibir tratamiento ambulatorio'),
    ('Cura de Heridas', 'Traslado para cura y seguimiento de heridas'),
    ('Vacunación', 'Traslado para administración de vacunas'),
    ('Extracciones', 'Traslado para extracción de sangre u otras muestras')
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- COMENTARIOS
-- ==============================================================================
COMMENT ON TABLE tmotivos_traslado IS 'Motivos por los cuales se realiza un traslado de pacientes';
COMMENT ON COLUMN tmotivos_traslado.nombre IS 'Nombre del motivo de traslado';
COMMENT ON COLUMN tmotivos_traslado.descripcion IS 'Descripción detallada del motivo';
COMMENT ON COLUMN tmotivos_traslado.activo IS 'Indica si el motivo está activo o inactivo';

-- ==============================================================================
-- NOTAS
-- ==============================================================================
-- Los motivos de traslado se utilizan para:
-- 1. Clasificar los servicios de ambulancia según su propósito
-- 2. Generar estadísticas de uso por tipo de traslado
-- 3. Planificar recursos según los motivos más frecuentes
-- 4. Facturación y reportes a aseguradoras
