# Propuesta: Auditoría general y logs (`/administracion/auditorias-logs`)

> **Estado**: PROPUESTA (no implementada en BD)
> **Fecha**: 2026-11-05
> **Pantalla actual**: `AuditoriasLogsPage` muestra un estado vacío explicando que está pendiente.

## 1. Situación actual

No existe una tabla de auditoría **general** (usuario × tabla × acción × fecha). Solo hay registros de actividad específicos de traslados:

| Tabla | Origen | Contenido | Uso en la app |
|-------|--------|-----------|---------------|
| `historial_estados_traslado` | `20250130_002_create_traslados_table.sql` | Cambios de estado de cada traslado (+ ubicación GPS opcional) | Detalle del servicio (`servicios_table.dart`, datasource de traslados) |
| `traslados_eventos` | `20260205_001_create_traslados_eventos_event_ledger.sql` | Event ledger: `assigned`, `unassigned`, `reassigned`, `status_changed` con `actor_user_id` | Sincronización realtime web ↔ móvil |
| `traslados_audit` | `apps/mobile/supabase/migrations/setup_realtime_traslados.sql` | Cambios de campos críticos de traslados (trigger `audit_traslados_changes`) | Ninguno en Dart |
| `cron_job_logs` | `20250130_005_setup_cron_jobs.sql` | Ejecuciones de pg_cron | Ninguno |

> No se ha podido verificar el estado real de la BD (sin acceso MCP de lectura); comprobar con `list_tables` antes de migrar.

## 2. Propuesta de modelo

### 2.1 Tabla `audit_log`

```sql
CREATE TABLE public.audit_log (
  id           BIGSERIAL PRIMARY KEY,
  empresa_id   UUID REFERENCES public.empresas(id) ON DELETE SET NULL,
  tabla        TEXT        NOT NULL,             -- TG_TABLE_NAME
  registro_id  TEXT,                             -- PK del registro afectado (texto para soportar uuid/int)
  accion       TEXT        NOT NULL CHECK (accion IN ('INSERT','UPDATE','DELETE')),
  usuario_id   UUID REFERENCES auth.users(id) ON DELETE SET NULL,  -- auth.uid()
  usuario_email TEXT,                            -- desnormalizado para conservarlo si se borra el usuario
  datos_antes  JSONB,                            -- OLD (UPDATE/DELETE)
  datos_despues JSONB,                           -- NEW (INSERT/UPDATE)
  campos_modificados TEXT[],                     -- solo UPDATE
  origen       TEXT DEFAULT 'app',               -- app | cron | edge_function | sql
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_log_created_at ON public.audit_log (created_at DESC);
CREATE INDEX idx_audit_log_tabla      ON public.audit_log (tabla, created_at DESC);
CREATE INDEX idx_audit_log_usuario    ON public.audit_log (usuario_id, created_at DESC);
CREATE INDEX idx_audit_log_registro   ON public.audit_log (tabla, registro_id);
```

Para volúmenes altos: particionar por mes (`PARTITION BY RANGE (created_at)`) y política de retención (p. ej. 24 meses) con pg_cron.

### 2.2 Función de trigger genérica

```sql
CREATE OR REPLACE FUNCTION public.fn_audit_row()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_old JSONB := CASE WHEN TG_OP IN ('UPDATE','DELETE') THEN to_jsonb(OLD) END;
  v_new JSONB := CASE WHEN TG_OP IN ('INSERT','UPDATE') THEN to_jsonb(NEW) END;
  v_row JSONB := COALESCE(v_new, v_old);
  v_campos TEXT[];
BEGIN
  IF TG_OP = 'UPDATE' THEN
    SELECT array_agg(k) INTO v_campos
    FROM jsonb_object_keys(v_new) k
    WHERE v_new -> k IS DISTINCT FROM v_old -> k
      AND k NOT IN ('updated_at');
    IF v_campos IS NULL THEN RETURN NEW; END IF;  -- nada relevante cambió
  END IF;

  INSERT INTO public.audit_log (empresa_id, tabla, registro_id, accion, usuario_id,
                                usuario_email, datos_antes, datos_despues, campos_modificados)
  VALUES (
    NULLIF(v_row ->> 'empresa_id', '')::UUID,
    TG_TABLE_NAME,
    v_row ->> 'id',
    TG_OP,
    auth.uid(),
    (SELECT email FROM auth.users WHERE id = auth.uid()),
    v_old, v_new, v_campos
  );
  RETURN COALESCE(NEW, OLD);
END;
$$;
```

### 2.3 Tablas a auditar (fase 1)

`usuarios`, `personal`/`tpersonal`, `tvehiculos`, `traslados`, `servicios`, `tcontratos`, `ttalleres`, `tordenes_reparacion`, `tmantenimientos`, `titv_revisiones`, `empresas`.

```sql
CREATE TRIGGER trg_audit_usuarios
AFTER INSERT OR UPDATE OR DELETE ON public.usuarios
FOR EACH ROW EXECUTE FUNCTION public.fn_audit_row();
-- repetir por tabla
```

Excluir columnas sensibles (p. ej. tokens) con `v_new - 'campo'` si aplica.

### 2.4 RLS

```sql
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

-- Solo lectura para administradores de la misma empresa
CREATE POLICY audit_log_select_admin ON public.audit_log
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.usuarios u
      WHERE u.id = auth.uid()
        AND u.rol = 'admin'
        AND (audit_log.empresa_id IS NULL OR u.empresa_id = audit_log.empresa_id)
    )
  );

-- Sin políticas de INSERT/UPDATE/DELETE: solo escribe el trigger (SECURITY DEFINER).
REVOKE INSERT, UPDATE, DELETE ON public.audit_log FROM authenticated, anon;
```

### 2.5 Vista unificada (opcional)

`vw_actividad` = `audit_log` ∪ `traslados_eventos` (normalizado a tabla/acción/usuario/fecha) para que el visor muestre también el histórico ya existente de traslados.

## 3. Aplicación (cuando exista la tabla)

- Core: `packages/ambutrack_core_datasource/lib/src/datasources/audit_log/` (entity, model manual, contract con `search({usuarioId, tabla, accion, desde, hasta, limit, offset})`, Supabase impl con paginación en servidor, factory).
- Web: `lib/features/administracion/auditoria/` → `AuditoriaBloc` (@injectable), `GestionLayout` con filtros **usuario** (AppSearchableDropdown), **tabla**, **acción**, **rango de fechas**; rejilla (fecha, usuario, tabla, acción, registro, campos) y ficha lateral con diff antes/después.
- Exportación CSV opcional.

## 4. Esfuerzo y riesgos

| Bloque | Esfuerzo |
|--------|----------|
| Migración (tabla, función, triggers, RLS) | S |
| Datasource + visor web | M |
| Particionado/retención | S |

Riesgos: crecimiento de la tabla (mitigar con particionado y retención), coste de triggers en tablas con muchas escrituras (`traslados` en tiempo real: valorar auditar solo campos clave).
