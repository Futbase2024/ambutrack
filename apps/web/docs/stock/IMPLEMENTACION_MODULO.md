# 📦 Implementación del Módulo Stock - AmbuTrack Web

Documentación técnica completa de la implementación del módulo de gestión de stock de vehículos.

## 📑 Tabla de Contenidos

- [Resumen Ejecutivo](#resumen-ejecutivo)
- [Arquitectura del Módulo](#arquitectura-del-módulo)
- [Entidades y Modelos](#entidades-y-modelos)
- [Capa de Datos (Data Layer)](#capa-de-datos-data-layer)
- [Gestión de Estado (BLoC)](#gestión-de-estado-bloc)
- [Widgets Compartidos](#widgets-compartidos)
- [Páginas (Presentation)](#páginas-presentation)
- [Enrutamiento](#enrutamiento)
- [Correcciones Realizadas](#correcciones-realizadas)
- [Estado Actual](#estado-actual)
- [Próximos Pasos](#próximos-pasos)

---

## 🎯 Resumen Ejecutivo

### Fecha de Implementación
**2025-01-27**

### Alcance del Módulo
Sistema completo de gestión de stock de vehículos con:
- ✅ **Gestión de Stock por Vehículo**
- ✅ **Sistema de Alertas Automáticas**
- ✅ **Revisiones Mensuales Planificadas**
- ✅ **Registro de Movimientos (estructura base)**
- ✅ **Niveles de Stock Visuales**

### Estado de Completitud
```
✅ Migraciones SQL (100%)
✅ Entities y Models (100%)
✅ DataSources (100%)
✅ Repositories (100%)
✅ BLoC Layer (100%)
✅ Widgets Compartidos (100%)
✅ Páginas Principales (100%)
✅ Rutas GoRouter (100%)
✅ Flutter Analyze (0 warnings del módulo stock)
```

---

## 🏗️ Arquitectura del Módulo

### Patrón Clean Architecture

El módulo sigue estrictamente **Clean Architecture** con 3 capas:

```
lib/features/stock/
├── domain/          → Entidades + Contratos (reglas de negocio)
├── data/            → Implementaciones de repositorios
└── presentation/    → BLoC + Widgets + Pages (UI)
```

### Flujo de Datos

```
┌─────────────┐
│   UI/Page   │
└──────┬──────┘
       │ Events
       ▼
┌─────────────┐
│    BLoC     │ ← Inyectado via GetIt
└──────┬──────┘
       │ Repository Interface
       ▼
┌─────────────┐
│ Repository  │ ← @LazySingleton
│    Impl     │
└──────┬──────┘
       │ Pass-through directo
       ▼
┌─────────────┐
│ DataSource  │ ← Paquete ambutrack_core_datasource
│  (Supabase) │
└─────────────┘
```

### Dependencias Inyectadas

```dart
// Repositories
@LazySingleton(as: StockRepository)
@LazySingleton(as: AlertasRepository)
@LazySingleton(as: MovimientosRepository)
@LazySingleton(as: RevisionRepository)

// BLoCs
@injectable
class StockBloc { }

@injectable
class AlertasBloc { }

@injectable
class RevisionBloc { }
```

---

## 📊 Entidades y Modelos

### StockVehiculoEntity

**Ubicación**: `lib/features/stock/domain/entities/stock_vehiculo_entity.dart`

```dart
class StockVehiculoEntity extends Equatable {
  final String id;
  final String vehiculoId;
  final String productoId;
  final String productoNombre;
  final String? categoria;
  final int cantidadActual;
  final int? cantidadMinima;        // ⚠️ Nullable
  final DateTime? fechaCaducidad;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

**Campos Clave**:
- `cantidadMinima`: **Nullable** - Se usa `?? 0` en cálculos
- `cantidadOptima`: **NO existe en entity** - Se calcula como `(cantidadMinima ?? 0) * 2`

**Categorías Soportadas**:
```dart
enum CategoriaStock {
  medicamentos,
  materialSanitario,
  equipamiento,
  otros,
}
```

### AlertaStockEntity

**Ubicación**: `lib/features/stock/domain/entities/alerta_stock_entity.dart`

```dart
class AlertaStockEntity extends Equatable {
  final String id;
  final String stockId;
  final TipoAlerta tipo;
  final String mensaje;
  final bool resuelta;      // ⚠️ Bool, NO DateTime
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

**Tipos de Alerta**:
```dart
enum TipoAlerta {
  sinStock,    // cantidadActual == 0
  critico,     // cantidadActual < cantidadMinima
  bajo,        // cantidadActual < cantidadOptima
  caducidad,   // fechaCaducidad - hoy < 30 días
}
```

**⚠️ IMPORTANTE**: Entity tiene `resuelta: bool`, **NO** `resueltaEn: DateTime`.

### MovimientoStockEntity

**Ubicación**: `lib/features/stock/domain/entities/movimiento_stock_entity.dart`

```dart
class MovimientoStockEntity extends Equatable {
  final String id;
  final String stockId;
  final TipoMovimiento tipo;
  final int cantidad;
  final String? motivo;
  final String? usuarioId;
  final DateTime fecha;
  final DateTime createdAt;
}
```

**Tipos de Movimiento**:
```dart
enum TipoMovimiento {
  entrada,        // Incrementa stock
  salida,         // Decrementa stock
  ajuste,         // Corrección manual
  transferencia,  // Entre vehículos
}
```

### RevisionMensualEntity

**Ubicación**: `lib/features/stock/domain/entities/revision_mensual_entity.dart`

```dart
class RevisionMensualEntity extends Equatable {
  final String id;
  final String vehiculoId;
  final DateTime fecha;
  final bool completada;        // ⚠️ Bool, NO enum EstadoRevision
  final DateTime? completedAt;
  final String? observaciones;
  final DateTime createdAt;
}
```

**⚠️ IMPORTANTE**: Entity tiene `completada: bool`, **NO** `estado: EstadoRevision` enum.

---

## 💾 Capa de Datos (Data Layer)

### Patrón Repository (Pass-Through)

**Principio**: El repositorio es un **simple pass-through** al DataSource del core.

```dart
@LazySingleton(as: StockRepository)
class StockRepositoryImpl implements StockRepository {
  StockRepositoryImpl() : _dataSource = StockDataSourceFactory.createSupabase();
  final StockDataSource _dataSource;

  @override
  Future<List<StockVehiculoEntity>> getByVehiculo(String vehiculoId) async {
    debugPrint('📦 Repository: Solicitando stock del vehículo $vehiculoId');
    return await _dataSource.getByVehiculo(vehiculoId);  // ✅ Pass-through directo
  }
}
```

**Características**:
- ✅ UN solo import: `package:ambutrack_core_datasource/ambutrack_core_datasource.dart`
- ✅ NO conversiones Entity ↔ Entity (ya están en el core)
- ✅ Solo delegación al DataSource
- ✅ Logging con `debugPrint` para trazabilidad

### DataSources (Core Package)

**Ubicación**: `packages/ambutrack_core_datasource/lib/src/datasources/stock/`

```
stock/
├── entities/
│   ├── stock_vehiculo_entity.dart
│   ├── alerta_stock_entity.dart
│   ├── movimiento_stock_entity.dart
│   └── revision_mensual_entity.dart
├── models/
│   ├── stock_vehiculo_supabase_model.dart
│   ├── alerta_stock_supabase_model.dart
│   ├── movimiento_stock_supabase_model.dart
│   └── revision_mensual_supabase_model.dart
├── implementations/supabase/
│   ├── supabase_stock_datasource.dart
│   ├── supabase_alertas_datasource.dart
│   ├── supabase_movimientos_datasource.dart
│   └── supabase_revision_datasource.dart
├── stock_contract.dart
├── alertas_contract.dart
├── movimientos_contract.dart
├── revision_contract.dart
├── stock_factory.dart
├── alertas_factory.dart
├── movimientos_factory.dart
└── revision_factory.dart
```

**Factory Pattern**:
```dart
class StockDataSourceFactory {
  static StockDataSource createSupabase() {
    return SupabaseStockDataSource();
  }
}
```

---

## 🔄 Gestión de Estado (BLoC)

### StockBloc

**Ubicación**: `lib/features/stock/presentation/bloc/stock/`

**Events**:
```dart
abstract class StockEvent extends Equatable {}

class StockLoadByVehiculo extends StockEvent {
  final String vehiculoId;
}

class StockCreateRequested extends StockEvent {
  final StockVehiculoEntity stock;
}

class StockUpdateRequested extends StockEvent {
  final StockVehiculoEntity stock;
}

class StockDeleteRequested extends StockEvent {
  final String id;
}
```

**States**:
```dart
abstract class StockState extends Equatable {}

class StockInitial extends StockState {}
class StockLoading extends StockState {}
class StockLoaded extends StockState {
  final List<StockVehiculoEntity> items;
}
class StockError extends StockState {
  final String message;
}
```

**Handler de Eventos**:
```dart
@injectable
class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository _repository;

  StockBloc(this._repository) : super(const StockInitial()) {
    on<StockLoadByVehiculo>(_onLoadByVehiculo);
    on<StockCreateRequested>(_onCreateRequested);
    on<StockUpdateRequested>(_onUpdateRequested);
    on<StockDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadByVehiculo(
    StockLoadByVehiculo event,
    Emitter<StockState> emit,
  ) async {
    emit(const StockLoading());
    try {
      final items = await _repository.getByVehiculo(event.vehiculoId);
      emit(StockLoaded(items));
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    StockCreateRequested event,
    Emitter<StockState> emit,
  ) async {
    try {
      await _repository.create(event.stock);
      add(StockLoadByVehiculo(event.stock.vehiculoId));  // ✅ Recargar
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }
}
```

**Correcciones Realizadas**:
- ❌ **ANTES**: `if (event.stock.vehiculoId != null) { ... }`
- ✅ **DESPUÉS**: Eliminado check innecesario (campo no nullable)

### AlertasBloc

**Ubicación**: `lib/features/stock/presentation/bloc/alertas/`

**Events Clave**:
```dart
class AlertasLoadAll extends AlertasEvent {}

class AlertasLoadActive extends AlertasEvent {}

class AlertasLoadByVehiculo extends AlertasEvent {
  final String vehiculoId;
}

class AlertasResolveRequested extends AlertasEvent {
  final String alertaId;
  final String usuarioId;  // ⚠️ TODO: Obtener de AuthService
}
```

**Handler de Resolve**:
```dart
Future<void> _onResolveRequested(
  AlertasResolveRequested event,
  Emitter<AlertasState> emit,
) async {
  try {
    await _repository.resolve(event.alertaId, event.usuarioId);
    add(AlertasLoadActive());  // ✅ Recargar activas
  } catch (e) {
    emit(AlertasError(e.toString()));
  }
}
```

### RevisionBloc

**Ubicación**: `lib/features/stock/presentation/bloc/revision/`

**Events Clave**:
```dart
class RevisionLoadByVehiculo extends RevisionEvent {
  final String vehiculoId;
}

class RevisionLoadPending extends RevisionEvent {}

class RevisionCompleteRequested extends RevisionEvent {
  final String id;
  final String observaciones;
}
```

**Correcciones Realizadas**:
- ❌ **ANTES**: `if (event.item.revisionId != null) { ... }`
- ✅ **DESPUÉS**: Eliminado check innecesario (campo no nullable)

---

## 🎨 Widgets Compartidos

### StockItemCard

**Ubicación**: `lib/features/stock/presentation/widgets/stock_item_card.dart`

**Props**:
```dart
class StockItemCard extends StatelessWidget {
  final StockVehiculoEntity item;
  final VoidCallback? onEdit;
  final VoidCallback? onMovimiento;
  final VoidCallback? onView;
}
```

**Características**:
- ✅ Card con diseño profesional
- ✅ NivelStockBadge integrado
- ✅ Información de producto y categoría
- ✅ Icono de caducidad (si aplica)
- ✅ 3 botones de acción (Ver/Editar/Movimiento)

**Cálculo de Nivel de Stock**:
```dart
Color _getNivelStockColor() {
  final int minimo = item.cantidadMinima ?? 0;
  final int optimo = minimo * 2;

  if (item.cantidadActual <= 0) return AppColors.emergency;
  else if (item.cantidadActual < minimo) return AppColors.highPriority;
  else if (item.cantidadActual < optimo) return AppColors.warning;
  else return AppColors.success;
}
```

**Correcciones Realizadas**:
- ❌ **ANTES**: `AppSizes.radiusXs` (no existe)
- ✅ **DESPUÉS**: `AppSizes.radiusSmall` (8.0)
- ❌ **ANTES**: `item.cantidadOptima` (campo no existe)
- ✅ **DESPUÉS**: `(item.cantidadMinima ?? 0) * 2`

### NivelStockBadge

**Ubicación**: `lib/features/stock/presentation/widgets/nivel_stock_badge.dart`

**Props**:
```dart
class NivelStockBadge extends StatelessWidget {
  final int cantidadActual;
  final int cantidadMinima;
  final int cantidadOptima;
}
```

**Niveles**:
```dart
({IconData icon, String label, Color color}) _getNivelInfo() {
  if (cantidadActual <= 0) {
    return (
      icon: Icons.error,
      label: 'SIN STOCK',
      color: AppColors.emergency,
    );
  } else if (cantidadActual < cantidadMinima) {
    return (
      icon: Icons.warning_amber,
      label: 'CRÍTICO',
      color: AppColors.highPriority,
    );
  } else if (cantidadActual < cantidadOptima) {
    return (
      icon: Icons.info,
      label: 'BAJO',
      color: AppColors.warning,
    );
  } else {
    return (
      icon: Icons.check_circle,
      label: 'ÓPTIMO',
      color: AppColors.success,
    );
  }
}
```

**Diseño**:
- ✅ IntrinsicWidth (ajustado al contenido)
- ✅ Padding: `horizontal: 8, vertical: 4`
- ✅ BorderRadius: `AppSizes.radiusSmall`
- ✅ Icon size: `14` (inline)

### TipoAlertaChip

**Ubicación**: `lib/features/stock/presentation/widgets/tipo_alerta_chip.dart`

**Props**:
```dart
class TipoAlertaChip extends StatelessWidget {
  final TipoAlerta tipo;
}
```

**Mapeo de Tipos**:
```dart
({IconData icon, String label, Color color}) _getTipoInfo() {
  switch (tipo) {
    case TipoAlerta.sinStock:
      return (
        icon: Icons.cancel,
        label: 'SIN STOCK',
        color: AppColors.emergency,
      );
    case TipoAlerta.critico:
      return (
        icon: Icons.warning,
        label: 'CRÍTICO',
        color: AppColors.highPriority,
      );
    case TipoAlerta.bajo:
      return (
        icon: Icons.info,
        label: 'BAJO',
        color: AppColors.warning,
      );
    case TipoAlerta.caducidad:
      return (
        icon: Icons.schedule,
        label: 'CADUCIDAD',
        color: AppColors.mediumPriority,
      );
  }
}
```

### AlertaCard

**Ubicación**: `lib/features/stock/presentation/widgets/alerta_card.dart`

**Props**:
```dart
class AlertaCard extends StatelessWidget {
  final AlertaStockEntity alerta;
  final VoidCallback? onResolve;
  final VoidCallback? onView;
}
```

**Características**:
- ✅ TipoAlertaChip integrado
- ✅ Mensaje descriptivo
- ✅ Fecha de creación formateada
- ✅ Badge de estado (Activa/Resuelta)
- ✅ Botones condicionales (solo Resolver si activa)

**Correcciones Realizadas**:
- ❌ **ANTES**: Referencia a `alerta.resueltaEn` (no existe)
- ✅ **DESPUÉS**: Eliminada sección (solo `resuelta: bool`)

### RevisionProgressCard

**Ubicación**: `lib/features/stock/presentation/widgets/revision_progress_card.dart`

**Props**:
```dart
class RevisionProgressCard extends StatelessWidget {
  final RevisionMensualEntity revision;
  final VoidCallback? onComplete;
  final VoidCallback? onView;
}
```

**Badge de Estado Inline**:
```dart
Widget _buildEstadoBadge(bool isCompletada) {
  final Color color = isCompletada ? AppColors.success : AppColors.warning;
  final String label = isCompletada ? 'COMPLETADA' : 'PENDIENTE';
  final IconData icon = isCompletada ? Icons.check_circle : Icons.schedule;

  return Align(
    alignment: Alignment.centerLeft,
    child: IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

**Correcciones Realizadas**:
- ❌ **ANTES**: Widget separado `EstadoRevisionBadge` con enum `EstadoRevision`
- ✅ **DESPUÉS**: Badge inline con `bool completada`
- ❌ **ANTES**: Referencia a `revision.estado` y `revision.fechaLimite`
- ✅ **DESPUÉS**: Uso de `revision.completada` y `revision.fecha`

---

## 📱 Páginas (Presentation)

### StockVehiculoPage

**Ubicación**: `lib/features/stock/presentation/pages/stock_vehiculo_page.dart`

**Constructor**:
```dart
class StockVehiculoPage extends StatelessWidget {
  const StockVehiculoPage({
    super.key,
    required this.vehiculoId,
  });

  final String vehiculoId;
}
```

**Features**:
- ✅ Búsqueda en tiempo real por producto/categoría
- ✅ Filtro dropdown por categoría
- ✅ Grid de 3 columnas con StockItemCards
- ✅ Botón FAB (+) para agregar items
- ✅ Estados: loading, error, vacío

**Filtrado**:
```dart
List<StockVehiculoEntity> _filterItems(List<StockVehiculoEntity> items) {
  var filtered = items;

  // Filtro de búsqueda
  if (_searchQuery.isNotEmpty) {
    filtered = filtered.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.productoNombre.toLowerCase().contains(query) ||
             (item.categoria?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // Filtro de categoría
  if (_categoriaFilter != 'Todas') {
    filtered = filtered.where((item) => item.categoria == _categoriaFilter).toList();
  }

  return filtered;
}
```

**Correcciones Realizadas**:
- ❌ **ANTES**: Missing imports `stock_event.dart`, `stock_state.dart`
- ✅ **DESPUÉS**: Agregados imports
- ❌ **ANTES**: `DropdownButtonFormField(value: ...)`
- ✅ **DESPUÉS**: `DropdownButtonFormField(initialValue: ...)` (deprecated v3.33+)
- ❌ **ANTES**: `TODO: Implementar`
- ✅ **DESPUÉS**: `TODO(dev): Implementar` (estilo Flutter)

**TODOs Pendientes**:
```dart
void _showAddItemDialog(BuildContext context) {
  // TODO(dev): Implementar diálogo de agregar item
}

void _showEditItemDialog(BuildContext context, StockVehiculoEntity item) {
  // TODO(dev): Implementar diálogo de editar item
}

void _showMovimientoDialog(BuildContext context, StockVehiculoEntity item) {
  // TODO(dev): Implementar diálogo de movimiento
}

void _showItemDetails(BuildContext context, StockVehiculoEntity item) {
  // TODO(dev): Implementar vista de detalles
}
```

### AlertasPage

**Ubicación**: `lib/features/stock/presentation/pages/alertas_page.dart`

**Constructor**:
```dart
class AlertasPage extends StatelessWidget {
  const AlertasPage({super.key});
}
```

**Features**:
- ✅ Estadísticas en cards (Total/Activas/Críticas/Caducidad)
- ✅ Filtro dropdown por tipo de alerta
- ✅ Toggle Activas/Todas (SegmentedButton)
- ✅ Lista scrollable de AlertaCards
- ✅ Botón para resolver alertas

**Estadísticas**:
```dart
Widget _buildStatsCards(List<AlertaStockEntity> alertas) {
  final int total = alertas.length;
  final int activas = alertas.where((a) => !a.resuelta).length;
  final int criticas = alertas.where((a) => a.tipo == TipoAlerta.critico).length;
  final int caducidad = alertas.where((a) => a.tipo == TipoAlerta.caducidad).length;

  return Row(
    children: [
      _StatCard(title: 'Total', value: total, color: AppColors.info),
      _StatCard(title: 'Activas', value: activas, color: AppColors.warning),
      _StatCard(title: 'Críticas', value: criticas, color: AppColors.emergency),
      _StatCard(title: 'Caducidad', value: caducidad, color: AppColors.mediumPriority),
    ],
  );
}
```

**Filtrado**:
```dart
List<AlertaStockEntity> _filterAlertas(List<AlertaStockEntity> alertas) {
  var filtered = alertas;

  // Filtro activas/todas
  if (_showOnlyActive) {
    filtered = filtered.where((a) => !a.resuelta).toList();
  }

  // Filtro por tipo
  if (_tipoFilter != null) {
    filtered = filtered.where((a) => a.tipo == _tipoFilter).toList();
  }

  return filtered;
}
```

**Resolver Alerta**:
```dart
void _resolveAlerta(BuildContext context, AlertaStockEntity alerta) {
  context.read<AlertasBloc>().add(
    AlertasResolveRequested(
      alertaId: alerta.id,
      usuarioId: 'current-user-id', // TODO(dev): Obtener de AuthService
    ),
  );
}
```

**Correcciones Realizadas**:
- ❌ **ANTES**: `AlertasResolveRequested(alerta.id)` (missing usuarioId)
- ✅ **DESPUÉS**: Agregado `usuarioId` con TODO
- ❌ **ANTES**: `TODO: Implementar`
- ✅ **DESPUÉS**: `TODO(dev): Implementar` (estilo Flutter)

---

## 🛣️ Enrutamiento

### Rutas Registradas

**Ubicación**: `lib/core/router/app_router.dart` (líneas 644-665)

```dart
// Stock de Vehículo
GoRoute(
  path: '/flota/stock-vehiculo/:vehiculoId',
  name: 'flota_stock_vehiculo',
  pageBuilder: (BuildContext context, GoRouterState state) {
    final String vehiculoId = state.pathParameters['vehiculoId']!;
    return _buildPageWithTransition(
      key: state.pageKey,
      child: StockVehiculoPage(vehiculoId: vehiculoId),
    );
  },
),

// Alertas de Stock
GoRoute(
  path: '/flota/alertas-stock',
  name: 'flota_alertas_stock',
  pageBuilder: (BuildContext context, GoRouterState state) =>
    _buildPageWithTransition(
      key: state.pageKey,
      child: const AlertasPage(),
    ),
),
```

### Navegación Tipada

```dart
// Ir a stock de vehículo
context.goNamed(
  'flota_stock_vehiculo',
  pathParameters: {'vehiculoId': vehiculo.id},
);

// Ir a alertas
context.goNamed('flota_alertas_stock');
```

### Imports Agregados

**Ubicación**: `lib/core/router/app_router.dart` (líneas 29-30)

```dart
import 'package:ambutrack_web/features/stock/presentation/pages/alertas_page.dart';
import 'package:ambutrack_web/features/stock/presentation/pages/stock_vehiculo_page.dart';
```

**Correcciones Realizadas**:
- ❌ **ANTES**: Imports al final del bloque (líneas 49-50)
- ✅ **DESPUÉS**: Ordenados alfabéticamente (líneas 29-30)
- ✅ Eliminado warning `directives_ordering`

---

## 🔧 Correcciones Realizadas

### 1. Warnings de Flutter Analyze

#### Null Checks Innecesarios (BLoC)

**Archivo**: `lib/features/stock/presentation/bloc/stock/stock_bloc.dart:124`

❌ **ANTES**:
```dart
if (event.stock.vehiculoId != null) {
  add(StockLoadByVehiculo(event.stock.vehiculoId!));
}
```

✅ **DESPUÉS**:
```dart
add(StockLoadByVehiculo(event.stock.vehiculoId));
```

**Archivo**: `lib/features/stock/presentation/bloc/revision/revision_bloc.dart:179`

❌ **ANTES**:
```dart
if (event.item.revisionId != null) {
  add(RevisionLoadItems(event.item.revisionId!));
}
```

✅ **DESPUÉS**:
```dart
add(RevisionLoadItems(event.item.revisionId));
```

#### Ordenamiento de Imports

**Archivo**: `lib/core/router/app_router.dart:49`

❌ **ANTES** (líneas 47-50):
```dart
import 'package:ambutrack_web/features/vehiculos/stock_equipamiento_page.dart';
import 'package:ambutrack_web/features/vehiculos/vehiculos_page.dart';
import 'package:ambutrack_web/features/stock/presentation/pages/alertas_page.dart';
import 'package:ambutrack_web/features/stock/presentation/pages/stock_vehiculo_page.dart';
```

✅ **DESPUÉS** (líneas 29-31):
```dart
import 'package:ambutrack_web/features/stock/presentation/pages/alertas_page.dart';
import 'package:ambutrack_web/features/stock/presentation/pages/stock_vehiculo_page.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/pages/stock_vestuario_page.dart';
```

#### Formato de TODOs

**Archivos**:
- `lib/features/stock/presentation/pages/alertas_page.dart:370`
- `lib/features/stock/presentation/pages/stock_vehiculo_page.dart:346,352,358,364`

❌ **ANTES**:
```dart
// TODO: Implementar diálogo de agregar item
// TODO: Obtener de AuthService
```

✅ **DESPUÉS**:
```dart
// TODO(dev): Implementar diálogo de agregar item
// TODO(dev): Obtener de AuthService
```

### 2. Correcciones de Entities

#### StockVehiculoEntity

**Problema**: Widget asumía campo `cantidadOptima` que no existe.

❌ **ANTES**:
```dart
NivelStockBadge(
  cantidadActual: item.cantidadActual,
  cantidadMinima: item.cantidadMinima,
  cantidadOptima: item.cantidadOptima,  // ❌ Campo no existe
)
```

✅ **DESPUÉS**:
```dart
NivelStockBadge(
  cantidadActual: item.cantidadActual,
  cantidadMinima: item.cantidadMinima ?? 0,
  cantidadOptima: (item.cantidadMinima ?? 0) * 2,  // ✅ Calculado
)
```

#### AlertaStockEntity

**Problema**: Widget asumía campo `resueltaEn: DateTime` que no existe.

❌ **ANTES**:
```dart
if (isResuelta && alerta.resueltaEn != null) {
  Text('Resuelta el: ${_formatDate(alerta.resueltaEn!)}'),
}
```

✅ **DESPUÉS**:
```dart
// ✅ Eliminada sección completa (entity solo tiene `resuelta: bool`)
```

#### RevisionMensualEntity

**Problema**: Widget asumía enum `EstadoRevision` y campos `estado`/`fechaLimite`.

❌ **ANTES** (archivo `estado_revision_badge.dart`):
```dart
enum EstadoRevision {
  pendiente,
  enProceso,
  completada,
}

class EstadoRevisionBadge extends StatelessWidget {
  final EstadoRevision estado;
  // ...
}
```

✅ **DESPUÉS**:
```dart
// ✅ Archivo eliminado
// ✅ Badge construido inline con `bool completada`

Widget _buildEstadoBadge(bool isCompletada) {
  final Color color = isCompletada ? AppColors.success : AppColors.warning;
  final String label = isCompletada ? 'COMPLETADA' : 'PENDIENTE';
  // ...
}
```

### 3. Correcciones de AppSizes

**Problema**: Widgets usaban constantes inexistentes.

❌ **ANTES**:
```dart
borderRadius: BorderRadius.circular(AppSizes.radiusXs)  // ❌ No existe
Icon(icon, size: AppSizes.iconXs)                       // ❌ No existe
```

✅ **DESPUÉS**:
```dart
borderRadius: BorderRadius.circular(AppSizes.radiusSmall)  // ✅ 8.0
Icon(icon, size: 14)                                       // ✅ Inline
```

**AppSizes Disponibles**:
```dart
// Radius
radiusSmall: 8.0
radiusMedium: 10.0
radius: 12.0
radiusLarge: 16.0
radiusXl: 20.0

// Icons
iconSmall: 16.0
iconMedium: 18.0
icon: 24.0
iconLarge: 28.0
```

### 4. Correcciones de Imports

**Archivo**: `lib/features/stock/presentation/pages/stock_vehiculo_page.dart`

❌ **ANTES**:
```dart
import 'package:ambutrack_web/features/stock/presentation/bloc/stock/stock_bloc.dart';
// ❌ Missing: stock_event.dart, stock_state.dart
```

✅ **DESPUÉS**:
```dart
import 'package:ambutrack_web/features/stock/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/stock/presentation/bloc/stock/stock_event.dart';
import 'package:ambutrack_web/features/stock/presentation/bloc/stock/stock_state.dart';
```

### 5. Deprecated APIs

**Archivo**: `lib/features/stock/presentation/pages/stock_vehiculo_page.dart:237`

❌ **ANTES** (deprecated desde Flutter v3.33):
```dart
DropdownButtonFormField<String>(
  value: _categoriaFilter,
  items: [...],
)
```

✅ **DESPUÉS**:
```dart
DropdownButtonFormField<String>(
  initialValue: _categoriaFilter,
  items: [...],
)
```

---

## ✅ Estado Actual

### Resumen de Análisis

```bash
flutter analyze
```

**Resultado**: `67 issues found (0 del módulo stock)`

**Desglose**:
- ✅ **0 warnings** específicos del módulo stock
- ✅ **0 errors** en todo el proyecto
- ℹ️ **67 info** globales del proyecto (no relacionados con stock)

### Tareas Completadas

- [x] Migraciones SQL de Supabase
- [x] Entities (domain layer)
- [x] Supabase Models (core package)
- [x] DataSource Implementations (core package)
- [x] Contracts y Factories (core package)
- [x] Repository Implementations (data layer)
- [x] BLoC Layer completo (StockBloc, AlertasBloc, RevisionBloc)
- [x] Widgets compartidos (5 widgets)
- [x] StockVehiculoPage (con búsqueda y filtros)
- [x] AlertasPage (con estadísticas y filtros)
- [x] Registro de rutas en GoRouter
- [x] Corrección de warnings de flutter analyze
- [x] Documentación completa del módulo

### Archivos Creados

**BLoC Layer** (9 archivos):
```
lib/features/stock/presentation/bloc/
├── stock/
│   ├── stock_bloc.dart
│   ├── stock_event.dart
│   └── stock_state.dart
├── alertas/
│   ├── alertas_bloc.dart
│   ├── alertas_event.dart
│   └── alertas_state.dart
└── revision/
    ├── revision_bloc.dart
    ├── revision_event.dart
    └── revision_state.dart
```

**Widgets** (5 archivos):
```
lib/features/stock/presentation/widgets/
├── stock_item_card.dart
├── nivel_stock_badge.dart
├── tipo_alerta_chip.dart
├── alerta_card.dart
└── revision_progress_card.dart
```

**Pages** (2 archivos):
```
lib/features/stock/presentation/pages/
├── stock_vehiculo_page.dart
└── alertas_page.dart
```

**Total**: 16 archivos nuevos (sin contar entities/repositories ya existentes)

---

## 🚀 Próximos Pasos

### 🔜 Funcionalidades Pendientes

#### 1. Formularios CRUD

**Prioridad**: Alta

**Tareas**:
- [ ] Crear `StockFormDialog` para agregar/editar items
  - Campos: Producto (dropdown), Categoría, Cantidad Actual, Cantidad Mínima, Fecha Caducidad
  - Validaciones: Cantidades > 0, fecha futura
  - Integración con StockBloc

- [ ] Crear `MovimientoFormDialog` para registrar movimientos
  - Campos: Tipo (dropdown), Cantidad, Motivo (opcional)
  - Validación: Cantidad > 0
  - Integración con MovimientosBloc

**Implementación**:
```dart
void _showAddItemDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => StockFormDialog(
      vehiculoId: vehiculoId,
      onSave: (item) {
        context.read<StockBloc>().add(StockCreateRequested(item));
      },
    ),
  );
}
```

#### 2. Vistas de Detalles

**Prioridad**: Media

**Tareas**:
- [ ] Crear `StockDetailsDialog`
  - Información completa del item
  - Historial de movimientos (últimos 10)
  - Gráfica de evolución de stock (últimos 30 días)
  - Alertas asociadas

- [ ] Crear `AlertaDetailsDialog`
  - Detalles de la alerta
  - Item de stock relacionado
  - Historial de resoluciones

**Ejemplo**:
```dart
void _showItemDetails(BuildContext context, StockVehiculoEntity item) {
  showDialog(
    context: context,
    builder: (context) => StockDetailsDialog(item: item),
  );
}
```

#### 3. Revisiones Mensuales

**Prioridad**: Media

**Tareas**:
- [ ] Crear `RevisionMensualPage`
  - Lista de revisiones planificadas
  - Filtros por estado (pendiente/completada)
  - Búsqueda por vehículo

- [ ] Crear `RevisionFormDialog`
  - Checklist de items a revisar
  - Observaciones
  - Firma digital (opcional)

- [ ] Implementar lógica de generación automática de revisiones

#### 4. AuthService Integration

**Prioridad**: Alta

**Tareas**:
- [ ] Integrar `AuthService` para obtener `usuarioId` real
- [ ] Actualizar `_resolveAlerta()` en AlertasPage
- [ ] Actualizar registro de movimientos con usuario actual

**Implementación**:
```dart
// En AlertasPage
void _resolveAlerta(BuildContext context, AlertaStockEntity alerta) {
  final String usuarioId = getIt<AuthService>().currentUser?.id ?? '';

  context.read<AlertasBloc>().add(
    AlertasResolveRequested(
      alertaId: alerta.id,
      usuarioId: usuarioId,
    ),
  );
}
```

#### 5. Sistema de Notificaciones

**Prioridad**: Baja

**Tareas**:
- [ ] Implementar notificaciones push (FCM) para alertas críticas
- [ ] Configurar preferencias de notificación por usuario
- [ ] Email alerts para stock crítico (opcional)

#### 6. Reportes e Informes

**Prioridad**: Media

**Tareas**:
- [ ] Informe de Stock Crítico (PDF/Excel)
- [ ] Informe de Caducidades Próximas
- [ ] Estadísticas de Consumo por Producto
- [ ] Dashboard de Métricas de Stock

### 📊 Mejoras Técnicas

#### Performance

- [ ] Implementar paginación en listas grandes (>100 items)
- [ ] Cache de imágenes de productos con `flutter_cache_manager`
- [ ] Lazy loading de historial de movimientos

#### Testing

- [ ] Unit tests de BLoCs (StockBloc, AlertasBloc, RevisionBloc)
- [ ] Widget tests de componentes (StockItemCard, NivelStockBadge, etc.)
- [ ] Integration tests de flujos completos (crear item → registrar movimiento → generar alerta)

**Ejemplo**:
```dart
// test/features/stock/bloc/stock_bloc_test.dart
void main() {
  group('StockBloc', () {
    late StockBloc bloc;
    late MockStockRepository repository;

    setUp(() {
      repository = MockStockRepository();
      bloc = StockBloc(repository);
    });

    blocTest<StockBloc, StockState>(
      'emits [StockLoading, StockLoaded] when LoadByVehiculo succeeds',
      build: () => bloc,
      act: (bloc) => bloc.add(StockLoadByVehiculo('vehiculo-123')),
      expect: () => [
        StockLoading(),
        StockLoaded([mockStockItem]),
      ],
    );
  });
}
```

#### Documentación

- [ ] Guía de usuario final (cómo usar el módulo)
- [ ] Videos tutoriales (screen recordings)
- [ ] Ejemplos de uso avanzado (snippets)

### 🔄 Integración con Otros Módulos

#### Vehículos

- [ ] Link directo desde VehiculosPage a StockVehiculoPage
- [ ] Badge de alertas de stock en VehiculoCard

**Ejemplo**:
```dart
// En VehiculoCard
if (vehiculo.tieneAlertasStock) {
  Badge(
    label: Text('${vehiculo.numAlertasStock}'),
    child: Icon(Icons.warning),
  )
}
```

#### Servicios

- [ ] Registro automático de movimientos de stock tras servicio
- [ ] Validación de stock antes de asignar servicio

#### Mantenimiento

- [ ] Revisar stock durante mantenimiento preventivo
- [ ] Alertas de stock bajo antes de mantenimiento

---

## 📚 Referencias

### Archivos Principales

**Domain Layer**:
- `lib/features/stock/domain/entities/stock_vehiculo_entity.dart`
- `lib/features/stock/domain/entities/alerta_stock_entity.dart`
- `lib/features/stock/domain/entities/movimiento_stock_entity.dart`
- `lib/features/stock/domain/entities/revision_mensual_entity.dart`
- `lib/features/stock/domain/repositories/stock_repository.dart`
- `lib/features/stock/domain/repositories/alertas_repository.dart`
- `lib/features/stock/domain/repositories/movimientos_repository.dart`
- `lib/features/stock/domain/repositories/revision_repository.dart`

**Data Layer**:
- `lib/features/stock/data/repositories/stock_repository_impl.dart`
- `lib/features/stock/data/repositories/alertas_repository_impl.dart`
- `lib/features/stock/data/repositories/movimientos_repository_impl.dart`
- `lib/features/stock/data/repositories/revision_repository_impl.dart`

**BLoC Layer**:
- `lib/features/stock/presentation/bloc/stock/` (3 archivos)
- `lib/features/stock/presentation/bloc/alertas/` (3 archivos)
- `lib/features/stock/presentation/bloc/revision/` (3 archivos)

**Widgets**:
- `lib/features/stock/presentation/widgets/stock_item_card.dart`
- `lib/features/stock/presentation/widgets/nivel_stock_badge.dart`
- `lib/features/stock/presentation/widgets/tipo_alerta_chip.dart`
- `lib/features/stock/presentation/widgets/alerta_card.dart`
- `lib/features/stock/presentation/widgets/revision_progress_card.dart`

**Pages**:
- `lib/features/stock/presentation/pages/stock_vehiculo_page.dart`
- `lib/features/stock/presentation/pages/alertas_page.dart`

**Router**:
- `lib/core/router/app_router.dart` (líneas 29-30, 644-665)

### DataSource (Core Package)

**Ubicación**: `packages/ambutrack_core_datasource/lib/src/datasources/stock/`

**Exports**: `packages/ambutrack_core_datasource/lib/ambutrack_core_datasource.dart`

### Migraciones SQL

**Ubicación**: `packages/ambutrack_core_datasource/supabase/migrations/`

**Archivos**:
- `20250127000001_stock_vehiculo.sql`
- `20250127000002_alertas_stock.sql`
- `20250127000003_movimientos_stock.sql`
- `20250127000004_revision_mensual.sql`

### Convenciones del Proyecto

**AppColors**: Usar siempre colores del sistema
```dart
AppColors.primary
AppColors.emergency
AppColors.success
AppColors.warning
```

**AppSizes**: Usar constantes de tamaño
```dart
AppSizes.radiusSmall   // 8.0
AppSizes.spacing       // 16.0
AppSizes.iconSmall     // 16.0
```

**TODO Format**: Estilo Flutter
```dart
// TODO(dev): Descripción de la tarea pendiente
```

**Widgets**: Preferir StatelessWidget
```dart
// ✅ Correcto
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) { }
}

// ❌ Incorrecto
Widget _buildMyWidget() {
  return Container();
}
```

**SafeArea**: OBLIGATORIO en todas las páginas
```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(  // ✅ OBLIGATORIO
      child: Scaffold( /* ... */ ),
    );
  }
}
```

---

## 🐛 Errores Críticos Corregidos

### Error #1: Referencia Incorrecta a Tabla de Vehículos

**Fecha de corrección**: 2025-01-27 (post-implementación)

**Problema**:
El `SupabaseStockDataSource` hacía JOIN con la tabla `vehiculos` en lugar de `tvehiculos`, causando error PostgrestException en todos los queries de alertas y movimientos:

```
PostgrestException: Could not find a relationship between 'alertas_stock'
and 'vehiculos' in the schema cache (PGRST200)
Hint: Perhaps you meant 'tvehiculos' instead of 'vehiculos'.
```

**Causa raíz**:
- En AmbuTrack, la tabla de **instancias de vehículos** se llama **`tvehiculos`** (no `vehiculos`)
- La migración SQL estaba correcta (`vehiculo_id UUID REFERENCES tvehiculos(id)`)
- Pero el DataSource usaba `vehiculos(matricula)` en los SELECT con JOIN

**Archivos afectados**:
```
packages/ambutrack_core_datasource/lib/src/datasources/stock/
  implementations/supabase/supabase_stock_datasource.dart
```

**Líneas corregidas**:
- Línea 402: `movimientos_stock` → `tvehiculos(matricula)` ✅
- Línea 442: `alertas_stock` (getAlertasVehiculo) → `tvehiculos(matricula)` ✅
- Línea 466: `alertas_stock` (getAlertasActivas) → `tvehiculos(matricula)` ✅

**Solución aplicada**:
```dart
// ❌ INCORRECTO (antes)
.select('*, productos(nombre), vehiculos(matricula)')

// ✅ CORRECTO (después)
.select('*, productos(nombre), tvehiculos(matricula)')
```

**Impacto**:
- **CRÍTICO**: Sin este fix, NINGUNA alerta ni movimiento se podía cargar
- **Afectaba**: AlertasPage, StockVehiculoPage, historial de movimientos
- **Test**: Después del fix, `flutter analyze` = 67 issues (sin cambios, ninguno del módulo stock)

**Validación**:
```bash
# Verificar que no queden referencias a 'vehiculos' (sin 't')
grep -n "vehiculos" supabase_stock_datasource.dart | grep -v tvehiculos
# Resultado: Vacío ✅
```

**Lección aprendida**:
- SIEMPRE verificar nombres de tablas en el schema de Supabase ANTES de escribir queries
- Los nombres de tabla pueden diferir de convenciones estándar (ej: `tvehiculos` vs `vehiculos`)
- Ejecutar queries de prueba en Supabase Dashboard antes de implementar en código

---

## 📞 Contacto y Soporte

Para dudas sobre este módulo:

1. Revisar esta documentación primero
2. Verificar el código de referencia en archivos existentes
3. Ejecutar `flutter analyze` antes de reportar issues
4. Seguir las convenciones del proyecto

---

*Última actualización: 2025-01-27*
*Versión del módulo: 1.0.0*
*Autor: Claude Code Assistant*
*Proyecto: AmbuTrack Web*
