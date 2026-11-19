-- =============================================
-- PERSONAL · Documentación del personal (documentos y certificaciones por trabajador)
-- El estado (vigente / próximo a caducar / caducado) se calcula en la app a partir
-- de fecha_caducidad (umbral 30 días), no se almacena.
-- RLS: gestionan admin y jefe_personal; leen los mandos que ven la plantilla
--      (fn_puede_ver_personal) y el propio trabajador sus documentos.
-- Depende de fn_rol_en() (048), fn_mi_personal_id()/fn_puede_ver_personal() (034).
-- =============================================

-- 1. Helper: empresa del usuario actual (SECURITY DEFINER: evita RLS de usuarios)
CREATE OR REPLACE FUNCTION public.fn_mi_empresa_id()
RETURNS UUID LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT empresa_id FROM public.usuarios WHERE id = auth.uid()
$$;
REVOKE EXECUTE ON FUNCTION public.fn_mi_empresa_id() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_mi_empresa_id() TO authenticated, service_role;

-- 2. Tabla
CREATE TABLE IF NOT EXISTS public.tdocumentos_personal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL,
  personal_id UUID NOT NULL REFERENCES public.tpersonal(id) ON DELETE CASCADE,
  tipo TEXT NOT NULL DEFAULT 'otro'
    CHECK (tipo IN ('dni', 'carnet_conducir', 'titulacion', 'certificado_sanitario',
                    'formacion', 'contrato', 'reconocimiento_medico', 'otro')),
  nombre TEXT,
  numero TEXT,
  fecha_emision DATE,
  fecha_caducidad DATE,
  observaciones TEXT,
  archivo_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID DEFAULT auth.uid(),
  CONSTRAINT chk_tdocumentos_personal_fechas
    CHECK (fecha_emision IS NULL OR fecha_caducidad IS NULL OR fecha_caducidad >= fecha_emision)
);

CREATE INDEX IF NOT EXISTS idx_tdocumentos_personal_empresa ON public.tdocumentos_personal(empresa_id);
CREATE INDEX IF NOT EXISTS idx_tdocumentos_personal_personal ON public.tdocumentos_personal(personal_id);
CREATE INDEX IF NOT EXISTS idx_tdocumentos_personal_caducidad ON public.tdocumentos_personal(fecha_caducidad);

-- 3. empresa_id por defecto: la del trabajador (o la del usuario actual)
CREATE OR REPLACE FUNCTION public.fn_set_empresa_desde_personal()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NEW.empresa_id IS NULL THEN
    SELECT p.empresa_id INTO NEW.empresa_id FROM public.tpersonal p WHERE p.id = NEW.personal_id;
  END IF;
  IF NEW.empresa_id IS NULL THEN
    NEW.empresa_id := public.fn_mi_empresa_id();
  END IF;
  RETURN NEW;
END $$;
REVOKE EXECUTE ON FUNCTION public.fn_set_empresa_desde_personal() FROM PUBLIC, anon;

DROP TRIGGER IF EXISTS trg_tdocumentos_personal_empresa ON public.tdocumentos_personal;
CREATE TRIGGER trg_tdocumentos_personal_empresa
  BEFORE INSERT ON public.tdocumentos_personal
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_empresa_desde_personal();

DROP TRIGGER IF EXISTS trg_tdocumentos_personal_updated_at ON public.tdocumentos_personal;
CREATE TRIGGER trg_tdocumentos_personal_updated_at
  BEFORE UPDATE ON public.tdocumentos_personal
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 4. Auditoría
DROP TRIGGER IF EXISTS trg_audit_tdocumentos_personal ON public.tdocumentos_personal;
CREATE TRIGGER trg_audit_tdocumentos_personal
  AFTER INSERT OR UPDATE OR DELETE ON public.tdocumentos_personal
  FOR EACH ROW EXECUTE FUNCTION public.fn_audit_row();

-- 5. RLS (misma empresa + rol)
ALTER TABLE public.tdocumentos_personal ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tdocumentos_personal_select ON public.tdocumentos_personal;
DROP POLICY IF EXISTS tdocumentos_personal_insert ON public.tdocumentos_personal;
DROP POLICY IF EXISTS tdocumentos_personal_update ON public.tdocumentos_personal;
DROP POLICY IF EXISTS tdocumentos_personal_delete ON public.tdocumentos_personal;

CREATE POLICY tdocumentos_personal_select ON public.tdocumentos_personal FOR SELECT TO authenticated
  USING (
    personal_id = public.fn_mi_personal_id()
    OR (public.fn_puede_ver_personal()
        AND (public.fn_mi_empresa_id() IS NULL OR empresa_id = public.fn_mi_empresa_id()))
  );
CREATE POLICY tdocumentos_personal_insert ON public.tdocumentos_personal FOR INSERT TO authenticated
  WITH CHECK (
    public.fn_rol_en(ARRAY['admin', 'jefe_personal'])
    AND (public.fn_mi_empresa_id() IS NULL OR empresa_id = public.fn_mi_empresa_id())
  );
CREATE POLICY tdocumentos_personal_update ON public.tdocumentos_personal FOR UPDATE TO authenticated
  USING (
    public.fn_rol_en(ARRAY['admin', 'jefe_personal'])
    AND (public.fn_mi_empresa_id() IS NULL OR empresa_id = public.fn_mi_empresa_id())
  )
  WITH CHECK (
    public.fn_rol_en(ARRAY['admin', 'jefe_personal'])
    AND (public.fn_mi_empresa_id() IS NULL OR empresa_id = public.fn_mi_empresa_id())
  );
CREATE POLICY tdocumentos_personal_delete ON public.tdocumentos_personal FOR DELETE TO authenticated
  USING (
    public.fn_rol_en(ARRAY['admin', 'jefe_personal'])
    AND (public.fn_mi_empresa_id() IS NULL OR empresa_id = public.fn_mi_empresa_id())
  );

-- 6. Comentarios
COMMENT ON TABLE public.tdocumentos_personal IS 'Documentos y certificaciones del personal (DNI, carnet, titulaciones, certificados...)';
COMMENT ON COLUMN public.tdocumentos_personal.fecha_caducidad IS 'NULL = sin caducidad. Estado calculado en la app (próximo a caducar: 30 días)';
COMMENT ON COLUMN public.tdocumentos_personal.archivo_url IS 'URL opcional del archivo (Storage o enlace externo)';
