-- =====================================================
-- Tabla: plantillas_turnos
-- Descripción: Plantillas predefinidas para turnos
-- Autor: AmbuTrack System
-- Fecha: 2025-12-20
-- =====================================================

-- Eliminar tabla si existe (solo para desarrollo)
-- DROP TABLE IF EXISTS public.plantillas_turnos CASCADE;

-- Crear tabla plantillas_turnos
CREATE TABLE IF NOT EXISTS public.plantillas_turnos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  hora_inicio TIME NOT NULL,
  hora_fin TIME NOT NULL,
  tipo_turno VARCHAR(50) NOT NULL, -- 'mañana', 'tarde', 'noche', 'partido', 'continuo'
  color VARCHAR(7) DEFAULT '#1E40AF', -- Color en formato hex para visualización
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id)
);

-- Índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_plantillas_turnos_activo
  ON public.plantillas_turnos(activo);

CREATE INDEX IF NOT EXISTS idx_plantillas_turnos_tipo_turno
  ON public.plantillas_turnos(tipo_turno);

CREATE INDEX IF NOT EXISTS idx_plantillas_turnos_nombre
  ON public.plantillas_turnos(nombre);

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_plantillas_turnos_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_plantillas_turnos_updated_at
  BEFORE UPDATE ON public.plantillas_turnos
  FOR EACH ROW
  EXECUTE FUNCTION update_plantillas_turnos_updated_at();

-- Habilitar RLS (Row Level Security)
ALTER TABLE public.plantillas_turnos ENABLE ROW LEVEL SECURITY;

-- Política: Permitir lectura a usuarios autenticados
CREATE POLICY "Permitir lectura de plantillas a usuarios autenticados"
  ON public.plantillas_turnos
  FOR SELECT
  TO authenticated
  USING (true);

-- Política: Permitir inserción a usuarios autenticados
CREATE POLICY "Permitir creación de plantillas a usuarios autenticados"
  ON public.plantillas_turnos
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Política: Permitir actualización a usuarios autenticados
CREATE POLICY "Permitir actualización de plantillas a usuarios autenticados"
  ON public.plantillas_turnos
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Política: Permitir eliminación a usuarios autenticados
CREATE POLICY "Permitir eliminación de plantillas a usuarios autenticados"
  ON public.plantillas_turnos
  FOR DELETE
  TO authenticated
  USING (true);

-- Comentarios en la tabla y columnas
COMMENT ON TABLE public.plantillas_turnos IS 'Plantillas predefinidas para turnos del personal';
COMMENT ON COLUMN public.plantillas_turnos.id IS 'ID único de la plantilla (UUID)';
COMMENT ON COLUMN public.plantillas_turnos.nombre IS 'Nombre de la plantilla (ej: "Turno Mañana 07:00-15:00")';
COMMENT ON COLUMN public.plantillas_turnos.descripcion IS 'Descripción opcional de la plantilla';
COMMENT ON COLUMN public.plantillas_turnos.hora_inicio IS 'Hora de inicio del turno';
COMMENT ON COLUMN public.plantillas_turnos.hora_fin IS 'Hora de fin del turno';
COMMENT ON COLUMN public.plantillas_turnos.tipo_turno IS 'Tipo de turno: mañana, tarde, noche, partido, continuo';
COMMENT ON COLUMN public.plantillas_turnos.color IS 'Color en formato hex (#RRGGBB) para visualización';
COMMENT ON COLUMN public.plantillas_turnos.activo IS 'Indica si la plantilla está activa';

-- Insertar plantillas por defecto
INSERT INTO public.plantillas_turnos (nombre, descripcion, hora_inicio, hora_fin, tipo_turno, color) VALUES
  ('Turno Mañana', 'Turno de mañana estándar', '07:00:00', '15:00:00', 'mañana', '#1E40AF'),
  ('Turno Tarde', 'Turno de tarde estándar', '15:00:00', '23:00:00', 'tarde', '#059669'),
  ('Turno Noche', 'Turno de noche estándar', '23:00:00', '07:00:00', 'noche', '#6B7280'),
  ('Turno Partido (Mañana)', 'Turno partido mañana', '07:00:00', '12:00:00', 'partido', '#3B82F6'),
  ('Turno Partido (Tarde)', 'Turno partido tarde', '17:00:00', '22:00:00', 'partido', '#10B981'),
  ('Turno 12h Diurno', 'Turno continuo 12h diurno', '08:00:00', '20:00:00', 'continuo', '#DC2626'),
  ('Turno 12h Nocturno', 'Turno continuo 12h nocturno', '20:00:00', '08:00:00', 'continuo', '#EA580C'),
  ('Turno 24h', 'Turno continuo 24 horas', '08:00:00', '08:00:00', 'continuo', '#D97706')
ON CONFLICT DO NOTHING;

-- Verificación final
SELECT
  COUNT(*) as total_plantillas,
  COUNT(*) FILTER (WHERE activo = true) as plantillas_activas
FROM public.plantillas_turnos;

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================
