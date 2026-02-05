-- ============================================
-- Crear tabla 'equipamiento_personal' en Supabase
-- ============================================
-- Tabla para gestión de equipamiento asignado al personal
-- Relacionada con: personal (personalId)
-- ============================================

CREATE TABLE IF NOT EXISTS public.equipamiento_personal (
  -- Identificador único (UUID generado automáticamente)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Relación con personal
  personal_id TEXT NOT NULL,

  -- Tipo de equipamiento
  tipo_equipamiento TEXT NOT NULL CHECK (tipo_equipamiento IN ('uniforme', 'epi', 'tecnologico', 'sanitario')),

  -- Información del equipamiento
  nombre_equipamiento TEXT NOT NULL,

  -- Fechas de asignación y devolución
  fecha_asignacion TIMESTAMPTZ NOT NULL,
  fecha_devolucion TIMESTAMPTZ,

  -- Detalles del equipamiento
  talla TEXT,
  numero_serie TEXT,
  marca TEXT,
  modelo TEXT,
  estado TEXT CHECK (estado IN ('nuevo', 'bueno', 'regular', 'malo', 'deteriorado')),
  observaciones TEXT,

  -- Estado
  activo BOOLEAN NOT NULL DEFAULT true,

  -- Timestamps automáticos
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Índices para optimizar consultas
-- ============================================

-- Índice para búsqueda por personal
CREATE INDEX IF NOT EXISTS idx_equipamiento_personal_id
ON public.equipamiento_personal(personal_id);

-- Índice para búsqueda por tipo
CREATE INDEX IF NOT EXISTS idx_equipamiento_tipo
ON public.equipamiento_personal(tipo_equipamiento);

-- Índice para filtrar activos
CREATE INDEX IF NOT EXISTS idx_equipamiento_activo
ON public.equipamiento_personal(activo);

-- Índice para equipamiento asignado (sin devolver)
CREATE INDEX IF NOT EXISTS idx_equipamiento_asignado
ON public.equipamiento_personal(personal_id, fecha_devolucion)
WHERE fecha_devolucion IS NULL AND activo = true;

-- ============================================
-- Trigger para actualizar updated_at automáticamente
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_equipamiento_personal_updated_at
BEFORE UPDATE ON public.equipamiento_personal
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Row Level Security (RLS)
-- ============================================

-- Habilitar RLS en la tabla
ALTER TABLE public.equipamiento_personal ENABLE ROW LEVEL SECURITY;

-- Política: Usuarios autenticados pueden leer todos los registros
CREATE POLICY "Usuarios autenticados pueden leer equipamiento"
ON public.equipamiento_personal
FOR SELECT
TO authenticated
USING (true);

-- Política: Usuarios autenticados pueden insertar registros
CREATE POLICY "Usuarios autenticados pueden crear equipamiento"
ON public.equipamiento_personal
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Política: Usuarios autenticados pueden actualizar registros
CREATE POLICY "Usuarios autenticados pueden actualizar equipamiento"
ON public.equipamiento_personal
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Política: Usuarios autenticados pueden eliminar registros
CREATE POLICY "Usuarios autenticados pueden eliminar equipamiento"
ON public.equipamiento_personal
FOR DELETE
TO authenticated
USING (true);

-- ============================================
-- Comentarios sobre la tabla
-- ============================================

COMMENT ON TABLE public.equipamiento_personal IS 'Gestión de equipamiento asignado al personal';
COMMENT ON COLUMN public.equipamiento_personal.id IS 'Identificador único del equipamiento (UUID)';
COMMENT ON COLUMN public.equipamiento_personal.personal_id IS 'ID del personal al que se asigna el equipamiento';
COMMENT ON COLUMN public.equipamiento_personal.tipo_equipamiento IS 'Tipo: uniforme, epi, tecnologico, sanitario';
COMMENT ON COLUMN public.equipamiento_personal.nombre_equipamiento IS 'Nombre o descripción del equipamiento';
COMMENT ON COLUMN public.equipamiento_personal.fecha_asignacion IS 'Fecha en que se asignó el equipamiento';
COMMENT ON COLUMN public.equipamiento_personal.fecha_devolucion IS 'Fecha de devolución (NULL si aún está asignado)';
COMMENT ON COLUMN public.equipamiento_personal.estado IS 'Estado del equipamiento: nuevo, bueno, regular, malo, deteriorado';
COMMENT ON COLUMN public.equipamiento_personal.activo IS 'Indica si el registro está activo (soft delete)';

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
