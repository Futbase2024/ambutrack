-- =====================================================
-- MIGRACIÓN: Agregar 'anulado' como estado válido en traslados
-- Fecha: 2026-01-03
-- Descripción: Modifica el CHECK constraint para incluir 'anulado'
-- =====================================================

-- Eliminar el constraint existente
ALTER TABLE traslados DROP CONSTRAINT IF EXISTS ck_traslados_estado;

-- Crear el nuevo constraint con 'anulado' incluido
ALTER TABLE traslados ADD CONSTRAINT ck_traslados_estado CHECK (estado IN (
  'pendiente',           -- Traslado generado, no asignado
  'asignado',            -- Vehículo y conductor asignados
  'enviado',             -- Enviado al conductor (notificación)
  'recibido_conductor',  -- Conductor confirmó recepción
  'en_origen',           -- Conductor llegó al origen
  'saliendo_origen',     -- Conductor salió del origen con paciente
  'en_transito',         -- Conductor en camino al destino
  'en_destino',          -- Conductor llegó al destino
  'finalizado',          -- Traslado completado exitosamente
  'cancelado',           -- Traslado cancelado (temporal)
  'anulado',             -- Traslado anulado (definitivo)
  'no_realizado'         -- Traslado no se pudo realizar
));

-- Comentario
COMMENT ON CONSTRAINT ck_traslados_estado ON traslados IS
'Estados válidos para traslados: pendiente, asignado, enviado, recibido_conductor, en_origen, saliendo_origen, en_transito, en_destino, finalizado, cancelado, anulado, no_realizado';
