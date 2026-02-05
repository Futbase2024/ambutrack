-- =====================================================
-- MIGRACIÓN: Fix generación de códigos de traslados con UUID
-- Descripción: Reemplaza la secuencia por UUID para evitar duplicados
-- Fecha: 2026-01-03
-- =====================================================

-- Eliminar el trigger antiguo que usa secuencia
DROP TRIGGER IF EXISTS trigger_generar_codigo_traslado ON traslados;

-- Eliminar la secuencia (ya no la necesitamos)
DROP SEQUENCE IF EXISTS traslados_codigo_seq;

-- Crear nueva función que usa UUID para generar códigos únicos
CREATE OR REPLACE FUNCTION generar_codigo_traslado()
RETURNS TRIGGER AS $$
DECLARE
  v_uuid_corto TEXT;
BEGIN
  -- Solo generar código si no viene especificado
  IF NEW.codigo IS NULL OR NEW.codigo = '' THEN
    -- Generar UUID corto (8 caracteres) en mayúsculas
    v_uuid_corto := UPPER(SUBSTRING(REPLACE(gen_random_uuid()::TEXT, '-', ''), 1, 8));

    -- Formato: TRS-YYYYMMDD-UUID8-I/V
    NEW.codigo := 'TRS-' ||
                  TO_CHAR(NEW.fecha, 'YYYYMMDD') || '-' ||
                  v_uuid_corto ||
                  CASE WHEN NEW.tipo_traslado = 'vuelta' THEN '-V' ELSE '-I' END;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recrear el trigger
CREATE TRIGGER trigger_generar_codigo_traslado
  BEFORE INSERT ON traslados
  FOR EACH ROW
  EXECUTE FUNCTION generar_codigo_traslado();

COMMENT ON FUNCTION generar_codigo_traslado() IS
'Genera códigos únicos para traslados usando UUID en lugar de secuencia.
Formato: TRS-YYYYMMDD-UUID8-I/V
Ejemplo: TRS-20260103-A3F2B8D1-I
Esto evita duplicados cuando se generan múltiples traslados simultáneamente.';

-- Refrescar el schema cache
NOTIFY pgrst, 'reload schema';
