import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DataTable moderna V2 - Diseño minimalista y profesional
///
/// Inspirado en diseños financieros/bancarios modernos
/// Características:
/// - Diseño limpio sin bordes gruesos
/// - Filas con hover sutil
/// - Acciones a la derecha (View/Edit/Delete)
/// - Columnas sortables con indicador
/// - Estado vacío elegante
class ModernDataTableV2<T> extends StatefulWidget {
  const ModernDataTableV2({
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.onEdit,
    this.onDelete,
    this.onView,
    this.showActions = true,
    this.emptyMessage = 'No hay datos disponibles',
    this.emptyIcon = Icons.inbox_outlined,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    super.key,
  });

  final List<ModernDataColumnV2> columns;
  final List<ModernDataRowV2<T>> rows;
  final void Function(T data)? onRowTap;
  final void Function(T data)? onEdit;
  final void Function(T data)? onDelete;
  final void Function(T data)? onView;
  final bool showActions;
  final String emptyMessage;
  final IconData emptyIcon;
  final int? sortColumnIndex;
  final bool sortAscending;
  // ignore: avoid_positional_boolean_parameters
  final void Function(int columnIndex, bool ascending)? onSort;

  @override
  State<ModernDataTableV2<T>> createState() => _ModernDataTableV2State<T>();
}

class _ModernDataTableV2State<T> extends State<ModernDataTableV2<T>> {
  T? _hoveredRow;

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) {
      return _buildEmptyState();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLarge,
        vertical: AppSizes.paddingMedium,
      ),
      child: Row(
        children: <Widget>[
          // Columnas de datos
          ...List<Widget>.generate(widget.columns.length, (int index) {
            final ModernDataColumnV2 column = widget.columns[index];
            final bool isSorted = widget.sortColumnIndex == index;
            final bool canSort = column.sortable && widget.onSort != null;

            return Expanded(
              flex: column.flex,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: InkWell(
                  onTap: canSort
                      ? () => widget.onSort!(index, isSorted ? !widget.sortAscending : true)
                      : null,
                  child: Row(
                    children: <Widget>[
                      Text(
                        column.label,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryLight,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (canSort) ...<Widget>[
                        const SizedBox(width: 4),
                        Icon(
                          isSorted
                              ? (widget.sortAscending
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
              ),
            );
          }),

          // Columna de acciones (si está habilitada)
          if (widget.showActions)
            const SizedBox(
              width: 120,
              child: Text(
                'ACCIONES',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                  letterSpacing: 0.3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.rows.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.gray200,
        indent: 0,
        endIndent: 0,
      ),
      itemBuilder: (BuildContext context, int index) {
        final ModernDataRowV2<T> row = widget.rows[index];
        final bool isHovered = _hoveredRow == row.data;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredRow = row.data),
          onExit: (_) => setState(() => _hoveredRow = null),
          child: InkWell(
            onTap: widget.onRowTap != null ? () => widget.onRowTap!(row.data) : null,
            child: Container(
              color: isHovered
                  ? AppColors.gray50.withValues(alpha: 0.5)
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLarge,
                vertical: AppSizes.paddingMedium + 4,
              ),
              child: Row(
                children: <Widget>[
                  // Celdas de datos
                  ...List<Widget>.generate(widget.columns.length, (int colIndex) {
                    final ModernDataColumnV2 column = widget.columns[colIndex];
                    return Expanded(
                      flex: column.flex,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: row.cells[colIndex],
                      ),
                    );
                  }),

                  // Acciones a la derecha
                  if (widget.showActions)
                    SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          if (widget.onView != null) ...<Widget>[
                            Tooltip(
                              message: 'Ver',
                              child: AppIconButton(
                                icon: Icons.visibility_outlined,
                                onPressed: () => widget.onView!(row.data),
                                color: AppColors.info,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (widget.onEdit != null) ...<Widget>[
                            Tooltip(
                              message: 'Editar',
                              child: AppIconButton(
                                icon: Icons.edit_outlined,
                                onPressed: () => widget.onEdit!(row.data),
                                color: AppColors.secondaryLight,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (widget.onDelete != null)
                            Tooltip(
                              message: 'Eliminar',
                              child: AppIconButton(
                                icon: Icons.delete_outline,
                                onPressed: () async {
                                  await Future<void>.delayed(
                                    const Duration(milliseconds: 50),
                                  );
                                  widget.onDelete!(row.data);
                                },
                                color: AppColors.error,
                                size: 36,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl * 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              widget.emptyIcon,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              widget.emptyMessage,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Columna de ModernDataTableV2
class ModernDataColumnV2 {
  const ModernDataColumnV2({
    required this.label,
    this.sortable = false,
    this.flex = 1,
  });

  final String label;
  final bool sortable;
  final int flex;
}

/// Fila de ModernDataTableV2
class ModernDataRowV2<T> {
  const ModernDataRowV2({
    required this.data,
    required this.cells,
  });

  final T data;
  final List<Widget> cells;
}
