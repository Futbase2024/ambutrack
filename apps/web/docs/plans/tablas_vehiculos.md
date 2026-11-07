# Propuesta: Tabla maestra `/tablas/vehiculos` (Catálogo de marcas y modelos)

> Estado: **PROPUESTA – no implementada** (no existe tabla en BD)

## Contexto

- La ruta `/tablas/vehiculos` ("Vehículos · Catálogo de vehículos") es un `PlaceholderPage` y **no figura en el menú**
  (`menu_repository_impl.dart`) ni en `AppModule`.
- La flota real ya está gestionada en `/vehiculos` (`VehiculosPage`, tabla `tvehiculos`), y las tablas maestras
  relacionadas ya existen: `/tablas/tipos-vehiculo` (`tipos_vehiculo`) y `/tablas/categorias-vehiculos`
  (`tcategorias_vehiculo`).
- `tvehiculos.marca` / `tvehiculos.modelo` son texto libre. No existe ninguna tabla de catálogo de marcas/modelos
  ni de equipamiento estándar por tipo (`tequipamiento_vehiculo` es equipamiento **por vehículo**, no catálogo).
- No hay datasource en `ambutrack_core_datasource` ni migración en `supabase/migrations` para ello.
- No se pudo inspeccionar la BD en vivo (MCP Supabase sin permisos); la conclusión se basa en migraciones y datasources.

## Propuesta

Catálogo normalizado de marcas y modelos de vehículo para evitar texto libre en la ficha de vehículo.

```sql
CREATE TABLE public.tmarcas_vehiculo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL UNIQUE,
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.tmodelos_vehiculo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  marca_id UUID NOT NULL REFERENCES public.tmarcas_vehiculo(id) ON DELETE RESTRICT,
  nombre TEXT NOT NULL,
  tipo_vehiculo_id UUID REFERENCES public.tipos_vehiculo(id),
  combustible TEXT,               -- diesel, gasolina, hibrido, electrico
  plazas INTEGER,
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (marca_id, nombre)
);
-- RLS: lectura para autenticados; escritura para admin / gestor de flota (mismo patrón que tipos_vehiculo).
```

Seed inicial: `SELECT DISTINCT marca, modelo FROM tvehiculos`.

## Implementación (tras aprobar y crear las tablas)

1. Core datasource `marcas_vehiculo/` (entity, model con fromJson manual, contract, supabase impl, factory) y export.
2. Feature `lib/features/tablas/marcas_vehiculo/` siguiendo `lib/features/tablas/motivos_traslado/`
   (repo pass-through, BLoC Equatable, `GestionLayout`, ficha lateral con pestaña "Modelos", Imprimir).
3. Router: `child: const MarcasVehiculoPage(),` en `/tablas/vehiculos`; añadir entrada de menú y `AppModule`.
4. (Opcional) Sustituir los campos texto marca/modelo del formulario de vehículo por `AppSearchableDropdown`.

## Alternativa

Si la intención era solo "listado de vehículos", eliminar la ruta `/tablas/vehiculos` o redirigirla a `/vehiculos`.
