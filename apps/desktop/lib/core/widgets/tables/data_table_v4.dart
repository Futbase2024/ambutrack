import 'package:ambutrack_desktop/core/theme/app_colors.dart';
import 'package:ambutrack_desktop/core/theme/app_sizes.dart';
import 'package:ambutrack_desktop/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DataTable v4 - Versión simplificada y optimizada
///
/// @deprecated Use AppDataGridV5 instead. This version is kept for legacy compatibility only.
/// Reason: AppDataGridV5 uses ListView.builder for better performance with large datasets.
///
/// Características:
/// - Bordes superiores redondeados
/// - Filas más compactas (altura reducida)
/// - Sin emojis para mejor rendimiento
/// - Código simplificado y eficiente
class DataTableV4<T> extends StatefulWidget {
  const DataTableV4({
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.onEdit,
    this.onDelete,
    this.onView,
    this.showActions = true,
    this.emptyMessage = 'No hay datos disponibles',
    this.alternateRowColor = true,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    super.key,
  });

  final List<DataColumnV4> columns;
  final List<DataRowV4<T>> rows;
  final void Function(T data)? onRowTap;
  final void Function(T data)? onEdit;
  final void Function(T data)? onDelete;
  final void Function(T data)? onView;
  final bool showActions;
  final String emptyMessage;
  final bool alternateRowColor;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, {required bool ascending})? onSort;

  @override
  State<DataTableV4<T>> createState() => _DataTableV4State<T>();
}

class _DataTableV4State<T> extends State<DataTableV4<T>> {
  T? _hoveredRow;

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) {
      return _buildEmptyState();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _buildHeader(),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusMedium),
          topRight: Radius.circular(AppSizes.radiusMedium),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLarge,
          vertical: AppSizes.paddingSmall, // Reducido de paddingMedium
        ),
        child: Row(
          children: <Widget>[
            ...List<Widget>.generate(widget.columns.length, (int index) {
              final DataColumnV4 column = widget.columns[index];
              final bool isSorted = widget.sortColumnIndex == index;
              final bool canSort = column.sortable && widget.onSort != null;

              return Expanded(
                flex: column.flex,
                child: canSort
                    ? InkWell(
                        onTap: () {
                          widget.onSort!(
                            index,
                            ascending: isSorted ? !widget.sortAscending : true,
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  column.label,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSorted
                                        ? AppColors.primary
                                        : AppColors.textSecondaryLight,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                isSorted
                                    ? (widget.sortAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward)
                                    : Icons.unfold_more,
                                size: 14,
                                color: isSorted
                                    ? AppColors.primary
                                    : AppColors.gray400,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Text(
                        column.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryLight,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              );
            }),
            if (widget.showActions) const SizedBox(width: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.rows.length,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 1,
          color: AppColors.gray100,
          thickness: 1,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        final DataRowV4<T> row = widget.rows[index];
        final bool isEven = index % 2 == 0;
        final bool isHovered = _hoveredRow == row.data;
        final bool isLastRow = index == widget.rows.length - 1;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredRow = row.data),
          onExit: (_) => setState(() => _hoveredRow = null),
          child: InkWell(
            onTap: widget.onRowTap != null ? () => widget.onRowTap!(row.data) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLarge,
                vertical: 10, // Reducido de paddingMedium (12) a 10
              ),
              decoration: BoxDecoration(
                color: isHovered
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : widget.alternateRowColor && !isEven
                        ? AppColors.gray50.withValues(alpha: 0.5)
                        : Colors.white,
                borderRadius: isLastRow
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(AppSizes.radiusMedium),
                        bottomRight: Radius.circular(AppSizes.radiusMedium),
                      )
                    : null,
              ),
              child: Row(
                children: <Widget>[
                  ...List<Widget>.generate(
                    row.cells.length,
                    (int cellIndex) {
                      return Expanded(
                        flex: widget.columns[cellIndex].flex,
                        child: row.cells[cellIndex],
                      );
                    },
                  ),
                  if (widget.showActions) _buildActions(row.data),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActions(T data) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.onView != null) ...<Widget>[
          Tooltip(
            message: 'Ver',
            child: AppIconButton(
              icon: Icons.visibility_outlined,
              onPressed: () => widget.onView!(data),
              color: AppColors.info,
              size: 36,
            ),
          ),
          const SizedBox(width: AppSizes.spacingSmall),
        ],
        if (widget.onEdit != null) ...<Widget>[
          Tooltip(
            message: 'Editar',
            child: AppIconButton(
              icon: Icons.edit_outlined,
              onPressed: () => widget.onEdit!(data),
              color: AppColors.secondaryLight,
              size: 36,
            ),
          ),
          const SizedBox(width: AppSizes.spacingSmall),
        ],
        if (widget.onDelete != null)
          Tooltip(
            message: 'Eliminar',
            child: AppIconButton(
              icon: Icons.delete_outline,
              onPressed: () async {
                await Future<void>.delayed(const Duration(milliseconds: 50));
                widget.onDelete!(data);
              },
              color: AppColors.error,
              size: 36,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.inbox_outlined,
                size: 48,
                color: AppColors.gray400,
              ),
              const SizedBox(height: AppSizes.spacingMedium),
              Text(
                widget.emptyMessage,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Columna del DataTable v4
class DataColumnV4 {
  const DataColumnV4({
    required this.label,
    this.flex = 1,
    this.sortable = false,
  });

  final String label;
  final int flex;
  final bool sortable;
}

/// Fila del DataTable v4
class DataRowV4<T> {
  const DataRowV4({
    required this.data,
    required this.cells,
  });

  final T data;
  final List<Widget> cells;
}
