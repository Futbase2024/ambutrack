-- ============================================
-- Crear tabla 'vestuario' en Supabase
-- ============================================
-- Tabla para gestión de vestuario y uniformes del personal
-- Relacionada con: personal (personalId)
-- ============================================

CREATE TABLE IF NOT EXISTS public.vestuario (
  -- Identificador único (UUID generado automáticamente)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Relación con personal
  personal_id TEXT NOT NULL,

  -- Información de la prenda
  prenda TEXT NOT NULL,
  talla TEXT,

  -- Fechas de entrega y devolución
  fecha_entrega TIMESTAMPTZ NOT NULL,
  fecha_devolucion TIMESTAMPTZ,

  -- Detalles de la prenda
  cantidad INTEGER,
  marca TEXT,
  color TEXT,
  estado TEXT CHECK (estado IN ('nuevo', 'bueno', 'regular', 'malo')),
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
CREATE INDEX IF NOT EXISTS idx_vestuario_personal_id
ON public.vestuario(personal_id);

-- Índice para búsqueda por prenda
CREATE INDEX IF NOT EXISTS idx_vestuario_prenda
ON public.vestuario(prenda);

-- Índice para filtrar activos
CREATE INDEX IF NOT EXISTS idx_vestuario_activo
ON public.vestuario(activo);

-- Índice para vestuario asignado (sin devolver)
CREATE INDEX IF NOT EXISTS idx_vestuario_asignado
ON public.vestuario(personal_id, fecha_devolucion)
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

CREATE TRIGGER update_vestuario_updated_at
BEFORE UPDATE ON public.vestuario
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Row Level Security (RLS)
-- ============================================

-- Habilitar RLS en la tabla
ALTER TABLE public.vestuario ENABLE ROW LEVEL SECURITY;

-- Política: Usuarios autenticados pueden leer todos los registros
CREATE POLICY "Usuarios autenticados pueden leer vestuario"
ON public.vestuario
FOR SELECT
TO authenticated
USING (true);

-- Política: Usuarios autenticados pueden insertar registros
CREATE POLICY "Usuarios autenticados pueden crear vestuario"
ON public.vestuario
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Política: Usuarios autenticados pueden actualizar registros
CREATE POLICY "Usuarios autenticados pueden actualizar vestuario"
ON public.vestuario
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Política: Usuarios autenticados pueden eliminar registros
CREATE POLICY "Usuarios autenticados pueden eliminar vestuario"
ON public.vestuario
FOR DELETE
TO authenticated
USING (true);

-- ============================================
-- Comentarios sobre la tabla
-- ============================================

COMMENT ON TABLE public.vestuario IS 'Gestión de vestuario y uniformes del personal';
COMMENT ON COLUMN public.vestuario.id IS 'Identificador único del vestuario (UUID)';
COMMENT ON COLUMN public.vestuario.personal_id IS 'ID del personal al que se entrega el vestuario';
COMMENT ON COLUMN public.vestuario.prenda IS 'Tipo de prenda (pantalón, camisa, chaleco, etc.)';
COMMENT ON COLUMN public.vestuario.talla IS 'Talla de la prenda';
COMMENT ON COLUMN public.vestuario.fecha_entrega IS 'Fecha en que se entregó la prenda';
COMMENT ON COLUMN public.vestuario.fecha_devolucion IS 'Fecha de devolución (NULL si aún está asignado)';
COMMENT ON COLUMN public.vestuario.cantidad IS 'Cantidad de prendas entregadas';
COMMENT ON COLUMN public.vestuario.estado IS 'Estado de la prenda: nuevo, bueno, regular, malo';
COMMENT ON COLUMN public.vestuario.activo IS 'Indica si el registro está activo (soft delete)';

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
