-- ==============================================================================
-- AmbuTrack - Tabla registros_horarios
-- Sistema de fichaje de entrada/salida del personal
-- ==============================================================================

-- ==============================================================================
-- TABLA: registros_horarios
-- Registros de fichaje de entrada y salida del personal
-- ==============================================================================
CREATE TABLE IF NOT EXISTS registros_horarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    personal_id UUID NOT NULL REFERENCES personal(id) ON DELETE CASCADE,
    nombre_personal TEXT,
    tipo TEXT NOT NULL CHECK (tipo IN ('entrada', 'salida')),
    fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    ubicacion TEXT,
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),
    precision_gps DECIMAL(10, 2),
    notas TEXT,
    estado TEXT NOT NULL DEFAULT 'normal' CHECK (estado IN ('normal', 'tarde', 'temprano', 'festivo')),
    es_manual BOOLEAN NOT NULL DEFAULT false,
    usuario_manual_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
    vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE SET NULL,
    turno TEXT,
    horas_trabajadas DECIMAL(10, 2),
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- ÍNDICES
-- ==============================================================================
CREATE INDEX idx_registros_horarios_personal_id ON registros_horarios(personal_id);
CREATE INDEX idx_registros_horarios_fecha_hora ON registros_horarios(fecha_hora DESC);
CREATE INDEX idx_registros_horarios_tipo ON registros_horarios(tipo);
CREATE INDEX idx_registros_horarios_estado ON registros_horarios(estado);
CREATE INDEX idx_registros_horarios_activo ON registros_horarios(activo);
CREATE INDEX idx_registros_horarios_es_manual ON registros_horarios(es_manual);
CREATE INDEX idx_registros_horarios_vehiculo_id ON registros_horarios(vehiculo_id);

-- Índice compuesto para consultas frecuentes por personal y fecha
CREATE INDEX idx_registros_horarios_personal_fecha ON registros_horarios(personal_id, fecha_hora DESC);

-- ==============================================================================
-- TRIGGER PARA UPDATED_AT
-- ==============================================================================
CREATE TRIGGER update_registros_horarios_updated_at
    BEFORE UPDATE ON registros_horarios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ==============================================================================
ALTER TABLE registros_horarios ENABLE ROW LEVEL SECURITY;

-- Política: Personal puede ver sus propios registros
CREATE POLICY "Personal puede ver sus propios registros de horario"
ON registros_horarios
    FOR SELECT USING (
        personal_id IN (
            SELECT id FROM personal WHERE usuario_id = auth.uid()
        )
        OR auth.uid() IN (
            SELECT id FROM usuarios WHERE rol IN ('admin', 'coordinador')
        )
    );

-- Política: Personal puede crear sus propios registros (fichaje)
CREATE POLICY "Personal puede crear sus propios registros de horario"
ON registros_horarios
    FOR INSERT WITH CHECK (
        personal_id IN (
            SELECT id FROM personal WHERE usuario_id = auth.uid()
        )
        OR auth.uid() IN (
            SELECT id FROM usuarios WHERE rol IN ('admin', 'coordinador')
        )
    );

-- Política: Solo admins y coordinadores pueden actualizar registros
CREATE POLICY "Admins y coordinadores pueden actualizar registros de horario"
ON registros_horarios
    FOR UPDATE USING (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol IN ('admin', 'coordinador')
        )
    );

-- Política: Solo admins pueden eliminar registros
CREATE POLICY "Admins pueden eliminar registros de horario"
ON registros_horarios
    FOR DELETE USING (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol = 'admin'
        )
    );

-- ==============================================================================
-- COMENTARIOS
-- ==============================================================================
COMMENT ON TABLE registros_horarios IS 'Registros de fichaje de entrada y salida del personal';
COMMENT ON COLUMN registros_horarios.personal_id IS 'Referencia al personal que ficha';
COMMENT ON COLUMN registros_horarios.tipo IS 'Tipo de fichaje: entrada o salida';
COMMENT ON COLUMN registros_horarios.fecha_hora IS 'Fecha y hora del fichaje';
COMMENT ON COLUMN registros_horarios.estado IS 'Estado del fichaje: normal, tarde, temprano, festivo';
COMMENT ON COLUMN registros_horarios.es_manual IS 'Indica si el fichaje fue realizado manualmente por un administrador';
COMMENT ON COLUMN registros_horarios.usuario_manual_id IS 'Usuario administrador que realizó el fichaje manual';
COMMENT ON COLUMN registros_horarios.horas_trabajadas IS 'Horas trabajadas calculadas hasta este fichaje';
COMMENT ON COLUMN registros_horarios.activo IS 'Indica si el registro está activo en el sistema';
