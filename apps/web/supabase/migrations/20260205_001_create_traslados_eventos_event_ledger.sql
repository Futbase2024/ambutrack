-- =====================================================
-- MIGRACIÓN: Event Ledger para Traslados
-- Fecha: 2026-02-05
-- Propósito: Implementar tabla de eventos para sincronización
--            en tiempo real entre web y mobile
-- =====================================================

-- 1. Crear tipo ENUM para tipos de eventos
CREATE TYPE evento_traslado_type AS ENUM (
  'assigned',      -- NULL → conductor (asignación inicial)
  'unassigned',    -- conductor → NULL (desasignación)
  'reassigned',    -- conductor A → conductor B (reasignación)
  'status_changed' -- cambio de estado del traslado
);

-- 2. Crear tabla de eventos
CREATE TABLE IF NOT EXISTS public.traslados_eventos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  traslado_id UUID NOT NULL REFERENCES public.traslados(id) ON DELETE CASCADE,
  event_type evento_traslado_type NOT NULL,

  -- Cambios de conductor
  old_conductor_id UUID REFERENCES public.personal(id) ON DELETE SET NULL,
  new_conductor_id UUID REFERENCES public.personal(id) ON DELETE SET NULL,

  -- Cambios de estado
  old_estado TEXT,
  new_estado TEXT,

  -- Auditoría
  actor_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Metadata adicional (JSON flexible para datos futuros)
  metadata JSONB,

  -- Constraint: Al menos debe haber un cambio de conductor O estado
  CONSTRAINT check_has_changes CHECK (
    (old_conductor_id IS NOT NULL OR new_conductor_id IS NOT NULL) OR
    (old_estado IS NOT NULL OR new_estado IS NOT NULL)
  )
);

-- 3. Crear índices para optimizar consultas
CREATE INDEX idx_traslados_eventos_traslado_id ON public.traslados_eventos(traslado_id);
CREATE INDEX idx_traslados_eventos_new_conductor ON public.traslados_eventos(new_conductor_id)
  WHERE new_conductor_id IS NOT NULL;
CREATE INDEX idx_traslados_eventos_old_conductor ON public.traslados_eventos(old_conductor_id)
  WHERE old_conductor_id IS NOT NULL;
CREATE INDEX idx_traslados_eventos_created_at ON public.traslados_eventos(created_at DESC);
CREATE INDEX idx_traslados_eventos_event_type ON public.traslados_eventos(event_type);

-- 4. Crear función del trigger que genera eventos automáticamente
CREATE OR REPLACE FUNCTION log_traslado_evento()
RETURNS TRIGGER
SECURITY DEFINER -- Permite insertar en tabla protegida por RLS
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_event_type evento_traslado_type;
  v_actor_user_id UUID;
BEGIN
  -- Obtener el usuario actual (si está disponible)
  BEGIN
    v_actor_user_id := auth.uid();
  EXCEPTION WHEN OTHERS THEN
    v_actor_user_id := NULL;
  END;

  -- Determinar el tipo de evento basado en los cambios

  -- CASO 1: Cambio de conductor (asignación, desasignación o reasignación)
  IF (OLD.id_conductor IS DISTINCT FROM NEW.id_conductor) THEN

    -- Sub-caso 1.1: NULL → conductor (asignación)
    IF OLD.id_conductor IS NULL AND NEW.id_conductor IS NOT NULL THEN
      v_event_type := 'assigned';

      INSERT INTO public.traslados_eventos (
        traslado_id,
        event_type,
        old_conductor_id,
        new_conductor_id,
        actor_user_id,
        metadata
      ) VALUES (
        NEW.id,
        v_event_type,
        OLD.id_conductor,
        NEW.id_conductor,
        v_actor_user_id,
        jsonb_build_object(
          'traslado_codigo', NEW.codigo,
          'timestamp', now()
        )
      );

    -- Sub-caso 1.2: conductor → NULL (desasignación)
    ELSIF OLD.id_conductor IS NOT NULL AND NEW.id_conductor IS NULL THEN
      v_event_type := 'unassigned';

      INSERT INTO public.traslados_eventos (
        traslado_id,
        event_type,
        old_conductor_id,
        new_conductor_id,
        actor_user_id,
        metadata
      ) VALUES (
        NEW.id,
        v_event_type,
        OLD.id_conductor,
        NEW.id_conductor,
        v_actor_user_id,
        jsonb_build_object(
          'traslado_codigo', NEW.codigo,
          'timestamp', now()
        )
      );

    -- Sub-caso 1.3: conductor A → conductor B (reasignación)
    ELSIF OLD.id_conductor IS NOT NULL AND NEW.id_conductor IS NOT NULL
          AND OLD.id_conductor <> NEW.id_conductor THEN
      v_event_type := 'reassigned';

      INSERT INTO public.traslados_eventos (
        traslado_id,
        event_type,
        old_conductor_id,
        new_conductor_id,
        actor_user_id,
        metadata
      ) VALUES (
        NEW.id,
        v_event_type,
        OLD.id_conductor,
        NEW.id_conductor,
        v_actor_user_id,
        jsonb_build_object(
          'traslado_codigo', NEW.codigo,
          'timestamp', now()
        )
      );
    END IF;
  END IF;

  -- CASO 2: Cambio de estado (independiente del conductor)
  IF (OLD.estado IS DISTINCT FROM NEW.estado) THEN
    v_event_type := 'status_changed';

    INSERT INTO public.traslados_eventos (
      traslado_id,
      event_type,
      old_conductor_id,
      new_conductor_id,
      old_estado,
      new_estado,
      actor_user_id,
      metadata
    ) VALUES (
      NEW.id,
      v_event_type,
      NEW.id_conductor, -- Mantener el conductor actual en ambos campos
      NEW.id_conductor,
      OLD.estado,
      NEW.estado,
      v_actor_user_id,
      jsonb_build_object(
        'traslado_codigo', NEW.codigo,
        'timestamp', now()
      )
    );
  END IF;

  RETURN NEW;
END;
$$;

-- 5. Crear trigger en tabla traslados
DROP TRIGGER IF EXISTS trigger_log_traslado_evento ON public.traslados;

CREATE TRIGGER trigger_log_traslado_evento
  AFTER UPDATE ON public.traslados
  FOR EACH ROW
  WHEN (
    -- Solo disparar si cambió el conductor O el estado
    (OLD.id_conductor IS DISTINCT FROM NEW.id_conductor) OR
    (OLD.estado IS DISTINCT FROM NEW.estado)
  )
  EXECUTE FUNCTION log_traslado_evento();

-- 6. Configurar Row Level Security (RLS)
ALTER TABLE public.traslados_eventos ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Los conductores solo ven eventos donde aparecen
CREATE POLICY "Conductores ven sus eventos"
ON public.traslados_eventos
FOR SELECT
USING (
  auth.uid() = new_conductor_id OR
  auth.uid() = old_conductor_id
);

-- RLS Policy: Admins y operadores ven todos los eventos
CREATE POLICY "Admins ven todos los eventos"
ON public.traslados_eventos
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.personal
    WHERE id = auth.uid()
    AND rol IN ('admin', 'operador', 'gerente')
  )
);

-- RLS Policy: Nadie puede insertar directamente (solo el trigger)
CREATE POLICY "Solo trigger puede insertar"
ON public.traslados_eventos
FOR INSERT
WITH CHECK (false); -- Bloquea inserts manuales

-- RLS Policy: Nadie puede actualizar eventos (son inmutables)
CREATE POLICY "Eventos son inmutables"
ON public.traslados_eventos
FOR UPDATE
WITH CHECK (false);

-- RLS Policy: Solo admins pueden eliminar eventos (para limpieza)
CREATE POLICY "Solo admins pueden eliminar"
ON public.traslados_eventos
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.personal
    WHERE id = auth.uid()
    AND rol = 'admin'
  )
);

-- 7. Habilitar Realtime en la tabla
ALTER PUBLICATION supabase_realtime ADD TABLE public.traslados_eventos;

-- 8. Comentarios para documentación
COMMENT ON TABLE public.traslados_eventos IS
'Event Ledger para traslados. Registra automáticamente cambios de conductor y estado para sincronización en tiempo real entre web y mobile.';

COMMENT ON COLUMN public.traslados_eventos.event_type IS
'Tipo de evento: assigned (asignación), unassigned (desasignación), reassigned (reasignación), status_changed (cambio de estado)';

COMMENT ON COLUMN public.traslados_eventos.metadata IS
'Metadata adicional en formato JSON. Flexible para agregar datos futuros sin necesidad de migración.';

COMMENT ON FUNCTION log_traslado_evento() IS
'Trigger function que genera eventos automáticamente cuando cambia id_conductor o estado en la tabla traslados.';

-- 9. Grant de permisos
GRANT SELECT ON public.traslados_eventos TO authenticated;
GRANT SELECT ON public.traslados_eventos TO anon;

-- =====================================================
-- FIN DE MIGRACIÓN
-- =====================================================

-- Verificación de la migración:
-- 1. SELECT * FROM traslados_eventos; (debe estar vacía)
-- 2. UPDATE traslados SET id_conductor = 'uuid' WHERE id = 'uuid'; (debe crear evento)
-- 3. SELECT * FROM traslados_eventos; (debe tener 1 evento)
