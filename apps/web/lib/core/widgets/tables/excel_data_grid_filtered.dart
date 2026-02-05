import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// DataGrid estilo Excel con filtros y búsqueda profesional
///
/// CARACTERÍSTICAS:
/// - ✅ Búsqueda por columna individual (debajo de headers)
/// - ✅ Filtros por columna (dropdown en header)
/// - ✅ Filtros rápidos por múltiples columnas
/// - ✅ Ordenamiento de columnas
/// - ✅ Scroll horizontal y vertical fluido
/// - ✅ Header fijo (sticky)
/// - ✅ Diseño profesional estilo Excel
///
/// USO:
/// ```dart
/// ExcelDataGridFiltered<ServicioEntity>(
///   columns: columns,
///   rows: data,
///   buildCells: (servicio) => [...],
///   getColumnValue: (servicio, columnIndex) {
///     switch (columnIndex) {
///       case 0: return servicio.codigo;
///       case 1: return servicio.paciente;
///       default: return '';
///     }
///   },
///   initialSortColumnIndex: 0,  // Ordenar por primera columna al inicio
///   initialSortAscending: false,  // En orden descendente
///   onEdit: (servicio) => _editar(servicio),
///   onDelete: (servicio) => _eliminar(servicio),
/// )
/// ```
class ExcelDataGridFiltered<T> extends StatefulWidget {
  const ExcelDataGridFiltered({
    super.key,
    required this.columns,
    required this.rows,
    required this.buildCells,
    required this.getColumnValue,
    this.onRowTap,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.emptyMessage = 'No hay datos disponibles',
    this.rowHeight = 28.0,
    this.headerHeight = 35.0,
    this.selectedItem,
    this.getItemId,
    this.initialSortColumnIndex,
    this.initialSortAscending = true,
  });

  final List<ExcelColumnFiltered> columns;
  final List<T> rows;
  final List<Widget> Function(T item) buildCells;
  final String Function(T item, int columnIndex) getColumnValue;
  final void Function(T data)? onRowTap;
  final void Function(T data)? onView;
  final void Function(T data)? onEdit;
  final void Function(T data)? onDelete;
  final String emptyMessage;
  final double rowHeight;
  final double headerHeight;
  final T? selectedItem;
  final String? Function(T item)? getItemId;
  final int? initialSortColumnIndex;
  final bool initialSortAscending;

  @override
  State<ExcelDataGridFiltered<T>> createState() => _ExcelDataGridFilteredState<T>();
}

class _ExcelDataGridFilteredState<T> extends State<ExcelDataGridFiltered<T>> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  // Estado de filtrado
  final Map<int, Set<String>> _columnFilters = <int, Set<String>>{};
  final Map<int, TextEditingController> _columnSearchControllers = <int, TextEditingController>{};
  final Map<int, String> _columnSearchQueries = <int, String>{};
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    // Crear controladores para búsqueda por columna
    for (int i = 0; i < widget.columns.length; i++) {
      if (widget.columns[i].searchable) {
        _columnSearchControllers[i] = TextEditingController();
        _columnSearchQueries[i] = '';
      }
    }

    // Configurar ordenamiento inicial si se especifica
    if (widget.initialSortColumnIndex != null) {
      _sortColumnIndex = widget.initialSortColumnIndex;
      _sortAscending = widget.initialSortAscending;
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    // Dispose de controladores de búsqueda por columna
    for (final TextEditingController controller in _columnSearchControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _hasActions =>
      widget.onView != null || widget.onEdit != null || widget.onDelete != null;

  int get _actionsCount {
    int count = 0;
    if (widget.onView != null) {
      count++;
    }
    if (widget.onEdit != null) {
      count++;
    }
    if (widget.onDelete != null) {
      count++;
    }
    return count;
  }

  /// Filtra las filas según búsqueda por columna y filtros dropdown
  List<T> _getFilteredRows() {
    List<T> filtered = widget.rows;

    // Aplicar búsqueda por columna individual
    _columnSearchQueries.forEach((int columnIndex, String query) {
      if (query.isNotEmpty) {
        filtered = filtered.where((T item) {
          final String value = widget.getColumnValue(item, columnIndex).toLowerCase();
          return value.contains(query.toLowerCase());
        }).toList();
      }
    });

    // Aplicar filtros por columna
    _columnFilters.forEach((int columnIndex, Set<String> selectedValues) {
      if (selectedValues.isNotEmpty) {
        filtered = filtered.where((T item) {
          final String value = widget.getColumnValue(item, columnIndex);
          return selectedValues.contains(value);
        }).toList();
      }
    });

    // Aplicar ordenamiento
    if (_sortColumnIndex != null) {
      filtered.sort((T a, T b) {
        final String valueA = widget.getColumnValue(a, _sortColumnIndex!);
        final String valueB = widget.getColumnValue(b, _sortColumnIndex!);
        final int comparison = valueA.compareTo(valueB);
        return _sortAscending ? comparison : -comparison;
      });
    }

    return filtered;
  }

  void _toggleSort(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _columnFilters.clear();
      _columnSearchQueries.clear();
      _columnSearchControllers.forEach((int index, TextEditingController controller) {
        controller.clear();
      });
      _sortColumnIndex = null;
      _sortAscending = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<T> filteredRows = _getFilteredRows();

    return Column(
      children: <Widget>[
        // Controles de filtros activos
        _buildFiltersBar(),

        // Tabla
        Expanded(
          child: filteredRows.isEmpty
              ? _buildEmptyState()
              : _buildTable(filteredRows),
        ),
      ],
    );
  }

  Widget _buildFiltersBar() {
    final int activeFiltersCount = _columnFilters.values
        .fold<int>(0, (int sum, Set<String> values) => sum + values.length);

    // Contar búsquedas activas por columna
    final int activeSearchesCount = _columnSearchQueries.values
        .where((String query) => query.isNotEmpty)
        .length;

    final bool hasActiveFilters = activeFiltersCount > 0 || activeSearchesCount > 0 || _sortColumnIndex != null;

    if (!hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: <Widget>[
          // Badge de filtros dropdown activos
          if (activeFiltersCount > 0) ...<Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.filter_alt, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '$activeFiltersCount filtro${activeFiltersCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.spacingSmall),
          ],

          // Badge de búsquedas activas
          if (activeSearchesCount > 0) ...<Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.search, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(
                    '$activeSearchesCount búsqueda${activeSearchesCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.spacingSmall),
          ],

          const Spacer(),

          // Info de resultados
          Text(
            '${_getFilteredRows().length} de ${widget.rows.length} registros',
            style: AppTextStyles.bodySmallSecondary,
          ),

          const SizedBox(width: AppSizes.spacing),

          // Botón limpiar todo
          OutlinedButton.icon(
            onPressed: _clearAllFilters,
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Limpiar todo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<T> filteredRows) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.gray300,
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _calculateTotalWidth(),
                  height: constraints.maxHeight,
                  child: Column(
                    children: <Widget>[
                      // Header con filtros
                      _buildHeader(),

                      // Fila de búsqueda por columna
                      _buildSearchRow(),

                      // Filas con scroll vertical
                      Expanded(
                        child: Scrollbar(
                          controller: _verticalController,
                          thumbVisibility: true,
                          child: ListView.builder(
                            controller: _verticalController,
                            itemCount: filteredRows.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildRow(filteredRows[index], index);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
        },
      ),
    );
  }

  double _calculateTotalWidth() {
    double total = 0;

    for (final ExcelColumnFiltered column in widget.columns) {
      if (column.width != null) {
        total += column.width!;
      } else if (column.minWidth != null) {
        total += column.minWidth!;
      } else {
        total += 150;
      }
    }

    if (_hasActions) {
      total += 50.0 * _actionsCount;
    }

    return total;
  }

  Widget _buildHeader() {
    return Container(
      height: widget.headerHeight,
      decoration: const BoxDecoration(
        color: AppColors.primary,  // ✅ Azul como tabla de trayectos
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusSmall),
          topRight: Radius.circular(AppSizes.radiusSmall),
        ),
      ),
      child: Row(
        children: <Widget>[
          // Columnas
          ...widget.columns.asMap().entries.map((MapEntry<int, ExcelColumnFiltered> entry) {
            final int index = entry.key;
            final ExcelColumnFiltered column = entry.value;
            return _buildHeaderCell(column, index);
          }),

          // Columna de acciones
          if (_hasActions)
            Container(
              width: 50.0 * _actionsCount,
              alignment: Alignment.center,
              child: const Text(
                'ACCIONES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,  // ✅ Texto blanco en header azul
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Construye la fila de búsqueda por columna
  Widget _buildSearchRow() {
    return Container(
      height: 42,
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,  // ✅ Fondo más limpio
      ),
      child: Row(
        children: <Widget>[
          // Campos de búsqueda por columna
          ...widget.columns.asMap().entries.map((MapEntry<int, ExcelColumnFiltered> entry) {
            final int index = entry.key;
            final ExcelColumnFiltered column = entry.value;
            return _buildSearchCell(column, index);
          }),

          // Espacio para columna de acciones
          if (_hasActions)
            SizedBox(
              width: 50.0 * _actionsCount,
            ),
        ],
      ),
    );
  }

  /// Construye una celda de búsqueda individual
  Widget _buildSearchCell(ExcelColumnFiltered column, int columnIndex) {
    final double width = column.width ?? column.minWidth ?? 150;

    if (!column.searchable) {
      return SizedBox(width: width);
    }

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      child: TextField(
        controller: _columnSearchControllers[columnIndex],
        onChanged: (String value) {
          setState(() {
            _columnSearchQueries[columnIndex] = value;
          });
        },
        decoration: InputDecoration(
          hintText: '🔍 Buscar...',
          hintStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryLight,
          ),
          suffixIcon: _columnSearchQueries[columnIndex]?.isNotEmpty == true
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 14),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    _columnSearchControllers[columnIndex]?.clear();
                    setState(() {
                      _columnSearchQueries[columnIndex] = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.gray300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.gray300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildHeaderCell(ExcelColumnFiltered column, int columnIndex) {
    final bool isSorted = _sortColumnIndex == columnIndex;
    // hasFilter variable removed - was unused after filter button was commented out
    final double width = column.width ?? column.minWidth ?? 150;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.paddingSmall,
      ),
      child: Row(
        children: <Widget>[
          // Texto del header
          Expanded(
            child: InkWell(
              onTap: column.sortable ? () => _toggleSort(columnIndex) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,  // ✅ Centrado como en trayectos
                children: <Widget>[
                  Flexible(
                    child: Text(
                      column.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(  // ✅ Texto blanco en header azul
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (column.sortable) ...<Widget>[
                    const SizedBox(width: 4),
                    Icon(
                      isSorted
                          ? (_sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward)
                          : Icons.unfold_more,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.8),  // ✅ Icono blanco semi-transparente
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Botón de filtro
          // if (column.filterable)
          //   PopupMenuButton<String>(
          //     icon: Icon(
          //       hasFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
          //       size: 16,
          //       color: hasFilter ? Colors.white : Colors.white.withValues(alpha: 0.8),  // ✅ Icono blanco
          //     ),
          //     tooltip: 'Filtrar',
          //     onSelected: (String value) {
          //       _toggleColumnFilter(columnIndex, value);
          //     },
          //     itemBuilder: (BuildContext context) {
          //       final Set<String> uniqueValues = _getUniqueValuesForColumn(columnIndex);
          //       final Set<String> selectedValues = _columnFilters[columnIndex] ?? <String>{};

          //       return <PopupMenuEntry<String>>[
          //         // Header del menú
          //         PopupMenuItem<String>(
          //           enabled: false,
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: <Widget>[
          //               Text(
          //                 'Filtrar ${column.label}',
          //                 style: const TextStyle(
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 12,
          //                 ),
          //               ),
          //               if (selectedValues.isNotEmpty)
          //                 TextButton(
          //                   onPressed: () {
          //                     Navigator.pop(context);
          //                     _clearColumnFilter(columnIndex);
          //                   },
          //                   style: TextButton.styleFrom(
          //                     padding: EdgeInsets.zero,
          //                     minimumSize: const Size(50, 20),
          //                   ),
          //                   child: const Text(
          //                     'Limpiar',
          //                     style: TextStyle(fontSize: 11),
          //                   ),
          //                 ),
          //             ],
          //           ),
          //         ),
          //         const PopupMenuDivider(),

          //         // Lista de valores
          //         ...uniqueValues.map((String value) {
          //           final bool isSelected = selectedValues.contains(value);
          //           return CheckedPopupMenuItem<String>(
          //             value: value,
          //             checked: isSelected,
          //             child: Text(
          //               value.isEmpty ? '(Vacío)' : value,
          //               style: TextStyle(
          //                 fontSize: 13,
          //                 color: isSelected ? AppColors.primary : null,
          //               ),
          //             ),
          //           );
          //         }),
          //       ];
          //     },
          //   ),
        ],
      ),
    );
  }

  Widget _buildRow(T item, int index) {
    final bool isSelected = widget.selectedItem != null &&
        widget.getItemId != null &&
        widget.getItemId!(item) == widget.getItemId!(widget.selectedItem as T);

    return _ExcelDataRow<T>(
      item: item,
      index: index,
      columns: widget.columns,
      cells: widget.buildCells(item),
      rowHeight: widget.rowHeight,
      hasActions: _hasActions,
      actionsCount: _actionsCount,
      onRowTap: widget.onRowTap,
      onView: widget.onView,
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
      isSelected: isSelected,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              _columnFilters.isNotEmpty || _columnSearchQueries.values.any((String q) => q.isNotEmpty)
                  ? Icons.search_off
                  : Icons.inbox_outlined,
              size: 64,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              _columnFilters.isNotEmpty || _columnSearchQueries.values.any((String q) => q.isNotEmpty)
                  ? 'No se encontraron resultados con los filtros aplicados'
                  : widget.emptyMessage,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            if (_columnFilters.isNotEmpty || _columnSearchQueries.values.any((String q) => q.isNotEmpty)) ...<Widget>[
              const SizedBox(height: AppSizes.spacing),
              OutlinedButton.icon(
                onPressed: _clearAllFilters,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Limpiar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Definición de columna con capacidad de filtrado y búsqueda
class ExcelColumnFiltered {
  const ExcelColumnFiltered({
    required this.label,
    this.width,
    this.minWidth,
    this.sortable = false,
    this.filterable = false,
    this.searchable = false,
  });

  final String label;
  final double? width;
  final double? minWidth;
  final bool sortable;
  final bool filterable;
  final bool searchable;
}

/// Fila de datos con hover azul visible y selección
class _ExcelDataRow<T> extends StatefulWidget {
  const _ExcelDataRow({
    required this.item,
    required this.index,
    required this.columns,
    required this.cells,
    required this.rowHeight,
    required this.hasActions,
    required this.actionsCount,
    this.onRowTap,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
  });

  final T item;
  final int index;
  final List<ExcelColumnFiltered> columns;
  final List<Widget> cells;
  final double rowHeight;
  final bool hasActions;
  final int actionsCount;
  final void Function(T)? onRowTap;
  final void Function(T)? onView;
  final void Function(T)? onEdit;
  final void Function(T)? onDelete;
  final bool isSelected;

  @override
  State<_ExcelDataRow<T>> createState() => _ExcelDataRowState<T>();
}

class _ExcelDataRowState<T> extends State<_ExcelDataRow<T>> {
  @override
  Widget build(BuildContext context) {
    final bool isEven = widget.index.isEven;

    return GestureDetector(
      onTap: widget.onRowTap != null ? () => widget.onRowTap!(widget.item) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSmall,
          // vertical: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppColors.primary.withValues(alpha: 0.15)  // ✅ Selección como en trayectos
              : (isEven ? AppColors.surfaceLight : Colors.white),  // ✅ Alternancia como en trayectos
          border: Border(
            bottom: const BorderSide(color: AppColors.gray200),  // ✅ Border inferior
            left: widget.isSelected
                ? const BorderSide(color: AppColors.primary, width: 3)  // ✅ Borde izquierdo azul cuando está seleccionado
                : BorderSide.none,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              // Celdas de datos con ancho fijo (igual que el header)
              ...widget.cells.asMap().entries.map((MapEntry<int, Widget> entry) {
                final int cellIndex = entry.key;
                final Widget cell = entry.value;
                final ExcelColumnFiltered column = widget.columns[cellIndex];
                final double width = column.width ?? column.minWidth ?? 150;

                // ✅ Usar SizedBox con ancho fijo para coincidir con el header
                return SizedBox(
                  width: width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 10,  // ✅ Texto más pequeño como en trayectos
                        color: AppColors.textPrimaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,  // ✅ Evitar que se corte el texto
                      child: cell,
                    ),
                  ),
                );
              }),

              // Acciones
              if (widget.hasActions)
                SizedBox(
                  width: 50.0 * widget.actionsCount,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (widget.onView != null)
                        _ActionButton(
                          icon: Icons.visibility_outlined,
                          color: AppColors.info,
                          tooltip: 'Ver',
                          onPressed: () => widget.onView!(widget.item),
                        ),
                      if (widget.onEdit != null)
                        _ActionButton(
                          icon: Icons.edit_outlined,
                          color: AppColors.secondaryLight,
                          tooltip: 'Editar',
                          onPressed: () => widget.onEdit!(widget.item),
                        ),
                      if (widget.onDelete != null)
                        _ActionButton(
                          icon: Icons.delete_outline,
                          color: AppColors.error,
                          tooltip: 'Eliminar',
                          onPressed: () => widget.onDelete!(widget.item),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón de acción
class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
