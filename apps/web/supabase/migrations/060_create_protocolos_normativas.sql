-- =============================================
-- TABLAS MAESTRAS: Protocolos y Normativas
-- Requiere: 002 (update_updated_at_column) y 048 (fn_rol_en)
-- =============================================

CREATE TABLE IF NOT EXISTS public.tprotocolos_normativas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo TEXT NOT NULL,
  codigo TEXT,
  categoria TEXT NOT NULL DEFAULT 'protocolo_asistencial'
    CHECK (categoria IN ('protocolo_asistencial', 'procedimiento_operativo', 'normativa_legal',
                         'seguridad', 'calidad', 'otro')),
  version TEXT,
  fecha_vigencia DATE,
  descripcion TEXT,
  url_documento TEXT,
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID DEFAULT auth.uid()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_tprotocolos_normativas_codigo
  ON public.tprotocolos_normativas (upper(codigo)) WHERE codigo IS NOT NULL AND codigo <> '';
CREATE INDEX IF NOT EXISTS idx_tprotocolos_normativas_categoria ON public.tprotocolos_normativas (categoria);
CREATE INDEX IF NOT EXISTS idx_tprotocolos_normativas_activo ON public.tprotocolos_normativas (activo);

DROP TRIGGER IF EXISTS trg_tprotocolos_normativas_updated_at ON public.tprotocolos_normativas;
CREATE TRIGGER trg_tprotocolos_normativas_updated_at
  BEFORE UPDATE ON public.tprotocolos_normativas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS: lectura para autenticados; escritura para roles de tablas maestras (igual que 049)
ALTER TABLE public.tprotocolos_normativas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tprotocolos_normativas_select ON public.tprotocolos_normativas;
DROP POLICY IF EXISTS tprotocolos_normativas_insert ON public.tprotocolos_normativas;
DROP POLICY IF EXISTS tprotocolos_normativas_update ON public.tprotocolos_normativas;
DROP POLICY IF EXISTS tprotocolos_normativas_delete ON public.tprotocolos_normativas;

CREATE POLICY tprotocolos_normativas_select ON public.tprotocolos_normativas
  FOR SELECT TO authenticated USING (true);
CREATE POLICY tprotocolos_normativas_insert ON public.tprotocolos_normativas
  FOR INSERT TO authenticated
  WITH CHECK (public.fn_rol_en(ARRAY['admin','jefe_trafico','jefe_personal','coordinador','jefe_mantenimiento']));
CREATE POLICY tprotocolos_normativas_update ON public.tprotocolos_normativas
  FOR UPDATE TO authenticated
  USING (public.fn_rol_en(ARRAY['admin','jefe_trafico','jefe_personal','coordinador','jefe_mantenimiento']))
  WITH CHECK (public.fn_rol_en(ARRAY['admin','jefe_trafico','jefe_personal','coordinador','jefe_mantenimiento']));
CREATE POLICY tprotocolos_normativas_delete ON public.tprotocolos_normativas
  FOR DELETE TO authenticated
  USING (public.fn_rol_en(ARRAY['admin','jefe_trafico','jefe_personal','coordinador','jefe_mantenimiento']));

COMMENT ON TABLE public.tprotocolos_normativas IS 'Tabla maestra de protocolos asistenciales, procedimientos y normativas';
COMMENT ON COLUMN public.tprotocolos_normativas.url_documento IS 'Enlace al documento (PDF, web oficial, Storage...)';
