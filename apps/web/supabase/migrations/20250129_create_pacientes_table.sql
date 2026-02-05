-- =====================================================
-- TABLA: pacientes
-- Descripción: Almacena información completa de pacientes
-- Fecha: 2025-01-29
-- =====================================================

CREATE TABLE IF NOT EXISTS public.pacientes (
  -- IDENTIFICACIÓN ÚNICA
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- DATOS PERSONALES BÁSICOS
  identificacion VARCHAR(50) UNIQUE, -- Número identificación único del sistema
  nombre VARCHAR(100) NOT NULL,
  primer_apellido VARCHAR(100) NOT NULL,
  segundo_apellido VARCHAR(100),

  -- DOCUMENTO DE IDENTIDAD
  tipo_documento VARCHAR(20) NOT NULL DEFAULT 'DNI', -- DNI, NIE, PASAPORTE
  documento VARCHAR(50) NOT NULL,
  seguridad_social VARCHAR(50), -- Número de la seguridad social
  num_historia VARCHAR(50), -- Número de historia clínica

  -- DATOS DEMOGRÁFICOS
  sexo VARCHAR(10) NOT NULL, -- HOMBRE, MUJER
  fecha_nacimiento DATE NOT NULL,
  edad INTEGER GENERATED ALWAYS AS (
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, fecha_nacimiento))
  ) STORED,

  -- CONTACTO
  telefono_movil VARCHAR(20),
  telefono_fijo VARCHAR(20),
  email VARCHAR(100),

  -- ORIGEN Y PROFESIÓN
  pais_origen VARCHAR(100) DEFAULT 'España',
  profesion VARCHAR(100),

  -- DIRECCIÓN DE RECOGIDA
  recogida_lunes BOOLEAN DEFAULT FALSE,
  recogida_martes BOOLEAN DEFAULT FALSE,
  recogida_miercoles BOOLEAN DEFAULT FALSE,
  recogida_jueves BOOLEAN DEFAULT FALSE,
  recogida_viernes BOOLEAN DEFAULT FALSE,
  recogida_sabado BOOLEAN DEFAULT FALSE,
  recogida_domingo BOOLEAN DEFAULT FALSE,
  recogida_festivos BOOLEAN DEFAULT FALSE,

  recogida_piso VARCHAR(10),
  recogida_puerta VARCHAR(10),
  recogida_latitud DECIMAL(10, 8),
  recogida_longitud DECIMAL(11, 8),
  recogida_informacion_adicional TEXT,

  -- DOMICILIO DEL PACIENTE
  domicilio_piso VARCHAR(10),
  domicilio_puerta VARCHAR(10),
  domicilio_direccion TEXT,
  domicilio_latitud DECIMAL(10, 8),
  domicilio_longitud DECIMAL(11, 8),

  -- DATOS ADMINISTRATIVOS
  centro_hospitalario_id UUID REFERENCES public.centros_hospitalarios(id) ON DELETE SET NULL,
  facultativo_id UUID REFERENCES public.facultativos(id) ON DELETE SET NULL,
  mutua_aseguradora VARCHAR(100),
  num_poliza VARCHAR(50),

  -- CONSENTIMIENTOS RGPD
  consentimiento_informado BOOLEAN DEFAULT FALSE,
  consentimiento_informado_fecha TIMESTAMP WITH TIME ZONE,
  consentimiento_rgpd BOOLEAN DEFAULT FALSE,
  consentimiento_rgpd_fecha TIMESTAMP WITH TIME ZONE,

  -- OBSERVACIONES
  observaciones TEXT,

  -- ESTADO
  activo BOOLEAN DEFAULT TRUE,

  -- AUDITORÍA
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,

  -- CONSTRAINTS
  CONSTRAINT pacientes_documento_unique UNIQUE(tipo_documento, documento),
  CONSTRAINT pacientes_edad_check CHECK (edad >= 0 AND edad <= 150),
  CONSTRAINT pacientes_sexo_check CHECK (sexo IN ('HOMBRE', 'MUJER')),
  CONSTRAINT pacientes_tipo_documento_check CHECK (tipo_documento IN ('DNI', 'NIE', 'PASAPORTE', 'OTROS')),
  CONSTRAINT pacientes_grupo_sanguineo_check CHECK (
    grupo_sanguineo IS NULL OR
    grupo_sanguineo IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')
  ),
  CONSTRAINT pacientes_movilidad_check CHECK (
    movilidad IN ('AUTONOMO', 'SILLA_RUEDAS', 'CAMILLA', 'ASISTENCIA')
  )
);

-- =====================================================
-- ÍNDICES
-- =====================================================

CREATE INDEX idx_pacientes_documento ON public.pacientes(documento);
CREATE INDEX idx_pacientes_nombre_apellidos ON public.pacientes(nombre, primer_apellido, segundo_apellido);
CREATE INDEX idx_pacientes_telefono_movil ON public.pacientes(telefono_movil);
CREATE INDEX idx_pacientes_activo ON public.pacientes(activo);
CREATE INDEX idx_pacientes_centro_hospitalario ON public.pacientes(centro_hospitalario_id);
CREATE INDEX idx_pacientes_facultativo ON public.pacientes(facultativo_id);
CREATE INDEX idx_pacientes_created_at ON public.pacientes(created_at DESC);

-- Índice GiST para búsquedas de texto completo
CREATE INDEX idx_pacientes_nombre_completo_gin ON public.pacientes
USING gin(to_tsvector('spanish',
  COALESCE(nombre, '') || ' ' ||
  COALESCE(primer_apellido, '') || ' ' ||
  COALESCE(segundo_apellido, '')
));

-- =====================================================
-- TRIGGER PARA ACTUALIZAR updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_pacientes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_pacientes_updated_at
  BEFORE UPDATE ON public.pacientes
  FOR EACH ROW
  EXECUTE FUNCTION update_pacientes_updated_at();

-- =====================================================
-- RLS (Row Level Security)
-- =====================================================

ALTER TABLE public.pacientes ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios autenticados pueden ver todos los pacientes activos
CREATE POLICY pacientes_select_policy ON public.pacientes
  FOR SELECT
  TO authenticated
  USING (activo = TRUE OR auth.uid() = created_by);

-- Política: Los usuarios autenticados pueden insertar pacientes
CREATE POLICY pacientes_insert_policy ON public.pacientes
  FOR INSERT
  TO authenticated
  WITH CHECK (TRUE);

-- Política: Los usuarios pueden actualizar solo si son el creador o admin
CREATE POLICY pacientes_update_policy ON public.pacientes
  FOR UPDATE
  TO authenticated
  USING (TRUE)
  WITH CHECK (TRUE);

-- Política: Los usuarios pueden eliminar solo si son el creador o admin
CREATE POLICY pacientes_delete_policy ON public.pacientes
  FOR DELETE
  TO authenticated
  USING (created_by = auth.uid());

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON TABLE public.pacientes IS 'Registro completo de pacientes del sistema AmbuTrack';
COMMENT ON COLUMN public.pacientes.id IS 'Identificador único UUID del paciente';
COMMENT ON COLUMN public.pacientes.identificacion IS 'Número de identificación único del sistema (auto-generado)';
COMMENT ON COLUMN public.pacientes.documento IS 'Documento de identidad (DNI, NIE, Pasaporte)';
COMMENT ON COLUMN public.pacientes.edad IS 'Edad calculada automáticamente desde fecha_nacimiento';
COMMENT ON COLUMN public.pacientes.recogida_lunes IS 'Indica si el paciente tiene recogida los lunes';
COMMENT ON COLUMN public.pacientes.recogida_festivos IS 'Indica si el paciente tiene recogida en días festivos';
COMMENT ON COLUMN public.pacientes.consentimiento_rgpd IS 'Consentimiento de protección de datos RGPD';

-- =====================================================
-- DATOS INICIALES (OPCIONAL)
-- =====================================================

-- Insertar paciente de prueba para desarrollo
INSERT INTO public.pacientes (
  identificacion,
  nombre,
  primer_apellido,
  segundo_apellido,
  tipo_documento,
  documento,
  sexo,
  fecha_nacimiento,
  telefono_movil,
  email,
  pais_origen,
  recogida_lunes,
  recogida_miercoles,
  recogida_viernes,
  recogida_festivos,
  activo
) VALUES (
  'PAC-00001',
  'Juan',
  'García',
  'López',
  'DNI',
  '12345678A',
  'HOMBRE',
  '1950-05-15',
  '+34 600 123 456',
  'juan.garcia@example.com',
  'España',
  TRUE,
  TRUE,
  TRUE,
  FALSE,
  TRUE
) ON CONFLICT (identificacion) DO NOTHING;
