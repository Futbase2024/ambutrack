import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Tabla estándar unificada para toda la aplicación
///
/// ESTILO (basado en diseño de referencia):
/// - Fondo de filas: #FFFFFF
/// - Fondo de cabecera: #F0F2F5
/// - Texto cabecera: #333333, bold (600), 14px
/// - Texto datos: #666666, regular (400), 14px
/// - Bordes: #E0E0E0, 1px
/// - Padding: 12px vertical, 16px horizontal
/// - Sin zebra striping
/// - Esquinas cuadradas (0px radius)
/// - Altura de fila: 48px
/// - Altura de cabecera: 48px
///
/// CARACTERÍSTICAS:
/// - Usa ListView.builder para alto rendimiento
/// - Header fijo (siempre visible)
/// - Soporte para ordenamiento
/// - Acciones (ver, editar, eliminar)
/// - Acciones personalizadas
/// - Estado vacío optimizado
/// - Diseño limpio y profesional
///
/// USO:
/// ```dart
/// AppStandardTable<VehiculoEntity>(
///   columns: columns,
///   rows: vehiculos,
///   buildCells: (vehiculo) => [
///     StandardTableCell(child: Text(vehiculo.matricula)),
///     StandardTableCell(child: Text(vehiculo.modelo)),
///     // ...
///   ],
///   onEdit: (vehiculo) => _editar(vehiculo),
///   onDelete: (vehiculo) => _eliminar(vehiculo),
/// )
/// ```
class AppStandardTable<T> extends StatelessWidget {
  const AppStandardTable({
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
    this.emptyIcon,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.showBorders = true,
    this.headerColor,
    this.rowHeight = 48.0,
    this.headerHeight = 48.0,
  });

  final List<StandardTableColumn> columns;
  final List<T> rows;
  final List<StandardTableCell> Function(T item) buildCells;
  final void Function(T data)? onRowTap;
  final void Function(T data)? onView;
  final void Function(T data)? onEdit;
  final void Function(T data)? onDelete;
  final List<CustomAction<T>> customActions;
  final String emptyMessage;
  final IconData? emptyIcon;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, {required bool ascending})? onSort;
  final bool showBorders;
  final Color? headerColor;
  final double rowHeight;
  final double headerHeight;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return _buildEmptyState(context);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: showBorders
            ? Border.all(
                color: AppColors.tableBorder,
              )
            : null,
      ),
      child: Column(
        children: <Widget>[
          // Header fijo
          _buildHeader(),

          // Lista con lazy loading
          Expanded(
            child: ListView.builder(
              itemCount: rows.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildRow(
                  rows[index],
                  index,
                  isLastRow: index == rows.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Verifica si hay acciones configuradas
  bool get _hasActions =>
      onView != null || onEdit != null || onDelete != null || customActions.isNotEmpty;

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

  /// Construye header con estilo estándar
  Widget _buildHeader() {
    final Color resolvedHeaderColor = headerColor ?? AppColors.tableHeaderBg;

    return Container(
      height: headerHeight,
      decoration: BoxDecoration(
        color: resolvedHeaderColor,
        border: showBorders
            ? const Border(
                bottom: BorderSide(
                  color: AppColors.tableBorder,
                ),
              )
            : null,
      ),
      child: Row(
        children: <Widget>[
          // Columnas normales
          ...columns.asMap().entries.map((MapEntry<int, StandardTableColumn> entry) {
            final int index = entry.key;
            final StandardTableColumn column = entry.value;

            return Expanded(
              flex: column.flexWidth?.toInt() ?? 1,
              child: _StandardHeaderCell(
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
              width: 40.0 * _actionsCount,
              child: Center(
                child: Text(
                  'ACCIONES',
                  style: AppTextStyles.standardTableHeader,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Construye fila con estilo estándar
  Widget _buildRow(
    T item,
    int index, {
    required bool isLastRow,
  }) {
    final List<StandardTableCell> cells = buildCells(item);

    return InkWell(
      onTap: onRowTap != null ? () => onRowTap!(item) : null,
      child: Container(
        height: rowHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          border: showBorders
              ? Border(
                  bottom: isLastRow
                      ? BorderSide.none
                      : const BorderSide(
                          color: AppColors.tableBorder,
                        ),
                )
              : null,
        ),
        child: Row(
          children: <Widget>[
            // Celdas de datos
            ...cells.asMap().entries.map((MapEntry<int, StandardTableCell> entry) {
              final int cellIndex = entry.key;
              final StandardTableCell cell = entry.value;
              final StandardTableColumn column = columns[cellIndex];

              return Expanded(
                flex: column.flexWidth?.toInt() ?? 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  alignment: cell.alignment ?? Alignment.centerLeft,
                  child: DefaultTextStyle(
                    style: AppTextStyles.standardTableCell,
                    child: cell.child,
                  ),
                ),
              );
            }),

            // Columna de acciones
            if (_hasActions)
              SizedBox(
                width: 40.0 * _actionsCount,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (onView != null)
                      _StandardActionButton(
                        icon: Icons.visibility_outlined,
                        tooltip: 'Ver',
                        onPressed: () => onView!(item),
                      ),
                    if (onView != null && (onEdit != null || onDelete != null || customActions.isNotEmpty))
                      const SizedBox(width: 4),
                    if (onEdit != null)
                      _StandardActionButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Editar',
                        onPressed: () => onEdit!(item),
                      ),
                    if (onEdit != null && (onDelete != null || customActions.isNotEmpty))
                      const SizedBox(width: 4),
                    // Acciones personalizadas
                    ...customActions.asMap().entries.expand(
                      (MapEntry<int, CustomAction<T>> entry) {
                        final int idx = entry.key;
                        final CustomAction<T> action = entry.value;
                        return <Widget>[
                          _StandardActionButton(
                            icon: action.icon,
                            tooltip: action.tooltip,
                            onPressed: () => action.onPressed(item),
                          ),
                          if (idx < customActions.length - 1 || onDelete != null)
                            const SizedBox(width: 4),
                        ];
                      },
                    ),
                    if (onDelete != null)
                      _StandardActionButton(
                        icon: Icons.delete_outline,
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

  /// Estado vacío con estilo estándar
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        border: showBorders
            ? Border.all(
                color: AppColors.tableBorder,
              )
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              emptyIcon ?? Icons.inbox_outlined,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              emptyMessage,
              style: AppTextStyles.standardTableCell,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Header cell con estilo estándar
class _StandardHeaderCell extends StatelessWidget {
  const _StandardHeaderCell({
    required this.column,
    required this.columnIndex,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
  });

  final StandardTableColumn column;
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
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        alignment: column.alignment ?? Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Text(
                column.label,
                style: AppTextStyles.standardTableHeader,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (column.sortable && onSort != null) ...<Widget>[
              const SizedBox(width: 4),
              Icon(
                isSorted
                    ? (sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                    : Icons.unfold_more,
                size: 16,
                color: isSorted ? AppColors.primary : AppColors.gray500,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Botón de acción con estilo estándar
class _StandardActionButton extends StatefulWidget {
  const _StandardActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  State<_StandardActionButton> createState() => _StandardActionButtonState();
}

class _StandardActionButtonState extends State<_StandardActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isHovered ? AppColors.gray100 : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              size: 16,
              color: _isHovered ? AppColors.gray700 : AppColors.gray500,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MODELOS
// ============================================================================

/// Definición de columna estándar
class StandardTableColumn {
  const StandardTableColumn({
    required this.label,
    this.sortable = false,
    this.fixedWidth,
    this.flexWidth,
    this.alignment,
  });

  final String label;
  final bool sortable;
  final double? fixedWidth;
  final double? flexWidth;
  final AlignmentGeometry? alignment;
}

/// Celda de datos estándar
class StandardTableCell {
  const StandardTableCell({
    required this.child,
    this.alignment,
  });

  final Widget child;
  final AlignmentGeometry? alignment;
}

/// Acción personalizada para botones de acción en tabla
class CustomAction<T> {
  const CustomAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final void Function(T item) onPressed;
}
