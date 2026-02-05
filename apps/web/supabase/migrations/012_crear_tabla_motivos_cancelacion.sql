-- ==============================================================================
-- MOTIVOS DE CANCELACIÓN
-- Tabla de motivos por los cuales se cancela un servicio o traslado
-- Requerida por: servicios
-- ==============================================================================

-- Crear tabla
CREATE TABLE IF NOT EXISTS tmotivos_cancelacion (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_tmotivos_cancelacion_nombre ON tmotivos_cancelacion(nombre);
CREATE INDEX idx_tmotivos_cancelacion_activo ON tmotivos_cancelacion(activo);

-- Trigger para actualizar updated_at
CREATE TRIGGER update_tmotivos_cancelacion_updated_at
    BEFORE UPDATE ON tmotivos_cancelacion
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE tmotivos_cancelacion ENABLE ROW LEVEL SECURITY;

-- Política: Todos pueden ver (lectura)
CREATE POLICY "Usuarios autenticados pueden ver motivos cancelacion" ON tmotivos_cancelacion
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política: Solo admins pueden modificar
CREATE POLICY "Admins pueden gestionar motivos cancelacion" ON tmotivos_cancelacion
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- ==============================================================================
-- DATOS INICIALES - Motivos de Cancelación comunes
-- ==============================================================================

INSERT INTO tmotivos_cancelacion (nombre, descripcion) VALUES
    ('Paciente rechaza el servicio', 'El paciente decide no utilizar el servicio de ambulancia'),
    ('Mejora del estado del paciente', 'El paciente ya no requiere el traslado debido a mejoría'),
    ('Duplicado', 'Servicio duplicado por error en el sistema'),
    ('Error en la solicitud', 'Datos incorrectos o incompletos en la solicitud inicial'),
    ('Falta de personal', 'No hay personal sanitario disponible para el servicio'),
    ('Falta de vehículo', 'No hay vehículos disponibles para realizar el servicio'),
    ('Condiciones meteorológicas', 'Clima adverso impide la realización del servicio'),
    ('Fallecimiento del paciente', 'El paciente fallece antes de iniciar el servicio'),
    ('Alta médica', 'El paciente recibe el alta médica antes del traslado programado'),
    ('Cancelación del centro sanitario', 'El centro de salud destino cancela la recepción'),
    ('Familia cancela', 'Familiares del paciente deciden cancelar el servicio'),
    ('No localizado', 'No se pudo localizar al paciente en la dirección indicada'),
    ('Traslado en vehículo particular', 'La familia decide trasladar al paciente por sus propios medios'),
    ('Cambio de horario', 'Se solicita cambio de horario en lugar de cancelación'),
    ('Fuerza mayor', 'Causas de fuerza mayor que impiden la realización del servicio')
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- COMENTARIOS
-- ==============================================================================
COMMENT ON TABLE tmotivos_cancelacion IS 'Motivos por los cuales se cancela un servicio o traslado';
COMMENT ON COLUMN tmotivos_cancelacion.nombre IS 'Nombre del motivo de cancelación';
COMMENT ON COLUMN tmotivos_cancelacion.descripcion IS 'Descripción detallada del motivo';
COMMENT ON COLUMN tmotivos_cancelacion.activo IS 'Indica si el motivo está activo o inactivo';

-- ==============================================================================
-- NOTAS
-- ==============================================================================
-- Los motivos de cancelación se utilizan para:
-- 1. Categorizar las razones de cancelación de servicios
-- 2. Generar estadísticas de motivos más frecuentes
-- 3. Identificar problemas operativos recurrentes
-- 4. Mejorar la planificación y asignación de recursos
