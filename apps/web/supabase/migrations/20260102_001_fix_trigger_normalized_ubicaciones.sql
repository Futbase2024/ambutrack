-- =====================================================
-- TRIGGER: Actualizar generar_traslados para arquitectura normalizada
-- Descripción: Copia campos normalizados de servicios a traslados
-- Arquitectura: Campos normalizados (NO JSONB)
--   servicios.tipo_origen → traslados.tipo_origen
--   servicios.origen → traslados.origen
--   servicios.origen_ubicacion_centro → traslados.origen_ubicacion_centro
--   servicios.tipo_destino → traslados.tipo_destino
--   servicios.destino → traslados.destino
--   servicios.destino_ubicacion_centro → traslados.destino_ubicacion_centro
-- Autor: Sistema AmbuTrack
-- Fecha: 2026-01-02
-- =====================================================

-- Función actualizada para generar traslados con campos normalizados
CREATE OR REPLACE FUNCTION generar_traslados_servicio_unico()
RETURNS TRIGGER AS $$
DECLARE
  v_traslados_generados INTEGER := 0;
BEGIN
  -- Solo procesar si es tipo_recurrencia = 'unico'
  IF NEW.tipo_recurrencia != 'unico' THEN
    RETURN NEW;
  END IF;

  RAISE NOTICE 'Generando traslados para servicio único: % (fecha: %)', NEW.codigo, NEW.fecha_servicio_inicio;

  -- TRASLADO DE IDA (siempre se crea)
  INSERT INTO traslados (
    id_servicio,
    id_servicio_recurrente,
    id_paciente,
    tipo_traslado,
    fecha,
    hora_programada,
    tipo_origen,              -- ✅ Campo normalizado de servicios
    origen,                   -- ✅ Campo normalizado de servicios
    origen_ubicacion_centro,  -- ✅ NUEVO: Ubicación en centro (ej: Urgencias, Hab-202)
    tipo_destino,             -- ✅ Campo normalizado de servicios
    destino,                  -- ✅ Campo normalizado de servicios
    destino_ubicacion_centro, -- ✅ NUEVO: Ubicación en centro (ej: UCI, Sala de Espera)
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
    NEW.tipo_origen,              -- ✅ Copia directa
    NEW.origen,                   -- ✅ Copia directa
    NEW.origen_ubicacion_centro,  -- ✅ Copia directa (puede ser NULL)
    NEW.tipo_destino,             -- ✅ Copia directa
    NEW.destino,                  -- ✅ Copia directa
    NEW.destino_ubicacion_centro, -- ✅ Copia directa (puede ser NULL)
    NEW.observaciones,
    true,
    NEW.created_by
  )
  ON CONFLICT (id_servicio_recurrente, id_servicio, fecha, tipo_traslado) DO NOTHING;

  IF FOUND THEN
    v_traslados_generados := v_traslados_generados + 1;
    RAISE NOTICE '✅ Traslado de IDA generado para servicio único % (origen: %, ubicación: %, destino: %, ubicación: %)',
      NEW.codigo, NEW.origen, NEW.origen_ubicacion_centro, NEW.destino, NEW.destino_ubicacion_centro;
  END IF;

  -- TRASLADO DE VUELTA (solo si requiere_vuelta = true)
  IF NEW.requiere_vuelta = true THEN
    IF NEW.hora_vuelta IS NULL THEN
      RAISE EXCEPTION 'INCONSISTENCIA: requiere_vuelta = true pero hora_vuelta es NULL en servicio %', NEW.codigo;
    END IF;

    -- Para la vuelta, invertimos origen ↔ destino
    INSERT INTO traslados (
      id_servicio,
      id_servicio_recurrente,
      id_paciente,
      tipo_traslado,
      fecha,
      hora_programada,
      tipo_origen,              -- ✅ INVERTIDO: tipo_destino del servicio
      origen,                   -- ✅ INVERTIDO: destino del servicio
      origen_ubicacion_centro,  -- ✅ INVERTIDO: destino_ubicacion_centro del servicio
      tipo_destino,             -- ✅ INVERTIDO: tipo_origen del servicio
      destino,                  -- ✅ INVERTIDO: origen del servicio
      destino_ubicacion_centro, -- ✅ INVERTIDO: origen_ubicacion_centro del servicio
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
      NEW.tipo_destino,             -- ✅ INVERTIDO
      NEW.destino,                  -- ✅ INVERTIDO
      NEW.destino_ubicacion_centro, -- ✅ INVERTIDO
      NEW.tipo_origen,              -- ✅ INVERTIDO
      NEW.origen,                   -- ✅ INVERTIDO
      NEW.origen_ubicacion_centro,  -- ✅ INVERTIDO
      NEW.observaciones,
      true,
      NEW.created_by
    )
    ON CONFLICT (id_servicio_recurrente, id_servicio, fecha, tipo_traslado) DO NOTHING;

    IF FOUND THEN
      v_traslados_generados := v_traslados_generados + 1;
      RAISE NOTICE '✅ Traslado de VUELTA generado para servicio único % (origen: %, ubicación: %, destino: %, ubicación: %)',
        NEW.codigo, NEW.destino, NEW.destino_ubicacion_centro, NEW.origen, NEW.origen_ubicacion_centro;
    END IF;
  ELSE
    RAISE NOTICE 'ℹ️ Servicio único % NO requiere vuelta (requiere_vuelta = false)', NEW.codigo;
  END IF;

  RAISE NOTICE 'Generados % traslados para servicio único %', v_traslados_generados, NEW.codigo;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- El trigger ya existe, solo actualizamos la función
COMMENT ON FUNCTION generar_traslados_servicio_unico() IS
'Genera traslados automáticamente al crear un servicio ÚNICO con arquitectura normalizada.
Copia campos normalizados de servicios a traslados:
  - tipo_origen, origen, origen_ubicacion_centro (IDA) → invertido en VUELTA
  - tipo_destino, destino, destino_ubicacion_centro (IDA) → invertido en VUELTA
Crea 1 traslado de IDA (siempre) y opcionalmente 1 traslado de VUELTA si requiere_vuelta = true.
Los campos ubicacion_centro son opcionales (pueden ser NULL).';

-- Eliminar trigger existente si existe
DROP TRIGGER IF EXISTS trigger_generar_traslados_unico ON servicios;

-- Crear el trigger para generar traslados automáticamente
CREATE TRIGGER trigger_generar_traslados_unico
  AFTER INSERT ON servicios
  FOR EACH ROW
  WHEN (NEW.tipo_recurrencia = 'unico')
  EXECUTE FUNCTION generar_traslados_servicio_unico();

-- Refrescar el schema cache
NOTIFY pgrst, 'reload schema';
