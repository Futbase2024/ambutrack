-- ==============================================================================
-- AmbuTrack Web - Supabase Initial Schema
-- Migración desde Firebase a Supabase
-- ==============================================================================

-- ==============================================================================
-- EXTENSIONES
-- ==============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- TABLA: usuarios
-- Datos adicionales de usuarios (complementa auth.users)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    nombre TEXT,
    apellidos TEXT,
    telefono TEXT,
    rol TEXT NOT NULL DEFAULT 'usuario' CHECK (rol IN ('admin', 'coordinador', 'conductor', 'sanitario', 'usuario')),
    activo BOOLEAN NOT NULL DEFAULT true,
    foto_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_usuarios_updated_at
    BEFORE UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================================
-- TABLA: vehiculos
-- Gestión de flota de ambulancias
-- ==============================================================================
CREATE TABLE IF NOT EXISTS vehiculos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    matricula TEXT NOT NULL UNIQUE,
    tipo TEXT NOT NULL,
    marca TEXT NOT NULL,
    modelo TEXT NOT NULL,
    anio INTEGER NOT NULL,
    estado TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo', 'mantenimiento', 'reparacion', 'baja')),
    capacidad INTEGER,
    equipamiento TEXT[],
    fecha_adquisicion DATE,
    fecha_proxima_itv DATE,
    km_actual DECIMAL(10, 2),
    ubicacion_actual TEXT,
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_vehiculos_matricula ON vehiculos(matricula);
CREATE INDEX idx_vehiculos_estado ON vehiculos(estado);

CREATE TRIGGER update_vehiculos_updated_at
    BEFORE UPDATE ON vehiculos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================================
-- TABLA: tipos_vehiculo (Simple DataSource - Reference Data)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tipos_vehiculo (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    orden INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- TABLA: personal
-- Gestión de personal sanitario
-- ==============================================================================
CREATE TABLE IF NOT EXISTS personal (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
    nombre TEXT NOT NULL,
    apellidos TEXT NOT NULL,
    dni TEXT NOT NULL UNIQUE,
    email TEXT,
    telefono TEXT,
    categoria TEXT NOT NULL,
    especialidad TEXT,
    fecha_alta DATE NOT NULL,
    fecha_baja DATE,
    activo BOOLEAN NOT NULL DEFAULT true,
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_personal_dni ON personal(dni);
CREATE INDEX idx_personal_activo ON personal(activo);

CREATE TRIGGER update_personal_updated_at
    BEFORE UPDATE ON personal
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================================
-- TABLA: servicios
-- Servicios de ambulancia
-- ==============================================================================
CREATE TABLE IF NOT EXISTS servicios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo TEXT NOT NULL UNIQUE,
    tipo TEXT NOT NULL,
    prioridad INTEGER NOT NULL DEFAULT 3 CHECK (prioridad BETWEEN 1 AND 4),
    estado TEXT NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'asignado', 'en_curso', 'completado', 'cancelado')),
    vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE SET NULL,
    conductor_id UUID REFERENCES personal(id) ON DELETE SET NULL,
    sanitario_id UUID REFERENCES personal(id) ON DELETE SET NULL,
    paciente_nombre TEXT,
    paciente_telefono TEXT,
    origen_direccion TEXT NOT NULL,
    origen_latitud DECIMAL(10, 8),
    origen_longitud DECIMAL(11, 8),
    destino_direccion TEXT,
    destino_latitud DECIMAL(10, 8),
    destino_longitud DECIMAL(11, 8),
    fecha_solicitud TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    fecha_asignacion TIMESTAMP WITH TIME ZONE,
    fecha_inicio TIMESTAMP WITH TIME ZONE,
    fecha_fin TIMESTAMP WITH TIME ZONE,
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_servicios_codigo ON servicios(codigo);
CREATE INDEX idx_servicios_estado ON servicios(estado);
CREATE INDEX idx_servicios_fecha ON servicios(fecha_solicitud);
CREATE INDEX idx_servicios_vehiculo ON servicios(vehiculo_id);

CREATE TRIGGER update_servicios_updated_at
    BEFORE UPDATE ON servicios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ==============================================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE tipos_vehiculo ENABLE ROW LEVEL SECURITY;
ALTER TABLE personal ENABLE ROW LEVEL SECURITY;
ALTER TABLE servicios ENABLE ROW LEVEL SECURITY;

-- Políticas para usuarios autenticados
CREATE POLICY "Usuarios pueden ver su propio perfil" ON usuarios
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Admins pueden ver todos los usuarios" ON usuarios
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'
        )
    );

CREATE POLICY "Usuarios pueden actualizar su propio perfil" ON usuarios
    FOR UPDATE USING (auth.uid() = id);

-- Políticas para vehículos (todos los autenticados pueden ver)
CREATE POLICY "Usuarios autenticados pueden ver vehículos" ON vehiculos
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admins y coordinadores pueden gestionar vehículos" ON vehiculos
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE id = auth.uid() AND rol IN ('admin', 'coordinador')
        )
    );

-- Políticas para tipos de vehículo (referencia, todos pueden leer)
CREATE POLICY "Todos pueden ver tipos de vehículo" ON tipos_vehiculo
    FOR SELECT USING (true);

CREATE POLICY "Admins pueden gestionar tipos de vehículo" ON tipos_vehiculo
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Políticas para personal
CREATE POLICY "Usuarios autenticados pueden ver personal" ON personal
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admins y coordinadores pueden gestionar personal" ON personal
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE id = auth.uid() AND rol IN ('admin', 'coordinador')
        )
    );

-- Políticas para servicios
CREATE POLICY "Usuarios autenticados pueden ver servicios" ON servicios
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admins y coordinadores pueden gestionar servicios" ON servicios
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE id = auth.uid() AND rol IN ('admin', 'coordinador')
        )
    );

-- ==============================================================================
-- DATOS INICIALES
-- ==============================================================================

-- Tipos de vehículo de ejemplo
INSERT INTO tipos_vehiculo (nombre, descripcion, orden) VALUES
    ('SVB', 'Soporte Vital Básico', 1),
    ('SVA', 'Soporte Vital Avanzado', 2),
    ('Colectiva', 'Ambulancia Colectiva', 3),
    ('Convencional', 'Ambulancia Convencional', 4)
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- FUNCIONES DE UTILIDAD
-- ==============================================================================

-- Función para obtener el rol del usuario actual
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT AS $$
BEGIN
    RETURN (SELECT rol FROM usuarios WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
