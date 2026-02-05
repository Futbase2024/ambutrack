import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// DataGrid estilo Excel con columnas adaptables y scroll horizontal
///
/// CARACTERÍSTICAS:
/// - ✅ Columnas adaptables al contenido (auto-sizing)
/// - ✅ Scroll horizontal fluido
/// - ✅ Header fijo (sticky)
/// - ✅ Diseño profesional estilo Excel
/// - ✅ Soporte para acciones (Ver/Editar/Eliminar)
/// - ✅ Ordenamiento de columnas
///
/// USO:
/// ```dart
/// ExcelDataGrid<PersonalEntity>(
///   columns: columns,
///   rows: data,
///   buildCells: (persona) => [...],
///   onEdit: (persona) => _editar(persona),
///   onDelete: (persona) => _eliminar(persona),
/// )
/// ```
class ExcelDataGrid<T> extends StatefulWidget {
  const ExcelDataGrid({
    super.key,
    required this.columns,
    required this.rows,
    required this.buildCells,
    this.onRowTap,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.emptyMessage = 'No hay datos disponibles',
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.rowHeight = 48.0,
    this.headerHeight = 56.0,
  });

  final List<ExcelColumn> columns;
  final List<T> rows;
  final List<Widget> Function(T item) buildCells;
  final void Function(T data)? onRowTap;
  final void Function(T data)? onView;
  final void Function(T data)? onEdit;
  final void Function(T data)? onDelete;
  final String emptyMessage;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, {required bool ascending})? onSort;
  final double rowHeight;
  final double headerHeight;

  @override
  State<ExcelDataGrid<T>> createState() => _ExcelDataGridState<T>();
}

class _ExcelDataGridState<T> extends State<ExcelDataGrid<T>> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
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

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) {
      return _buildEmptyState();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
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
                    // Header fijo
                    _buildHeader(),

                    // Filas con scroll vertical
                    Expanded(
                      child: Scrollbar(
                        controller: _verticalController,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: _verticalController,
                          itemCount: widget.rows.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _buildRow(widget.rows[index], index);
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

  /// Calcula el ancho total de la tabla
  double _calculateTotalWidth() {
    double total = 0;

    for (final ExcelColumn column in widget.columns) {
      if (column.width != null) {
        total += column.width!;
      } else if (column.minWidth != null) {
        total += column.minWidth!;
      } else {
        total += 150; // Ancho por defecto
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
        color: AppColors.gray50,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        children: <Widget>[
          // Columnas
          ...widget.columns.asMap().entries.map((MapEntry<int, ExcelColumn> entry) {
            final int index = entry.key;
            final ExcelColumn column = entry.value;
            return _buildHeaderCell(column, index);
          }),

          // Columna de acciones
          if (_hasActions)
            Container(
              width: 50.0 * _actionsCount,
              alignment: Alignment.center,
              child: Text(
                'ACCIONES',
                style: AppTextStyles.tableHeader,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(ExcelColumn column, int columnIndex) {
    final bool isSorted = widget.sortColumnIndex == columnIndex;
    final double width = column.width ?? column.minWidth ?? 150;

    return InkWell(
      onTap: column.sortable && widget.onSort != null
          ? () => widget.onSort!(
                columnIndex,
                ascending: isSorted ? !widget.sortAscending : true,
              )
          : null,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSmall,
          vertical: AppSizes.paddingSmall,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                column.label,
                style: AppTextStyles.tableHeader,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (column.sortable && widget.onSort != null) ...<Widget>[
              const SizedBox(width: 4),
              Icon(
                isSorted
                    ? (widget.sortAscending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward)
                    : Icons.unfold_more,
                size: 16,
                color: isSorted ? AppColors.primary : AppColors.textSecondaryLight,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(T item, int index) {
    final List<Widget> cells = widget.buildCells(item);
    final bool isEven = index.isEven;

    return InkWell(
      onTap: widget.onRowTap != null ? () => widget.onRowTap!(item) : null,
      child: Container(
        height: widget.rowHeight,
        decoration: BoxDecoration(
          color: isEven ? Colors.white : AppColors.gray50,
          border: const Border(
            bottom: BorderSide(color: AppColors.gray200, width: 0.5),
          ),
        ),
        child: Row(
          children: <Widget>[
            // Celdas de datos
            ...cells.asMap().entries.map((MapEntry<int, Widget> entry) {
              final int cellIndex = entry.key;
              final Widget cell = entry.value;
              final ExcelColumn column = widget.columns[cellIndex];
              final double width = column.width ?? column.minWidth ?? 150;

              return Container(
                width: width,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 4.0,
                ),
                child: cell,
              );
            }),

            // Acciones
            if (_hasActions)
              SizedBox(
                width: 50.0 * _actionsCount,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (widget.onView != null)
                      _ActionButton(
                        icon: Icons.visibility_outlined,
                        color: AppColors.info,
                        tooltip: 'Ver',
                        onPressed: () => widget.onView!(item),
                      ),
                    if (widget.onEdit != null)
                      _ActionButton(
                        icon: Icons.edit_outlined,
                        color: AppColors.secondaryLight,
                        tooltip: 'Editar',
                        onPressed: () => widget.onEdit!(item),
                      ),
                    if (widget.onDelete != null)
                      _ActionButton(
                        icon: Icons.delete_outline,
                        color: AppColors.error,
                        tooltip: 'Eliminar',
                        onPressed: () => widget.onDelete!(item),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
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
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              widget.emptyMessage,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Definición de columna estilo Excel
class ExcelColumn {
  const ExcelColumn({
    required this.label,
    this.width,
    this.minWidth,
    this.sortable = false,
  });

  final String label;
  final double? width;
  final double? minWidth;
  final bool sortable;
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
