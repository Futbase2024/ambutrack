# 📊 Análisis de Sistemas de Stock - AmbuTrack Web

**Proyecto**: AmbuTrack Web
**Módulo**: Gestión de Stock de Equipamiento Médico
**Fecha de Análisis**: 2025-01-27
**Autor**: Claude Code Assistant
**Versión**: 1.0.0

---

## 📑 Tabla de Contenidos

- [Resumen Ejecutivo](#resumen-ejecutivo)
- [Diferenciación de Sistemas](#diferenciación-de-sistemas)
- [Sistema 1: Stock General de la Empresa](#sistema-1-stock-general-de-la-empresa)
- [Sistema 2: Stock Asignado por Vehículo](#sistema-2-stock-asignado-por-vehículo)
- [Comparativa de Sistemas](#comparativa-de-sistemas)
- [Estado de Implementación](#estado-de-implementación)
- [Propuesta de Ampliación](#propuesta-de-ampliación)
- [Arquitectura Propuesta para Sistema 1](#arquitectura-propuesta-para-sistema-1)
- [Flujos de Trabajo](#flujos-de-trabajo)
- [Decisiones Pendientes](#decisiones-pendientes)
- [Roadmap de Implementación](#roadmap-de-implementación)

---

## 🎯 Resumen Ejecutivo

### Contexto

En la gestión de ambulancias existen **DOS sistemas de stock completamente diferentes** que deben coexistir:

1. **Stock General de la Empresa (Almacén Central)**: Inventario global de material disponible
2. **Stock Asignado por Vehículo**: Material específico asignado a cada ambulancia

### Problema Identificado

La implementación actual del módulo de stock **SOLO contempla el Sistema 2** (stock por vehículo), lo que limita:
- ❌ Control de inventario general de la empresa
- ❌ Gestión de compras y proveedores
- ❌ Flujo de asignación almacén → vehículo
- ❌ Valoración económica del stock
- ❌ Planificación de compras basada en consumo

### Objetivo del Documento

Documentar la **diferenciación clara entre ambos sistemas**, el **estado actual de implementación**, y proponer una **hoja de ruta** para completar la gestión integral de stock.

---

## 🏢 Diferenciación de Sistemas

### Vista Conceptual

```
┌─────────────────────────────────────────────────────────────────┐
│                        EMPRESA AMBULANCIAS                       │
│                                                                  │
│  ┌────────────────────────────┐      ┌──────────────────────┐  │
│  │  SISTEMA 1: ALMACÉN        │      │  SISTEMA 2: VEHÍCULOS│  │
│  │  Stock General             │──────│  Stock Asignado      │  │
│  │                            │      │                      │  │
│  │  • Inventario total        │      │  • Por matrícula     │  │
│  │  • Compras                 │      │  • Revisiones        │  │
│  │  • Proveedores             │      │  • Caducidades       │  │
│  │  • Valoración económica    │      │  • Normativa EN 1789 │  │
│  └────────────────────────────┘      └──────────────────────┘  │
│           ↓                                    ↑                │
│           └─────── Transferencias ─────────────┘                │
│              (Asignación / Devolución)                          │
└─────────────────────────────────────────────────────────────────┘
```

### Diferencias Clave

| Aspecto | Sistema 1: Almacén General | Sistema 2: Stock por Vehículo |
|---------|---------------------------|-------------------------------|
| **Ubicación** | Almacén central / Bodega | Dentro de cada ambulancia |
| **Propósito** | Control de inventario global | Revisiones y cumplimiento normativo |
| **Granularidad** | Producto + Lote + Ubicación almacén | Producto + Lote + Matrícula vehículo |
| **Usuario Principal** | Responsable de compras / Logística | Técnicos sanitarios / Conductores |
| **Frecuencia de Cambio** | Alta (entradas/salidas diarias) | Media (revisiones mensuales) |
| **Control de Costes** | SÍ (precio compra, valoración) | NO (solo cantidades) |
| **Proveedores** | SÍ (gestión de proveedores) | NO |
| **Normativa** | Gestión interna | EN 1789:2021 (obligatorio) |

---

## 🏥 Sistema 1: Stock General de la Empresa

### Definición

**Stock General de la Empresa** es el inventario centralizado de **TODO el material disponible** en el almacén/bodega de la organización, antes de ser asignado a vehículos o consumido en operaciones.

### Características Principales

#### 1. Inventario Total
- **Qué incluye**: Material fungible, electromedicina, medicamentos, equipamiento sanitario
- **Cantidades**: Stock físico disponible + reservado
- **Ubicación**: Zonas/estanterías del almacén
- **Lotes**: Control por lote de fabricación
- **Caducidades**: Control global de fechas de caducidad

#### 2. Gestión de Compras
- **Proveedores**: Catálogo de proveedores habituales
- **Órdenes de compra**: Generación automática por stock mínimo
- **Recepciones**: Registro de entradas de material
- **Valoración económica**: Precio unitario, valor total del stock
- **Facturas**: Vinculación con facturas de proveedor

#### 3. Control de Movimientos
- **Entradas**: Compras, devoluciones de vehículos
- **Salidas**: Asignaciones a vehículos, consumo interno
- **Transferencias**: Entre ubicaciones del almacén
- **Ajustes**: Por inventario físico, mermas, caducidades

#### 4. Reportes y Analytics
- **Valoración**: Valor económico total del stock
- **Rotación**: Productos más/menos usados
- **Necesidades de compra**: Alertas por stock mínimo
- **Consumo histórico**: Tendencias de uso
- **Caducidades próximas**: Material a devolver o consumir

### Tablas de Base de Datos Necesarias

#### Tabla: `stock_almacen`
```sql
CREATE TABLE stock_almacen (
  -- Identificación
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producto_id UUID REFERENCES productos(id) ON DELETE RESTRICT,

  -- Cantidades
  cantidad_disponible INT NOT NULL DEFAULT 0 CHECK (cantidad_disponible >= 0),
  cantidad_reservada INT DEFAULT 0 CHECK (cantidad_reservada >= 0),
  cantidad_minima INT DEFAULT 0,  -- Para alertas de reposición

  -- Trazabilidad
  lote VARCHAR(50),
  fecha_caducidad DATE,
  fecha_entrada DATE NOT NULL,

  -- Ubicación física
  ubicacion_almacen VARCHAR(100),  -- Ej: "Estantería A-3"
  zona VARCHAR(50),  -- Ej: "Medicamentos", "Fungibles"

  -- Información de compra
  proveedor_id UUID REFERENCES proveedores(id),
  numero_factura VARCHAR(50),
  precio_unitario DECIMAL(10,2),
  precio_total DECIMAL(10,2),
  moneda VARCHAR(3) DEFAULT 'EUR',

  -- Control
  observaciones TEXT,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  updated_by UUID REFERENCES auth.users(id)
);

-- Índices para performance
CREATE INDEX idx_stock_almacen_producto ON stock_almacen(producto_id);
CREATE INDEX idx_stock_almacen_lote ON stock_almacen(lote);
CREATE INDEX idx_stock_almacen_caducidad ON stock_almacen(fecha_caducidad);
CREATE INDEX idx_stock_almacen_ubicacion ON stock_almacen(ubicacion_almacen);
CREATE INDEX idx_stock_almacen_activo ON stock_almacen(activo);

-- Constraint: cantidad reservada no puede exceder disponible
ALTER TABLE stock_almacen ADD CONSTRAINT chk_reserva_valida
  CHECK (cantidad_reservada <= cantidad_disponible);
```

#### Tabla: `proveedores`
```sql
CREATE TABLE proveedores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo VARCHAR(20) UNIQUE,
  nombre_comercial VARCHAR(150) NOT NULL,
  razon_social VARCHAR(150),
  cif_nif VARCHAR(20),

  -- Contacto
  direccion TEXT,
  codigo_postal VARCHAR(10),
  ciudad VARCHAR(100),
  provincia VARCHAR(100),
  pais VARCHAR(100) DEFAULT 'España',
  telefono VARCHAR(20),
  email VARCHAR(100),
  web VARCHAR(200),
  persona_contacto VARCHAR(100),

  -- Información comercial
  condiciones_pago VARCHAR(50),  -- Ej: "30 días", "Contado"
  descuento_general DECIMAL(5,2),  -- Porcentaje
  observaciones TEXT,

  -- Control
  activo BOOLEAN DEFAULT TRUE,
  fecha_alta DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_proveedores_nombre ON proveedores(nombre_comercial);
CREATE INDEX idx_proveedores_activo ON proveedores(activo);
```

#### Tabla: `entradas_almacen`
```sql
CREATE TABLE entradas_almacen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_entrada VARCHAR(20) UNIQUE,  -- Auto-generado
  tipo VARCHAR(20) CHECK (tipo IN ('compra', 'devolucion', 'ajuste', 'transferencia')),

  -- Origen
  proveedor_id UUID REFERENCES proveedores(id),
  numero_factura VARCHAR(50),
  fecha_factura DATE,

  -- Detalles
  fecha_entrada DATE NOT NULL,
  recibido_por UUID REFERENCES auth.users(id),
  observaciones TEXT,

  -- Estado
  estado VARCHAR(20) CHECK (estado IN ('pendiente', 'recibida', 'parcial', 'cancelada')),

  -- Control
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Detalle de cada línea de entrada
CREATE TABLE detalle_entradas_almacen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entrada_id UUID REFERENCES entradas_almacen(id) ON DELETE CASCADE,
  producto_id UUID REFERENCES productos(id),

  cantidad INT NOT NULL CHECK (cantidad > 0),
  lote VARCHAR(50),
  fecha_caducidad DATE,
  ubicacion_destino VARCHAR(100),

  precio_unitario DECIMAL(10,2),
  precio_total DECIMAL(10,2),

  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Tabla: `transferencias_stock`
```sql
CREATE TABLE transferencias_stock (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_transferencia VARCHAR(20) UNIQUE,  -- Auto-generado

  -- Tipo de movimiento
  tipo VARCHAR(20) CHECK (tipo IN ('asignacion', 'devolucion', 'ajuste')),

  -- Origen y Destino
  origen_tipo VARCHAR(20) CHECK (origen_tipo IN ('almacen', 'vehiculo')),
  origen_id UUID,  -- NULL si es almacén, vehiculo_id si es vehículo

  destino_tipo VARCHAR(20) CHECK (destino_tipo IN ('almacen', 'vehiculo')),
  destino_id UUID,  -- NULL si es almacén, vehiculo_id si es vehículo

  -- Producto
  producto_id UUID REFERENCES productos(id),
  cantidad INT NOT NULL CHECK (cantidad > 0),
  lote VARCHAR(50),

  -- Control
  motivo TEXT,
  realizada_por UUID REFERENCES auth.users(id),
  fecha_transferencia TIMESTAMPTZ DEFAULT NOW(),
  estado VARCHAR(20) CHECK (estado IN ('pendiente', 'completada', 'cancelada')),

  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_transferencias_origen ON transferencias_stock(origen_tipo, origen_id);
CREATE INDEX idx_transferencias_destino ON transferencias_stock(destino_tipo, destino_id);
CREATE INDEX idx_transferencias_producto ON transferencias_stock(producto_id);
CREATE INDEX idx_transferencias_fecha ON transferencias_stock(fecha_transferencia);
```

### Páginas y Funcionalidades Necesarias

#### 1. **AlmacenGeneralPage** (`/almacen/inventario`)
**Propósito**: Vista principal del inventario del almacén

**Características**:
- 📊 **Vista general**: Stock actual por producto
- 🔍 **Filtros**: Por categoría, ubicación, caducidad, proveedor
- 📈 **Métricas**: Valor total, productos bajo mínimo, próximos a caducar
- 🎨 **Badges visuales**:
  - 🟢 Stock normal
  - 🟡 Stock bajo (< mínimo)
  - 🔴 Sin stock
  - ⏰ Próximo a caducar (< 30 días)
- 📥 **Acciones rápidas**: Registrar entrada, crear transferencia

#### 2. **EntradaAlmacenPage** (`/almacen/entradas`)
**Propósito**: Registrar recepciones de material (compras)

**Características**:
- 📝 **Formulario de entrada**:
  - Selección de proveedor
  - Número de factura
  - Fecha de recepción
  - Líneas de detalle (producto, cantidad, lote, caducidad, precio)
- 📋 **Historial de entradas**: Búsqueda y edición
- 💰 **Cálculo automático**: Subtotales, total
- 🏷️ **Asignación de ubicación**: Por defecto según tipo de producto

#### 3. **TransferenciasPage** (`/almacen/transferencias`)
**Propósito**: Asignar material desde almacén a vehículos

**Características**:
- 🔄 **Tipos de transferencia**:
  - **Asignación**: Almacén → Vehículo
  - **Devolución**: Vehículo → Almacén
  - **Ajuste**: Correcciones de inventario
- 🚑 **Selector de vehículo**: Autocomplete por matrícula
- 📦 **Selector de producto**: Con stock disponible en tiempo real
- 📊 **Validaciones**:
  - Stock suficiente en origen
  - Lote y caducidad válidos
  - Vehículo activo
- 📜 **Historial**: Log completo de movimientos

#### 4. **ProveedoresPage** (`/almacen/proveedores`)
**Propósito**: Gestión de catálogo de proveedores

**Características**:
- 📇 **CRUD completo**: Crear, editar, desactivar proveedores
- 📊 **Estadísticas por proveedor**: Total comprado, frecuencia, última compra
- 🔍 **Búsqueda**: Por nombre, CIF, ciudad
- 📁 **Exportación**: Listado en CSV/Excel

#### 5. **ReportesAlmacenPage** (`/almacen/reportes`)
**Propósito**: Analytics y reportes de stock

**Características**:
- 📈 **Valoración de stock**: Total, por categoría, por ubicación
- 🔄 **Rotación de productos**: Más/menos usados
- 📉 **Necesidades de compra**: Stock bajo mínimo
- ⏰ **Caducidades próximas**: Alert de material a gestionar
- 📊 **Consumo histórico**: Tendencias mensuales/anuales
- 📉 **Gráficos**: Evolución de stock, top productos, etc.

---

## 🚑 Sistema 2: Stock Asignado por Vehículo

### Definición

**Stock Asignado por Vehículo** es el material médico y equipamiento que **físicamente se encuentra dentro de cada ambulancia específica**, sujeto a revisiones periódicas según normativa EN 1789:2021.

### Características Principales

#### 1. Asignación por Matrícula
- Cada vehículo tiene su **stock independiente**
- Control por **matrícula única** (ej: ABC-1234)
- Stock vinculado a **tipo de ambulancia** (A2, B, C)
- Requisitos mínimos según normativa

#### 2. Revisiones Periódicas
- **Frecuencia**: Mensual (días 1, 2 o 3 según categoría)
- **Checklist normativo**: Según EN 1789:2021
- **Registro de revisión**: Quién, cuándo, qué se revisó
- **Incidencias**: Material faltante, dañado o caducado

#### 3. Control de Caducidades
- **Alertas automáticas**: 30 días antes de caducidad
- **Nivel de urgencia**: Crítico, Alto, Medio, Bajo
- **Acciones**: Consumir, devolver, reponer
- **Trazabilidad**: Lote y fecha de caducidad

#### 4. Movimientos Internos
- **Entrada**: Asignación desde almacén
- **Salida**: Consumo en servicio, devolución a almacén
- **Transferencia**: Entre vehículos (excepcional)
- **Ajuste**: Correcciones por inventario

### Tablas Implementadas (Sistema 2)

✅ **Ya implementado** en el módulo actual:

```sql
-- Catálogo de productos
categorias_equipamiento
productos
stock_minimo_por_tipo

-- Stock por vehículo
stock_vehiculo (vehiculo_id, producto_id, cantidad_actual, fecha_caducidad, lote)

-- Control
movimientos_stock
alertas_stock
revisiones_mensuales
```

### Páginas Implementadas

✅ **StockVehiculoPage** (`/flota/stock-vehiculo/:vehiculoId`)
- Stock actual del vehículo
- Alertas activas
- Historial de movimientos
- Pendiente: Formularios de agregar/editar

✅ **AlertasPage** (`/flota/alertas-stock`)
- Vista general de todas las alertas
- Filtros por vehículo, nivel, tipo
- Acciones de resolución

⏸️ **RevisionMensualPage** (opcional)
- Registro de revisiones mensuales
- Checklist normativo
- Firma digital del responsable

---

## 🔄 Comparativa de Sistemas

### Tabla Comparativa Completa

| Característica | Sistema 1: Almacén | Sistema 2: Vehículos | Interacción |
|----------------|-------------------|---------------------|-------------|
| **Ubicación Física** | Almacén central | Dentro ambulancia | Transferencias |
| **Granularidad** | Producto + Lote | Producto + Lote + Vehículo | Misma estructura |
| **Cantidades** | Alta (cientos/miles) | Baja (unidades/decenas) | - |
| **Usuario Principal** | Logística / Compras | Personal sanitario | Ambos |
| **Frecuencia Actualización** | Diaria | Mensual (revisiones) | - |
| **Control de Costes** | ✅ SÍ (precio, valoración) | ❌ NO | Solo almacén |
| **Proveedores** | ✅ SÍ (gestión completa) | ❌ NO | Solo almacén |
| **Normativa** | Gestión interna | ✅ EN 1789:2021 | Complementarias |
| **Alertas** | Stock mínimo, caducidad | Stock mínimo, caducidad, revisión | Paralelas |
| **Reportes** | Valoración, rotación, compras | Cumplimiento normativo | Diferentes |
| **Estado** | ❌ NO implementado | ✅ Implementado | - |

### Flujo de Material: Almacén → Vehículo

```
┌─────────────────────────────────────────────────────────────────┐
│                     CICLO DE VIDA DEL MATERIAL                   │
└─────────────────────────────────────────────────────────────────┘

1️⃣ COMPRA
   ├─ Proveedor envía material
   ├─ Se registra ENTRADA en Sistema 1 (almacén)
   └─ Stock disponible aumenta

2️⃣ ALMACENAMIENTO
   ├─ Material ubicado en almacén
   ├─ Control de caducidades
   └─ Valoración económica

3️⃣ ASIGNACIÓN
   ├─ Se detecta necesidad en vehículo (alerta stock bajo)
   ├─ Se crea TRANSFERENCIA (almacén → vehículo)
   ├─ Stock almacén disminuye
   └─ Stock vehículo aumenta

4️⃣ USO EN VEHÍCULO
   ├─ Material en ambulancia
   ├─ Revisiones mensuales
   └─ Control de caducidades

5️⃣ CONSUMO O DEVOLUCIÓN
   ├─ Opción A: Se consume en servicio → MOVIMIENTO salida
   ├─ Opción B: Caduca sin usar → DEVOLUCIÓN a almacén
   └─ Opción C: Vehículo de baja → DEVOLUCIÓN total a almacén

6️⃣ CIERRE DEL CICLO
   ├─ Material consumido → Fin del ciclo
   └─ Material devuelto → Vuelve a almacén (punto 2)
```

---

## ✅ Estado de Implementación

### Lo que TENEMOS (Sistema 2 - Vehículos)

#### ✅ Base de Datos
```sql
✅ categorias_equipamiento (9 categorías según EN 1789)
✅ productos (catálogo de equipamiento médico)
✅ stock_minimo_por_tipo (A2, B, C)
✅ stock_vehiculo (stock actual por vehículo)
✅ movimientos_stock (historial de cambios)
✅ alertas_stock (alertas automáticas)
✅ revisiones_mensuales (checklist normativo)
```

#### ✅ Capa de Datos (Core DataSource)
```dart
✅ StockVehiculoEntity
✅ MovimientoStockEntity
✅ AlertaStockEntity
✅ RevisionMensualEntity
✅ SupabaseStockDataSource
✅ StockRepository
```

#### ✅ Gestión de Estado (BLoC)
```dart
✅ StockBloc (stock por vehículo)
✅ AlertasBloc (alertas activas)
✅ RevisionBloc (revisiones mensuales)
```

#### ✅ Presentación (Pages & Widgets)
```dart
✅ StockVehiculoPage (visualización)
✅ AlertasPage (listado de alertas)
✅ StockTable, AlertasTable
✅ Badges de nivel de stock
```

#### ✅ Navegación
```dart
✅ /flota/stock-vehiculo/:vehiculoId
✅ /flota/alertas-stock
✅ Botón "Gestionar Stock" en VehiculosPage
✅ Menú lateral "Alertas de Stock"
```

### Lo que FALTA (Sistema 1 - Almacén)

#### ❌ Base de Datos
```sql
❌ stock_almacen
❌ proveedores
❌ entradas_almacen
❌ detalle_entradas_almacen
❌ transferencias_stock (almacén ↔ vehículo)
```

#### ❌ Capa de Datos
```dart
❌ StockAlmacenEntity
❌ ProveedorEntity
❌ EntradaAlmacenEntity
❌ TransferenciaEntity
❌ SupabaseAlmacenDataSource
❌ AlmacenRepository
```

#### ❌ Gestión de Estado
```dart
❌ AlmacenBloc
❌ ProveedoresBloc
❌ EntradasBloc
❌ TransferenciasBloc
```

#### ❌ Presentación
```dart
❌ AlmacenGeneralPage
❌ EntradaAlmacenPage
❌ TransferenciasPage
❌ ProveedoresPage
❌ ReportesAlmacenPage
```

#### ❌ Navegación
```dart
❌ /almacen/inventario
❌ /almacen/entradas
❌ /almacen/transferencias
❌ /almacen/proveedores
❌ /almacen/reportes
```

### Resumen de Completitud

```
╔══════════════════════════════════════════════════════════════╗
║                   MÓDULO DE STOCK                            ║
╠══════════════════════════════════════════════════════════════╣
║ Sistema 1: Almacén General        ████░░░░░░░░   0%          ║
║ Sistema 2: Stock por Vehículo     ██████████   100%         ║
║ ─────────────────────────────────────────────────────────── ║
║ TOTAL DEL MÓDULO                  █████░░░░░░   50%         ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 🚀 Propuesta de Ampliación

### Fases de Implementación

#### **FASE 1: Sistema 2 - Validación** ⏸️ (En Testing)
**Objetivo**: Asegurar que lo implementado funciona correctamente

**Tareas**:
- [x] Corregir error de tabla `vehiculos` → `tvehiculos` ✅
- [ ] Probar carga de alertas en AlertasPage
- [ ] Probar navegación desde VehículosPage
- [ ] Implementar formularios faltantes (StockFormDialog, MovimientoFormDialog)
- [ ] Testing de flujo completo: Ver stock → Agregar item → Generar alerta
- [ ] Validar cálculo de niveles de stock
- [ ] Validar generación automática de alertas

**Duración estimada**: 1-2 días

---

#### **FASE 2: Sistema 1 - Base de Datos** 📋 (Pendiente)
**Objetivo**: Crear el schema completo del almacén

**Tareas**:
- [ ] Crear migración `002_crear_tablas_almacen.sql`
- [ ] Tabla `stock_almacen`
- [ ] Tabla `proveedores`
- [ ] Tabla `entradas_almacen` + `detalle_entradas_almacen`
- [ ] Tabla `transferencias_stock`
- [ ] Índices y constraints
- [ ] Triggers automáticos (actualización de cantidades)
- [ ] RLS (Row Level Security)
- [ ] Datos de prueba (seed)

**Duración estimada**: 1 día

---

#### **FASE 3: Sistema 1 - Entities y DataSources** 📦 (Pendiente)
**Objetivo**: Implementar capa de datos para almacén

**Tareas**:
- [ ] `StockAlmacenEntity` + Model
- [ ] `ProveedorEntity` + Model
- [ ] `EntradaAlmacenEntity` + Model
- [ ] `TransferenciaEntity` + Model
- [ ] `SupabaseAlmacenDataSource`
- [ ] `AlmacenRepository`
- [ ] Tests unitarios

**Duración estimada**: 1-2 días

---

#### **FASE 4: Sistema 1 - BLoC Layer** 🎛️ (Pendiente)
**Objetivo**: Gestión de estado del almacén

**Tareas**:
- [ ] `AlmacenBloc` (stock general)
- [ ] `ProveedoresBloc`
- [ ] `EntradasBloc`
- [ ] `TransferenciasBloc`
- [ ] Events, States para cada BLoC
- [ ] Manejo de errores
- [ ] Tests de BLoC

**Duración estimada**: 1 día

---

#### **FASE 5: Sistema 1 - UI/UX** 🎨 (Pendiente)
**Objetivo**: Páginas y widgets del almacén

**Tareas**:
- [ ] `AlmacenGeneralPage` (inventario)
- [ ] `EntradaAlmacenPage` (recepciones)
- [ ] `TransferenciasPage` (movimientos)
- [ ] `ProveedoresPage` (catálogo)
- [ ] `ReportesAlmacenPage` (analytics)
- [ ] Widgets compartidos (badges, cards, filtros)
- [ ] Formularios (EntradaFormDialog, TransferenciaFormDialog)
- [ ] Navegación en menú lateral

**Duración estimada**: 2-3 días

---

#### **FASE 6: Integración de Sistemas** 🔗 (Pendiente)
**Objetivo**: Conectar almacén con vehículos

**Tareas**:
- [ ] Flujo completo: Entrada almacén → Transferencia → Stock vehículo
- [ ] Validaciones cruzadas (stock disponible antes de transferir)
- [ ] Sincronización de lotes y caducidades
- [ ] Alertas coordinadas (almacén bajo mínimo + vehículo bajo mínimo)
- [ ] Reportes integrados (consumo total = almacén + vehículos)

**Duración estimada**: 1 día

---

#### **FASE 7: Testing y Refinamiento** 🧪 (Pendiente)
**Objetivo**: Asegurar calidad y estabilidad

**Tareas**:
- [ ] Tests de integración (flujo completo)
- [ ] Tests de UI (widgets y páginas)
- [ ] Performance testing (grandes volúmenes de stock)
- [ ] UX testing (usabilidad con usuarios reales)
- [ ] Documentación de usuario
- [ ] Video tutoriales

**Duración estimada**: 1-2 días

---

### Duración Total Estimada

```
Fase 1: Validación Sistema 2         1-2 días
Fase 2: Base de Datos                1 día
Fase 3: Entities y DataSources       1-2 días
Fase 4: BLoC Layer                   1 día
Fase 5: UI/UX                        2-3 días
Fase 6: Integración                  1 día
Fase 7: Testing                      1-2 días
─────────────────────────────────────────────
TOTAL:                               8-12 días
```

---

## 🏗️ Arquitectura Propuesta para Sistema 1

### Estructura de Directorios

```
lib/features/almacen/
├── domain/
│   ├── entities/
│   │   ├── stock_almacen_entity.dart
│   │   ├── proveedor_entity.dart
│   │   ├── entrada_almacen_entity.dart
│   │   ├── detalle_entrada_entity.dart
│   │   └── transferencia_entity.dart
│   └── repositories/
│       ├── almacen_repository.dart
│       ├── proveedores_repository.dart
│       ├── entradas_repository.dart
│       └── transferencias_repository.dart
├── data/
│   └── repositories/
│       ├── almacen_repository_impl.dart
│       ├── proveedores_repository_impl.dart
│       ├── entradas_repository_impl.dart
│       └── transferencias_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── almacen/
    │   │   ├── almacen_bloc.dart
    │   │   ├── almacen_event.dart
    │   │   └── almacen_state.dart
    │   ├── proveedores/
    │   ├── entradas/
    │   └── transferencias/
    ├── pages/
    │   ├── almacen_general_page.dart
    │   ├── entrada_almacen_page.dart
    │   ├── transferencias_page.dart
    │   ├── proveedores_page.dart
    │   └── reportes_almacen_page.dart
    └── widgets/
        ├── almacen_table.dart
        ├── stock_almacen_card.dart
        ├── entrada_form_dialog.dart
        ├── transferencia_form_dialog.dart
        ├── proveedor_form_dialog.dart
        └── valoracion_widget.dart
```

### DataSource en Core

```
packages/ambutrack_core_datasource/lib/src/datasources/almacen/
├── entities/
│   ├── stock_almacen_entity.dart
│   ├── proveedor_entity.dart
│   ├── entrada_almacen_entity.dart
│   └── transferencia_entity.dart
├── models/
│   ├── stock_almacen_supabase_model.dart
│   ├── proveedor_supabase_model.dart
│   ├── entrada_almacen_supabase_model.dart
│   └── transferencia_supabase_model.dart
├── implementations/
│   └── supabase/
│       └── supabase_almacen_datasource.dart
├── almacen_contract.dart
└── almacen_factory.dart
```

---

## 🔄 Flujos de Trabajo

### Flujo 1: Compra de Material

```
┌─────────────────────────────────────────────────────────────┐
│  FLUJO: COMPRA DE MATERIAL                                  │
└─────────────────────────────────────────────────────────────┘

1️⃣ DETECCIÓN DE NECESIDAD
   └─ ReportesAlmacenPage muestra productos bajo stock mínimo

2️⃣ ORDEN DE COMPRA
   ├─ Usuario revisa necesidades
   ├─ Contacta con proveedor
   └─ Realiza pedido

3️⃣ RECEPCIÓN DE MATERIAL
   ├─ Material llega al almacén
   ├─ Usuario abre EntradaAlmacenPage
   ├─ Selecciona proveedor
   ├─ Ingresa número de factura
   └─ Registra cada línea:
       ├─ Producto
       ├─ Cantidad
       ├─ Lote
       ├─ Fecha caducidad
       ├─ Precio unitario
       └─ Ubicación destino

4️⃣ ACTUALIZACIÓN AUTOMÁTICA
   ├─ Al guardar entrada:
   │   ├─ stock_almacen.cantidad_disponible += cantidad
   │   └─ Se crea registro en detalle_entradas_almacen
   └─ AlmacenGeneralPage se actualiza en tiempo real

5️⃣ DISPONIBILIDAD
   └─ Material disponible para asignar a vehículos
```

### Flujo 2: Asignación a Vehículo

```
┌─────────────────────────────────────────────────────────────┐
│  FLUJO: ASIGNACIÓN ALMACÉN → VEHÍCULO                       │
└─────────────────────────────────────────────────────────────┘

1️⃣ DETECCIÓN DE NECESIDAD
   ├─ AlertasPage muestra vehículo ABC-1234 con stock bajo
   └─ Usuario decide reponer

2️⃣ CREAR TRANSFERENCIA
   ├─ Usuario abre TransferenciasPage
   ├─ Tipo: "Asignación"
   ├─ Origen: "Almacén"
   ├─ Destino: "Vehículo ABC-1234"
   ├─ Producto: "Mascarilla FFP2"
   ├─ Cantidad: 20 unidades
   ├─ Lote: Auto-seleccionado (FIFO)
   └─ Motivo: "Reposición por stock bajo"

3️⃣ VALIDACIONES AUTOMÁTICAS
   ├─ ✅ Stock almacén suficiente? (>= 20)
   ├─ ✅ Lote válido? (no caducado)
   └─ ✅ Vehículo activo?

4️⃣ EJECUTAR TRANSFERENCIA
   ├─ Al confirmar:
   │   ├─ stock_almacen.cantidad_disponible -= 20
   │   ├─ stock_vehiculo.cantidad_actual += 20
   │   ├─ Se crea movimiento_stock (entrada vehículo)
   │   └─ Se crea transferencias_stock (log)
   └─ Alerta de vehículo se resuelve automáticamente

5️⃣ CONFIRMACIÓN
   └─ StockVehiculoPage muestra stock actualizado
```

### Flujo 3: Devolución de Vehículo

```
┌─────────────────────────────────────────────────────────────┐
│  FLUJO: DEVOLUCIÓN VEHÍCULO → ALMACÉN                       │
└─────────────────────────────────────────────────────────────┘

1️⃣ MOTIVO DE DEVOLUCIÓN
   ├─ Material próximo a caducar (no consumido)
   ├─ Vehículo dado de baja
   └─ Sobra de stock en vehículo

2️⃣ CREAR DEVOLUCIÓN
   ├─ Usuario abre TransferenciasPage
   ├─ Tipo: "Devolución"
   ├─ Origen: "Vehículo ABC-1234"
   ├─ Destino: "Almacén"
   ├─ Producto: "Suero Fisiológico 500ml"
   ├─ Cantidad: 5 unidades
   ├─ Lote: (el del vehículo)
   └─ Motivo: "Caduca en 10 días"

3️⃣ VALIDACIONES
   ├─ ✅ Stock vehículo suficiente? (>= 5)
   └─ ✅ Lote coincide?

4️⃣ EJECUTAR DEVOLUCIÓN
   ├─ Al confirmar:
   │   ├─ stock_vehiculo.cantidad_actual -= 5
   │   ├─ stock_almacen.cantidad_disponible += 5
   │   ├─ Se crea movimiento_stock (salida vehículo)
   │   └─ Se crea transferencias_stock (log)
   └─ Material vuelve a estar disponible en almacén

5️⃣ GESTIÓN EN ALMACÉN
   ├─ Si caduca pronto → Usar primero (FIFO)
   └─ Si no caduca → Disponible para reasignación
```

### Flujo 4: Revisión Mensual

```
┌─────────────────────────────────────────────────────────────┐
│  FLUJO: REVISIÓN MENSUAL DE VEHÍCULO                        │
└─────────────────────────────────────────────────────────────┘

1️⃣ NOTIFICACIÓN AUTOMÁTICA
   └─ Sistema genera alerta: "Revisión vehículo ABC-1234 día 1"

2️⃣ ACCESO A REVISIÓN
   ├─ Usuario abre StockVehiculoPage del vehículo
   └─ Click en "Realizar Revisión Mensual"

3️⃣ CHECKLIST NORMATIVO
   ├─ Sistema carga categorías según EN 1789
   └─ Usuario revisa cada producto:
       ├─ ✅ Presente
       ├─ ✅ Cantidad correcta
       ├─ ✅ Estado aceptable
       └─ ✅ No caducado

4️⃣ DETECCIÓN DE INCIDENCIAS
   ├─ Si falta material → Marca como "Faltante"
   ├─ Si está dañado → Marca como "Dañado"
   └─ Si caduca pronto → Sistema genera alerta automática

5️⃣ FINALIZACIÓN
   ├─ Usuario ingresa observaciones
   ├─ Firma digital (usuario_id)
   ├─ Se guarda revisiones_mensuales
   └─ Si hay faltantes → Se generan transferencias pendientes

6️⃣ SEGUIMIENTO
   └─ ReportesAlmacenPage muestra vehículos con revisión pendiente
```

---

## ❓ Decisiones Pendientes

### Decisiones de Negocio

#### 1. **Política de Valoración de Stock**
**Pregunta**: ¿Cómo valorar el stock?
- **Opción A**: FIFO (First In, First Out) - El más común
- **Opción B**: Precio medio ponderado
- **Opción C**: Último precio de compra

**Impacto**: Cálculo de valor total del stock en reportes

---

#### 2. **Control de Múltiples Ubicaciones**
**Pregunta**: ¿La empresa tiene múltiples almacenes/ubicaciones?
- **Opción A**: Un solo almacén central
- **Opción B**: Múltiples almacenes (por sede, ciudad, etc.)

**Impacto**:
- Si múltiples → Agregar `almacen_id` a tablas
- Si múltiples → Transferencias entre almacenes

---

#### 3. **Gestión de Órdenes de Compra**
**Pregunta**: ¿Se necesita un módulo completo de órdenes de compra?
- **Opción A**: Sí, con workflow completo (solicitud → aprobación → orden → recepción)
- **Opción B**: No, solo registrar entradas directas

**Impacto**: Complejidad del módulo y tiempo de desarrollo

---

#### 4. **Integración con Contabilidad**
**Pregunta**: ¿El sistema debe integrarse con contabilidad?
- **Opción A**: Sí, exportar movimientos valorados para contabilidad
- **Opción B**: No, solo control operativo

**Impacto**: Estructura de datos y reportes

---

#### 5. **Manejo de Devoluciones a Proveedor**
**Pregunta**: ¿Se devuelve material defectuoso o caducado a proveedores?
- **Opción A**: Sí, con gestión de notas de crédito
- **Opción B**: No, se da de baja internamente

**Impacto**: Flujo de devoluciones y relación con proveedores

---

#### 6. **Stock de Seguridad**
**Pregunta**: ¿Cómo calcular stock mínimo del almacén?
- **Opción A**: Fijo por producto (ej: 100 unidades)
- **Opción B**: Dinámico basado en consumo histórico (ej: 2 meses de consumo)
- **Opción C**: Basado en capacidad total de vehículos (suma de mínimos de todos los vehículos)

**Impacto**: Generación de alertas y órdenes de compra

---

#### 7. **Transferencias Urgentes**
**Pregunta**: ¿Qué hacer si vehículo necesita material y almacén no tiene stock?
- **Opción A**: Permitir transferencia entre vehículos
- **Opción B**: Solo desde almacén, bloquear si no hay stock
- **Opción C**: Generar orden de compra urgente automática

**Impacto**: Flexibilidad operativa vs control de inventario

---

#### 8. **Auditoría de Inventario**
**Pregunta**: ¿Se harán inventarios físicos periódicos?
- **Opción A**: Sí, con ajustes de inventario
- **Opción B**: Solo ajustes puntuales cuando se detectan diferencias

**Impacto**: Funcionalidad de cierre de inventario y ajustes masivos

---

### Decisiones Técnicas

#### 1. **Generación de Códigos Automáticos**
¿Auto-generar números de entrada, transferencia, etc.?
- Formato sugerido: `ENT-2025-00001`, `TRF-2025-00001`

#### 2. **Permisos de Usuario**
¿Qué roles pueden hacer qué?
- **Administrador**: Todo
- **Responsable Almacén**: Entradas, transferencias, ajustes
- **Personal Sanitario**: Solo ver stock vehículos, crear solicitudes de material
- **Conductor**: Solo ver stock de su vehículo

#### 3. **Notificaciones**
¿Enviar notificaciones automáticas?
- Email cuando stock bajo mínimo
- Push notification cuando alerta crítica
- SMS para caducidades inminentes

#### 4. **Integración con Otros Módulos**
- **Servicios**: Consumir material durante servicios
- **Mantenimiento**: Material usado en reparaciones de vehículos
- **Personal**: Asignar EPIs (Equipos de Protección Individual)

---

## 📅 Roadmap de Implementación

### Sprint 1: Validación Sistema 2 (1-2 días)
**Objetivo**: Asegurar que stock por vehículo funciona correctamente

- [x] Fix tabla `vehiculos` → `tvehiculos` ✅
- [x] Actualizar documentación ✅
- [ ] Probar carga de alertas
- [ ] Probar navegación
- [ ] Implementar formularios faltantes
- [ ] Testing end-to-end

**Entregable**: Sistema 2 100% funcional

---

### Sprint 2: Diseño Sistema 1 (1 día)
**Objetivo**: Definir arquitectura y requisitos completos del almacén

- [ ] Definir decisiones de negocio pendientes (con stakeholders)
- [ ] Finalizar diseño de base de datos
- [ ] Definir flujos de trabajo detallados
- [ ] Crear wireframes de páginas
- [ ] Validar permisos y roles

**Entregable**: Documento de diseño técnico aprobado

---

### Sprint 3: Backend Sistema 1 (2-3 días)
**Objetivo**: Implementar toda la capa de datos del almacén

- [ ] Migración SQL completa
- [ ] Entities y Models
- [ ] DataSources
- [ ] Repositories
- [ ] BLoCs
- [ ] Tests unitarios

**Entregable**: Backend de almacén funcional

---

### Sprint 4: Frontend Sistema 1 (2-3 días)
**Objetivo**: Implementar todas las páginas del almacén

- [ ] AlmacenGeneralPage
- [ ] EntradaAlmacenPage
- [ ] TransferenciasPage
- [ ] ProveedoresPage
- [ ] ReportesAlmacenPage
- [ ] Widgets compartidos
- [ ] Formularios

**Entregable**: UI completa del almacén

---

### Sprint 5: Integración y Testing (2 días)
**Objetivo**: Conectar ambos sistemas y validar flujo completo

- [ ] Flujo entrada → almacén → transferencia → vehículo
- [ ] Flujo devolución vehículo → almacén
- [ ] Sincronización de alertas
- [ ] Tests de integración
- [ ] Tests de UI
- [ ] Performance testing

**Entregable**: Sistema completo integrado y testeado

---

### Sprint 6: Refinamiento y Documentación (1 día)
**Objetivo**: Pulir detalles y crear documentación de usuario

- [ ] Ajustes de UX según feedback
- [ ] Documentación de usuario
- [ ] Video tutoriales
- [ ] Guía de permisos y roles
- [ ] Manual de operación

**Entregable**: Sistema listo para producción

---

## 📊 Métricas de Éxito

### KPIs del Sistema de Stock

#### Para Sistema 1 (Almacén)
- **Valoración de stock**: Valor total del inventario en €
- **Rotación de productos**: Veces que se renueva el stock al año
- **Stock sin movimiento**: % de productos con >90 días sin salidas
- **Precisión de inventario**: % de coincidencia inventario físico vs sistema
- **Tiempo promedio de reposición**: Días desde alerta hasta recepción
- **Productos caducados**: Unidades/€ de material que caducó sin usar

#### Para Sistema 2 (Vehículos)
- **Cumplimiento de revisiones**: % de revisiones mensuales realizadas a tiempo
- **Alertas resueltas**: % de alertas cerradas en <48h
- **Vehículos conformes**: % de vehículos con stock completo según normativa
- **Caducidades evitadas**: % de material rotado antes de caducar
- **Tiempo de resolución de incidencias**: Promedio de horas

#### Integración
- **Eficiencia de transferencias**: Tiempo promedio almacén → vehículo
- **Aprovechamiento de stock**: % de material asignado vs disponible
- **Costo por vehículo**: € promedio de stock por ambulancia/mes

---

## 🎓 Lecciones Aprendidas

### Del Sistema 2 (Implementado)

#### ✅ Lo que funcionó bien:
- **Arquitectura clara**: Clean Architecture facilitó mantenimiento
- **Migraciones SQL**: Schema bien diseñado desde el inicio
- **Pass-through repositories**: Simplificó mucho el código
- **Documentación continua**: Documento de implementación fue clave

#### ⚠️ Desafíos encontrados:
- **Nombres de tablas**: Confusión `vehiculos` vs `tvehiculos` (corregido)
- **Testing**: Faltó testing antes de integrar UI
- **Validaciones**: Algunas validaciones de negocio quedaron en UI (deberían estar en BLoC)

#### 💡 Mejoras para Sistema 1:
- **Testing desde el inicio**: Unit tests + integration tests
- **Validar nombres de tablas**: Antes de escribir queries
- **Prototipo de UI**: Wireframes antes de codificar
- **Definir permisos**: Desde el diseño de base de datos

---

## 📞 Contacto y Soporte

### Para Consultas sobre este Documento

**Autor**: Claude Code Assistant
**Proyecto**: AmbuTrack Web
**Módulo**: Stock de Equipamiento Médico

### Recursos Adicionales

- **Documento de Implementación**: `docs/stock/IMPLEMENTACION_MODULO.md`
- **Migraciones SQL**: `docs/stock/migraciones_supabase_corrected.sql`
- **Normativa**: EN 1789:2021 (Vehículos de transporte sanitario)

---

## 🔄 Control de Versiones del Documento

| Versión | Fecha | Autor | Cambios |
|---------|-------|-------|---------|
| 1.0.0 | 2025-01-27 | Claude Code Assistant | Documento inicial completo |

---

## 📝 Próximos Pasos Inmediatos

### Acción Requerida del Usuario

1. **Revisar este documento completo**
2. **Decidir estrategia**:
   - ⏸️ Opción A: Probar Sistema 2 antes de continuar
   - 🚀 Opción B: Implementar Sistema 1 inmediatamente
   - 📋 Opción C: Definir requisitos detallados primero

3. **Responder preguntas de negocio** (sección "Decisiones Pendientes")
4. **Aprobar roadmap** o proponer ajustes
5. **Dar luz verde** para siguiente fase de desarrollo

---

*Última actualización: 2025-01-27*
*Versión del documento: 1.0.0*
*Autor: Claude Code Assistant*
*Proyecto: AmbuTrack Web*
