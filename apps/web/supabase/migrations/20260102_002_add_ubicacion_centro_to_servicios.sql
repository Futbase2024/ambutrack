-- =====================================================
-- MIGRACIÓN: Agregar columnas ubicacion_centro a servicios
-- Descripción: Añade campos origen_ubicacion_centro y destino_ubicacion_centro
--              para almacenar ubicaciones específicas dentro de centros hospitalarios
-- Autor: Sistema AmbuTrack
-- Fecha: 2026-01-02
-- Dependencias: 20260102_001_fix_trigger_normalized_ubicaciones.sql
-- =====================================================

-- Agregar columnas ubicacion_centro a la tabla servicios
ALTER TABLE servicios
  ADD COLUMN IF NOT EXISTS origen_ubicacion_centro TEXT,
  ADD COLUMN IF NOT EXISTS destino_ubicacion_centro TEXT;

-- Comentarios explicativos
COMMENT ON COLUMN servicios.origen_ubicacion_centro IS
  'Ubicación específica dentro del centro de origen (ej: Urgencias, Hab-202, UCI). Campo opcional.';

COMMENT ON COLUMN servicios.destino_ubicacion_centro IS
  'Ubicación específica dentro del centro de destino (ej: Sala de Espera, Planta 3, Consultas). Campo opcional.';

-- Refrescar el schema cache de PostgREST
NOTIFY pgrst, 'reload schema';
