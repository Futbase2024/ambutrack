-- =====================================================
-- FIX: Corregir función validar_servicios_recurrencia
-- Problema: Sintaxis incorrecta en CASE statement
-- Error original: "case not found, code: 20000"
-- Fecha: 2025-01-31
-- =====================================================

-- Función corregida de validación
CREATE OR REPLACE FUNCTION validar_servicios_recurrencia()
RETURNS TRIGGER AS $$
BEGIN
  -- Validar que tipo_recurrencia tenga los parámetros necesarios
  CASE NEW.tipo_recurrencia

    -- SEMANAL: Requiere dias_semana
    WHEN 'semanal' THEN
      IF NEW.dias_semana IS NULL OR array_length(NEW.dias_semana, 1) IS NULL THEN
        RAISE EXCEPTION 'dias_semana es obligatorio para tipo_recurrencia = %', NEW.tipo_recurrencia;
      END IF;

    -- SEMANAS ALTERNAS: Requiere dias_semana e intervalo_semanas
    WHEN 'semanas_alternas' THEN
      IF NEW.dias_semana IS NULL OR array_length(NEW.dias_semana, 1) IS NULL THEN
        RAISE EXCEPTION 'dias_semana es obligatorio para tipo_recurrencia = %', NEW.tipo_recurrencia;
      END IF;
      IF NEW.intervalo_semanas IS NULL OR NEW.intervalo_semanas < 2 THEN
        RAISE EXCEPTION 'intervalo_semanas debe ser >= 2 para semanas_alternas';
      END IF;

    -- DÍAS ALTERNOS: Requiere intervalo_dias
    WHEN 'dias_alternos' THEN
      IF NEW.intervalo_dias IS NULL OR NEW.intervalo_dias < 2 THEN
        RAISE EXCEPTION 'intervalo_dias debe ser >= 2 para dias_alternos';
      END IF;

    -- MENSUAL: Requiere dias_mes
    WHEN 'mensual' THEN
      IF NEW.dias_mes IS NULL OR array_length(NEW.dias_mes, 1) IS NULL THEN
        RAISE EXCEPTION 'dias_mes es obligatorio para tipo_recurrencia = mensual';
      END IF;

    -- ESPECÍFICO: Requiere fechas_especificas
    WHEN 'especifico' THEN
      IF NEW.fechas_especificas IS NULL OR array_length(NEW.fechas_especificas, 1) IS NULL THEN
        RAISE EXCEPTION 'fechas_especificas es obligatorio para tipo_recurrencia = especifico';
      END IF;

    -- ÚNICO y DIARIO: No requieren parámetros adicionales
    WHEN 'unico' THEN
      NULL; -- No se requiere validación adicional

    WHEN 'diario' THEN
      NULL; -- No se requiere validación adicional

    -- ELSE para tipo_recurrencia no reconocido (no debería ocurrir por CHECK constraint)
    ELSE
      RAISE EXCEPTION 'tipo_recurrencia no reconocido: %', NEW.tipo_recurrencia;

  END CASE;

  -- Validar que si requiere vuelta, tenga hora_vuelta
  IF NEW.requiere_vuelta = true AND NEW.hora_vuelta IS NULL THEN
    RAISE EXCEPTION 'hora_vuelta es obligatoria si requiere_vuelta = true';
  END IF;

  -- Validar fechas
  IF NEW.fecha_servicio_fin IS NOT NULL AND NEW.fecha_servicio_fin < NEW.fecha_servicio_inicio THEN
    RAISE EXCEPTION 'fecha_servicio_fin no puede ser anterior a fecha_servicio_inicio';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION validar_servicios_recurrencia() IS
'Valida que un servicio tenga los parámetros de recurrencia necesarios según su tipo.
CORREGIDO: Se agregaron casos WHEN para unico y diario, y se agregó ELSE para evitar error "case not found".';

-- Refrescar el schema cache
NOTIFY pgrst, 'reload schema';
