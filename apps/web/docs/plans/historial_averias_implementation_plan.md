# Plan de Implementación: Historial de Averías

> **Fecha:** 2026-02-12
> **Feature:** Historial de Averías (Incidencias de Vehículos)
> **Estado:** Pendiente de aprobación

---

## 🎯 Objetivo

Implementar el módulo completo de **Historial de Averías** para gestionar incidencias de vehículos (reportes, seguimiento, resolución).

---

## 📋 Estado Actual

### ✅ Infraestructura Backend (Completa)

| Componente | Ubicación | Estado |
|------------|-----------|--------|
| **Entity** | `packages/ambutrack_core_datasource/.../incidencia_vehiculo_entity.dart` | ✅ Completo |
| **Repository Interface** | `lib/features/vehiculos/domain/repositories/incidencia_vehiculo_repository.dart` | ✅ Completo |
| **Repository Impl** | `lib/features/vehiculos/data/repositories/incidencia_vehiculo_repository_impl.dart` | ✅ Completo con validaciones |
| **DataSource** | `packages/ambutrack_core_datasource/.../implementations/supabase/` | ✅ Completo |

**Validaciones existentes en Repository:**
- ✅ Validación de kilometraje (no puede ser inferior al actual)
- ✅ Actualización automática del KM del vehículo
- ✅ Manejo de errores con debugPrint

### 🚧 UI (Incompleta)

| Componente | Ubicación | Estado |
|------------|-----------|--------|
| **Página** | `lib/features/vehiculos/historial_averias_page.dart` | 🚧 Solo header + placeholder |
| **BLoC** | - | ❌ No existe |
| **Formulario** | - | ❌ No existe |
| **Widgets** | - | ❌ No existen |

---

## 🏗️ Arquitectura Propuesta

### Estructura de Archivos

```
lib/features/vehiculos/
├── presentation/
│   ├── bloc/
│   │   └── incidencia_vehiculo/
│   │       ├── incidencia_vehiculo_bloc.dart        # BLoC principal
│   │       ├── incidencia_vehiculo_event.dart       # Eventos (Freezed)
│   │       └── incidencia_vehiculo_state.dart       # Estados (Freezed)
│   │
│   ├── pages/
│   │   └── historial_averias_page.dart              # 🔄 Modificar (reemplazar placeholder)
│   │
│   └── widgets/
│       ├── incidencias/
│       │   ├── incidencia_form_modal.dart           # Modal crear/editar
│       │   ├── incidencia_data_table.dart           # Tabla principal
│       │   ├── incidencia_filters.dart              # Filtros (estado, prioridad, tipo)
│       │   ├── incidencia_estado_badge.dart         # Badge de estado
│       │   ├── incidencia_prioridad_badge.dart      # Badge de prioridad
│       │   ├── incidencia_tipo_badge.dart           # Badge de tipo
│       │   └── incidencia_detail_modal.dart         # Modal detalle (opcional)
│       │
│       └── (opcional)
│           └── incidencia_card.dart                 # Card para vista móvil
```

---

## 📊 Modelo de Datos (Entity)

### IncidenciaVehiculoEntity

```dart
class IncidenciaVehiculoEntity {
  // Identificación
  final String id;
  final String vehiculoId;
  final String empresaId;

  // Reporte
  final String reportadoPor;           // UUID usuario
  final String reportadoPorNombre;     // Nombre en MAYÚSCULAS
  final DateTime fechaReporte;

  // Clasificación
  final TipoIncidencia tipo;           // mecanica, electrica, carroceria, etc.
  final PrioridadIncidencia prioridad; // baja, media, alta, critica
  final EstadoIncidencia estado;       // reportada, enRevision, enReparacion, resuelta, cerrada

  // Descripción
  final String titulo;                 // Max 100 caracteres
  final String descripcion;            // Max 500 caracteres

  // Datos adicionales
  final double? kilometrajeReporte;
  final List<String>? fotosUrls;       // Máximo 5 fotos
  final String? ubicacionReporte;      // JSON {lat, lng}

  // Resolución
  final String? asignadoA;             // UUID mecánico/responsable
  final DateTime? fechaAsignacion;
  final DateTime? fechaResolucion;
  final String? solucionAplicada;
  final double? costoReparacion;
  final String? tallerResponsable;

  // Auditoría
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

### Enums

| Enum | Valores |
|------|---------|
| **TipoIncidencia** | `mecanica`, `electrica`, `carroceria`, `neumaticos`, `limpieza`, `equipamiento`, `documentacion`, `otra` |
| **PrioridadIncidencia** | `baja`, `media`, `alta`, `critica` |
| **EstadoIncidencia** | `reportada`, `enRevision`, `enReparacion`, `resuelta`, `cerrada` |

---

## 🎨 Diseño UI

### 1. Página Principal (Historial de Averías)

**Componentes:**
- ✅ **Header profesional** (ya existe): Gradiente rojo emergencia + icono + título + botón
- 🆕 **Filtros**: Dropdowns para estado, prioridad, tipo
- 🆕 **Tabla de incidencias**: AppDataGridV5 con paginación
- 🆕 **Modal formulario**: Crear/editar incidencia

**Layout:**
```
┌────────────────────────────────────────────────┐
│  [Header con gradiente rojo]                   │
│  ⚠️ Historial de Averías                       │
│  Registro y seguimiento de averías             │
│                    [+ Reportar Avería]         │
└────────────────────────────────────────────────┘
│  Filtros:                                       │
│  [Estado ▼] [Prioridad ▼] [Tipo ▼] [Limpiar]  │
├────────────────────────────────────────────────┤
│  Tabla de Incidencias                          │
│  ┌─────┬──────────┬───────┬──────┬────────┐   │
│  │ Veh │ Tipo     │ Prior │ Est  │ Accio  │   │
│  ├─────┼──────────┼───────┼──────┼────────┤   │
│  │ 123 │ Mecánica │ Alta  │ Rep  │ [👁️✏️🗑️]│   │
│  │ 456 │ Eléctrica│ Media │ En R │ [👁️✏️🗑️]│   │
│  └─────┴──────────┴───────┴──────┴────────┘   │
├────────────────────────────────────────────────┤
│  Paginación: [◀️] Página 1 de 5 [▶️]          │
└────────────────────────────────────────────────┘
```

### 2. Tabla de Incidencias (AppDataGridV5)

**Columnas:**
1. **Vehículo** - Matrícula + marca/modelo
2. **Fecha Reporte** - Formato dd/MM/yyyy HH:mm
3. **Tipo** - Badge con color según tipo
4. **Prioridad** - Badge con color según prioridad
5. **Estado** - Badge con color según estado
6. **Reportado Por** - Nombre en mayúsculas
7. **Título** - Descripción breve
8. **Acciones** - Ver, Editar, Eliminar

**Paginación:**
- 25 items por página
- Navegación con botones y badge "Página X de Y"

### 3. Modal: Reportar/Editar Avería

**Campos del formulario:**
```
┌──────────────────────────────────────────┐
│  [X] Reportar Avería                     │
├──────────────────────────────────────────┤
│  Vehículo * [Dropdown con búsqueda]      │
│                                           │
│  Tipo * [Dropdown]                        │
│  ○ Mecánica  ○ Eléctrica  ○ Carrocería   │
│                                           │
│  Prioridad * [Dropdown]                   │
│  ○ Baja  ○ Media  ○ Alta  ○ Crítica      │
│                                           │
│  Título * [TextField] (max 100 chars)     │
│                                           │
│  Descripción * [TextArea] (max 500)       │
│                                           │
│  Kilometraje [TextField] (opcional)       │
│  ℹ️ Si se indica, debe ser ≥ KM actual   │
│                                           │
│  Fotos [Upload] (máx 5)                   │
│  [Drag & drop o seleccionar archivos]    │
│                                           │
│  [Cancelar]              [Guardar] 💾    │
└──────────────────────────────────────────┘
```

**Validaciones:**
- ✅ Campos obligatorios: vehículo, tipo, prioridad, título, descripción
- ✅ Kilometraje: Si se proporciona, debe ser ≥ KM actual del vehículo
- ✅ Título: Max 100 caracteres
- ✅ Descripción: Max 500 caracteres
- ✅ Fotos: Máximo 5 archivos (formatos: jpg, png)

**Estados del modal:**
- `barrierDismissible: false` (no cerrar tocando fuera)
- Loading overlay al guardar
- Diálogo de confirmación al salir sin guardar

### 4. Badges

#### Badge de Estado
| Estado | Color | Icono |
|--------|-------|-------|
| Reportada | `AppColors.info` (azul) | `Icons.report_problem` |
| En Revisión | `AppColors.warning` (naranja) | `Icons.search` |
| En Reparación | `AppColors.secondary` (amarillo) | `Icons.build` |
| Resuelta | `AppColors.success` (verde) | `Icons.check_circle` |
| Cerrada | `AppColors.gray600` (gris) | `Icons.archive` |

#### Badge de Prioridad
| Prioridad | Color | Icono |
|-----------|-------|-------|
| Baja | `AppColors.gray600` | `Icons.arrow_downward` |
| Media | `AppColors.warning` | `Icons.remove` |
| Alta | `AppColors.error` | `Icons.arrow_upward` |
| Crítica | `AppColors.emergency` | `Icons.priority_high` |

#### Badge de Tipo
| Tipo | Color |
|------|-------|
| Mecánica | `AppColors.error` |
| Eléctrica | `AppColors.warning` |
| Carrocería | `AppColors.info` |
| Neumáticos | `AppColors.gray700` |
| Limpieza | `AppColors.success` |
| Equipamiento | `AppColors.secondary` |
| Documentación | `AppColors.primary` |
| Otra | `AppColors.gray600` |

**Patrón obligatorio:**
```dart
Align(
  alignment: Alignment.centerLeft,
  child: IntrinsicWidth(
    child: Container(...),
  ),
)
```

---

## 🔄 Flujo de Estados (BLoC)

### Estados (Freezed)

```dart
@freezed
class IncidenciaVehiculoState with _$IncidenciaVehiculoState {
  const factory IncidenciaVehiculoState.initial() = _Initial;
  const factory IncidenciaVehiculoState.loading() = _Loading;
  const factory IncidenciaVehiculoState.loaded({
    required List<IncidenciaVehiculoEntity> incidencias,
    required int currentPage,
    required int totalPages,
    EstadoIncidencia? filtroEstado,
    PrioridadIncidencia? filtroPrioridad,
    TipoIncidencia? filtroTipo,
  }) = _Loaded;
  const factory IncidenciaVehiculoState.error(String message) = _Error;
}
```

### Eventos (Freezed)

```dart
@freezed
class IncidenciaVehiculoEvent with _$IncidenciaVehiculoEvent {
  const factory IncidenciaVehiculoEvent.started() = _Started;
  const factory IncidenciaVehiculoEvent.loadIncidencias() = _LoadIncidencias;
  const factory IncidenciaVehiculoEvent.createIncidencia(IncidenciaVehiculoEntity incidencia) = _CreateIncidencia;
  const factory IncidenciaVehiculoEvent.updateIncidencia(IncidenciaVehiculoEntity incidencia) = _UpdateIncidencia;
  const factory IncidenciaVehiculoEvent.deleteIncidencia(String id) = _DeleteIncidencia;
  const factory IncidenciaVehiculoEvent.filterByEstado(EstadoIncidencia? estado) = _FilterByEstado;
  const factory IncidenciaVehiculoEvent.filterByPrioridad(PrioridadIncidencia? prioridad) = _FilterByPrioridad;
  const factory IncidenciaVehiculoEvent.filterByTipo(TipoIncidencia? tipo) = _FilterByTipo;
  const factory IncidenciaVehiculoEvent.clearFilters() = _ClearFilters;
  const factory IncidenciaVehiculoEvent.changePage(int page) = _ChangePage;
}
```

### Lógica del BLoC

```dart
@injectable
class IncidenciaVehiculoBloc extends Bloc<IncidenciaVehiculoEvent, IncidenciaVehiculoState> {
  final IncidenciaVehiculoRepository _repository;

  IncidenciaVehiculoBloc(this._repository) : super(const _Initial()) {
    on<_Started>(_onStarted);
    on<_LoadIncidencias>(_onLoadIncidencias);
    on<_CreateIncidencia>(_onCreateIncidencia);
    on<_UpdateIncidencia>(_onUpdateIncidencia);
    on<_DeleteIncidencia>(_onDeleteIncidencia);
    on<_FilterByEstado>(_onFilterByEstado);
    on<_FilterByPrioridad>(_onFilterByPrioridad);
    on<_FilterByTipo>(_onFilterByTipo);
    on<_ClearFilters>(_onClearFilters);
    on<_ChangePage>(_onChangePage);
  }

  // Implementaciones...
}
```

---

## 🛠️ Implementación Step-by-Step

### Fase 1: BLoC (Gestión de Estado)

**Archivos a crear:**
1. `lib/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_bloc.dart` (~200 líneas)
2. `lib/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_event.dart` (~30 líneas)
3. `lib/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_state.dart` (~25 líneas)

**Tareas:**
- [ ] Definir eventos con Freezed
- [ ] Definir estados con Freezed
- [ ] Implementar lógica del BLoC
- [ ] Registrar BLoC en DI (`injection.dart`)
- [ ] Ejecutar `build_runner` para generar código Freezed
- [ ] Ejecutar `flutter analyze` → 0 warnings

### Fase 2: Widgets de UI

**Archivos a crear:**
1. `lib/features/vehiculos/presentation/widgets/incidencias/incidencia_estado_badge.dart` (~60 líneas)
2. `lib/features/vehiculos/presentation/widgets/incidencias/incidencia_prioridad_badge.dart` (~60 líneas)
3. `lib/features/vehiculos/presentation/widgets/incidencias/incidencia_tipo_badge.dart` (~80 líneas)
4. `lib/features/vehiculos/presentation/widgets/incidencias/incidencia_filters.dart` (~120 líneas)

**Tareas:**
- [ ] Crear badges con patrón `Align + IntrinsicWidth`
- [ ] Crear widget de filtros con dropdowns
- [ ] Ejecutar `flutter analyze` → 0 warnings

### Fase 3: Tabla de Datos

**Archivos a crear:**
1. `lib/features/vehiculos/presentation/widgets/incidencias/incidencia_data_table.dart` (~250 líneas)

**Tareas:**
- [ ] Usar `AppDataGridV5` como base
- [ ] Definir columnas (vehículo, fecha, tipo, prioridad, estado, reportado por, título, acciones)
- [ ] Implementar paginación (25 items/página)
- [ ] Integrar badges de estado/prioridad/tipo
- [ ] Botones de acción (ver, editar, eliminar)
- [ ] Ejecutar `flutter analyze` → 0 warnings

### Fase 4: Formulario Modal

**Archivos a crear:**
1. `lib/features/vehiculos/presentation/widgets/incidencias/incidencia_form_modal.dart` (~350 líneas)

**Tareas:**
- [ ] Crear formulario con validaciones
- [ ] Dropdown de vehículos con búsqueda (`AppSearchableDropdown`)
- [ ] Dropdowns de tipo, prioridad, estado
- [ ] Campos: título, descripción, kilometraje
- [ ] Upload de fotos (máx 5)
- [ ] Validación de kilometraje (≥ KM actual)
- [ ] Loading overlay al guardar
- [ ] Diálogos de confirmación (éxito/error)
- [ ] `barrierDismissible: false`
- [ ] Ejecutar `flutter analyze` → 0 warnings

### Fase 5: Integración en Página

**Archivos a modificar:**
1. `lib/features/vehiculos/historial_averias_page.dart` (reemplazar placeholder)

**Tareas:**
- [ ] Mantener header existente
- [ ] Integrar BLoC con `BlocProvider`
- [ ] Conectar botón "Reportar Avería" con modal
- [ ] Renderizar filtros + tabla según estado del BLoC
- [ ] Manejo de estados: initial, loading, loaded, error
- [ ] SafeArea obligatorio
- [ ] Ejecutar `flutter analyze` → 0 warnings

---

## ✅ Checklist de Validación

### Funcionalidades
- [ ] Listar todas las incidencias con paginación
- [ ] Filtrar por estado, prioridad y tipo
- [ ] Crear nueva incidencia desde modal
- [ ] Editar incidencia existente
- [ ] Eliminar incidencia con confirmación
- [ ] Validación de kilometraje (≥ actual)
- [ ] Actualización automática del KM del vehículo
- [ ] Upload de fotos (máx 5)
- [ ] Badges visuales por estado/prioridad/tipo
- [ ] Navegación por páginas (25 items/página)

### UI/UX
- [ ] Header profesional con gradiente rojo
- [ ] Botón "Reportar Avería" visible y funcional
- [ ] Filtros claros y funcionales
- [ ] Tabla responsive con todas las columnas
- [ ] Badges ajustados al texto (IntrinsicWidth)
- [ ] Modal no se cierra tocando fuera
- [ ] Loading overlay al guardar
- [ ] Diálogos de éxito/error profesionales
- [ ] SafeArea en toda la página

### Técnico
- [ ] BLoC con estados inmutables (Freezed)
- [ ] Repository pass-through directo
- [ ] AppColors en todos los estilos
- [ ] Widgets como clases (NO métodos `_buildXxx()`)
- [ ] `debugPrint` para logs (NO `print()`)
- [ ] `flutter analyze` → 0 warnings
- [ ] Archivo <400 líneas (HARD LIMIT)
- [ ] Métodos <40 líneas
- [ ] Profundidad anidación ≤3 niveles

### Testing (Opcional - Futuro)
- [ ] Unit tests para BLoC
- [ ] Widget tests para tabla
- [ ] Widget tests para formulario
- [ ] Integration tests para flujo completo

---

## 🚨 Recordatorios Críticos

### OBLIGATORIO
- ✅ **Material Design 3** (NO Cupertino)
- ✅ **AppColors** para todos los colores
- ✅ **SafeArea** en la página
- ✅ **BLoC + Freezed** para estados/eventos
- ✅ **Repository pass-through** directo al datasource
- ✅ **Widgets como clases** separadas
- ✅ **`flutter analyze`** → 0 warnings después de cada fase
- ✅ **CrudOperationHandler** para feedback de operaciones
- ✅ **showSimpleConfirmationDialog** para eliminar
- ✅ **`barrierDismissible: false`** en formulario
- ✅ **debugPrint** para todos los logs

### PROHIBIDO
- ❌ NO usar Cupertino
- ❌ NO usar datos MOCK
- ❌ NO crear métodos `_buildXxx()` que devuelvan Widget
- ❌ NO hardcodear colores
- ❌ NO usar `print()` (usar `debugPrint`)
- ❌ NO usar SnackBar para operaciones CRUD (usar diálogos profesionales)
- ❌ NO exceder 400 líneas por archivo (dividir si es necesario)

---

## 📊 Estimación de Archivos

| Fase | Archivos Nuevos | Archivos Modificados | Total Líneas Estimadas |
|------|-----------------|----------------------|------------------------|
| 1. BLoC | 3 | 1 (injection.dart) | ~255 |
| 2. Badges + Filtros | 4 | 0 | ~320 |
| 3. Tabla | 1 | 0 | ~250 |
| 4. Formulario | 1 | 0 | ~350 |
| 5. Integración | 0 | 1 (historial_averias_page.dart) | ~200 (reemplazo) |
| **TOTAL** | **9** | **2** | **~1,375** |

---

## 📝 Notas Adicionales

### Dependencias a Verificar
- `flutter_bloc: ^8.1.x` ✅ (ya en proyecto)
- `freezed_annotation: ^2.4.x` ✅ (ya en proyecto)
- `injectable: ^2.x` ✅ (ya en proyecto)
- `equatable: ^2.0.x` ✅ (ya en proyecto)

### Comandos Necesarios
```bash
# Después de crear eventos/estados con Freezed:
flutter pub run build_runner build --delete-conflicting-outputs

# Después de registrar BLoC en DI:
flutter pub run build_runner build --delete-conflicting-outputs

# Verificar código:
flutter analyze
```

### Referencias en el Proyecto
- **Patrón de tabla:** Ver `lib/core/widgets/modern_data_table.dart` o `app_data_grid_v5.dart`
- **Patrón de formulario:** Ver `lib/features/vehiculos/presentation/widgets/vehiculo_form_modal.dart`
- **Patrón de badges:** Ver implementaciones existentes en tablas maestras
- **Patrón de BLoC:** Ver `lib/features/vehiculos/presentation/bloc/vehiculos_bloc.dart`

---

## ✅ Aprobación

Una vez aprobado este plan, procederé con la implementación **fase por fase**, ejecutando `flutter analyze` después de cada fase para garantizar 0 warnings.

**¿Apruebas este plan para comenzar la implementación?**
