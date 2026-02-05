-- =====================================================
-- MIGRACIÓN: Agregar id_motivo_traslado a tabla traslados
-- Problema: La tabla traslados no tiene referencia al motivo de traslado
-- Solución: Agregar FK a motivos_traslado para poder filtrar/agrupar traslados
-- Fecha: 2026-01-03
-- =====================================================

-- PASO 1: Agregar columna id_motivo_traslado (nullable)
ALTER TABLE traslados
ADD COLUMN id_motivo_traslado UUID REFERENCES tmotivos_traslado(id) ON DELETE SET NULL;

-- PASO 2: Crear índice en id_motivo_traslado para mejorar queries
CREATE INDEX idx_traslados_motivo_traslado ON traslados(id_motivo_traslado);

-- PASO 3: Comentario en la columna
COMMENT ON COLUMN traslados.id_motivo_traslado IS
'Referencia al motivo del traslado (herencia desde servicios o servicios_recurrentes)';

-- PASO 4: Actualizar trigger para propagar id_motivo_traslado desde servicios
-- Modificar función generar_traslados_servicio_unico para incluir id_motivo_traslado
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
    id_motivo_traslado,    -- ✅ NUEVO: Heredar de servicios
    tipo_traslado,
    fecha,
    hora_programada,
    tipo_origen,
    origen,
    tipo_destino,
    destino,
    origen_ubicacion_centro,
    destino_ubicacion_centro,
    observaciones,
    generado_automaticamente,
    created_by
  )
  VALUES (
    NEW.id,
    NULL,
    NEW.id_paciente,
    NEW.id_motivo_traslado,  -- ✅ Propagar desde servicios
    'ida',
    NEW.fecha_servicio_inicio,
    NEW.hora_recogida,
    NEW.tipo_origen,
    NEW.origen,
    NEW.tipo_destino,
    NEW.destino,
    NEW.origen_ubicacion_centro,
    NEW.destino_ubicacion_centro,
    NEW.observaciones,
    true,
    NEW.created_by
  )
  ON CONFLICT (id_servicio_recurrente, id_servicio, fecha, tipo_traslado) DO NOTHING;

  IF FOUND THEN
    v_traslados_generados := v_traslados_generados + 1;
    RAISE NOTICE '✅ Traslado de IDA generado para servicio único %', NEW.codigo;
  END IF;

  -- TRASLADO DE VUELTA (solo si requiere_vuelta = true)
  IF NEW.requiere_vuelta = true THEN
    IF NEW.hora_vuelta IS NULL THEN
      RAISE EXCEPTION 'INCONSISTENCIA: requiere_vuelta = true pero hora_vuelta es NULL en servicio %', NEW.codigo;
    END IF;

    INSERT INTO traslados (
      id_servicio,
      id_servicio_recurrente,
      id_paciente,
      id_motivo_traslado,    -- ✅ NUEVO
      tipo_traslado,
      fecha,
      hora_programada,
      tipo_origen,           -- ✅ Invertir origen/destino
      origen,
      tipo_destino,
      destino,
      origen_ubicacion_centro,
      destino_ubicacion_centro,
      observaciones,
      generado_automaticamente,
      created_by
    )
    VALUES (
      NEW.id,
      NULL,
      NEW.id_paciente,
      NEW.id_motivo_traslado,  -- ✅ Propagar desde servicios
      'vuelta',
      NEW.fecha_servicio_inicio,
      NEW.hora_vuelta,
      NEW.tipo_destino,      -- ✅ Origen = Destino de IDA
      NEW.destino,
      NEW.tipo_origen,       -- ✅ Destino = Origen de IDA
      NEW.origen,
      NEW.destino_ubicacion_centro,
      NEW.origen_ubicacion_centro,
      NEW.observaciones,
      true,
      NEW.created_by
    )
    ON CONFLICT (id_servicio_recurrente, id_servicio, fecha, tipo_traslado) DO NOTHING;

    IF FOUND THEN
      v_traslados_generados := v_traslados_generados + 1;
      RAISE NOTICE '✅ Traslado de VUELTA generado para servicio único %', NEW.codigo;
    END IF;
  ELSE
    RAISE NOTICE 'ℹ️ Servicio único % NO requiere vuelta (requiere_vuelta = false)', NEW.codigo;
  END IF;

  RAISE NOTICE 'Generados % traslados para servicio único %', v_traslados_generados, NEW.codigo;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Comentario actualizado
COMMENT ON FUNCTION generar_traslados_servicio_unico() IS
'Genera traslados automáticamente al crear un servicio ÚNICO.
Lee campos de servicios y propaga id_motivo_traslado, ubicaciones y trayectos.
Crea 1 traslado de IDA (siempre) y opcionalmente 1 traslado de VUELTA si requiere_vuelta = true.';

-- Refrescar schema cache
NOTIFY pgrst, 'reload schema';
