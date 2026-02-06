-- =====================================================
-- VISTA: v_traslados_completos
-- Descripción: Vista materializada de traslados con todos los datos necesarios
--              incluyendo nombres de pacientes, conductores, localidades, etc.
-- Autor: Sistema AmbuTrack
-- Fecha: 2026-02-06
-- =====================================================

-- Crear vista de traslados completos con todos los JOINs necesarios
CREATE OR REPLACE VIEW v_traslados_completos AS
SELECT
  -- Datos principales del traslado
  t.*,

  -- Datos del paciente
  p.nombre AS paciente_nombre,
  p.primer_apellido AS paciente_primer_apellido,
  p.segundo_apellido AS paciente_segundo_apellido,

  -- Localidad del domicilio del paciente
  tpob_paciente.nombre AS poblacion_paciente,

  -- Datos del conductor
  pers.nombre AS conductor_nombre,
  pers.apellidos AS conductor_apellidos,

  -- Datos del vehículo
  v.matricula AS vehiculo_matricula,

  -- Localidad del hospital de origen (si tipo_origen = 'centro_hospitalario')
  CASE
    WHEN sr.tipo_origen = 'centro_hospitalario' OR t.tipo_origen = 'centro_hospitalario'
    THEN tpob_hosp_origen.nombre
    ELSE NULL
  END AS poblacion_centro_origen,

  -- Localidad del hospital de destino (si tipo_destino = 'centro_hospitalario')
  CASE
    WHEN sr.tipo_destino = 'centro_hospitalario' OR t.tipo_destino = 'centro_hospitalario'
    THEN tpob_hosp_destino.nombre
    ELSE NULL
  END AS poblacion_centro_destino,

  -- Datos del servicio recurrente (para heredar si el traslado no tiene)
  sr.tipo_origen AS sr_tipo_origen,
  sr.origen AS sr_origen,
  sr.origen_ubicacion_centro AS sr_origen_ubicacion_centro,
  sr.tipo_destino AS sr_tipo_destino,
  sr.destino AS sr_destino,
  sr.destino_ubicacion_centro AS sr_destino_ubicacion_centro

FROM traslados t

-- JOIN con paciente (OBLIGATORIO)
LEFT JOIN pacientes p ON t.id_paciente = p.id

-- JOIN con localidad del paciente
LEFT JOIN tpoblaciones tpob_paciente ON p.localidad_id = tpob_paciente.id

-- JOIN con conductor (OPCIONAL)
LEFT JOIN tpersonal pers ON t.id_conductor = pers.id

-- JOIN con vehículo (OPCIONAL)
LEFT JOIN tvehiculos v ON t.id_vehiculo = v.id

-- JOIN con servicio recurrente (OPCIONAL)
LEFT JOIN servicios_recurrentes sr ON t.id_servicio_recurrente = sr.id

-- JOIN con hospital de origen (OPCIONAL - solo si es centro_hospitalario)
LEFT JOIN tcentros_hospitalarios hosp_origen
  ON (COALESCE(t.origen, sr.origen) = hosp_origen.nombre)
  AND (COALESCE(t.tipo_origen, sr.tipo_origen) = 'centro_hospitalario')

-- JOIN con localidad del hospital de origen
LEFT JOIN tpoblaciones tpob_hosp_origen ON hosp_origen.localidad_id = tpob_hosp_origen.id

-- JOIN con hospital de destino (OPCIONAL - solo si es centro_hospitalario)
LEFT JOIN tcentros_hospitalarios hosp_destino
  ON (COALESCE(t.destino, sr.destino) = hosp_destino.nombre)
  AND (COALESCE(t.tipo_destino, sr.tipo_destino) = 'centro_hospitalario')

-- JOIN con localidad del hospital de destino
LEFT JOIN tpoblaciones tpob_hosp_destino ON hosp_destino.localidad_id = tpob_hosp_destino.id;

-- Comentarios
COMMENT ON VIEW v_traslados_completos IS
  'Vista completa de traslados con datos desnormalizados (paciente, conductor, vehículo, localidades)';

-- Crear índices en las tablas base para optimizar los JOINs (si no existen ya)
CREATE INDEX IF NOT EXISTS idx_traslados_id_paciente ON traslados(id_paciente);
CREATE INDEX IF NOT EXISTS idx_traslados_id_conductor ON traslados(id_conductor);
CREATE INDEX IF NOT EXISTS idx_traslados_id_vehiculo ON traslados(id_vehiculo);
CREATE INDEX IF NOT EXISTS idx_traslados_id_servicio_recurrente ON traslados(id_servicio_recurrente);

CREATE INDEX IF NOT EXISTS idx_pacientes_localidad_id ON pacientes(localidad_id);
CREATE INDEX IF NOT EXISTS idx_centros_nombre ON tcentros_hospitalarios(nombre);
CREATE INDEX IF NOT EXISTS idx_centros_localidad_id ON tcentros_hospitalarios(localidad_id);

-- RLS: Heredar las políticas de la tabla traslados
-- (La vista automáticamente respeta el RLS de las tablas subyacentes)
