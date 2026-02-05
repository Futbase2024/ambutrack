-- Migración: Corregir función validar_servicios_rec_recurrencia()
-- Fecha: 2025-01-31
-- Descripción: Corrige sintaxis de CASE statement para manejar todos los tipos de recurrencia
--              Añade WHEN para 'unico' y 'diario', y cláusula ELSE

-- Reemplazar la función con la versión corregida
CREATE OR REPLACE FUNCTION validar_servicios_rec_recurrencia()
RETURNS TRIGGER AS $$
BEGIN
  -- Validar parámetros de recurrencia según tipo
  -- IMPORTANTE: Cada WHEN debe estar separado, no se puede usar sintaxis "WHEN 'a', 'b'"
  CASE NEW.tipo_recurrencia

    WHEN 'semanal' THEN
      IF NEW.dias_semana IS NULL OR array_length(NEW.dias_semana, 1) IS NULL THEN
        RAISE EXCEPTION 'dias_semana es obligatorio para tipo_recurrencia = %', NEW.tipo_recurrencia;
      END IF;

    WHEN 'semanas_alternas' THEN
      IF NEW.dias_semana IS NULL OR array_length(NEW.dias_semana, 1) IS NULL THEN
        RAISE EXCEPTION 'dias_semana es obligatorio para tipo_recurrencia = %', NEW.tipo_recurrencia;
      END IF;
      IF NEW.intervalo_semanas IS NULL OR NEW.intervalo_semanas < 2 THEN
        RAISE EXCEPTION 'intervalo_semanas debe ser >= 2 para semanas_alternas';
      END IF;

    WHEN 'dias_alternos' THEN
      IF NEW.intervalo_dias IS NULL OR NEW.intervalo_dias < 2 THEN
        RAISE EXCEPTION 'intervalo_dias debe ser >= 2 para dias_alternos';
      END IF;

    WHEN 'mensual' THEN
      IF NEW.dias_mes IS NULL OR array_length(NEW.dias_mes, 1) IS NULL THEN
        RAISE EXCEPTION 'dias_mes es obligatorio para tipo_recurrencia = mensual';
      END IF;

    WHEN 'especifico' THEN
      IF NEW.fechas_especificas IS NULL OR array_length(NEW.fechas_especificas, 1) IS NULL THEN
        RAISE EXCEPTION 'fechas_especificas es obligatorio para tipo_recurrencia = especifico';
      END IF;

    -- Tipos que no requieren validaciones adicionales
    WHEN 'unico' THEN
      NULL;

    WHEN 'diario' THEN
      NULL;

    -- Manejar valores inesperados
    ELSE
      RAISE EXCEPTION 'tipo_recurrencia no reconocido: %', NEW.tipo_recurrencia;

  END CASE;

  -- Validaciones comunes a todos los tipos
  IF NEW.requiere_vuelta = true AND NEW.hora_vuelta IS NULL THEN
    RAISE EXCEPTION 'hora_vuelta es obligatoria si requiere_vuelta = true';
  END IF;

  IF NEW.fecha_servicio_fin IS NOT NULL AND NEW.fecha_servicio_fin < NEW.fecha_servicio_inicio THEN
    RAISE EXCEPTION 'fecha_servicio_fin no puede ser anterior a fecha_servicio_inicio';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Añadir comentario a la función
COMMENT ON FUNCTION validar_servicios_rec_recurrencia() IS
'Trigger function para validar servicios recurrentes antes de INSERT/UPDATE.
Corregido el 2025-01-31 para manejar todos los tipos de recurrencia correctamente.';
