-- =============================================
-- AUDITORÍA GENERAL: audit_log + trigger genérico
-- Quién / qué / cuándo / antes-después en tablas clave.
-- Lectura: solo administradores de la misma empresa. Escritura: solo el trigger.
-- =============================================

-- 1. Tabla
CREATE TABLE IF NOT EXISTS public.audit_log (
  id                 BIGSERIAL PRIMARY KEY,
  empresa_id         UUID REFERENCES public.empresas(id) ON DELETE SET NULL,
  tabla              TEXT NOT NULL,
  registro_id        TEXT,
  accion             TEXT NOT NULL CHECK (accion IN ('INSERT', 'UPDATE', 'DELETE')),
  usuario_id         UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  usuario_email      TEXT,
  datos_antes        JSONB,
  datos_despues      JSONB,
  campos_modificados TEXT[],
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON public.audit_log (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_tabla      ON public.audit_log (tabla, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_usuario    ON public.audit_log (usuario_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_registro   ON public.audit_log (tabla, registro_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_empresa    ON public.audit_log (empresa_id, created_at DESC);

COMMENT ON TABLE public.audit_log IS 'Auditoría general de cambios (trigger fn_audit_row). Solo lectura para admin.';

-- 2. Función de trigger genérica
CREATE OR REPLACE FUNCTION public.fn_audit_row()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_old    JSONB := CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN to_jsonb(OLD) END;
  v_new    JSONB := CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) END;
  v_row    JSONB := COALESCE(v_new, v_old);
  v_uid    UUID  := auth.uid();
  v_campos TEXT[];
  v_empresa UUID;
BEGIN
  IF TG_OP = 'UPDATE' THEN
    SELECT array_agg(k ORDER BY k) INTO v_campos
      FROM jsonb_object_keys(v_new) AS k
     WHERE v_new -> k IS DISTINCT FROM v_old -> k
       AND k NOT IN ('updated_at', 'updated_by');
    IF v_campos IS NULL THEN
      RETURN NEW; -- solo cambió updated_at/updated_by
    END IF;
  END IF;

  BEGIN
    v_empresa := NULLIF(v_row ->> 'empresa_id', '')::UUID;
  EXCEPTION WHEN invalid_text_representation THEN
    v_empresa := NULL;
  END;
  IF v_empresa IS NULL AND v_uid IS NOT NULL THEN
    SELECT u.empresa_id INTO v_empresa FROM public.usuarios u WHERE u.id = v_uid;
  END IF;

  INSERT INTO public.audit_log (empresa_id, tabla, registro_id, accion, usuario_id,
                                usuario_email, datos_antes, datos_despues, campos_modificados)
  VALUES (
    v_empresa,
    TG_TABLE_NAME,
    v_row ->> 'id',
    TG_OP,
    v_uid,
    (SELECT au.email FROM auth.users au WHERE au.id = v_uid),
    v_old,
    v_new,
    v_campos
  );

  RETURN COALESCE(NEW, OLD);
END;
$$;

-- 3. Triggers (fase 1)
DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'usuarios', 'tpersonal', 'tvehiculos', 'servicios', 'contratos', 'ttalleres',
    'tordenes_reparacion', 'tmantenimientos', 'titv_revisiones', 'empresas'
  ]
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_audit_%1$s ON public.%1$I', t);
    EXECUTE format(
      'CREATE TRIGGER trg_audit_%1$s AFTER INSERT OR UPDATE OR DELETE ON public.%1$I '
      'FOR EACH ROW EXECUTE FUNCTION public.fn_audit_row()', t);
  END LOOP;
END $$;

-- traslados: tabla de alta escritura → solo altas, bajas y cambios de estado/asignación/programación
DROP TRIGGER IF EXISTS trg_audit_traslados_ins_del ON public.traslados;
CREATE TRIGGER trg_audit_traslados_ins_del
  AFTER INSERT OR DELETE ON public.traslados
  FOR EACH ROW EXECUTE FUNCTION public.fn_audit_row();

DROP TRIGGER IF EXISTS trg_audit_traslados_upd ON public.traslados;
CREATE TRIGGER trg_audit_traslados_upd
  AFTER UPDATE OF estado, id_vehiculo, id_conductor, personal_asignado, fecha, hora_programada,
                  motivo_cancelacion, id_paciente, origen, destino, prioridad
  ON public.traslados
  FOR EACH ROW EXECUTE FUNCTION public.fn_audit_row();

-- 4. RLS: solo lectura para administradores de la misma empresa
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS audit_log_select_admin ON public.audit_log;
CREATE POLICY audit_log_select_admin ON public.audit_log
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.usuarios u
       WHERE u.id = auth.uid()
         AND u.rol = 'admin'
         AND (audit_log.empresa_id IS NULL OR u.empresa_id IS NULL OR u.empresa_id = audit_log.empresa_id)
    )
  );

REVOKE INSERT, UPDATE, DELETE ON public.audit_log FROM authenticated, anon;
REVOKE EXECUTE ON FUNCTION public.fn_audit_row() FROM PUBLIC, anon, authenticated;
