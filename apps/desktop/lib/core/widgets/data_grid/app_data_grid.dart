import 'package:ambutrack_desktop/core/theme/app_colors.dart';
import 'package:ambutrack_desktop/core/theme/app_sizes.dart';
import 'package:ambutrack_desktop/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget de DataGrid responsivo estándar para toda la aplicación
///
/// Características:
/// - Responsivo para todo tipo de pantallas
/// - Ocupa todo el ancho disponible
/// - Scroll horizontal automático en pantallas pequeñas
/// - Estilos consistentes con AppColors
/// - Header opcional con título y acciones
/// - Estado vacío personalizable
class AppDataGrid<T> extends StatefulWidget {
  const AppDataGrid({
    required this.columns,
    required this.rows,
    super.key,
    this.title,
    this.headerActions,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'No hay datos',
    this.emptySubtitle,
    this.onRowTap,
    this.showBorder = true,
    this.showHeader = true,
    this.showActions = false,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
  });

  /// Título del DataGrid (opcional)
  final String? title;

  /// Acciones del header (opcional)
  final List<Widget>? headerActions;

  /// Columnas del DataGrid
  final List<AppDataColumn> columns;

  /// Filas del DataGrid
  final List<AppDataRow<T>> rows;

  /// Icono para estado vacío
  final IconData emptyIcon;

  /// Título para estado vacío
  final String emptyTitle;

  /// Subtítulo para estado vacío (opcional)
  final String? emptySubtitle;

  /// Callback cuando se toca una fila (opcional)
  final void Function(T data)? onRowTap;

  /// Mostrar borde alrededor del DataGrid
  final bool showBorder;

  /// Mostrar header con título y acciones
  final bool showHeader;

  /// Mostrar columna de acciones
  final bool showActions;

  /// Callback para ver fila
  final void Function(T data)? onView;

  /// Callback para editar fila
  final void Function(T data)? onEdit;

  /// Callback para borrar fila
  final void Function(T data)? onDelete;

  /// Índice de la columna por la que se está ordenando
  final int? sortColumnIndex;

  /// Dirección del ordenamiento (true = ascendente, false = descendente)
  final bool sortAscending;

  /// Callback cuando se hace clic en una columna ordenable
  final void Function(int columnIndex, {required bool ascending})? onSort;

  @override
  State<AppDataGrid<T>> createState() => _AppDataGridState<T>();
}

class _AppDataGridState<T> extends State<AppDataGrid<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.showBorder ? BorderRadius.circular(AppSizes.radius) : null,
        border: widget.showBorder ? Border.all(color: AppColors.gray200) : null,
        boxShadow: widget.showBorder
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.gray900.withValues(alpha: 0.05),
                  blurRadius: AppSizes.shadowSmall,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header opcional
          if (widget.showHeader && (widget.title != null || widget.headerActions != null)) ...<Widget>[
            _buildHeader(),
            const Divider(height: 1),
          ],

          // Contenido: tabla o estado vacío
          if (widget.rows.isEmpty)
            _buildEmptyState()
          else
            _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Row(
        children: <Widget>[
          if (widget.title != null)
            Expanded(
              child: Text(
                widget.title!,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
          if (widget.headerActions != null) ...widget.headerActions!,
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXl * 2),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(widget.emptyIcon, size: 64, color: AppColors.gray400),
            const SizedBox(height: AppSizes.spacing),
            Text(
              widget.emptyTitle,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
              ),
            ),
            if (widget.emptySubtitle != null) ...<Widget>[
              const SizedBox(height: AppSizes.spacingSmall),
              Text(
                widget.emptySubtitle!,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.primarySurface),
              columnSpacing: AppSizes.spacingLarge,
              horizontalMargin: AppSizes.paddingLarge,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 80,
              sortColumnIndex: widget.sortColumnIndex,
              sortAscending: widget.sortAscending,
              columns: <DataColumn>[
                ...widget.columns.asMap().entries.map(
                  (MapEntry<int, AppDataColumn> entry) {
                    final int index = entry.key;
                    final AppDataColumn col = entry.value;

                    return DataColumn(
                      label: Text(
                        col.label,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.fontSmall,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      numeric: col.numeric,
                      onSort: col.sortable && widget.onSort != null
                          ? (int columnIndex, bool ascending) {
                              widget.onSort!(index, ascending: ascending);
                            }
                          : null,
                    );
                  },
                ),
                if (widget.showActions)
                  DataColumn(
                    label: Text(
                      'Acciones',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
              ],
              rows: widget.rows
                  .map(
                    (AppDataRow<T> row) => DataRow(
                      cells: <DataCell>[
                        ...row.cells.map(DataCell.new),
                        if (widget.showActions)
                          DataCell(
                            _buildActions(row.data),
                          ),
                      ],
                      onSelectChanged: widget.onRowTap != null ? (_) => widget.onRowTap!(row.data) : null,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  /// Construye los botones de acción para cada fila
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
                // Esperar un frame para evitar propagación de eventos
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
}

/// Definición de columna para AppDataGrid
class AppDataColumn {
  const AppDataColumn({
    required this.label,
    this.numeric = false,
    this.sortable = false,
    this.sortKey,
  });

  /// Etiqueta de la columna
  final String label;

  /// Si la columna es numérica
  final bool numeric;

  /// Si la columna permite ordenamiento
  final bool sortable;

  /// Clave para ordenar (si es diferente del label)
  final String? sortKey;
}

/// Definición de fila para AppDataGrid
class AppDataRow<T> {
  const AppDataRow({
    required this.data,
    required this.cells,
  });

  /// Datos asociados a la fila
  final T data;

  /// Celdas de la fila
  final List<Widget> cells;
}

/// Helper para crear celdas con texto simple
class AppDataCell {
  /// Celda con texto simple
  static Widget text(
    String text, {
    FontWeight? fontWeight,
    Color? color,
    double? fontSize,
  }) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontWeight: fontWeight,
        color: color ?? AppColors.textPrimaryLight,
        fontSize: fontSize ?? AppSizes.fontSmall,
      ),
    );
  }

  /// Celda con badge/etiqueta de estado
  static Widget badge(
    String label, {
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Celda con chip pequeño
  static Widget chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Celda con columna de textos (título + subtítulo)
  static Widget column({
    required String title,
    String? subtitle,
    FontWeight? titleWeight,
    Color? subtitleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: titleWeight ?? FontWeight.w600,
            fontSize: AppSizes.fontSmall,
            color: AppColors.textPrimaryLight,
          ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: subtitleColor ?? AppColors.gray600,
            ),
          ),
        ],
      ],
    );
  }

  /// Celda con múltiples líneas de texto
  static Widget multiline(
    String text, {
    int maxLines = 2,
    double? width,
  }) {
    return SizedBox(
      width: width ?? 200,
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: AppSizes.fontSmall,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}
