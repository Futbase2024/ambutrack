-- =====================================================
-- FUNCIÓN: cambiar_estado_traslado
-- Descripción: Cambia el estado de un traslado validando transiciones
-- y registrando cronas, ubicaciones y auditoría
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-01-30
-- =====================================================

CREATE OR REPLACE FUNCTION cambiar_estado_traslado(
  p_id_traslado UUID,
  p_estado_nuevo VARCHAR(50),
  p_usuario_id UUID DEFAULT NULL,
  p_ubicacion JSONB DEFAULT NULL,
  p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
  success BOOLEAN,
  message TEXT,
  traslado_actualizado JSONB
) AS $$
DECLARE
  v_traslado RECORD;
  v_transicion_valida BOOLEAN := false;
  v_campo_crona TEXT;
  v_campo_ubicacion TEXT;
  v_update_query TEXT;
BEGIN
  -- Obtener el traslado actual
  SELECT * INTO v_traslado
  FROM traslados
  WHERE id = p_id_traslado;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Traslado no encontrado', NULL::JSONB;
    RETURN;
  END IF;

  -- Validar transiciones de estado permitidas
  CASE v_traslado.estado
    WHEN 'pendiente' THEN
      v_transicion_valida := p_estado_nuevo IN ('asignado', 'cancelado');

    WHEN 'asignado' THEN
      v_transicion_valida := p_estado_nuevo IN ('enviado', 'cancelado');

    WHEN 'enviado' THEN
      v_transicion_valida := p_estado_nuevo IN ('recibido_conductor', 'cancelado');

    WHEN 'recibido_conductor' THEN
      v_transicion_valida := p_estado_nuevo IN ('en_origen', 'cancelado', 'no_realizado');

    WHEN 'en_origen' THEN
      v_transicion_valida := p_estado_nuevo IN ('saliendo_origen', 'cancelado', 'no_realizado');

    WHEN 'saliendo_origen' THEN
      v_transicion_valida := p_estado_nuevo IN ('en_transito', 'en_destino', 'cancelado', 'no_realizado');

    WHEN 'en_transito' THEN
      v_transicion_valida := p_estado_nuevo IN ('en_destino', 'cancelado', 'no_realizado');

    WHEN 'en_destino' THEN
      v_transicion_valida := p_estado_nuevo IN ('finalizado', 'cancelado', 'no_realizado');

    WHEN 'finalizado' THEN
      -- No se puede cambiar desde finalizado (estado terminal)
      v_transicion_valida := false;

    WHEN 'cancelado' THEN
      -- No se puede cambiar desde cancelado (estado terminal)
      v_transicion_valida := false;

    WHEN 'no_realizado' THEN
      -- No se puede cambiar desde no_realizado (estado terminal)
      v_transicion_valida := false;

    ELSE
      v_transicion_valida := false;
  END CASE;

  -- Si la transición no es válida, retornar error
  IF NOT v_transicion_valida THEN
    RETURN QUERY SELECT
      false,
      'Transición no válida: ' || v_traslado.estado || ' → ' || p_estado_nuevo,
      NULL::JSONB;
    RETURN;
  END IF;

  -- Determinar qué campo de crona actualizar según el nuevo estado
  CASE p_estado_nuevo
    WHEN 'asignado' THEN
      v_campo_crona := 'fecha_asignacion';

    WHEN 'enviado' THEN
      v_campo_crona := 'fecha_enviado';

    WHEN 'recibido_conductor' THEN
      v_campo_crona := 'fecha_recibido_conductor';

    WHEN 'en_origen' THEN
      v_campo_crona := 'fecha_en_origen';
      v_campo_ubicacion := 'ubicacion_en_origen';

    WHEN 'saliendo_origen' THEN
      v_campo_crona := 'fecha_saliendo_origen';
      v_campo_ubicacion := 'ubicacion_saliendo_origen';

    WHEN 'en_destino' THEN
      v_campo_crona := 'fecha_en_destino';
      v_campo_ubicacion := 'ubicacion_en_destino';

    WHEN 'finalizado' THEN
      v_campo_crona := 'fecha_finalizado';
      v_campo_ubicacion := 'ubicacion_finalizado';

    WHEN 'cancelado' THEN
      v_campo_crona := 'fecha_cancelacion';

    ELSE
      v_campo_crona := NULL;
      v_campo_ubicacion := NULL;
  END CASE;

  -- Construir y ejecutar UPDATE dinámico
  v_update_query := 'UPDATE traslados SET estado = $1, updated_at = now(), updated_by = $2';

  IF v_campo_crona IS NOT NULL THEN
    v_update_query := v_update_query || ', ' || v_campo_crona || ' = now()';
  END IF;

  IF v_campo_ubicacion IS NOT NULL AND p_ubicacion IS NOT NULL THEN
    v_update_query := v_update_query || ', ' || v_campo_ubicacion || ' = $3';
  END IF;

  -- Campos especiales para asignación
  IF p_estado_nuevo = 'asignado' AND p_usuario_id IS NOT NULL THEN
    v_update_query := v_update_query || ', usuario_asignacion = $2';
  END IF;

  -- Campos especiales para envío
  IF p_estado_nuevo = 'enviado' AND p_usuario_id IS NOT NULL THEN
    v_update_query := v_update_query || ', usuario_envio = $2';
  END IF;

  -- Campos especiales para cancelación
  IF p_estado_nuevo = 'cancelado' AND p_usuario_id IS NOT NULL THEN
    v_update_query := v_update_query || ', usuario_cancelacion = $2';
    IF p_observaciones IS NOT NULL THEN
      v_update_query := v_update_query || ', observaciones_cancelacion = $4';
    END IF;
  END IF;

  v_update_query := v_update_query || ' WHERE id = $5 RETURNING *';

  -- Ejecutar UPDATE
  IF v_campo_ubicacion IS NOT NULL AND p_ubicacion IS NOT NULL THEN
    IF p_estado_nuevo = 'cancelado' AND p_observaciones IS NOT NULL THEN
      EXECUTE v_update_query
      INTO v_traslado
      USING p_estado_nuevo, p_usuario_id, p_ubicacion, p_observaciones, p_id_traslado;
    ELSE
      EXECUTE v_update_query
      INTO v_traslado
      USING p_estado_nuevo, p_usuario_id, p_ubicacion, p_id_traslado;
    END IF;
  ELSE
    IF p_estado_nuevo = 'cancelado' AND p_observaciones IS NOT NULL THEN
      EXECUTE v_update_query
      INTO v_traslado
      USING p_estado_nuevo, p_usuario_id, p_observaciones, p_id_traslado;
    ELSE
      EXECUTE v_update_query
      INTO v_traslado
      USING p_estado_nuevo, p_usuario_id, p_id_traslado;
    END IF;
  END IF;

  -- Insertar en historial (el trigger ya lo hace, pero podemos agregar ubicación)
  INSERT INTO historial_estados_traslado (
    id_traslado,
    estado_anterior,
    estado_nuevo,
    id_usuario,
    ubicacion,
    observaciones,
    fecha_cambio
  ) VALUES (
    p_id_traslado,
    v_traslado.estado,
    p_estado_nuevo,
    p_usuario_id,
    p_ubicacion,
    p_observaciones,
    now()
  );

  -- Retornar éxito con el traslado actualizado
  RETURN QUERY SELECT
    true,
    'Estado cambiado: ' || v_traslado.estado || ' → ' || p_estado_nuevo,
    row_to_json(v_traslado)::JSONB;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN AUXILIAR: validar_estado_traslado
-- Descripción: Valida si una transición de estado es válida
-- =====================================================

CREATE OR REPLACE FUNCTION validar_estado_traslado(
  p_estado_actual VARCHAR(50),
  p_estado_nuevo VARCHAR(50)
)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN CASE p_estado_actual
    WHEN 'pendiente' THEN p_estado_nuevo IN ('asignado', 'cancelado')
    WHEN 'asignado' THEN p_estado_nuevo IN ('enviado', 'cancelado')
    WHEN 'enviado' THEN p_estado_nuevo IN ('recibido_conductor', 'cancelado')
    WHEN 'recibido_conductor' THEN p_estado_nuevo IN ('en_origen', 'cancelado', 'no_realizado')
    WHEN 'en_origen' THEN p_estado_nuevo IN ('saliendo_origen', 'cancelado', 'no_realizado')
    WHEN 'saliendo_origen' THEN p_estado_nuevo IN ('en_transito', 'en_destino', 'cancelado', 'no_realizado')
    WHEN 'en_transito' THEN p_estado_nuevo IN ('en_destino', 'cancelado', 'no_realizado')
    WHEN 'en_destino' THEN p_estado_nuevo IN ('finalizado', 'cancelado', 'no_realizado')
    ELSE false
  END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =====================================================
-- FUNCIÓN AUXILIAR: obtener_estados_disponibles
-- Descripción: Retorna los estados válidos a los que se puede transicionar
-- =====================================================

CREATE OR REPLACE FUNCTION obtener_estados_disponibles(p_estado_actual VARCHAR(50))
RETURNS TEXT[] AS $$
BEGIN
  RETURN CASE p_estado_actual
    WHEN 'pendiente' THEN ARRAY['asignado', 'cancelado']::TEXT[]
    WHEN 'asignado' THEN ARRAY['enviado', 'cancelado']::TEXT[]
    WHEN 'enviado' THEN ARRAY['recibido_conductor', 'cancelado']::TEXT[]
    WHEN 'recibido_conductor' THEN ARRAY['en_origen', 'cancelado', 'no_realizado']::TEXT[]
    WHEN 'en_origen' THEN ARRAY['saliendo_origen', 'cancelado', 'no_realizado']::TEXT[]
    WHEN 'saliendo_origen' THEN ARRAY['en_transito', 'en_destino', 'cancelado', 'no_realizado']::TEXT[]
    WHEN 'en_transito' THEN ARRAY['en_destino', 'cancelado', 'no_realizado']::TEXT[]
    WHEN 'en_destino' THEN ARRAY['finalizado', 'cancelado', 'no_realizado']::TEXT[]
    ELSE ARRAY[]::TEXT[]
  END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON FUNCTION cambiar_estado_traslado(UUID, VARCHAR, UUID, JSONB, TEXT) IS
'Cambia el estado de un traslado validando que la transición sea válida.
Actualiza automáticamente los campos de crona (fecha_X) y ubicación correspondientes.
Registra el cambio en historial_estados_traslado.
Retorna éxito/error y el traslado actualizado en formato JSON.';

COMMENT ON FUNCTION validar_estado_traslado(VARCHAR, VARCHAR) IS
'Valida si una transición de estado es válida según el flujo del conductor.
Útil para checks en la app antes de intentar cambiar el estado.';

COMMENT ON FUNCTION obtener_estados_disponibles(VARCHAR) IS
'Retorna un array con los estados válidos a los que se puede transicionar desde el estado actual.
Útil para mostrar opciones disponibles en la UI.';
