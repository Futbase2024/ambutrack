-- =====================================================================
-- Corrige fecha_hora de fichajes guardados con hora local como si fuera UTC
-- =====================================================================
-- La app enviaba DateTime.now().toIso8601String() (hora local SIN offset)
-- y Postgres lo interpretaba como UTC → fichajes adelantados 1h (invierno)
-- o 2h (verano). Se reinterpreta la hora guardada como hora de Madrid.
-- Solo afecta a registros cuyo desfase con created_at coincide con el
-- offset de Madrid (los ya correctos no se tocan).
-- =====================================================================

UPDATE public.registros_horarios
SET fecha_hora = (fecha_hora AT TIME ZONE 'UTC') AT TIME ZONE 'Europe/Madrid'
WHERE fecha_hora - created_at
      BETWEEN (((created_at AT TIME ZONE 'Europe/Madrid') - (created_at AT TIME ZONE 'UTC')) - interval '5 minutes')
          AND (((created_at AT TIME ZONE 'Europe/Madrid') - (created_at AT TIME ZONE 'UTC')) + interval '5 minutes');
