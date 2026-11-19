# Propuesta: Tabla maestra `/tablas/protocolos` (Protocolos y Normativas)

> Estado: **PROPUESTA – no implementada** (no existe tabla en BD)

## Contexto

- Ruta `/tablas/protocolos` ("Protocolos y Normativas · Gestión de protocolos médicos") es un `PlaceholderPage`.
  Sí está en el menú (`tablas_protocolos`) y en `AppModule.protocolos` con permisos por rol.
- No existe tabla (`protocolos`, `tprotocolos`, `normativas`...) en `supabase/migrations`, ni datasource en
  `packages/ambutrack_core_datasource/lib/src/datasources/`. Solo hay menciones a "protocolo" en el checklist de
  vehículo (texto descriptivo).
- No se pudo inspeccionar la BD en vivo (MCP Supabase sin permisos).

## Propuesta

Catálogo documental de protocolos clínicos/operativos y normativa aplicable, con versión y vigencia,
y documento adjunto en Storage.

```sql
CREATE TABLE public.tprotocolos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo TEXT NOT NULL UNIQUE,                 -- p.ej. PROT-SVB-001
  titulo TEXT NOT NULL,
  tipo TEXT NOT NULL CHECK (tipo IN ('clinico','operativo','seguridad','normativa','calidad')),
  ambito TEXT,                                 -- SVB, SVA, transporte programado...
  descripcion TEXT,
  version TEXT NOT NULL DEFAULT '1.0',
  fecha_aprobacion DATE,
  fecha_revision DATE,                         -- próxima revisión
  organismo_emisor TEXT,                       -- para normativas (BOE, Consejería...)
  referencia_legal TEXT,
  documento_path TEXT,                         -- bucket 'protocolos' en Supabase Storage
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id)
);
-- RLS: lectura para todos los autenticados; escritura para admin / coordinador.
```

Integración opcional con `alertas_caducidad` para avisar de `fecha_revision` vencida.

## Implementación (tras aprobar y crear la tabla)

1. Core datasource `protocolos/` (entity, model fromJson manual, contract, supabase impl, factory) y export.
2. Feature `lib/features/tablas/protocolos/` según el patrón de `lib/features/tablas/motivos_traslado/`:
   `GestionLayout` con filtros (tipo, vigencia, texto), ficha lateral (General / Documento / Revisión),
   Imprimir, CRUD con `showConfirmationDialog` y `CrudOperationHandler`.
3. Router: `child: const ProtocolosPage(),` en `/tablas/protocolos`.
