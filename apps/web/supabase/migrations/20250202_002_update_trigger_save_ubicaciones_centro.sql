-- =====================================================
-- TRIGGER: Actualizar generar_traslados_servicio_unico
-- Descripción: Extrae ubicaciones_centro del JSONB trayectos y las guarda en columnas dedicadas
-- Autor: Sistema AmbuTrack
-- Fecha: 2025-02-02
-- =====================================================

-- Función actualizada para generar traslados al crear servicio único
CREATE OR REPLACE FUNCTION generar_traslados_servicio_unico()
RETURNS TRIGGER AS $$
DECLARE
  v_traslados_generados INTEGER := 0;
  v_trayecto_ida JSONB;
  v_trayecto_vuelta JSONB;
  v_origen_ubicacion_centro TEXT;
  v_destino_ubicacion_centro TEXT;
BEGIN
  -- Solo procesar si es tipo_recurrencia = 'unico'
  IF NEW.tipo_recurrencia != 'unico' THEN
    RETURN NEW;
  END IF;

  RAISE NOTICE 'Generando traslados para servicio único: % (fecha: %)', NEW.codigo, NEW.fecha_servicio_inicio;

  -- Extraer el primer trayecto del array JSONB (IDA)
  IF jsonb_array_length(NEW.trayectos) > 0 THEN
    v_trayecto_ida := NEW.trayectos->0;

    -- Extraer ubicaciones en centro (pueden ser null)
    v_origen_ubicacion_centro := v_trayecto_ida->>'origen_ubicacion_centro';
    v_destino_ubicacion_centro := v_trayecto_ida->>'destino_ubicacion_centro';
  END IF;

  -- TRASLADO DE IDA (siempre se crea)
  INSERT INTO traslados (
    id_servicio,
    id_servicio_recurrente,
    id_paciente,
    tipo_traslado,
    fecha,
    hora_programada,
    trayecto,
    origen_ubicacion_centro,  -- 🆕 NUEVO CAMPO
    destino_ubicacion_centro, -- 🆕 NUEVO CAMPO
    observaciones,
    generado_automaticamente,
    created_by
  )
  VALUES (
    NEW.id,
    NULL,
    NEW.id_paciente,
    'ida',
    NEW.fecha_servicio_inicio,
    NEW.hora_recogida,
    v_trayecto_ida,  -- Solo el primer trayecto para IDA
    v_origen_ubicacion_centro,  -- 🆕 Ubicación en origen (ej: Urgencias)
    v_destino_ubicacion_centro, -- 🆕 Ubicación en destino (ej: Hab-202)
    NEW.observaciones,
    true,
    NEW.created_by
  )
  ON CONFLICT (id_servicio_recurrente, id_servicio, fecha, tipo_traslado) DO NOTHING;

  IF FOUND THEN
    v_traslados_generados := v_traslados_generados + 1;
    RAISE NOTICE '✅ Traslado de IDA generado para servicio único % (origen_ubic: %, destino_ubic: %)',
      NEW.codigo, v_origen_ubicacion_centro, v_destino_ubicacion_centro;
  END IF;

  -- TRASLADO DE VUELTA (solo si requiere_vuelta = true)
  IF NEW.requiere_vuelta = true THEN
    IF NEW.hora_vuelta IS NULL THEN
      RAISE EXCEPTION 'INCONSISTENCIA: requiere_vuelta = true pero hora_vuelta es NULL en servicio %', NEW.codigo;
    END IF;

    -- Extraer el segundo trayecto del array JSONB (VUELTA)
    IF jsonb_array_length(NEW.trayectos) > 1 THEN
      v_trayecto_vuelta := NEW.trayectos->1;

      -- Extraer ubicaciones en centro para la vuelta
      v_origen_ubicacion_centro := v_trayecto_vuelta->>'origen_ubicacion_centro';
      v_destino_ubicacion_centro := v_trayecto_vuelta->>'destino_ubicacion_centro';
    ELSE
      -- Si solo hay un trayecto, usarlo invertido para la vuelta
      v_trayecto_vuelta := v_trayecto_ida;
      -- Las ubicaciones se invierten (origen → destino, destino → origen)
      v_origen_ubicacion_centro := v_trayecto_ida->>'destino_ubicacion_centro';
      v_destino_ubicacion_centro := v_trayecto_ida->>'origen_ubicacion_centro';
    END IF;

    INSERT INTO traslados (
      id_servicio,
      id_servicio_recurrente,
      id_paciente,
      tipo_traslado,
      fecha,
      hora_programada,
      trayecto,
      origen_ubicacion_centro,  -- 🆕 NUEVO CAMPO
      destino_ubicacion_centro, -- 🆕 NUEVO CAMPO
      observaciones,
      generado_automaticamente,
      created_by
    )
    VALUES (
      NEW.id,
      NULL,
      NEW.id_paciente,
      'vuelta',
      NEW.fecha_servicio_inicio,
      NEW.hora_vuelta,
      v_trayecto_vuelta,
      v_origen_ubicacion_centro,  -- 🆕 Ubicación en origen de vuelta
      v_destino_ubicacion_centro, -- 🆕 Ubicación en destino de vuelta
      NEW.observaciones,
      true,
      NEW.created_by
    )
    ON CONFLICT (id_servicio_recurrente, id_servicio, fecha, tipo_traslado) DO NOTHING;

    IF FOUND THEN
      v_traslados_generados := v_traslados_generados + 1;
      RAISE NOTICE '✅ Traslado de VUELTA generado para servicio único % (origen_ubic: %, destino_ubic: %)',
        NEW.codigo, v_origen_ubicacion_centro, v_destino_ubicacion_centro;
    END IF;
  ELSE
    RAISE NOTICE 'ℹ️ Servicio único % NO requiere vuelta (requiere_vuelta = false)', NEW.codigo;
  END IF;

  RAISE NOTICE 'Generados % traslados para servicio único %', v_traslados_generados, NEW.codigo;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- El trigger ya está creado, solo necesitamos reemplazar la función
COMMENT ON FUNCTION generar_traslados_servicio_unico() IS
'Genera traslados automáticamente al crear un servicio ÚNICO.
Lee el campo trayectos JSONB de la tabla servicios y extrae:
  - Datos del trayecto completo (JSONB)
  - origen_ubicacion_centro (ej: Urgencias, Hab-202) → columna dedicada
  - destino_ubicacion_centro (ej: UCI, Sala de Espera) → columna dedicada
Crea 1 traslado de IDA (siempre) y opcionalmente 1 traslado de VUELTA si requiere_vuelta = true.';

-- Refrescar el schema cache
NOTIFY pgrst, 'reload schema';
