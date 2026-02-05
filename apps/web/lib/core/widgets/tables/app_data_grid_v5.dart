import 'dart:math' as math;

import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// DataGrid optimizada con ListView.builder para alto rendimiento
///
/// DIFERENCIAS CON AppDataGridV4:
/// - ✅ Usa ListView.builder (lazy loading - solo renderiza elementos visibles)
/// - ✅ Mantiene el MISMO diseño visual (header fijo, bordes, estilos)
/// - ✅ Optimizada para tablas grandes (1000+ registros sin lag)
/// - ✅ Compatible con código existente (mismos parámetros)
///
/// VENTAJAS:
/// - 🚀 Renderiza solo ~10-15 filas visibles (vs TODAS las filas en Table)
/// - ⚡ Scroll fluido incluso con 10,000+ registros
/// - 💾 Menor uso de memoria (no crea todos los widgets al inicio)
///
/// PERFORMANCE ESPERADO:
/// - 19 registros: ~200-300ms (vs 1200ms con Table)
/// - 100 registros: ~300-400ms (vs 6000ms+ con Table)
/// - 1000+ registros: ~400-500ms (vs 60000ms+ con Table)
///
/// USO:
/// ```dart
/// AppDataGridV5<PersonalEntity>(
///   columns: columns,
///   rows: data,
///   buildCells: (persona) => [...],
///   onEdit: (persona) => _editar(persona),
///   onDelete: (persona) => _eliminar(persona),
/// )
/// ```
class AppDataGridV5<T> extends StatelessWidget {
  const AppDataGridV5({
    super.key,
    required this.columns,
    required this.rows,
    required this.buildCells,
    this.onRowTap,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.customActions = const <CustomAction<Never>>[],
    this.emptyMessage = 'No hay datos disponibles',
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.showBorders = true,
    this.headerColor,
    this.rowHeight = 48.0,
    this.headerHeight = 56.0,
    this.borderRadius = 12.0,
    this.outerBorderColor,
    this.outerBorderWidth = 1.0,
  });

  final List<DataGridColumn> columns;
  final List<T> rows;
  final List<DataGridCell> Function(T item) buildCells;
  final void Function(T data)? onRowTap;
  final void Function(T data)? onView;
  final void Function(T data)? onEdit;
  final void Function(T data)? onDelete;
  final List<CustomAction<T>> customActions;
  final String emptyMessage;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, {required bool ascending})? onSort;
  final bool showBorders;
  final Color? headerColor;
  final double rowHeight;
  final double headerHeight;
  final double borderRadius;
  final Color? outerBorderColor;
  final double outerBorderWidth;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return _buildEmptyState();
    }

    final double clampedRadius = math.max(borderRadius, 0);
    final BorderRadius resolvedRadius = BorderRadius.circular(clampedRadius);

    return ClipRRect(
      borderRadius: resolvedRadius,
      child: Container(
        color: Colors.white,
        foregroundDecoration: BoxDecoration(
          borderRadius: resolvedRadius,
          border: Border.all(
            color: outerBorderColor ?? AppColors.gray200,
            width: outerBorderWidth,
          ),
        ),
        child: Column(
          children: <Widget>[
            // Header fijo (siempre visible)
            _buildHeader(borderRadius: resolvedRadius),

            // Lista con lazy loading (solo renderiza elementos visibles)
            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (BuildContext context, int index) {
                  final bool isLastRow = index == rows.length - 1;
                  final BorderRadius? rowRadius = isLastRow
                      ? BorderRadius.only(
                          bottomLeft: resolvedRadius.bottomLeft,
                          bottomRight: resolvedRadius.bottomRight,
                        )
                      : null;
                  return _buildRow(
                    rows[index],
                    index,
                    rowBorderRadius: rowRadius,
                    isLastRow: isLastRow,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Verifica si hay acciones configuradas
  bool get _hasActions => onView != null || onEdit != null || onDelete != null || customActions.isNotEmpty;

  /// Cuenta el número de acciones
  int get _actionsCount {
    int count = 0;
    if (onView != null) {
      count++;
    }
    if (onEdit != null) {
      count++;
    }
    if (onDelete != null) {
      count++;
    }
    return count + customActions.length;
  }

  /// Construye header fijo (MISMO diseño que AppDataGridV4)
  Widget _buildHeader({BorderRadius? borderRadius}) {
    return Container(
      height: headerHeight,
      decoration: BoxDecoration(
        color: headerColor ?? AppColors.gray50,
        borderRadius: borderRadius?.copyWith(
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
        border: showBorders
            ? const Border(
                bottom: BorderSide(color: AppColors.gray200),
              )
            : null,
      ),
      child: Row(
        children: <Widget>[
          // Columnas normales
          ...columns.asMap().entries.map((MapEntry<int, DataGridColumn> entry) {
            final int index = entry.key;
            final DataGridColumn column = entry.value;

            return Expanded(
              flex: column.flexWidth?.toInt() ?? 1,
              child: _DataGridHeaderCell(
                column: column,
                columnIndex: index,
                sortColumnIndex: sortColumnIndex,
                sortAscending: sortAscending,
                onSort: onSort,
              ),
            );
          }),

          // Columna de acciones
          if (_hasActions)
            SizedBox(
              width: 50.0 * _actionsCount,
              child: Center(
                child: Text(
                  'ACCIONES',
                  style: AppTextStyles.tableHeader,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Construye una fila (MISMO diseño que AppDataGridV4)
  Widget _buildRow(
    T item,
    int index, {
    BorderRadius? rowBorderRadius,
    required bool isLastRow,
  }) {
    final List<DataGridCell> cells = buildCells(item);

    return InkWell(
      onTap: onRowTap != null ? () => onRowTap!(item) : null,
      child: Container(
        height: rowHeight,
        decoration: BoxDecoration(
          color: index.isEven ? Colors.white : AppColors.gray50,
          borderRadius: rowBorderRadius,
          border: showBorders
              ? Border(
                  bottom: isLastRow
                      ? BorderSide.none
                      : const BorderSide(color: AppColors.gray200),
                )
              : null,
        ),
        child: Row(
          children: <Widget>[
            // Celdas de datos
            ...cells.asMap().entries.map((MapEntry<int, DataGridCell> entry) {
              final int cellIndex = entry.key;
              final DataGridCell cell = entry.value;
              final DataGridColumn column = columns[cellIndex];

              return Expanded(
                flex: column.flexWidth?.toInt() ?? 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSmall,
                    vertical: 4.0,
                  ),
                  child: cell.child,
                ),
              );
            }),

            // Columna de acciones
            if (_hasActions)
              SizedBox(
                width: 50.0 * _actionsCount,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (onEdit != null)
                      _ActionButton(
                        icon: Icons.edit_outlined,
                        color: AppColors.secondaryLight,
                        tooltip: 'Editar',
                        onPressed: () => onEdit!(item),
                      ),
                    if (onEdit != null && (onView != null || onDelete != null || customActions.isNotEmpty))
                      const SizedBox(width: AppSizes.spacingSmall),
                    if (onView != null)
                      _ActionButton(
                        icon: Icons.swap_horiz,
                        color: AppColors.info,
                        tooltip: 'Transferir Stock',
                        onPressed: () => onView!(item),
                      ),
                    if (onView != null && (onDelete != null || customActions.isNotEmpty))
                      const SizedBox(width: AppSizes.spacingSmall),
                    // Acciones personalizadas
                    ...customActions.asMap().entries.expand((MapEntry<int, CustomAction<T>> entry) {
                      final int idx = entry.key;
                      final CustomAction<T> action = entry.value;
                      return <Widget>[
                        _ActionButton(
                          icon: action.icon,
                          color: action.color,
                          tooltip: action.tooltip,
                          onPressed: () => action.onPressed(item),
                        ),
                        if (idx < customActions.length - 1 || onDelete != null)
                          const SizedBox(width: AppSizes.spacingSmall),
                      ];
                    }),
                    if (onDelete != null)
                      _ActionButton(
                        icon: Icons.delete_outline,
                        color: AppColors.error,
                        tooltip: 'Eliminar',
                        onPressed: () async {
                          await Future<void>.delayed(const Duration(milliseconds: 50));
                          onDelete!(item);
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Estado vacío (MISMO diseño que AppDataGridV4)
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: outerBorderColor ?? AppColors.gray200,
          width: outerBorderWidth,
        ),
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
              emptyMessage,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Header cell (MISMO diseño que AppDataGridV4)
class _DataGridHeaderCell extends StatelessWidget {
  const _DataGridHeaderCell({
    required this.column,
    required this.columnIndex,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
  });

  final DataGridColumn column;
  final int columnIndex;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, {required bool ascending})? onSort;

  @override
  Widget build(BuildContext context) {
    final bool isSorted = sortColumnIndex == columnIndex;

    return InkWell(
      onTap: column.sortable && onSort != null
          ? () => onSort!(columnIndex, ascending: isSorted ? !sortAscending : true)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSmall,
          vertical: AppSizes.paddingSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Text(
                column.label,
                style: AppTextStyles.tableHeader,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (column.sortable && onSort != null) ...<Widget>[
              const SizedBox(width: 4),
              Icon(
                isSorted
                    ? (sortAscending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward)
                    : Icons.unfold_more,
                size: 16,
                color: isSorted
                    ? AppColors.primary
                    : AppColors.textSecondaryLight,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Botón de acción (mismo estilo que ModernDataTableV3/AppDataGridV4)
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
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
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

// ============================================================================
// MODELOS (REUTILIZADOS de AppDataGridV4 para compatibilidad)
// ============================================================================

/// Definición de columna
class DataGridColumn {
  const DataGridColumn({
    required this.label,
    this.sortable = false,
    this.fixedWidth,
    this.flexWidth,
  });

  final String label;
  final bool sortable;
  final double? fixedWidth;
  final double? flexWidth;
}

/// Celda de datos
class DataGridCell {
  const DataGridCell({required this.child});

  final Widget child;
}

/// Fila de datos (NO SE USA EN V5, pero se mantiene para compatibilidad)
class DataGridRow<T> {
  const DataGridRow({
    required this.data,
    required this.cells,
  });

  final T data;
  final List<DataGridCell> cells;
}

/// Acción personalizada para botones de acción en tabla
class CustomAction<T> {
  const CustomAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final String tooltip;
  final void Function(T item) onPressed;
  final Color color;
}
