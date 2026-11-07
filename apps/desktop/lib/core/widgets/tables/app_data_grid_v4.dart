import 'package:ambutrack_desktop/core/theme/app_colors.dart';
import 'package:ambutrack_desktop/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DataTable simplificada y optimizada para alto rendimiento
///
/// @deprecated Use AppDataGridV5 instead. This version is kept for legacy compatibility only.
/// Reason: AppDataGridV5 uses ListView.builder for better performance with large datasets (lazy loading).
///
/// - Ocupa todo el ancho disponible
/// - Diseño minimalista
/// - Optimizada para grandes volúmenes de datos
/// - Sin animaciones ni efectos complejos
class AppDataGridV4<T> extends StatelessWidget {
  const AppDataGridV4({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.emptyMessage = 'No hay datos disponibles',
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.showBorders = true,
    this.headerColor,
    this.rowHeight = 48.0,
    this.headerHeight = 56.0,
    this.borderRadius = 12.0,
  });

  final List<DataGridColumn> columns;
  final List<DataGridRow<T>> rows;
  final void Function(T data)? onRowTap;
  final void Function(T data)? onView;
  final void Function(T data)? onEdit;
  final void Function(T data)? onDelete;
  final String emptyMessage;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, {required bool ascending})? onSort;
  final bool showBorders;
  final Color? headerColor;
  final double rowHeight;
  final double headerHeight;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
              ),
              child: Table(
                columnWidths: _buildColumnWidths(),
                border: showBorders
                    ? const TableBorder.symmetric(
                        inside: BorderSide(
                          color: AppColors.gray200,
                        ),
                      )
                    : null,
                children: <TableRow>[
                  _buildHeader(),
                  ...rows.map(_buildRow),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Verifica si hay acciones configuradas (solo Editar/Eliminar)
  bool get _hasActions => onEdit != null || onDelete != null;

  /// Cuenta el número de acciones (solo Editar/Eliminar)
  int get _actionsCount {
    int count = 0;
    if (onEdit != null) {
      count++;
    }
    if (onDelete != null) {
      count++;
    }
    return count;
  }

  /// Construye configuración de anchos de columna
  Map<int, TableColumnWidth> _buildColumnWidths() {
    final Map<int, TableColumnWidth> widths = <int, TableColumnWidth>{};

    for (int i = 0; i < columns.length; i++) {
      final DataGridColumn column = columns[i];

      if (column.fixedWidth != null) {
        widths[i] = FixedColumnWidth(column.fixedWidth!);
      } else if (column.flexWidth != null) {
        widths[i] = FlexColumnWidth(column.flexWidth!);
      } else {
        // Por defecto: distribución equitativa
        widths[i] = const FlexColumnWidth();
      }
    }

    // Columna de acciones con ancho fijo
    if (_hasActions) {
      widths[columns.length] = FixedColumnWidth(50.0 * _actionsCount);
    }

    return widths;
  }

  /// Construye header de la tabla
  TableRow _buildHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: headerColor ?? AppColors.gray50,
        border: showBorders
            ? const Border(
                bottom: BorderSide(
                  color: AppColors.gray200,
                ),
              )
            : null,
      ),
      children: <Widget>[
        // Columnas normales
        ...columns.asMap().entries.map((MapEntry<int, DataGridColumn> entry) {
          final int index = entry.key;
          final DataGridColumn column = entry.value;

          return _DataGridHeaderCell(
            column: column,
            columnIndex: index,
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscending,
            onSort: onSort,
            height: headerHeight,
          );
        }),
        // Columna de acciones si hay acciones definidas
        if (_hasActions)
          Container(
            height: headerHeight,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: Text(
              'ACCIONES',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }

  /// Construye fila de datos
  TableRow _buildRow(DataGridRow<T> row) {
    return TableRow(
      decoration: BoxDecoration(
        color: row.backgroundColor ?? Colors.white,
        border: showBorders
            ? const Border(
                bottom: BorderSide(
                  color: AppColors.gray100,
                ),
              )
            : null,
      ),
      children: <Widget>[
        // Celdas normales
        ...row.cells.map((DataGridCell cell) {
          return InkWell(
            onTap: onView != null
                ? () => onView!(row.data)
                : (onRowTap != null ? () => onRowTap!(row.data) : null),
            child: Container(
              height: rowHeight,
              alignment: cell.alignment ?? Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              child: cell.child,
            ),
          );
        }),
        // Celda de acciones si hay acciones definidas
        if (_hasActions) _buildActionsCell(row.data),
      ],
    );
  }

  /// Construye celda de acciones (solo Editar/Eliminar)
  Widget _buildActionsCell(T data) {
    return Container(
      height: rowHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (onEdit != null) ...<Widget>[
            _ActionButton(
              icon: Icons.edit_outlined,
              color: AppColors.info,
              tooltip: 'Editar',
              onPressed: () => onEdit!(data),
            ),
            const SizedBox(width: AppSizes.spacingSmall),
          ],
          if (onDelete != null)
            _ActionButton(
              icon: Icons.delete_outline,
              color: AppColors.error,
              tooltip: 'Eliminar',
              onPressed: () async {
                // Delay para evitar propagación de eventos
                await Future<void>.delayed(const Duration(milliseconds: 50));
                onDelete!(data);
              },
            ),
        ],
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(
            emptyMessage,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Definición de columna
class DataGridColumn {
  const DataGridColumn({
    required this.label,
    this.sortable = false,
    this.fixedWidth,
    this.flexWidth,
    this.alignment = Alignment.centerLeft,
  }) : assert(
          fixedWidth == null || flexWidth == null,
          'No se puede definir fixedWidth y flexWidth al mismo tiempo',
        );

  final String label;
  final bool sortable;
  final double? fixedWidth;
  final double? flexWidth;
  final Alignment alignment;
}

/// Fila de datos
class DataGridRow<T> {
  const DataGridRow({
    required this.data,
    required this.cells,
    this.backgroundColor,
  });

  final T data;
  final List<DataGridCell> cells;
  final Color? backgroundColor;
}

/// Celda de datos
class DataGridCell {
  const DataGridCell({
    required this.child,
    this.alignment,
  });

  final Widget child;
  final Alignment? alignment;
}

/// Header cell con sort opcional
class _DataGridHeaderCell extends StatelessWidget {
  const _DataGridHeaderCell({
    required this.column,
    required this.columnIndex,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.height,
  });

  final DataGridColumn column;
  final int columnIndex;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, {required bool ascending})? onSort;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool isSorted = sortColumnIndex == columnIndex;

    Widget content = Text(
      column.label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.gray600,
        letterSpacing: 0.5,
      ),
      overflow: TextOverflow.ellipsis,
    );

    if (column.sortable) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(child: content),
          const SizedBox(width: 4),
          Icon(
            isSorted
                ? (sortAscending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward)
                : Icons.unfold_more,
            size: 16,
            color: isSorted
                ? AppColors.gray700
                : AppColors.gray400,
          ),
        ],
      );
    }

    return InkWell(
      onTap: column.sortable && onSort != null
          ? () {
              final bool newAscending = isSorted ? !sortAscending : true;
              onSort!(columnIndex, ascending: newAscending);
            }
          : null,
      child: Container(
        height: height,
        alignment: column.alignment,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        child: content,
      ),
    );
  }
}

/// Botón de acción en tabla
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
    // Determinar colores según el tipo de acción
    final bool isDelete = widget.tooltip.toLowerCase().contains('eliminar');
    final Color hoverBg = isDelete
        ? AppColors.actionDeleteHoverBg
        : AppColors.actionEditHoverBg;
    final Color hoverIconColor = isDelete
        ? AppColors.actionDeleteHoverIcon
        : AppColors.actionEditHoverIcon;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _isHovered ? hoverBg : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              size: 18,
              color: _isHovered ? hoverIconColor : AppColors.actionIconDefault,
            ),
          ),
        ),
      ),
    );
  }
}
