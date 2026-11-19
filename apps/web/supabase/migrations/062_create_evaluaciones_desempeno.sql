-- =============================================
-- PERSONAL · Evaluaciones de desempeño
-- Puntuaciones 1-5 en cuatro criterios; puntuacion_media es columna generada.
-- RLS: gestionan admin y jefe_personal; el trabajador consulta sus evaluaciones.
--      (dato sensible de RRHH: no lo ven el resto de mandos)
-- Depende de fn_rol_en() (048), fn_mi_personal_id() (034), fn_mi_empresa_id() y
-- fn_set_empresa_desde_personal() (061).
-- =============================================

CREATE TABLE IF NOT EXISTS public.tevaluaciones_desempeno (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL,
  personal_id UUID NOT NULL REFERENCES public.tpersonal(id) ON DELETE CASCADE,
  fecha DATE NOT NULL DEFAULT CURRENT_DATE,
  periodo TEXT,
  evaluador_id UUID DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE SET NULL,
  evaluador_nombre TEXT,
  puntualidad SMALLINT NOT NULL CHECK (puntualidad BETWEEN 1 AND 5),
  trato_paciente SMALLINT NOT NULL CHECK (trato_paciente BETWEEN 1 AND 5),
  trabajo_equipo SMALLINT NOT NULL CHECK (trabajo_equipo BETWEEN 1 AND 5),
  cumplimiento_protocolos SMALLINT NOT NULL CHECK (cumplimiento_protocolos BETWEEN 1 AND 5),
  puntuacion_media NUMERIC(3,2) GENERATED ALWAYS AS (
    round((puntualidad + trato_paciente + trabajo_equipo + cumplimiento_protocolos)::NUMERIC / 4, 2)
  ) STORED,
  comentarios TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID DEFAULT auth.uid()
);

CREATE INDEX IF NOT EXISTS idx_tevaluaciones_desempeno_empresa ON public.tevaluaciones_desempeno(empresa_id);
CREATE INDEX IF NOT EXISTS idx_tevaluaciones_desempeno_personal ON public.tevaluaciones_desempeno(personal_id);
CREATE INDEX IF NOT EXISTS idx_tevaluaciones_desempeno_fecha ON public.tevaluaciones_desempeno(fecha DESC);

DROP TRIGGER IF EXISTS trg_tevaluaciones_desempeno_empresa ON public.tevaluaciones_desempeno;
CREATE TRIGGER trg_tevaluaciones_desempeno_empresa
  BEFORE INSERT ON public.tevaluaciones_desempeno
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_empresa_desde_personal();

DROP TRIGGER IF EXISTS trg_tevaluaciones_desempeno_updated_at ON public.tevaluaciones_desempeno;
CREATE TRIGGER trg_tevaluaciones_desempeno_updated_at
  BEFORE UPDATE ON public.tevaluaciones_desempeno
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trg_audit_tevaluaciones_desempeno ON public.tevaluaciones_desempeno;
CREATE TRIGGER trg_audit_tevaluaciones_desempeno
  AFTER INSERT OR UPDATE OR DELETE ON public.tevaluaciones_desempeno
  FOR EACH ROW EXECUTE FUNCTION public.fn_audit_row();

ALTER TABLE public.tevaluaciones_desempeno ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tevaluaciones_desempeno_select ON public.tevaluaciones_desempeno;
DROP POLICY IF EXISTS tevaluaciones_desempeno_insert ON public.tevaluaciones_desempeno;
DROP POLICY IF EXISTS tevaluaciones_desempeno_update ON public.tevaluaciones_desempeno;
DROP POLICY IF EXISTS tevaluaciones_desempeno_delete ON public.tevaluaciones_desempeno;

CREATE POLICY tevaluaciones_desempeno_select ON public.tevaluaciones_desempeno FOR SELECT TO authenticated
  USING (
    personal_id = public.fn_mi_personal_id()
    OR (public.fn_rol_en(ARRAY['admin', 'jefe_personal'])
        AND (public.fn_mi_empresa_id() IS NULL OR empresa_id = public.fn_mi_empresa_id()))
  );
CREATE POLICY tevaluaciones_desempeno_insert ON public.tevaluaciones_desempeno FOR INSERT TO authenticated
  WITH CHECK (
    public.fn_rol_en(ARRAY['admin', 'jefe_personal'])
    AND (public.fn_mi_empresa_id() IS NULL OR empresa_id = public.fn_mi_empresa_id())
  );
CREATE POLICY tevaluaciones_desempeno_update ON public.tevaluaciones_desempeno FOR UPDATE TO authenticated
  USING (
    public.fn_rol_en(ARRAY['admin', 'jefe_personal'])
    AND (public.fn_mi_empresa_id() IS NULL OR empresa_id = public.fn_mi_empresa_id())
  )
  WITH CHECK (
    public.fn_rol_en(ARRAY['admin', 'jefe_personal'])
    AND (public.fn_mi_empresa_id() IS NULL OR empresa_id = public.fn_mi_empresa_id())
  );
CREATE POLICY tevaluaciones_desempeno_delete ON public.tevaluaciones_desempeno FOR DELETE TO authenticated
  USING (
    public.fn_rol_en(ARRAY['admin', 'jefe_personal'])
    AND (public.fn_mi_empresa_id() IS NULL OR empresa_id = public.fn_mi_empresa_id())
  );

COMMENT ON TABLE public.tevaluaciones_desempeno IS 'Evaluaciones de desempeño del personal (criterios 1-5)';
COMMENT ON COLUMN public.tevaluaciones_desempeno.puntuacion_media IS 'Generada: media de los cuatro criterios (2 decimales)';
COMMENT ON COLUMN public.tevaluaciones_desempeno.periodo IS 'Texto libre del periodo evaluado (p. ej. 2026, 2026-S1, 2026-T3)';
