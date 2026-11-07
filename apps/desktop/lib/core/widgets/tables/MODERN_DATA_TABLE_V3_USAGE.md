# ModernDataTableV3 - Guía de Uso

## 📋 Descripción

`ModernDataTableV3` es una tabla genérica reutilizable diseñada para toda la aplicación AmbuTrack. Se basa en el patrón exitoso de `personal_table_v4.dart` y proporciona una solución completa para mostrar datos tabulares con funcionalidades avanzadas.

## ✨ Características

- ✅ **Diseño moderno** con bordes redondeados y sombras
- ✅ **Ordenamiento (sort)** por columnas
- ✅ **Paginación** integrada y configurable
- ✅ **Estados manejados**: Loading, Error, Vacío
- ✅ **Filtros** personalizables
- ✅ **Acciones CRUD**: Ver, Editar, Eliminar
- ✅ **Completamente genérico**: Funciona con cualquier tipo `T`
- ✅ **Responsive** y adaptativo
- ✅ **Hover effects** en filas
- ✅ **Alternancia de colores** en filas

## 🚀 Uso Básico

### Ejemplo Simple

```dart
import 'package:ambutrack_web/core/widgets/tables/modern_data_table_v3.dart';

class MiTabla extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<MiEntidad> datos = [...];

    return ModernDataTableV3<MiEntidad>(
      data: datos,
      title: 'Lista de Items',
      columns: const [
        DataColumnV4(label: 'NOMBRE', flex: 3, sortable: true),
        DataColumnV4(label: 'CATEGORÍA', flex: 2, sortable: true),
        DataColumnV4(label: 'FECHA', flex: 2, sortable: true),
      ],
      buildCells: (MiEntidad item) => [
        Text(item.nombre),
        Text(item.categoria),
        Text(DateFormat('dd/MM/yyyy').format(item.fecha)),
      ],
      onEdit: (MiEntidad item) => _editar(item),
      onDelete: (MiEntidad item) => _eliminar(item),
    );
  }
}
```

## 🔧 Uso Avanzado con BLoC

### Estructura Recomendada

```dart
import 'dart:async';

import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/modern_data_table_v3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MiTableV4 extends StatefulWidget {
  const MiTableV4({super.key});

  @override
  State<MiTableV4> createState() => _MiTableV4State();
}

class _MiTableV4State extends State<MiTableV4> {
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;

  @override
  Widget build(BuildContext context) {
    return BlocListener<MiBloc, MiState>(
      listener: (BuildContext context, MiState state) {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is MiLoaded || state is MiError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);
            final int durationMs = elapsed.inMilliseconds;

            setState(() {
              _isDeleting = false;
              _loadingDialogContext = null;
              _deleteStartTime = null;
            });

            if (state is MiError) {
              CrudOperationHandler.handleDeleteError(
                context: context,
                isDeleting: true,
                entityName: 'Item',
                errorMessage: state.message,
              );
            } else if (state is MiLoaded) {
              CrudOperationHandler.handleDeleteSuccess(
                context: context,
                isDeleting: true,
                entityName: 'Item',
                durationMs: durationMs,
              );
            }
          }
        }
      },
      child: BlocBuilder<MiBloc, MiState>(
        builder: (BuildContext context, MiState state) {
          if (state is MiLoading) {
            return const LoadingView(message: 'Cargando items...');
          }

          if (state is MiError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<MiBloc>().add(const MiLoadRequested());
              },
            );
          }

          if (state is MiLoaded) {
            return ModernDataTableV3<MiEntidad>(
              data: state.items,
              title: 'Lista de Items',
              columns: const [
                DataColumnV4(label: 'NOMBRE', flex: 3, sortable: true),
                DataColumnV4(label: 'CATEGORÍA', flex: 2, sortable: true),
                DataColumnV4(label: 'FECHA', flex: 2, sortable: true),
              ],
              buildCells: (MiEntidad item) => [
                Text(item.nombre),
                Text(item.categoria),
                Text(DateFormat('dd/MM/yyyy').format(item.fecha)),
              ],
              sortComparators: {
                0: (a, b) => a.nombre.compareTo(b.nombre),
                1: (a, b) => a.categoria.compareTo(b.categoria),
                2: (a, b) => a.fecha.compareTo(b.fecha),
              },
              onEdit: (MiEntidad item) => _editItem(context, item),
              onDelete: (MiEntidad item) => _confirmDelete(context, item),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _editItem(BuildContext context, MiEntidad item) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<MiBloc>.value(
          value: context.read<MiBloc>(),
          child: MiFormDialog(item: item),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, MiEntidad item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este item? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': item.nombre,
        'Categoría': item.categoria,
      },
    );

    if (confirmed == true && context.mounted) {
      BuildContext? loadingContext;

      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            loadingContext = dialogContext;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && loadingContext != null) {
                setState(() {
                  _isDeleting = true;
                  _loadingDialogContext = loadingContext;
                  _deleteStartTime = DateTime.now();
                });
              }
            });

            return const AppLoadingOverlay(
              message: 'Eliminando item...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<MiBloc>().add(MiDeleteRequested(id: item.id));
      }
    }
  }
}
```

## 🎯 Propiedades Configurables

### Obligatorias

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `data` | `List<T>` | Lista de datos a mostrar |
| `columns` | `List<DataColumnV4>` | Definición de columnas |
| `buildCells` | `Function(T) => List<Widget>` | Función que construye las celdas de cada fila |

### Opcionales

| Propiedad | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `title` | `String` | `'Lista'` | Título de la tabla |
| `emptyMessage` | `String` | `'No hay datos disponibles'` | Mensaje cuando no hay datos |
| `loadingMessage` | `String` | `'Cargando datos...'` | Mensaje durante carga |
| `itemsPerPage` | `int` | `25` | Items por página |
| `showPagination` | `bool` | `true` | Mostrar controles de paginación |
| `alternateRowColor` | `bool` | `true` | Alternar color en filas |
| `onEdit` | `Function(T)?` | `null` | Callback al editar |
| `onDelete` | `Function(T)?` | `null` | Callback al eliminar |
| `onView` | `Function(T)?` | `null` | Callback al ver detalles |
| `onRowTap` | `Function(T)?` | `null` | Callback al hacer clic en fila |
| `sortComparators` | `Map<int, Function>?` | `null` | Comparadores para ordenamiento |
| `filterWidget` | `Widget?` | `null` | Widget de filtros personalizado |

## 📊 Ordenamiento (Sort)

Para habilitar ordenamiento, proporcionar `sortComparators`:

```dart
sortComparators: {
  0: (MiEntidad a, MiEntidad b) => a.nombre.compareTo(b.nombre),
  1: (MiEntidad a, MiEntidad b) => (a.categoria ?? '').compareTo(b.categoria ?? ''),
  2: (MiEntidad a, MiEntidad b) {
    if (a.fecha == null && b.fecha == null) return 0;
    if (a.fecha == null) return 1;
    if (b.fecha == null) return -1;
    return a.fecha!.compareTo(b.fecha!);
  },
}
```

**Nota**: El índice del Map corresponde al índice de columna (0-based).

## 🔍 Filtros

Para agregar filtros, pasar un widget personalizado:

```dart
filterWidget: MisFiltros(
  onFiltersChanged: (filtros) {
    // Actualizar estado con datos filtrados
  },
)
```

## 📄 Paginación

Configurar paginación:

```dart
ModernDataTableV3<MiEntidad>(
  itemsPerPage: 50,        // 50 items por página
  showPagination: true,    // Mostrar controles
  // ...
)
```

Para desactivar paginación:

```dart
ModernDataTableV3<MiEntidad>(
  showPagination: false,
  // ...
)
```

## 🎨 Celdas Personalizadas

### Texto Simple

```dart
buildCells: (item) => [
  Text(item.nombre),
]
```

### Chip con Color

```dart
buildCells: (item) => [
  Text(
    item.categoria,
    style: GoogleFonts.inter(
      fontSize: AppSizes.fontSmall,
      fontWeight: FontWeight.w500,
      color: _getCategoriaColor(item.categoria),
    ),
  ),
]
```

### Columna con Iconos

```dart
buildCells: (item) => [
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (item.email != null)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.email, size: 11, color: AppColors.textSecondaryLight),
            const SizedBox(width: 3),
            Text(item.email!),
          ],
        ),
      if (item.telefono != null)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone, size: 11, color: AppColors.textSecondaryLight),
            const SizedBox(width: 3),
            Text(item.telefono!),
          ],
        ),
    ],
  ),
]
```

## 🚨 Eliminación Segura

Siempre usar el patrón con `showConfirmationDialog` + `AppLoadingOverlay` + `CrudOperationHandler`:

```dart
Future<void> _confirmDelete(BuildContext context, MiEntidad item) async {
  // 1. Confirmar con usuario
  final bool? confirmed = await showConfirmationDialog(
    context: context,
    title: 'Confirmar Eliminación',
    message: '¿Estás seguro...?',
    itemDetails: {...},
  );

  if (confirmed != true || !context.mounted) return;

  // 2. Mostrar loading overlay
  BuildContext? loadingContext;
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        loadingContext = dialogContext;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && loadingContext != null) {
            setState(() {
              _isDeleting = true;
              _loadingDialogContext = loadingContext;
              _deleteStartTime = DateTime.now();
            });
          }
        });
        return const AppLoadingOverlay(...);
      },
    ),
  );

  // 3. Disparar evento BLoC
  if (context.mounted) {
    context.read<MiBloc>().add(MiDeleteRequested(id: item.id));
  }
}
```

## 🏗️ Widgets de Estado

### LoadingView

```dart
if (state is MiLoading) {
  return const LoadingView(
    message: 'Cargando items...',
  );
}
```

### ErrorView

```dart
if (state is MiError) {
  return ErrorView(
    title: 'Error al cargar',
    message: state.message,
    onRetry: () {
      context.read<MiBloc>().add(const MiLoadRequested());
    },
  );
}
```

## 📚 Ejemplos Completos

Ver implementación de referencia en:
- [personal_table_v4.dart](../../features/personal/presentation/widgets/personal_table_v4.dart)

## ⚠️ Reglas OBLIGATORIAS

1. ✅ **SIEMPRE** usar `ModernDataTableV3` para nuevas tablas
2. ✅ **SIEMPRE** proporcionar `sortComparators` si las columnas son ordenables
3. ✅ **SIEMPRE** usar `CrudOperationHandler` para operaciones CRUD
4. ✅ **SIEMPRE** manejar estados de loading y error
5. ✅ **SIEMPRE** usar `showConfirmationDialog` antes de eliminar
6. ✅ **NUNCA** usar métodos que devuelven Widgets (usar StatelessWidget)
7. ✅ **NUNCA** hardcodear colores (usar `AppColors`)

## 🔄 Migración desde otras tablas

Para migrar desde `ModernDataTable` o `AppDataGrid`:

1. Reemplazar widget por `ModernDataTableV3<TuEntidad>`
2. Convertir `columns` a `List<DataColumnV4>`
3. Implementar `buildCells(item) => [...]`
4. Agregar `sortComparators` si es necesario
5. Actualizar callbacks (`onEdit`, `onDelete`, etc.)
6. Ejecutar `flutter analyze` → debe dar 0 warnings

---

**Ubicación**: `lib/core/widgets/tables/modern_data_table_v3.dart`
