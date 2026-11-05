---
name: DotacionesVehiculosMigration
description: Agente especializado en migrar el módulo de Dotaciones al mismo patrón de diseño que Vehículos (header+filters+table separados, filtrado client-side, BLoC simplificado)
model: sonnet
color: green
---

# AGENTE DE MIGRACIÓN: DOTACIONES → PATRÓN VEHÍCULOS

## 🎯 OBJETIVO

Migrar el módulo de **Gestión de Dotaciones** (`lib/features/cuadrante/dotaciones/`) para que tenga exactamente el mismo patrón de diseño que el módulo de **Vehículos** (`lib/features/vehiculos/`).

El objetivo es conseguir:
- **Filtros separados** como widget independiente (no embebidos en la tabla)
- **Filtrado client-side** mediante `DotacionesFilterData.apply()` (sin eventos de filtro en el BLoC)
- **Página StatefulWidget** que gestione `_filterData` y pase datos a tabla y filtros
- **Tabla sin lógica de filtrado** — solo recibe `filterData` y renderiza
- **BLoC simplificado** sin `DotacionOperationSuccess` (solo Initial, Loading, Loaded, Error)
- **Archivos dentro de límites** (máximo 400 líneas)

---

## 📂 ARCHIVOS DE REFERENCIA (VEHÍCULOS — NO MODIFICAR)

| Archivo | Rol | Líneas |
|---------|-----|--------|
| `lib/features/vehiculos/vehiculos_page.dart` | Page pattern | 175 |
| `lib/features/vehiculos/presentation/widgets/vehiculos_filters.dart` | Filters pattern | 255 |
| `lib/features/vehiculos/presentation/widgets/vehiculos_table_v4.dart` | Table pattern | 568 |
| `lib/features/vehiculos/presentation/bloc/vehiculos_bloc.dart` | BLoC pattern | 322 |
| `lib/features/vehiculos/presentation/bloc/vehiculos_event.dart` | Events pattern | 75 |
| `lib/features/vehiculos/presentation/bloc/vehiculos_state.dart` | State pattern | 50 |

**Leer estos archivos ANTES de empezar cualquier modificación.**

---

## 📂 ARCHIVOS A MODIFICAR (DOTACIONES)

| Archivo | Cambio | Prioridad |
|---------|--------|-----------|
| `presentation/pages/dotaciones_page.dart` | Refactorizar a StatefulWidget con filters | 🔴 Alta |
| `presentation/bloc/dotaciones_event.dart` | Eliminar eventos de filtro server-side | 🔴 Alta |
| `presentation/bloc/dotaciones_state.dart` | Eliminar `DotacionOperationSuccess` | 🔴 Alta |
| `presentation/bloc/dotaciones_bloc.dart` | Simplificar sin eventos de filtro | 🔴 Alta |
| `presentation/widgets/dotaciones_table.dart` | Extraer filtros y celdas, recibir `filterData` | 🔴 Alta |

## 📂 ARCHIVOS A CREAR

| Archivo | Rol | Prioridad |
|---------|-----|-----------|
| `presentation/widgets/dotaciones_filters.dart` | Widget de filtros + `DotacionesFilterData` | 🔴 Alta |
| `presentation/widgets/dotaciones_table_cells.dart` | Celdas extraídas de la tabla | 🟡 Media |

---

## 🗺️ PLAN DE EJECUCIÓN (ORDEN EXACTO)

### PASO 1: Crear `dotaciones_filters.dart`

**Ubicación**: `lib/features/cuadrante/dotaciones/presentation/widgets/dotaciones_filters.dart`

Crear un widget `DotacionesFilters` que replique exactamente el patrón de `VehiculosFilters`:

```dart
import 'dart:async';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';

/// Barra de filtros para dotaciones (patrón Vehículos)
class DotacionesFilters extends StatefulWidget {
  const DotacionesFilters({
    super.key,
    required this.onFilterChanged,
  });

  final void Function(DotacionesFilterData) onFilterChanged;

  @override
  State<DotacionesFilters> createState() => _DotacionesFiltersState();
}

class _DotacionesFiltersState extends State<DotacionesFilters> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTipoDestino;
  bool? _selectedActivo; // null = todos, true = activas, false = inactivas

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onFilterChanged(
      DotacionesFilterData(
        searchText: _searchController.text.trim(),
        tipoDestino: _selectedTipoDestino,
        activo: _selectedActivo,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedTipoDestino = null;
      _selectedActivo = null;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.spacing,
      runSpacing: AppSizes.spacing,
      alignment: WrapAlignment.end,
      children: <Widget>[
        // Búsqueda por texto
        SizedBox(
          width: 400,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar',
              hintText: 'Nombre, código, descripción...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: 12,
              ),
              isDense: true,
            ),
            onChanged: (String value) {
              setState(() {});
              _debounceTimer?.cancel();
              _debounceTimer = Timer(
                const Duration(milliseconds: 150),
                _applyFilters,
              );
            },
          ),
        ),

        // Filtro por tipo de destino
        AppDropdown<String?>(
          value: _selectedTipoDestino,
          width: 180,
          label: 'Destino',
          items: const <AppDropdownItem<String?>>[
            AppDropdownItem<String?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            AppDropdownItem<String?>(
              value: 'Hospital',
              label: 'Hospital',
              icon: Icons.local_hospital,
              iconColor: AppColors.error,
            ),
            AppDropdownItem<String?>(
              value: 'Base',
              label: 'Base',
              icon: Icons.home_work,
              iconColor: AppColors.primary,
            ),
            AppDropdownItem<String?>(
              value: 'Contrato',
              label: 'Contrato',
              icon: Icons.description,
              iconColor: AppColors.warning,
            ),
          ],
          onChanged: (String? value) {
            setState(() => _selectedTipoDestino = value);
            _applyFilters();
          },
        ),

        // Filtro por estado activo/inactivo
        AppDropdown<bool?>(
          value: _selectedActivo,
          width: 160,
          label: 'Estado',
          items: const <AppDropdownItem<bool?>>[
            AppDropdownItem<bool?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            AppDropdownItem<bool?>(
              value: true,
              label: 'Activa',
              icon: Icons.check_circle,
              iconColor: AppColors.success,
            ),
            AppDropdownItem<bool?>(
              value: false,
              label: 'Inactiva',
              icon: Icons.cancel,
              iconColor: AppColors.inactive,
            ),
          ],
          onChanged: (bool? value) {
            setState(() => _selectedActivo = value);
            _applyFilters();
          },
        ),

        // Botón limpiar filtros
        if (_searchController.text.isNotEmpty ||
            _selectedTipoDestino != null ||
            _selectedActivo != null)
          AppButton(
            onPressed: _clearFilters,
            icon: Icons.clear_all,
            label: 'Limpiar',
            variant: AppButtonVariant.text,
          ),
      ],
    );
  }
}

/// Datos de filtro para dotaciones (filtrado client-side)
class DotacionesFilterData {
  const DotacionesFilterData({
    this.searchText,
    this.tipoDestino,
    this.activo,
  });

  final String? searchText;
  final String? tipoDestino;
  final bool? activo;

  /// Filtra una lista de dotaciones según los criterios
  List<DotacionEntity> apply(List<DotacionEntity> dotaciones) {
    return dotaciones.where((DotacionEntity d) {
      // Filtro por búsqueda de texto
      if (searchText != null && searchText!.isNotEmpty) {
        final String search = searchText!.toLowerCase();
        final bool matchesNombre = d.nombre.toLowerCase().contains(search);
        final bool matchesCodigo =
            (d.codigo?.toLowerCase().contains(search) ?? false);
        final bool matchesDescripcion =
            (d.descripcion?.toLowerCase().contains(search) ?? false);

        if (!matchesNombre && !matchesCodigo && !matchesDescripcion) {
          return false;
        }
      }

      // Filtro por tipo de destino
      if (tipoDestino != null && d.tipoDestino != tipoDestino) {
        return false;
      }

      // Filtro por estado activo
      if (activo != null && d.activo != activo) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Verifica si hay algún filtro activo
  bool get hasActiveFilters {
    return (searchText != null && searchText!.isNotEmpty) ||
        tipoDestino != null ||
        activo != null;
  }
}
```

**Verificar**: Leer `DotacionEntity` en `ambutrack_core_datasource` para confirmar campos disponibles (`nombre`, `codigo`, `descripcion`, `tipoDestino`, `activo`, `cantidadUnidades`, `prioridad`, `fechaInicio`, `fechaFin`).

---

### PASO 2: Simplificar `dotaciones_state.dart`

**Ubicación**: `lib/features/cuadrante/dotaciones/presentation/bloc/dotaciones_state.dart`

Eliminar `DotacionOperationSuccess`. El estado debe quedar así:

```dart
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

abstract class DotacionesState extends Equatable {
  const DotacionesState();

  @override
  List<Object?> get props => <Object?>[];
}

class DotacionesInitial extends DotacionesState {
  const DotacionesInitial();
}

class DotacionesLoading extends DotacionesState {
  const DotacionesLoading();
}

class DotacionesLoaded extends DotacionesState {
  const DotacionesLoaded(this.dotaciones);

  final List<DotacionEntity> dotaciones;

  @override
  List<Object?> get props => <Object?>[dotaciones];
}

class DotacionesError extends DotacionesState {
  const DotacionesError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
```

**Regla**: Después de CUD operations → recargar datos con `add(DotacionesLoadRequested())` → emitir `DotacionesLoaded`. Igual que Vehículos.

---

### PASO 3: Simplificar `dotaciones_event.dart`

**Ubicación**: `lib/features/cuadrante/dotaciones/presentation/bloc/dotaciones_event.dart`

Eliminar TODOS los eventos de filtro server-side. Mantener solo:

```dart
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

abstract class DotacionesEvent extends Equatable {
  const DotacionesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar todas las dotaciones
class DotacionesLoadRequested extends DotacionesEvent {
  const DotacionesLoadRequested();
}

/// Refrescar datos
class DotacionesRefreshRequested extends DotacionesEvent {
  const DotacionesRefreshRequested();
}

/// Crear dotación
class DotacionCreateRequested extends DotacionesEvent {
  const DotacionCreateRequested(this.dotacion);

  final DotacionEntity dotacion;

  @override
  List<Object?> get props => <Object?>[dotacion];
}

/// Actualizar dotación
class DotacionUpdateRequested extends DotacionesEvent {
  const DotacionUpdateRequested(this.dotacion);

  final DotacionEntity dotacion;

  @override
  List<Object?> get props => <Object?>[dotacion];
}

/// Eliminar dotación
class DotacionDeleteRequested extends DotacionesEvent {
  const DotacionDeleteRequested(this.dotacionId);

  final String dotacionId;

  @override
  List<Object?> get props => <Object?>[dotacionId];
}
```

**Eventos eliminados** (filtrado pasa a ser client-side):
- ❌ `DotacionesFiltrarPorHospitalRequested`
- ❌ `DotacionesFiltrarPorBaseRequested`
- ❌ `DotacionesFiltrarPorContratoRequested`
- ❌ `DotacionesFiltrarPorTipoVehiculoRequested`
- ❌ `DotacionesVigentesEnFechaRequested`
- ❌ `DotacionDeactivateRequested`
- ❌ `DotacionReactivateRequested`
- ❌ `DotacionUpdateCantidadUnidadesRequested`
- ❌ `DotacionUpdatePrioridadRequested`

**Nota**: Si `DotacionDeactivateRequested` / `DotacionReactivateRequested` se usan en el BLoC, integrar su lógica dentro de `DotacionUpdateRequested` (modificar campo `activo`).

---

### PASO 4: Simplificar `dotaciones_bloc.dart`

**Ubicación**: `lib/features/cuadrante/dotaciones/presentation/bloc/dotaciones_bloc.dart`

Adaptar el BLoC para:
1. Eliminar handlers de eventos de filtro
2. Simplificar handlers CUD: después de éxito → `add(DotacionesLoadRequested())`
3. Eliminar `DotacionOperationSuccess`
4. Mantener `@injectable` y patrón Equatable

**Patrón a seguir** (igual que `vehiculos_bloc.dart`):
```dart
// Después de crear/actualizar/eliminar:
try {
  await _repository.create(dotacion);
  add(const DotacionesLoadRequested()); // ← Recargar en vez de emitir OperationSuccess
} catch (e) {
  emit(DotacionesError(message: e.toString()));
}
```

**Importante**: Leer el BLoC actual completo antes de modificar. Verificar qué eventos de filtro están conectados a la lógica del repository y asegurarse de que el filtrado client-side los cubre adecuadamente.

---

### PASO 5: Refactorizar `dotaciones_page.dart`

**Ubicación**: `lib/features/cuadrante/dotaciones/presentation/pages/dotaciones_page.dart`

Transformar para seguir exactamente el patrón de `vehiculos_page.dart`:

```dart
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/dotacion_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/dotaciones_filters.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/dotaciones_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DotacionesPage extends StatelessWidget {
  const DotacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<DotacionesBloc>.value(
        value: getIt<DotacionesBloc>(),
        child: const _DotacionesView(),
      ),
    );
  }
}

class _DotacionesView extends StatefulWidget {
  const _DotacionesView();

  @override
  State<_DotacionesView> createState() => _DotacionesViewState();
}

class _DotacionesViewState extends State<_DotacionesView> {
  DateTime? _pageStartTime;
  DotacionesFilterData _filterData = const DotacionesFilterData();

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    debugPrint('⏱️ DotacionesPage: Inicio de carga de página');

    final DotacionesBloc bloc = context.read<DotacionesBloc>();
    if (bloc.state is DotacionesInitial) {
      debugPrint('🚀 DotacionesPage: Primera carga, solicitando dotaciones...');
      bloc.add(const DotacionesLoadRequested());
    } else if (bloc.state is DotacionesLoaded) {
      final DotacionesLoaded loadedState = bloc.state as DotacionesLoaded;
      debugPrint(
        '⚡ DotacionesPage: Datos ya cargados '
        '(${loadedState.dotaciones.length} dotaciones), '
        'reutilizando estado del BLoC',
      );
      // Performance tracking para caché
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageStartTime != null) {
          final Duration elapsed =
              DateTime.now().difference(_pageStartTime!);
          debugPrint(
            '⏱️ Tiempo total de carga (caché): ${elapsed.inMilliseconds}ms',
          );
          _pageStartTime = null;
        }
      });
    }
  }

  void _onFilterChanged(DotacionesFilterData filterData) {
    setState(() => _filterData = filterData);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DotacionesBloc, DotacionesState>(
      listener: (BuildContext context, DotacionesState state) {
        if (state is DotacionesLoaded && _pageStartTime != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageStartTime != null) {
              final Duration elapsed =
                  DateTime.now().difference(_pageStartTime!);
              debugPrint(
                '⏱️ Tiempo total de carga: ${elapsed.inMilliseconds}ms',
              );
              _pageStartTime = null;
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingXl,
            AppSizes.paddingXl,
            AppSizes.paddingXl,
            AppSizes.paddingLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BlocBuilder<DotacionesBloc, DotacionesState>(
                builder: (BuildContext context, DotacionesState state) {
                  return PageHeader(
                    config: PageHeaderConfig(
                      icon: Icons.assignment,
                      title: 'Gestión de Dotaciones',
                      subtitle: 'Administra las dotaciones del sistema',
                      addButtonLabel: 'Nueva Dotación',
                      stats: _buildHeaderStats(state),
                      onAdd: _showCreateDialog,
                      extra: DotacionesFilters(
                        onFilterChanged: _onFilterChanged,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              Expanded(
                child: DotacionesTable(filterData: _filterData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(DotacionesState state) {
    String total = '-';
    String activas = '-';
    String inactivas = '-';

    if (state is DotacionesLoaded) {
      total = state.dotaciones.length.toString();
      activas = state.dotaciones
          .where((DotacionEntity d) => d.activo)
          .length
          .toString();
      inactivas = state.dotaciones
          .where((DotacionEntity d) => !d.activo)
          .length
          .toString();
    }

    return <HeaderStat>[
      HeaderStat(value: total, icon: Icons.assignment),
      HeaderStat(value: activas, icon: Icons.check_circle),
      HeaderStat(value: inactivas, icon: Icons.cancel),
    ];
  }

  Future<void> _showCreateDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) =>
          BlocProvider<DotacionesBloc>.value(
            value: context.read<DotacionesBloc>(),
            child: const DotacionFormDialog(),
          ),
    );
  }
}
```

**Cambios clave vs actual**:
1. ✅ `BlocProvider.value` en vez de `BlocProvider(create:)`
2. ✅ `_DotacionesView` es **StatefulWidget** (era StatelessWidget)
3. ✅ `_filterData` como estado del widget
4. ✅ `DotacionesFilters` pasado como `extra` en `PageHeaderConfig`
5. ✅ `_filterData` pasado a `DotacionesTable`
6. ✅ Performance tracking con `_pageStartTime`
7. ✅ `_showCreateDialog` sin parámetro `context` (usar `this.context` del State)
8. ✅ `_buildHeaderStats` solo maneja `DotacionesLoaded` (sin `DotacionOperationSuccess`)

---

### PASO 6: Crear `dotaciones_table_cells.dart`

**Ubicación**: `lib/features/cuadrante/dotaciones/presentation/widgets/dotaciones_table_cells.dart`

Extraer TODOS los widgets de celda de la tabla actual. **Renombrarlos sin guion bajo** (serán públicos):

| Widget actual (privado) | Nuevo nombre (público) |
|--------------------------|------------------------|
| `_NombreCell` | `DotacionNombreCell` |
| `_DestinoCell` | `DotacionDestinoCell` |
| `_UnidadesCell` | `DotacionUnidadesCell` |
| `_PrioridadCell` | `DotacionPrioridadCell` |
| `_VigenciaCell` | `DotacionVigenciaCell` |
| `_EstadoCell` | `DotacionEstadoCell` |

**⚠️ REGLAS OBLIGATORIAS para celdas**:
- ✅ **SIEMPRE** usar `AppTextStyles.tableCell*` (nunca `GoogleFonts`)
- ✅ Imports: `app_colors.dart`, `app_text_styles.dart`, `status_badge.dart`, `intl`
- ❌ **NUNCA** importar `google_fonts`
- ❌ **NUNCA** importar `app_sizes.dart` (no se necesita con AppTextStyles)
- ✅ StatusBadge → envolver en `Align(alignment: Alignment.centerLeft, ...)`

Ejemplo de celda correcta:
```dart
class DotacionNombreCell extends StatelessWidget {
  const DotacionNombreCell({super.key, required this.dotacion});
  final DotacionEntity dotacion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(dotacion.nombre,
          style: AppTextStyles.tableCellBold,      // ✅ NO GoogleFonts
          maxLines: 1, overflow: TextOverflow.ellipsis),
        if (dotacion.descripcion != null && dotacion.descripcion!.isNotEmpty)
          Text(dotacion.description!,
            style: AppTextStyles.tableCellSmall,    // ✅ NO GoogleFonts
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
```

---

### PASO 7: Refactorizar `dotaciones_table.dart`

**Ubicación**: `lib/features/cuadrante/dotaciones/presentation/widgets/dotaciones_table.dart`

Transformar para seguir el patrón de `vehiculos_table_v4.dart`:

**Cambios obligatorios**:

1. **Constructor**: Aceptar `filterData` como parámetro
   ```dart
   class DotacionesTable extends StatefulWidget {
     const DotacionesTable({super.key, required this.filterData});
     final DotacionesFilterData filterData;
     @override
     State<DotacionesTable> createState() => _DotacionesTableState();
   }
   ```

2. **didUpdateWidget**: Reset página al cambiar filtros
   ```dart
   @override
   void didUpdateWidget(covariant DotacionesTable oldWidget) {
     super.didUpdateWidget(oldWidget);
     if (widget.filterData != oldWidget.filterData) {
       _currentPage = 0;
     }
   }
   ```

3. **Eliminar variables de filtro interno**: Borrar `_searchQuery` del State. El filtrado viene de `widget.filterData`.

4. **Eliminar widgets inline**: Borrar `_SearchBar`, `_SearchField`, `_FilterInfoBadge` (ya no se necesitan, los filtros están en el header).

5. **Usar `DotacionesFilterData.apply()`**:
   ```dart
   final List<DotacionEntity> filtradas =
       widget.filterData.apply(dotaciones);
   ```

6. **Importar celdas desde archivo separado**:
   ```dart
   import 'dotaciones_table_cells.dart';
   ```

7. **Eliminar widgets `_LoadingView` y `_ErrorView`** inline. Crear como clases públicas en el mismo archivo o importarlas.

8. **BlocListener simplificado**: Solo escuchar `DotacionesError` para delete (sin `DotacionOperationSuccess`).

9. **Tabla compacta** — `headerHeight: 44`, **NUNCA** definir `rowHeight`:
   ```dart
   AppDataGridV5<DotacionEntity>(
     columns: [...],
     headerHeight: 44,                          // ✅ Compacto
     // rowHeight: 72,                           // ❌ NUNCA
     outerBorderColor: AppColors.gray300,
     ...
   )
   ```

10. **Footer compacto** — `paddingSmall` + `constraints: BoxConstraints(minWidth: 36, minHeight: 36)`:
    ```dart
    Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),  // ✅ NO paddingMedium
      ...
      Row(children: [
        IconButton(
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),  // ✅ Compacto
          ...
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSmall,  // ✅ NO paddingMedium
            vertical: 4,                        // ✅ 4px
          ),
          ...
        ),
      ]),
    )
    ```

11. **Info de filtros como Text simple** — sin Container decorado:
    ```dart
    // ✅ CORRECTO
    if (widget.filterData.hasActiveFilters)
      Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.spacing),
        child: Text('Mostrando X de Y dotaciones',
          style: AppTextStyles.bodySmallSecondary),
      ),
    ```

**Estructura final del archivo** (~350 líneas):

```
- DotacionesTable (StatefulWidget, recibe filterData)
  - _DotacionesTableState
    - Variables: _sortColumnIndex, _sortAscending, _currentPage, _isDeleting, etc.
    - didUpdateWidget: reset _currentPage
    - build: BlocListener + BlocBuilder
      - Loading → AppLoadingIndicator
      - Error → ErrorView
      - Loaded → Column(AppDataGridV5 + pagination)
    - _sortDotaciones
    - _editDotacion
    - _confirmDelete
    - _buildPaginationControls
- _LoadingView (privado)
- _ErrorView (privado)
```

---

## ⚠️ REGLAS CRÍTICAS

### Antes de empezar
- [ ] Leer TODOS los archivos de referencia de Vehículos
- [ ] Leer TODOS los archivos actuales de Dotaciones
- [ ] Verificar campos disponibles en `DotacionEntity` (`ambutrack_core_datasource`)
- [ ] Verificar que `dotaciones_bloc_exports.dart` exporta los nuevos estados/eventos

### 🎨 REGLAS DE DISEÑO VISUAL (MUY IMPORTANTE)

La tabla, footer y celdas DEBEN coincidir visualmente con Vehículos y Personal. Referencia exacta:

#### Tabla (AppDataGridV5)
- ✅ `headerHeight: 44` (SIEMPRE)
- ❌ **NUNCA** usar `rowHeight` — dejar el default compacto (Vehículos y Personal NO lo definen)
- ✅ `outerBorderColor: AppColors.gray300`

```dart
AppDataGridV5<DotacionEntity>(
  columns: [...],
  rows: paginadas,
  headerHeight: 44,                              // ✅ Compacto como Vehículos
  // rowHeight: 72,                               // ❌ NUNCA — fila demasiado alta
  outerBorderColor: AppColors.gray300,
  ...
)
```

#### Footer / Paginación (compacto, NO inflado)
El footer DEBE ser compacto con botones pequeños. Copiar exactamente:

```dart
return Container(
  padding: const EdgeInsets.all(AppSizes.paddingSmall),   // ✅ paddingSmall, NO paddingMedium
  decoration: BoxDecoration(
    color: AppColors.surfaceLight,
    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
    border: Border.all(color: AppColors.gray200),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Text('Mostrando $startItem-$endItem de $totalItems ...',
        style: AppTextStyles.bodySmallSecondary),
      Row(children: <Widget>[
        IconButton(
          icon: const Icon(Icons.first_page),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36), // ✅ Compacto
          onPressed: ...,
        ),
        // ... resto de IconButtons con constraints: BoxConstraints(minWidth: 36, minHeight: 36)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSmall,    // ✅ paddingSmall, NO paddingMedium
            vertical: 4,                          // ✅ 4px, NO paddingSmall
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text('Página ${currentPage + 1} de $totalPages', ...),
        ),
      ]),
    ],
  ),
);
```

#### Info de filtros activos (simple Text, sin Container decorado)
Vehículos/Personal usan un `Text` simple, NO un Container con fondo:

```dart
// ✅ CORRECTO — como Vehículos/Personal
if (widget.filterData.hasActiveFilters)
  Padding(
    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
    child: Text(
      'Mostrando ${filtradas.length} de ${state.dotaciones.length} dotaciones',
      style: AppTextStyles.bodySmallSecondary,
    ),
  ),

// ❌ INCORRECTO — Container con fondo decorado
if (widget.filterData.hasActiveFilters)
  Container(
    padding: ...,
    decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), ...),
    child: Text('Mostrando ...', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
  ),
```

#### Celdas de tabla (AppTextStyles, NO GoogleFonts)
- ✅ **SIEMPRE** usar `AppTextStyles.tableCell*` para texto en celdas
- ❌ **NUNCA** usar `GoogleFonts.inter(...)` en celdas de tabla

```dart
// ✅ CORRECTO
Text(dotacion.nombre, style: AppTextStyles.tableCellBold)
Text(dotacion.tipoDestino, style: AppTextStyles.tableCell)
Text(dotacion.descripcion!, style: AppTextStyles.tableCellSmall)

// ❌ INCORRECTO
Text(dotacion.nombre, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: ...))
```

Estilos disponibles en `AppTextStyles` para tablas:
| Estilo | Uso |
|--------|-----|
| `AppTextStyles.tableCell` | Texto normal de celda |
| `AppTextStyles.tableCellBold` | Texto destacado (nombre, código) |
| `AppTextStyles.tableCellSecondary` | Texto secundario (sin dato) |
| `AppTextStyles.tableCellSmall` | Texto pequeño (subtítulo, descripción) |
| `AppTextStyles.tableCellBold` + `.copyWith(color: ...)` | Badge numérico (unidades) |

#### Badges/StatusBadge en celdas
- ✅ Envolver en `Align(alignment: Alignment.centerLeft, ...)` para ajustar ancho al texto
- ❌ **NUNCA** envolver en `Center()` que expande al ancho completo

```dart
// ✅ CORRECTO — Badge ajustado al texto
return Align(
  alignment: Alignment.centerLeft,
  child: StatusBadge(label: 'Activa', type: StatusBadgeType.success),
);

// ❌ INCORRECTO — Badge centrado que expande
return Center(
  child: StatusBadge(label: 'Activa', type: StatusBadgeType.success),
);
```

### Durante la implementación
- [ ] **NUNCA** usar `_buildXxx()` methods — usar clases separadas
- [ ] **SIEMPRE** usar `AppColors` para colores (nunca `Color(0xFF...)`)
- [ ] **SIEMPRE** usar `AppTextStyles.tableCell*` en celdas (nunca `GoogleFonts`)
- [ ] **SIEMPRE** usar `debugPrint` (nunca `print()`)
- [ ] **SIEMPRE** `AppDropdown` para dropdowns
- [ ] **SIEMPRE** `StatusBadge` para badges de estado
- [ ] **SIEMPRE** `CrudOperationHandler` para feedback CRUD
- [ ] **SIEMPRE** `showConfirmationDialog` para eliminar
- [ ] **SIEMPRE** `AppLoadingOverlay` para loading de operaciones
- [ ] **NUNCA** definir `rowHeight` en AppDataGridV5 (usar default compacto)
- [ ] **NUNCA** usar `GoogleFonts` en celdas de tabla
- [ ] **NUNCA** files > 400 líneas
- [ ] **NUNCA** ejecutar `flutter analyze` sin autorización

### Después de cada archivo modificado
- [ ] Verificar imports correctos
- [ ] Verificar que no hay warnings
- [ ] Verificar que los nombres de clases coinciden

### Al finalizar
- [ ] Todos los archivos < 400 líneas
- [ ] Sin eventos de filtro en el BLoC
- [ ] Sin `DotacionOperationSuccess`
- [ ] Sin `_SearchBar` / `_SearchField` / `_FilterInfoBadge` en la tabla
- [ ] Filtros en el header vía `extra: DotacionesFilters(...)`
- [ ] Filtrado client-side con `DotacionesFilterData.apply()`
- [ ] `BlocProvider.value` en la Page (no `create:`)
- [ ] `_DotacionesView` es StatefulWidget

---

## 🔗 DEPENDENCIAS CON OTROS ARCHIVOS

### Imports que pueden necesitar actualización
Si otros archivos importan `DotacionOperationSuccess`, actualizarlos:
```bash
# Buscar referencias:
grep -r "DotacionOperationSuccess" lib/
grep -r "DotacionesFiltrarPor" lib/
grep -r "DotacionDeactivate" lib/
grep -r "DotacionReactivate" lib/
grep -r "DotacionUpdateCantidad" lib/
grep -r "DotacionUpdatePrioridad" lib/
```

### `dotaciones_bloc_exports.dart`
Verificar que exporta los eventos y estados correctos después de la simplificación.

---

## 📊 DIAGRAMA ANTES vs DESPUÉS

### ANTES (estado actual)
```
DotacionesPage (StatelessWidget)
├── BlocProvider(create: ..add(LoadRequested))
├── _DotacionesView (StatelessWidget)
│   ├── PageHeader (sin extra/filters)
│   └── DotacionesTable
│       ├── _SearchBar + _SearchField (inline!)
│       ├── _FilterInfoBadge (inline!)
│       ├── _NombreCell, _DestinoCell... (inline!)
│       ├── _LoadingView (inline!)
│       └── _ErrorView (inline!)
│
├── BLoC Events: 13 eventos (incl. 5 de filtro server-side)
└── BLoC States: 5 estados (incl. DotacionOperationSuccess)
```

### DESPUÉS (patrón Vehículos)
```
DotacionesPage (StatelessWidget)
├── BlocProvider.value (getIt<DotacionesBloc>())
└── _DotacionesView (StatefulWidget!)
    ├── _filterData state
    ├── PageHeader (con extra: DotacionesFilters)
    │   └── DotacionesFilters (widget separado)
    │       ├── TextField búsqueda (debounced 150ms)
    │       ├── AppDropdown destino
    │       ├── AppDropdown estado
    │       └── AppButton limpiar
    └── DotacionesTable(filterData: _filterData)
        ├── AppDataGridV5 (sin search bar!)
        ├── Celdas importadas de dotaciones_table_cells.dart
        └── _PaginationControls
│
├── BLoC Events: 5 eventos (sin filtros server-side)
└── BLoC States: 4 estados (sin OperationSuccess)
```

---

## 📝 NOTAS

- **No modificar el `dotacion_form_dialog.dart`** — ese archivo se mantiene igual.
- **No modificar los repositories** — la capa de datos no cambia.
- **Verificar** que `AppDropdown` soporta tipos genéricos (`String?`, `bool?`).
- **Si el BLoC actual tiene lógica de deactivate/reactivate**, integrarla en `DotacionUpdateRequested` (actualizar campo `activo`).
- **Si otros módulos dependen de eventos eliminados**, documentar el impacto.

> **Fecha creación**: 2025-06-05
> **Versión**: 1.0
> **Refiere a**: Vehículos pattern (`lib/features/vehiculos/`)
