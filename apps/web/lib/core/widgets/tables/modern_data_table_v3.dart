import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v4.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ModernDataTableV3 - Tabla genérica reutilizable para toda la aplicación
///
/// IMPORTANTE: Este widget ahora usa AppDataGridV4 siguiendo el mismo patrón
/// que vehiculos_table_v4.dart para consistencia UI/UX.
///
/// Características:
/// - Diseño moderno profesional con AppDataGridV4
/// - Soporte para ordenamiento (sort)
/// - Filtros personalizables
/// - Acciones CRUD (Ver/Editar/Eliminar)
/// - Estados de loading y error profesionales
/// - Completamente genérico (funciona con cualquier tipo T)
/// - Badge con width ajustado al contenido (patrón Align)
/// - Row click para ver detalles (sin botón "Ver" separado)
///
/// Uso:
/// ```dart
/// ModernDataTableV3<MiEntidad>(
///   data: misDatos,
///   columns: [...],
///   buildCells: (entidad) => [...],
///   onEdit: (entidad) => _editar(entidad),
///   onDelete: (entidad) => _eliminar(entidad),
///   onView: (entidad) => _verDetalles(entidad),  // Opcional
///   filterWidget: MisFilters(...),
///   title: 'Lista de Entidades',
/// )
/// ```
class ModernDataTableV3<T> extends StatefulWidget {
  const ModernDataTableV3({
    required this.data,
    required this.columns,
    required this.buildCells,
    this.onEdit,
    this.onDelete,
    this.onView,
    this.sortComparators,
    this.filterWidget,
    this.title = 'Lista',
    this.emptyMessage = 'No hay datos disponibles',
    this.hasActiveFilters = false,
    this.totalItems,
    super.key,
  });

  /// Datos a mostrar en la tabla
  final List<T> data;

  /// Definición de columnas (AppDataGridV4)
  final List<DataGridColumn> columns;

  /// Función que construye las celdas para cada fila
  final List<DataGridCell> Function(T item) buildCells;

  /// Callbacks para acciones
  final void Function(T item)? onEdit;
  final void Function(T item)? onDelete;
  final void Function(T item)? onView;

  /// Comparadores para ordenamiento por columna
  /// Map<índice_columna, función_comparación>
  final Map<int, int Function(T a, T b)>? sortComparators;

  /// Widget de filtros personalizado
  final Widget? filterWidget;

  /// Textos configurables
  final String title;
  final String emptyMessage;

  /// Info de filtros
  final bool hasActiveFilters;
  final int? totalItems;

  @override
  State<ModernDataTableV3<T>> createState() => _ModernDataTableV3State<T>();
}

class _ModernDataTableV3State<T> extends State<ModernDataTableV3<T>> {
  // Sort
  int? _sortColumnIndex;
  bool _sortAscending = true;

  void _onSort(int columnIndex, {required bool ascending}) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<T> _getSortedData(List<T> data) {
    if (_sortColumnIndex == null ||
        widget.sortComparators == null ||
        !widget.sortComparators!.containsKey(_sortColumnIndex)) {
      return data;
    }

    return List<T>.from(data)
      ..sort((T a, T b) {
        final int comparison = widget.sortComparators![_sortColumnIndex]!(a, b);
        return _sortAscending ? comparison : -comparison;
      });
  }

  @override
  Widget build(BuildContext context) {
    final List<T> sortedData = _getSortedData(widget.data);
    final int totalCount = widget.totalItems ?? widget.data.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Header: Título + Filtros
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.title,
                style: AppTextStyles.h4,
              ),
            ),
            if (widget.filterWidget != null) widget.filterWidget!,
          ],
        ),

        const SizedBox(height: AppSizes.spacing),

        // Info de resultados filtrados
        if (totalCount != sortedData.length)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacing),
            child: Text(
              'Mostrando ${sortedData.length} de $totalCount elementos',
              style: AppTextStyles.bodySmallSecondary,
            ),
          ),

        // Tabla v4
        AppDataGridV4<T>(
          columns: widget.columns,
          rows: sortedData.map((T item) {
            return DataGridRow<T>(
              data: item,
              cells: widget.buildCells(item),
            );
          }).toList(),
          onView: widget.onView,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
          emptyMessage: widget.hasActiveFilters
              ? 'No se encontraron resultados con los filtros aplicados'
              : widget.emptyMessage,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          onSort: widget.sortComparators != null ? _onSort : null,
          rowHeight: 60.0, // Aumentado de 48 a 60 para soportar 2 líneas de texto
        ),
      ],
    );
  }
}

/// Vista de carga profesional
///
/// Sigue el mismo diseño que _LoadingView en vehiculos_table_v4.dart
class LoadingView extends StatelessWidget {
  const LoadingView({
    this.message = 'Cargando datos...',
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMassive),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      constraints: const BoxConstraints(minHeight: 400),
      child: Center(
        child: AppLoadingIndicator(
          message: message,
        ),
      ),
    );
  }
}

/// Vista de error profesional
///
/// Sigue el mismo diseño que _ErrorView en vehiculos_table_v4.dart
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    this.onRetry,
    this.title = 'Error al cargar datos',
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMassive),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: AppSizes.iconMassive,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              title,
              style: AppTextStyles.errorTextLarge,
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              message,
              style: AppTextStyles.bodySmallSecondary,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppSizes.spacing),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Wrapper completo que maneja estados de BLoC
///
/// IMPORTANTE: Este es un wrapper helper. Para implementaciones reales,
/// se recomienda seguir el patrón de vehiculos_table_v4.dart donde:
/// 1. Se crea un StatefulWidget específico para la tabla
/// 2. Se usa BlocListener + BlocBuilder manualmente
/// 3. Se tienen vistas _LoadingView y _ErrorView privadas
/// 4. Se maneja el estado de delete con loading overlay
///
/// Este wrapper es útil para tablas simples sin CRUD complejo.
///
/// Ejemplo de uso con BLoC:
/// ```dart
/// BlocBuilder<MiBloc, MiState>(
///   builder: (context, state) {
///     if (state is MiLoading) return const LoadingView();
///     if (state is MiError) return ErrorView(message: state.message);
///     if (state is MiLoaded) {
///       return ModernDataTableV3<MiEntidad>(
///         data: state.items,
///         columns: [...],
///         buildCells: (item) => [...],
///         // ...
///       );
///     }
///     return const SizedBox.shrink();
///   },
/// )
/// ```
class ModernDataTableV3Wrapper<T> extends StatelessWidget {
  const ModernDataTableV3Wrapper({
    required this.data,
    required this.columns,
    required this.buildCells,
    required this.isLoading,
    required this.isError,
    required this.errorMessage,
    this.onEdit,
    this.onDelete,
    this.onView,
    this.sortComparators,
    this.filterWidget,
    this.onRetry,
    this.title = 'Lista',
    this.emptyMessage = 'No hay datos disponibles',
    this.loadingMessage = 'Cargando datos...',
    this.errorTitle = 'Error al cargar datos',
    this.hasActiveFilters = false,
    this.totalItems,
    super.key,
  });

  final List<T>? data;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final VoidCallback? onRetry;

  final String title;
  final String emptyMessage;
  final String loadingMessage;
  final String errorTitle;
  final List<DataGridColumn> columns;
  final List<DataGridCell> Function(T item) buildCells;
  final void Function(T item)? onEdit;
  final void Function(T item)? onDelete;
  final void Function(T item)? onView;
  final Map<int, int Function(T a, T b)>? sortComparators;
  final Widget? filterWidget;
  final bool hasActiveFilters;
  final int? totalItems;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingView(message: loadingMessage);
    }

    if (isError) {
      return ErrorView(
        title: errorTitle,
        message: errorMessage ?? 'Ha ocurrido un error inesperado',
        onRetry: onRetry,
      );
    }

    if (data == null || data!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.spacingMassive),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(color: AppColors.gray200),
        ),
        constraints: const BoxConstraints(minHeight: 400),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.inbox_outlined,
                size: AppSizes.iconMassive,
                color: AppColors.gray400,
              ),
              const SizedBox(height: AppSizes.spacing),
              Text(
                emptyMessage,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontMedium,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ModernDataTableV3<T>(
      data: data!,
      columns: columns,
      buildCells: buildCells,
      onEdit: onEdit,
      onDelete: onDelete,
      onView: onView,
      sortComparators: sortComparators,
      filterWidget: filterWidget,
      title: title,
      emptyMessage: emptyMessage,
      hasActiveFilters: hasActiveFilters,
      totalItems: totalItems,
    );
  }
}
