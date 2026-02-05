-- =====================================================
-- MIGRACIÓN: Agregar campo requiere_ayudante a servicios
-- Descripción: Agrega el campo requiere_ayudante para indicar
--              si el servicio necesita ayudante adicional
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-01-30
-- =====================================================

-- Agregar columna requiere_ayudante a la tabla servicios
ALTER TABLE servicios
ADD COLUMN IF NOT EXISTS requiere_ayudante BOOLEAN DEFAULT false;

-- Comentario de documentación
COMMENT ON COLUMN servicios.requiere_ayudante IS 'Indica si el servicio requiere ayudante adicional al personal sanitario';
