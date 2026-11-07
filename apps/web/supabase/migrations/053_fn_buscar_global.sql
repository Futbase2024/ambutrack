-- =============================================
-- D7: búsqueda global de registros (Ctrl+K)
--
-- SECURITY INVOKER: se ejecuta con los permisos de quien busca, así que las
-- reglas RLS se aplican solas (un conductor no encuentra pacientes ajenos).
-- Todas las palabras del texto deben aparecer (sin distinguir mayúsculas ni
-- tildes) en los campos de búsqueda de cada tipo.
-- =============================================

CREATE OR REPLACE FUNCTION public.fn_buscar_global(p_texto TEXT, p_limite INT DEFAULT 6)
RETURNS TABLE (tipo TEXT, id TEXT, titulo TEXT, subtitulo TEXT)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = public AS $$
  WITH palabras AS (
    SELECT array_agg(w) AS w
      FROM unnest(regexp_split_to_array(
             lower(translate(trim(coalesce(p_texto, '')), 'ÁÉÍÓÚÜáéíóúü', 'AEIOUUaeiouu')), '\s+')) AS w
     WHERE w <> ''
  ),
  lim AS (SELECT LEAST(GREATEST(coalesce(p_limite, 6), 1), 20) AS n)
  SELECT * FROM (
    (SELECT 'vehiculo'::TEXT, v.id::TEXT, v.matricula,
            concat_ws(' · ', nullif(trim(concat_ws(' ', v.marca, v.modelo)), ''), v.numero_interno, v.estado)
       FROM tvehiculos v, palabras p
      WHERE p.w IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM unnest(p.w) x
           WHERE lower(translate(concat_ws(' ', v.matricula, replace(v.matricula, ' ', ''), v.numero_interno,
                                           v.alias, v.marca, v.modelo),
                                 'ÁÉÍÓÚÜáéíóúü', 'AEIOUUaeiouu')) NOT LIKE '%' || x || '%')
      ORDER BY v.matricula
      LIMIT (SELECT n FROM lim))
    UNION ALL
    (SELECT 'paciente', pa.id::TEXT,
            trim(concat_ws(' ', pa.nombre, pa.primer_apellido, pa.segundo_apellido)),
            concat_ws(' · ', nullif(pa.documento, ''), CASE WHEN pa.num_historia <> '' THEN 'HC ' || pa.num_historia END)
       FROM pacientes pa, palabras p
      WHERE p.w IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM unnest(p.w) x
           WHERE lower(translate(concat_ws(' ', pa.nombre, pa.primer_apellido, pa.segundo_apellido, pa.documento,
                                           pa.num_historia, pa.telefono_movil),
                                 'ÁÉÍÓÚÜáéíóúü', 'AEIOUUaeiouu')) NOT LIKE '%' || x || '%')
      ORDER BY pa.primer_apellido, pa.nombre
      LIMIT (SELECT n FROM lim))
    UNION ALL
    (SELECT 'personal', tp.id::TEXT, trim(concat_ws(' ', tp.nombre, tp.apellidos)),
            concat_ws(' · ', nullif(tp.dni, ''), nullif(tp.categoria, ''))
       FROM tpersonal tp, palabras p
      WHERE p.w IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM unnest(p.w) x
           WHERE lower(translate(concat_ws(' ', tp.nombre, tp.apellidos, tp.dni, tp.categoria),
                                 'ÁÉÍÓÚÜáéíóúü', 'AEIOUUaeiouu')) NOT LIKE '%' || x || '%')
      ORDER BY tp.apellidos, tp.nombre
      LIMIT (SELECT n FROM lim))
    UNION ALL
    (SELECT 'orden', o.id::TEXT, coalesce(o.numero_orden, 'Orden'),
            concat_ws(' · ', o.estado, left(o.diagnostico, 60))
       FROM tordenes_reparacion o, palabras p
      WHERE p.w IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM unnest(p.w) x
           WHERE lower(translate(concat_ws(' ', o.numero_orden, o.diagnostico, o.mecanico_nombre),
                                 'ÁÉÍÓÚÜáéíóúü', 'AEIOUUaeiouu')) NOT LIKE '%' || x || '%')
      ORDER BY o.numero_orden DESC
      LIMIT (SELECT n FROM lim))
  ) r
$$;

REVOKE EXECUTE ON FUNCTION public.fn_buscar_global(TEXT, INT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_buscar_global(TEXT, INT) TO authenticated, service_role;
