-- ============================================
-- Crear tabla 'turnos' en Supabase
-- ============================================
-- Tabla para gestión de turnos de trabajo del personal
-- Relacionada con: personal (idPersonal)
-- ============================================

CREATE TABLE IF NOT EXISTS public.turnos (
  -- Identificador único (UUID generado automáticamente)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Relación con personal
  "idPersonal" TEXT NOT NULL,
  "nombrePersonal" TEXT NOT NULL,

  -- Tipo de turno
  "tipoTurno" TEXT NOT NULL CHECK ("tipoTurno" IN ('manana', 'tarde', 'noche', 'personalizado')),

  -- Rango de fechas
  "fechaInicio" TIMESTAMPTZ NOT NULL,
  "fechaFin" TIMESTAMPTZ NOT NULL,

  -- Horas del turno (formato HH:mm)
  "horaInicio" TEXT NOT NULL,
  "horaFin" TEXT NOT NULL,

  -- Información adicional
  observaciones TEXT,

  -- Estado
  activo BOOLEAN NOT NULL DEFAULT true,

  -- Timestamps automáticos
  "createdAt" TIMESTAMPTZ DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Índices para optimizar consultas
-- ============================================

-- Índice para búsqueda por personal
CREATE INDEX IF NOT EXISTS idx_turnos_id_personal
ON public.turnos("idPersonal");

-- Índice para búsqueda por rango de fechas
CREATE INDEX IF NOT EXISTS idx_turnos_fecha_inicio
ON public.turnos("fechaInicio");

CREATE INDEX IF NOT EXISTS idx_turnos_fecha_fin
ON public.turnos("fechaFin");

-- Índice para filtrar activos
CREATE INDEX IF NOT EXISTS idx_turnos_activo
ON public.turnos(activo);

-- Índice compuesto para búsqueda de conflictos
CREATE INDEX IF NOT EXISTS idx_turnos_personal_fechas
ON public.turnos("idPersonal", "fechaInicio", "fechaFin")
WHERE activo = true;

-- ============================================
-- Trigger para actualizar updatedAt automáticamente
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_turnos_updated_at
BEFORE UPDATE ON public.turnos
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Row Level Security (RLS)
-- ============================================

-- Habilitar RLS en la tabla
ALTER TABLE public.turnos ENABLE ROW LEVEL SECURITY;

-- Política: Usuarios autenticados pueden leer todos los turnos
CREATE POLICY "Usuarios autenticados pueden leer turnos"
ON public.turnos
FOR SELECT
TO authenticated
USING (true);

-- Política: Usuarios autenticados pueden insertar turnos
CREATE POLICY "Usuarios autenticados pueden crear turnos"
ON public.turnos
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Política: Usuarios autenticados pueden actualizar turnos
CREATE POLICY "Usuarios autenticados pueden actualizar turnos"
ON public.turnos
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Política: Usuarios autenticados pueden eliminar (soft delete) turnos
CREATE POLICY "Usuarios autenticados pueden eliminar turnos"
ON public.turnos
FOR DELETE
TO authenticated
USING (true);

-- ============================================
-- Comentarios sobre la tabla
-- ============================================

COMMENT ON TABLE public.turnos IS 'Gestión de turnos de trabajo del personal';
COMMENT ON COLUMN public.turnos.id IS 'Identificador único del turno (UUID)';
COMMENT ON COLUMN public.turnos."idPersonal" IS 'ID del personal asignado al turno';
COMMENT ON COLUMN public.turnos."nombrePersonal" IS 'Nombre del personal (desnormalizado para consultas rápidas)';
COMMENT ON COLUMN public.turnos."tipoTurno" IS 'Tipo de turno: manana, tarde, noche, personalizado';
COMMENT ON COLUMN public.turnos."fechaInicio" IS 'Fecha de inicio del turno';
COMMENT ON COLUMN public.turnos."fechaFin" IS 'Fecha de fin del turno';
COMMENT ON COLUMN public.turnos."horaInicio" IS 'Hora de inicio (formato HH:mm)';
COMMENT ON COLUMN public.turnos."horaFin" IS 'Hora de fin (formato HH:mm)';
COMMENT ON COLUMN public.turnos.observaciones IS 'Notas u observaciones del turno';
COMMENT ON COLUMN public.turnos.activo IS 'Indica si el turno está activo (soft delete)';

-- ============================================
-- Datos de ejemplo (OPCIONAL - comentar si no se necesita)
-- ============================================

/*
INSERT INTO public.turnos ("idPersonal", "nombrePersonal", "tipoTurno", "fechaInicio", "fechaFin", "horaInicio", "horaFin", activo)
VALUES
  ('personal-uuid-1', 'Juan Pérez', 'manana', '2025-01-20 00:00:00+00', '2025-01-20 23:59:59+00', '07:00', '15:00', true),
  ('personal-uuid-2', 'María García', 'tarde', '2025-01-20 00:00:00+00', '2025-01-20 23:59:59+00', '15:00', '23:00', true),
  ('personal-uuid-3', 'Carlos López', 'noche', '2025-01-20 00:00:00+00', '2025-01-21 23:59:59+00', '23:00', '07:00', true);
*/

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
