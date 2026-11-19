-- Fin de turno para el parte diario (km final y justificantes P-10)
ALTER TABLE public.inicios_turno
  ADD COLUMN IF NOT EXISTS km_final numeric,
  ADD COLUMN IF NOT EXISTS foto_km_final_url text,
  ADD COLUMN IF NOT EXISTS numeros_p10 text,
  ADD COLUMN IF NOT EXISTS fin_turno_at timestamptz;

COMMENT ON COLUMN public.inicios_turno.km_final IS 'Km del vehículo al cerrar el turno (parte diario)';
COMMENT ON COLUMN public.inicios_turno.numeros_p10 IS 'Números de justificantes P-10 entregados (opcional)';

-- Los trabajadores no tienen UPDATE en inicios_turno: cierran su turno con esta RPC
CREATE OR REPLACE FUNCTION public.fn_registrar_fin_turno(
  p_inicio_id uuid,
  p_km_final numeric,
  p_foto_km_final_url text DEFAULT NULL,
  p_numeros_p10 text DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_km_inicial numeric;
BEGIN
  SELECT it.km_inicial INTO v_km_inicial
  FROM inicios_turno it
  JOIN tpersonal p ON p.id = it.personal_id
  WHERE it.id = p_inicio_id AND p.usuario_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Inicio de turno no encontrado o no pertenece al usuario';
  END IF;

  IF p_km_final IS NULL OR p_km_final < 0 THEN
    RAISE EXCEPTION 'Km final no válido';
  END IF;

  IF v_km_inicial IS NOT NULL AND p_km_final < v_km_inicial THEN
    RAISE EXCEPTION 'El km final (%) no puede ser menor que el inicial (%)', p_km_final, v_km_inicial;
  END IF;

  UPDATE inicios_turno
  SET km_final = p_km_final,
      foto_km_final_url = COALESCE(p_foto_km_final_url, foto_km_final_url),
      numeros_p10 = NULLIF(btrim(p_numeros_p10), ''),
      fin_turno_at = now()
  WHERE id = p_inicio_id;
END;
$$;

REVOKE ALL ON FUNCTION public.fn_registrar_fin_turno(uuid, numeric, text, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_registrar_fin_turno(uuid, numeric, text, text) TO authenticated;
