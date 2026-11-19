# Propuesta: Configuración general (`/administracion/configuracion-general` y `/configuracion`)

> **Estado**: PROPUESTA de persistencia. La pantalla actual (`ConfiguracionGeneralPage`) es de **solo lectura**.
> **Fecha**: 2026-11-05

## 1. Qué existe hoy

| Fuente | Contenido | Mostrado en la pantalla |
|--------|-----------|------------------------|
| `AppConfig` (`lib/core/config/app_config.dart`) | Nombre, versión, build, timeouts, feature flags (constantes) | Sí (nombre, versión, build) |
| `F` / `Flavor` (`lib/app/flavors.dart`) | Flavor dev/prod, título | Sí |
| `SupabaseOptions` | URL del proyecto por entorno | Sí (URL e ID; la anon key **no**) |
| `AuthBloc` (`AuthAuthenticated.user`) | Usuario, email, DNI, rol, empresa, último acceso | Sí |
| `RolePermissions` | Módulos accesibles del rol | Sí (número) |
| `empresas.configuracion` (JSONB) | Parámetros por empresa (vacío por defecto) | En Multi-centro › ficha › Configuración |
| `ambutrack_alertas_umbrales_config` | Umbrales de alertas de caducidad | No (tiene su propio módulo) |
| `SharedPreferences` | Solo anchos de columnas de una tabla de servicios | No |

**No existe** una tabla de parámetros globales ni preferencias de usuario persistidas.

## 2. Propuesta

### 2.1 Parámetros por empresa: `configuracion_parametros`

Preferible a seguir usando `empresas.configuracion` (JSONB sin esquema) porque permite tipado, validación, auditoría y RLS por clave.

```sql
CREATE TABLE public.configuracion_parametros (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id  UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  clave       TEXT NOT NULL,                 -- p. ej. 'servicios.margen_recogida_min'
  valor       JSONB NOT NULL,
  tipo        TEXT NOT NULL CHECK (tipo IN ('int','bool','text','json','time')),
  grupo       TEXT NOT NULL,                 -- 'servicios', 'cuadrante', 'notificaciones', ...
  descripcion TEXT,
  updated_by  UUID REFERENCES auth.users(id),
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now(),
  UNIQUE (empresa_id, clave)
);
```

Parámetros iniciales sugeridos: margen de recogida (min), horizonte de generación de traslados recurrentes (días), hora de cierre de jornada, días de aviso de caducidades (unificar con `ambutrack_alertas_umbrales_config`), zona horaria, formato de nombres (MAYÚSCULAS).

RLS: `SELECT` para usuarios de la misma empresa; `INSERT/UPDATE/DELETE` solo `rol = 'admin'` de esa empresa. Trigger `updated_at` y, cuando exista, `fn_audit_row()` (ver `administracion_auditoria.md`).

### 2.2 Preferencias de usuario: `usuarios_preferencias`

```sql
CREATE TABLE public.usuarios_preferencias (
  usuario_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  idioma     TEXT DEFAULT 'es',
  tema       TEXT DEFAULT 'light',
  tamano_pagina INT DEFAULT 25,
  preferencias JSONB DEFAULT '{}'::jsonb,   -- anchos de columnas, filtros guardados...
  updated_at TIMESTAMPTZ DEFAULT now()
);
-- RLS: cada usuario solo su fila (usuario_id = auth.uid())
```

## 3. Aplicación

- Core: `configuracion_parametros/` y `usuarios_preferencias/` (entity, model manual, contract, Supabase impl, factory).
- Web: `/administracion/configuracion-general` → `GestionLayout` con rejilla de parámetros por grupo y ficha lateral editable (solo admin, `CrudOperationHandler`). `/configuracion` → preferencias del usuario actual + bloque de información de solo lectura actual.

## 4. Esfuerzo

| Bloque | Esfuerzo |
|--------|----------|
| Migraciones + RLS | S |
| Datasources | S |
| UI parámetros (admin) | M |
| UI preferencias usuario + integración (tamaño de página, idioma) | M |
