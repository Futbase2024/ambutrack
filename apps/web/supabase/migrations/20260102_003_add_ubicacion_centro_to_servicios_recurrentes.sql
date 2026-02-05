-- =====================================================
-- MIGRACIÓN: Agregar campos de trayectos a servicios_recurrentes
-- Descripción: Añade campos tipo_origen, origen, origen_ubicacion_centro,
--              tipo_destino, destino, destino_ubicacion_centro
--              para almacenar información de trayectos en servicios recurrentes
-- Autor: Sistema AmbuTrack
-- Fecha: 2026-01-02
-- Dependencias: 20260102_002_add_ubicacion_centro_to_servicios.sql
-- =====================================================

-- Agregar campos de trayectos a la tabla servicios_recurrentes
ALTER TABLE servicios_recurrentes
  ADD COLUMN IF NOT EXISTS tipo_origen tipo_ubicacion,
  ADD COLUMN IF NOT EXISTS origen TEXT,
  ADD COLUMN IF NOT EXISTS origen_ubicacion_centro TEXT,
  ADD COLUMN IF NOT EXISTS tipo_destino tipo_ubicacion,
  ADD COLUMN IF NOT EXISTS destino TEXT,
  ADD COLUMN IF NOT EXISTS destino_ubicacion_centro TEXT;

-- Comentarios explicativos
COMMENT ON COLUMN servicios_recurrentes.tipo_origen IS
  'Tipo de ubicación de origen: domicilio_paciente o centro_hospitalario';

COMMENT ON COLUMN servicios_recurrentes.origen IS
  'Dirección del domicilio o nombre del centro hospitalario de origen';

COMMENT ON COLUMN servicios_recurrentes.origen_ubicacion_centro IS
  'Ubicación específica dentro del centro de origen (ej: Urgencias, Hab-202, UCI). Campo opcional.';

COMMENT ON COLUMN servicios_recurrentes.tipo_destino IS
  'Tipo de ubicación de destino: domicilio_paciente o centro_hospitalario';

COMMENT ON COLUMN servicios_recurrentes.destino IS
  'Dirección del domicilio o nombre del centro hospitalario de destino';

COMMENT ON COLUMN servicios_recurrentes.destino_ubicacion_centro IS
  'Ubicación específica dentro del centro de destino (ej: Sala de Espera, Planta 3, Consultas). Campo opcional.';

-- Refrescar el schema cache de PostgREST
NOTIFY pgrst, 'reload schema';
