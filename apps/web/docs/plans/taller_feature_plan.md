# 📋 Plan: Módulo Taller - Gestión Integral del Taller Mecánico

> **Fecha**: 2026-06-09
> **Estado**: Plan pendiente de aprobación
> **Branch**: `features/taller_vehiculos`

---

## 🎯 Visión General

### Problema Actual

Actualmente en AmbuTrack existen **3 features separadas** que gestionan aspectos de mantenimiento de vehículos, con información duplicada y descoordinada:

| Feature | Qué hace | Campos de "taller" |
|---------|----------|---------------------|
| **Mantenimiento Preventivo** | Planificación y registro de mantenimientos programados | `taller` (texto), `mecanico_responsable`, `numero_orden` |
| **ITV y Revisiones** | Control de inspecciones técnicas oficiales | `taller`/`estacion` (texto), `inspector` |
| **Incidencias/Averías** | Registro de averías y reparaciones | `taller_responsable` (texto), `costo_reparacion`, `repuestos_utilizados` |

**Problemas**:
1. El nombre del taller es **texto libre** → errores tipográficos, no se puede filtrar correctamente
2. No hay **tabla maestra de talleres** → no se gestionan datos de contacto, dirección, teléfono
3. No hay **proveedores** formalizados → no se sabe quién suministra repuestos
4. No hay **órdenes de reparación** → las reparaciones se registran como texto en averías sin seguimiento
5. No hay **control de repuestos** → no se gestiona inventario ni costes de piezas

### Solución Propuesta

Crear el **módulo Taller** como **hub central** que unifica y profesionaliza la gestión mecánica, manteniendo las features existentes como están pero conectándolas a través de:

1. **Tabla maestra de Talleres** (catálogo)
2. **Tabla maestra de Proveedores** (catálogo)
3. **Órdenes de Reparación** (proceso)
4. **Control de Repuestos** (inventario)
5. **Alertas de Mantenimiento** (dashboard)

---

## 🏗️ Arquitectura: Relación entre Features

```
┌─────────────────────────────────────────────────────────┐
│                    VEHÍCULOS (existente)                  │
│  - Flota, estado, geolocalización, consumo, documentación│
└────────────┬──────────────┬──────────────┬───────────────┘
             │              │              │
     ┌───────▼──────┐ ┌────▼────────┐ ┌──▼──────────────┐
     │ Mantenimiento│ │ ITV y       │ │ Incidencias/    │
     │ Preventivo   │ │ Revisiones  │ │ Averías         │
     │ (existente)  │ │ (existente) │ │ (existente)     │
     └───────┬──────┘ └────┬────────┘ └──┬──────────────┘
             │              │              │
             │    REFERENCIA (FK)          │
             │              │              │
     ┌───────▼──────────────▼──────────────▼───────────────┐
     │                  TALLER (NUEVO)                       │
     │                                                       │
     │  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐ │
     │  │ Catálogo    │  │ Órdenes de   │  │ Control     │ │
     │  │ Talleres    │  │ Reparación   │  │ Repuestos   │ │
     │  └─────────────┘  └──────────────┘  └─────────────┘ │
     │                                                       │
     │  ┌─────────────┐  ┌──────────────┐                   │
     │  │ Proveedores │  │ Alertas      │                   │
     │  │             │  │ Mantenimiento│                   │
     │  └─────────────┘  └──────────────┘                   │
     └───────────────────────────────────────────────────────┘
```

### Cómo se relacionan

| Elemento Existente | Relación con Taller | Cambio |
|---------------------|---------------------|--------|
| `MantenimientoEntity.taller` | → FK a `taller_id` en tabla maestra | Refactor campo texto → UUID |
| `MantenimientoEntity.numeroOrden` | → FK a `orden_reparacion_id` | Vincular con órdenes |
| `IncidenciaVehiculoEntity.tallerResponsable` | → FK a `taller_id` | Refactor campo texto → UUID |
| `IncidenciaVehiculoEntity.costoReparacion` | → Viene de la Orden de Reparación | Vincular costes |
| `ItvRevisionEntity.taller` | → FK a `taller_id` (estación ITV) | Refactor campo texto → UUID |

---

## 📊 Modelo de Datos - Nuevas Tablas Supabase

### 1. `ttalleres` - Tabla Maestra de Talleres

```sql
CREATE TABLE ttalleres (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresas(id),
  nombre TEXT NOT NULL,                    -- "Taller Mecánico García S.L."
  nif TEXT,                                -- "B12345678"
  direccion TEXT,                          -- "Polígono Industrial..."
  ciudad TEXT,
  provincia TEXT,
  codigo_postal TEXT,
  telefono TEXT,
  email TEXT,
  contacto_nombre TEXT,                    -- Persona de contacto
  especialidad TEXT,                       -- "Mecánica general", "Electromecánica", "Chapa y pintura"
  tipo TEXT NOT NULL DEFAULT 'propio',     -- 'propio', 'externo', 'itv'
  activo BOOLEAN DEFAULT true,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES auth.users(id)
);
```

### 2. `tproveedores_taller` - Proveedores de Repuestos/Servicios

```sql
CREATE TABLE tproveedores_taller (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresas(id),
  nombre TEXT NOT NULL,                    -- "Recambios López S.L."
  nif TEXT,
  direccion TEXT,
  ciudad TEXT,
  provincia TEXT,
  codigo_postal TEXT,
  telefono TEXT,
  email TEXT,
  contacto_nombre TEXT,
  tipo TEXT NOT NULL DEFAULT 'repuestos',  -- 'repuestos', 'servicios', 'lubricantes', 'neumaticos', 'otros'
  forma_pago TEXT,                         -- "Transferencia 30 días"
  cuenta_bancaria TEXT,
  activo BOOLEAN DEFAULT true,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES auth.users(id)
);
```

### 3. `tordenes_reparacion` - Órdenes de Reparación (CORE del Taller)

```sql
CREATE TABLE tordenes_reparacion (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresas(id),
  numero_orden TEXT NOT NULL,              -- "OR-2026-0001" (autogenerado)
  vehiculo_id UUID NOT NULL REFERENCES tvehiculos(id),
  taller_id UUID REFERENCES ttalleres(id),
  
  -- Origen de la orden
  origen TEXT NOT NULL DEFAULT 'averia',   -- 'averia', 'mantenimiento', 'itv', 'voluntaria'
  incidencia_id UUID REFERENCES incidencias_vehiculos(id),  -- Si viene de una avería
  mantenimiento_id UUID REFERENCES tmantenimientos(id),      -- Si viene de mantenimiento
  
  -- Estado del proceso
  estado TEXT NOT NULL DEFAULT 'abierta',  -- 'abierta', 'en_proceso', 'esperando_repuestos', 'finalizada', 'cerrada', 'anulada'
  prioridad TEXT NOT NULL DEFAULT 'normal', -- 'baja', 'normal', 'alta', 'urgente'
  
  -- Descripción del trabajo
  diagnostico TEXT,                        -- Diagnóstico inicial
  trabajos_realizados TEXT,                -- Descripción detallada
  kilometraje_entrada INTEGER,
  kilometraje_salida INTEGER,
  
  -- Asignación
  mecanico_asignado UUID REFERENCES auth.users(id),
  mecanico_nombre TEXT,
  
  -- Fechas del proceso
  fecha_entrada TIMESTAMPTZ NOT NULL DEFAULT now(),
  fecha_inicio_trabajo TIMESTAMPTZ,
  fecha_espera_repuestos TIMESTAMPTZ,
  fecha_finalizacion TIMESTAMPTZ,
  fecha_cierre TIMESTAMPTZ,
  
  -- Costes
  mano_obra_horas NUMERIC(5,2) DEFAULT 0,
  costo_mano_obra NUMERIC(10,2) DEFAULT 0,
  costo_repuestos NUMERIC(10,2) DEFAULT 0,
  costo_grua NUMERIC(10,2) DEFAULT 0,
  costo_total NUMERIC(10,2) DEFAULT 0,
  cubierto_seguro BOOLEAN DEFAULT false,
  
  -- Garantía
  garantia_meses INTEGER,
  fecha_fin_garantia TIMESTAMPTZ,
  
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES auth.users(id)
);
```

### 4. `trepuestos_orden` - Repuestos por Orden de Reparación

```sql
CREATE TABLE trepuestos_orden (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  orden_id UUID NOT NULL REFERENCES tordenes_reparacion(id) ON DELETE CASCADE,
  proveedor_id UUID REFERENCES tproveedores_taller(id),
  
  descripcion TEXT NOT NULL,               -- "Filtro de aceite Castrol"
  referencia TEXT,                         -- "REF-AC-12345"
  cantidad INTEGER NOT NULL DEFAULT 1,
  precio_unitario NUMERIC(10,2) NOT NULL,
  precio_total NUMERIC(10,2) NOT NULL,     -- cantidad * precio_unitario
  
  estado TEXT DEFAULT 'solicitado',        -- 'solicitado', 'pedido', 'recibido', 'instalado'
  fecha_pedido TIMESTAMPTZ,
  fecha_recibido TIMESTAMPTZ,
  
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### 5. `talertas_mantenimiento` - Alertas Automáticas

```sql
CREATE TABLE talertas_mantenimiento (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresas(id),
  vehiculo_id UUID NOT NULL REFERENCES tvehiculos(id),
  
  tipo_alerta TEXT NOT NULL,               -- 'mantenimiento_km', 'mantenimiento_tiempo', 'itv_vencimiento', 'seguro_vencimiento', 'revision_periodica'
  titulo TEXT NOT NULL,
  descripcion TEXT,
  
  -- Condición de activación
  km_activacion INTEGER,                   -- "Avisar a los 10.000 km"
  fecha_activacion TIMESTAMPTZ,            -- "Avisar 30 días antes"
  fecha_vencimiento TIMESTAMPTZ,           -- Fecha límite
  
  -- Estado
  estado TEXT NOT NULL DEFAULT 'pendiente', -- 'pendiente', 'notificada', 'en_proceso', 'resuelta', 'vencida'
  prioridad TEXT DEFAULT 'normal',         -- 'baja', 'normal', 'alta', 'critica'
  
  -- Resolución
  orden_reparacion_id UUID REFERENCES tordenes_reparacion(id),
  resuelta_por UUID REFERENCES auth.users(id),
  fecha_resolucion TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

---

## 🔄 Fases de Implementación

### Fase 1: Fundamentos (Tablas Maestras)
**Duración estimada**: 2-3 días

| # | Tarea | Archivos |
|---|-------|----------|
| 1.1 | Crear migraciones SQL (ttalleres, tproveedores_taller) | `supabase/migrations/` |
| 1.2 | Crear entities en core_datasource | `packages/.../datasources/talleres/entities/` |
| 1.3 | Crear models en core_datasource | `packages/.../datasources/talleres/models/` |
| 1.4 | Crear contract + implementation + factory | `packages/.../datasources/talleres/` |
| 1.5 | Crear repository pass-through | `apps/web/lib/features/taller/data/repositories/` |
| 1.6 | Implementar página Catálogo de Talleres (CRUD) | `apps/web/lib/features/taller/talleres/` |
| 1.7 | Implementar página Catálogo de Proveedores (CRUD) | `apps/web/lib/features/taller/proveedores/` |
| 1.8 | Actualizar rutas PlaceholderPage → páginas reales | `lib/core/router/app_router.dart` |

### Fase 2: Órdenes de Reparación (CORE)
**Duración estimada**: 3-4 días

| # | Tarea | Archivos |
|---|-------|----------|
| 2.1 | Crear migración SQL (tordenes_reparacion, trepuestos_orden) | `supabase/migrations/` |
| 2.2 | Crear entities/models en core_datasource | `packages/.../datasources/ordenes_reparacion/` |
| 2.3 | Crear contract + implementation + factory | `packages/.../datasources/ordenes_reparacion/` |
| 2.4 | Crear BLoC de órdenes | `apps/web/lib/features/taller/ordenes/bloc/` |
| 2.5 | Implementar página de Órdenes (listado + filtros + tabla) | `apps/web/lib/features/taller/ordenes/` |
| 2.6 | Implementar formulario de creación de Orden | `apps/web/lib/features/taller/ordenes/widgets/` |
| 2.7 | Implementar vista detalle de Orden con repuestos | `apps/web/lib/features/taller/ordenes/widgets/` |
| 2.8 | Implementar gestión de repuestos dentro de la orden | `apps/web/lib/features/taller/ordenes/widgets/` |

### Fase 3: Historial y Alertas
**Duración estimada**: 2-3 días

| # | Tarea | Archivos |
|---|-------|----------|
| 3.1 | Crear migración SQL (talertas_mantenimiento) | `supabase/migrations/` |
| 3.2 | Implementar página Historial de Reparaciones | `apps/web/lib/features/taller/historial/` |
| 3.3 | Implementar página Alertas de Mantenimiento | `apps/web/lib/features/taller/alertas/` |
| 3.4 | Crear función SQL de alertas automáticas | `supabase/migrations/` |
| 3.5 | Crear vista SQL de historial por vehículo | `supabase/migrations/` |

### Fase 4: Integración con Features Existentes
**Duración estimada**: 1-2 días

| # | Tarea | Descripción |
|---|-------|-------------|
| 4.1 | Refactor `MantenimientoEntity.taller` | Texto libre → FK UUID a ttalleres |
| 4.2 | Refactor `IncidenciaVehiculoEntity.tallerResponsable` | Texto libre → FK UUID a ttalleres |
| 4.3 | Refactor `ItvRevisionEntity.taller` | Texto libre → FK UUID a ttalleres |
| 4.4 | Actualizar formularios existentes | Dropdown de talleres en vez de texto libre |
| 4.5 | Vincular incidencias con órdenes | Botón "Crear Orden de Reparación" desde avería |

---

## 📁 Estructura de Archivos Propuesta

```
lib/features/taller/
├── data/
│   └── repositories/
│       ├── taller_repository_impl.dart          # Catálogo de talleres
│       ├── proveedor_taller_repository_impl.dart # Proveedores
│       ├── orden_reparacion_repository_impl.dart # Órdenes
│       └── alerta_mantenimiento_repository_impl.dart # Alertas
│
├── domain/
│   └── repositories/
│       ├── taller_repository.dart
│       ├── proveedor_taller_repository.dart
│       ├── orden_reparacion_repository.dart
│       └── alerta_mantenimiento_repository.dart
│
├── talleres/                         # Sub-feature: Catálogo de Talleres
│   ├── talleres_page.dart
│   └── widgets/
│       ├── taller_form_dialog.dart
│       └── taller_card.dart
│
├── proveedores/                      # Sub-feature: Proveedores
│   ├── proveedores_page.dart
│   └── widgets/
│       ├── proveedor_form_dialog.dart
│       └── proveedor_table.dart
│
├── ordenes/                          # Sub-feature: Órdenes de Reparación
│   ├── ordenes_reparacion_page.dart
│   ├── historial_reparaciones_page.dart
│   └── widgets/
│       ├── orden_form_dialog.dart
│       ├── orden_detail_dialog.dart
│       ├── orden_estado_badge.dart
│       ├── repuesto_form_dialog.dart
│       ├── repuestos_list.dart
│       └── orden_timeline.dart
│
├── alertas/                          # Sub-feature: Alertas
│   ├── alertas_mantenimiento_page.dart
│   └── widgets/
│       ├── alerta_card.dart
│       └── alerta_prioridad_badge.dart
│
└── bloc/
    ├── taller_bloc.dart
    ├── taller_event.dart
    └── taller_state.dart

packages/ambutrack_core_datasource/lib/src/datasources/
├── talleres/                         # DataSource: Talleres
│   ├── entities/taller_entity.dart
│   ├── models/taller_supabase_model.dart
│   ├── implementations/supabase/supabase_talleres_datasource.dart
│   ├── talleres_contract.dart
│   └── talleres_factory.dart
│
├── proveedores_taller/               # DataSource: Proveedores
│   ├── entities/proveedor_taller_entity.dart
│   ├── models/proveedor_taller_supabase_model.dart
│   ├── implementations/supabase/supabase_proveedores_taller_datasource.dart
│   ├── proveedores_taller_contract.dart
│   └── proveedores_taller_factory.dart
│
├── ordenes_reparacion/               # DataSource: Órdenes
│   ├── entities/orden_reparacion_entity.dart
│   ├── entities/repuesto_orden_entity.dart
│   ├── models/orden_reparacion_supabase_model.dart
│   ├── models/repuesto_orden_supabase_model.dart
│   ├── implementations/supabase/supabase_ordenes_reparacion_datasource.dart
│   ├── ordenes_reparacion_contract.dart
│   └── ordenes_reparacion_factory.dart
│
└── alertas_mantenimiento/            # DataSource: Alertas
    ├── entities/alerta_mantenimiento_entity.dart
    ├── models/alerta_mantenimiento_supabase_model.dart
    ├── implementations/supabase/supabase_alertas_mantenimiento_datasource.dart
    ├── alertas_mantenimiento_contract.dart
    └── alertas_mantenimiento_factory.dart
```

---

## 📊 Flujo de Trabajo del Taller

```
1. AVERÍA REPORTADA
   └─> IncidenciaVehiculo (existente)
       └─> [NUEVO] Botón "Crear Orden de Reparación"
           └─> Taller: Orden (estado: ABIERTA)
               ├─> Diagnóstico inicial
               ├─> Asignar mecánico
               ├─> Agregar repuestos (cada uno con proveedor, precio, estado)
               │   ├─> Solicitado → Pedido → Recibido → Instalado
               │   └─> Si espera repuestos: estado orden = ESPERANDO_REPUESTOS
               ├─> Registrar trabajos realizados
               ├─> Calcular costes totales (mano obra + repuestos + grúa)
               └─> Finalizar → Cerrar orden
                   ├─> Actualiza coste en incidencia original
                   └─> Genera alerta si hay garantía

2. MANTENIMIENTO PROGRAMADO
   └─> MantenimientoEntity (existente)
       ├─> [NUEVO] Taller asignado desde catálogo (FK)
       └─> [NUEVO] Número de orden vinculado a tordenes_reparacion

3. ALERTAS AUTOMÁTICAS
   └─> Función SQL calcula:
       ├─> Vehículos próximos a km de mantenimiento
       ├─> ITV a punto de vencer
       ├─> Seguros a punto de vencer
       └─> Revisiones periódicas pendientes
```

---

## 🎨 UI: Mapeo de Submódulos

| Submódulo | Página | Widget Principal | Patrón |
|-----------|--------|------------------|--------|
| **Catálogo Talleres** | `TalleresPage` | `VehiculosTable`-like con AppDataGridV5 | Tabla maestra CRUD |
| **Proveedores** | `ProveedoresPage` | Tabla con filtros tipo y estado | Tabla maestra CRUD |
| **Órdenes Reparación** | `OrdenesReparacionPage` | Tabla con filtros estado/prioridad/vehículo + Kanban simplificado | Tabla + Flujo |
| **Historial Reparaciones** | `HistorialReparacionesPage` | Tabla de solo lectura con filtros por vehículo/taller/fecha | Tabla ReadOnly |
| **Alertas Mantenimiento** | `AlertasMantenimientoPage` | Cards con colores por prioridad + badge conteo | Dashboard |
| **Control Repuestos** | *Integrado en Orden* | Sección dentro del detalle de la orden | Inline en Orden |

---

## ⚠️ Decisiones de Diseño Clave

### 1. Taller vs. Mantenimiento Preventivo - ¿Dónde está la frontera?

| Aspecto | Mantenimiento Preventivo (existente) | Taller (nuevo) |
|---------|--------------------------------------|-----------------|
| **Naturaleza** | Planificación programada | Ejecución real de reparaciones |
| **Temporalidad** | "Qué hay que hacer y cuándo" | "Qué se hizo, cómo y cuánto costó" |
| **Registro** | Plan de mantenimiento | Orden de reparación con costes |
| **Repuestos** | No gestiona | Sí, con proveedor y precio |
| **Costes** | Estimado | Real (mano obra + repuestos + grúa) |
| **Flujo** | Crear → Programar → Completar | Abrir → Diagnosticar → Reparar → Cerrar |

**Analogía**: Mantenimiento = **Agenda médica** (chequeos programados) / Taller = **Historial clínico** (intervenciones realizadas)

### 2. Control de Repuestos = Sub-feature de Órdenes

Los repuestos **no son un módulo independiente**. Siempre pertenecen a una orden de reparación. La página "Control de Repuestos" será una vista transversal que agrega repuestos de todas las órdenes (filtro por proveedor, estado, fecha).

### 3. Historial = Vista de solo lectura

El historial no introduce datos nuevos. Es una **vista consolidada** que cruza:
- Órdenes de reparación finalizadas/cerradas
- Mantenimientos realizados
- ITV aprobadas/rechazadas

---

## 📋 Checklist de Aprobación

Antes de empezar la implementación:

- [ ] Aprobar modelo de datos (tablas nuevas)
- [ ] Aprobar relación con features existentes (FK vs texto libre)
- [ ] Aprobar fases de implementación
- [ ] Confirmar si se implementan las 5 fases o se priorizan algunas
- [ ] Confirmar colores/iconos para el módulo taller
- [ ] Confirmar permisos CRUD por rol para cada submódulo

---

## 📏 Estimación

| Fase | Tiempo | Complejidad |
|------|--------|-------------|
| Fase 1: Fundamentos | 2-3 días | Media |
| Fase 2: Órdenes (CORE) | 3-4 días | Alta |
| Fase 3: Historial y Alertas | 2-3 días | Media |
| Fase 4: Integración | 1-2 días | Media-Baja |
| **TOTAL** | **8-12 días** | |

**Prioridad recomendada**: Fase 1 → Fase 2 → Fase 4 → Fase 3 (integrar antes de alertas)
