import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/theme/app_colors.dart';

/// Tabla de datos redimensionable con persistencia de anchos de columna
class ResizableDataTable extends StatefulWidget {
  const ResizableDataTable({
    required this.columns,
    required this.rows,
    this.storageKey = 'resizable_table_widths',
    this.minColumnWidth = 40.0,
    this.defaultColumnWidth = 120.0,
    this.rowHeight = 36.0,
    this.filterRow, // Nueva propiedad para fila de filtros
    this.initialColumnWidths, // Anchos predefinidos (opcional)
    this.onRowTap, // Callback cuando se hace clic en una fila
    super.key,
  });

  final List<DataTableColumn> columns;
  final List<DataTableRow> rows;
  final String storageKey;
  final double minColumnWidth;
  final double defaultColumnWidth;
  final double rowHeight;
  final DataTableRow? filterRow; // Fila opcional de filtros
  final List<double>? initialColumnWidths; // Anchos iniciales predefinidos
  final void Function(int index)? onRowTap; // Callback para clic en fila

  @override
  State<ResizableDataTable> createState() => _ResizableDataTableState();
}

class _ResizableDataTableState extends State<ResizableDataTable> {
  late List<double> _columnWidths;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  int? _selectedRowIndex; // Índice de la fila seleccionada

  @override
  void initState() {
    super.initState();
    _initializeColumnWidths();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeColumnWidths() async {
    await _loadColumnWidths();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Carga los anchos de columna desde SharedPreferences
  Future<void> _loadColumnWidths() async {
    try {
      debugPrint('🔍 Intentando cargar anchos para key: ${widget.storageKey}');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? savedWidths = prefs.getStringList(widget.storageKey);

      debugPrint('📦 Datos guardados: $savedWidths');
      debugPrint('📊 Columnas actuales: ${widget.columns.length}');

      // Prioridad 1: Anchos guardados en SharedPreferences
      if (savedWidths != null && savedWidths.length == widget.columns.length) {
        _columnWidths = savedWidths.map(double.parse).toList();
        debugPrint('✅ Anchos de columna cargados desde storage: $_columnWidths');
        debugPrint('🔑 Storage key: ${widget.storageKey}');
        return;
      }

      // Prioridad 2: Anchos iniciales predefinidos
      if (widget.initialColumnWidths != null && widget.initialColumnWidths!.length == widget.columns.length) {
        _columnWidths = List<double>.from(widget.initialColumnWidths!);
        debugPrint('✅ Usando anchos predefinidos: $_columnWidths');
        // Guardar los anchos predefinidos para próximas veces
        await _saveColumnWidths();
        return;
      }

      // Prioridad 3: Anchos por defecto
      // El número de columnas cambió o no hay datos guardados
      if (savedWidths != null) {
        debugPrint('⚠️ Número de columnas cambió: guardado=${savedWidths.length}, actual=${widget.columns.length}');
        // Limpiar storage antiguo
        await prefs.remove(widget.storageKey);
        debugPrint('🗑️ Storage antiguo limpiado');
      } else {
        debugPrint('ℹ️ No hay datos guardados previamente');
      }

      // Usar anchos por defecto
      _columnWidths = List<double>.filled(
        widget.columns.length,
        widget.defaultColumnWidth,
      );
      debugPrint('ℹ️ Usando anchos por defecto (${widget.columns.length} columnas)');

      // Guardar los nuevos anchos por defecto
      await _saveColumnWidths();
    } catch (e) {
      debugPrint('⚠️ Error cargando anchos de columna: $e');
      _columnWidths = List<double>.filled(
        widget.columns.length,
        widget.defaultColumnWidth,
      );
    }
  }

  /// Guarda los anchos de columna en SharedPreferences
  Future<void> _saveColumnWidths() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> widthsAsStrings = _columnWidths.map((double w) => w.toString()).toList();
      final bool success = await prefs.setStringList(widget.storageKey, widthsAsStrings);

      if (success) {
        debugPrint('💾 Anchos guardados correctamente: $_columnWidths');
        debugPrint('🔑 Storage key: ${widget.storageKey}');
      } else {
        debugPrint('⚠️ No se pudo guardar en SharedPreferences');
      }
    } catch (e, stackTrace) {
      debugPrint('⚠️ Error guardando anchos de columna: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Actualiza el ancho de una columna específica
  void _updateColumnWidth(int columnIndex, double delta) {
    setState(() {
      final double newWidth = (_columnWidths[columnIndex] + delta).clamp(
        widget.minColumnWidth,
        double.infinity,
      );
      _columnWidths[columnIndex] = newWidth;
      debugPrint('📏 Columna $columnIndex ajustada a: $newWidth px');
    });
    // Guardar de forma asíncrona sin bloquear UI
    _saveColumnWidths();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Calcular el ancho total de la tabla (suma de todos los anchos de columna + resize handles)
    final double totalWidth = _columnWidths.fold<double>(0.0, (double sum, double width) => sum + width) +
                              (widget.columns.length - 1) * 8; // 8px por cada resize handle

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: 12,
      radius: const Radius.circular(6),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 16), // ✅ Espacio para ver última fila
        child: SizedBox(
          width: totalWidth, // ⭐ Forzar ancho total
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Header Row
              _buildHeaderRow(),

              // Filter Row (si existe)
              if (widget.filterRow != null) _buildFilterRow(widget.filterRow!),

              // Data Rows
              ...widget.rows.asMap().entries.map((MapEntry<int, DataTableRow> entry) {
                return _buildDataRow(entry.value, entry.key);
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la fila de encabezado
  Widget _buildHeaderRow() {
    return SizedBox(
      height: widget.rowHeight + 8, // Header un poco más alto
      child: Row(
        children: List<Widget>.generate(
          widget.columns.length,
          (int index) {
            final DataTableColumn column = widget.columns[index];
            final double width = _columnWidths[index];

            return SizedBox(
              width: width,
              child: Row(
                children: <Widget>[
                  // Header Cell
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        border: Border(
                          top: const BorderSide(color: AppColors.gray200),
                          bottom: const BorderSide(color: AppColors.gray200),
                          left: index == 0 ? const BorderSide(color: AppColors.gray200) : BorderSide.none,
                          right: const BorderSide(color: AppColors.gray200, width: 0.5),
                        ),
                      ),
                      alignment: column.alignment ?? Alignment.centerLeft,
                      child: Text(
                        column.label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: column.alignment == Alignment.center
                            ? TextAlign.center
                            : TextAlign.left,
                      ),
                    ),
                  ),

                  // Resize Handle (línea vertical sutil)
                  if (index < widget.columns.length - 1)
                    MouseRegion(
                      cursor: SystemMouseCursors.resizeColumn,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (DragUpdateDetails details) {
                          _updateColumnWidth(index, details.delta.dx);
                        },
                        child: Container(
                          width: 8,
                          height: widget.rowHeight + 8,
                          color: Colors.transparent,
                          child: Center(
                            child: Container(
                              width: 2,
                              height: widget.rowHeight + 8,
                              decoration: BoxDecoration(
                                color: AppColors.gray300,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Construye la fila de filtros (primera fila debajo del header)
  Widget _buildFilterRow(DataTableRow row) {
    return SizedBox(
      height: widget.rowHeight,
      child: Row(
        children: List<Widget>.generate(
          row.cells.length,
          (int index) {
            final DataTableCell cell = row.cells[index];
            final double width = _columnWidths[index];

            return SizedBox(
              width: width,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05), // Fondo sutil
                  border: Border(
                    bottom: const BorderSide(color: AppColors.gray300),
                    left: index == 0 ? const BorderSide(color: AppColors.gray200) : BorderSide.none,
                    right: const BorderSide(color: AppColors.gray200, width: 0.5),
                  ),
                ),
                alignment: cell.alignment ?? Alignment.center,
                child: cell.child,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Construye una fila de datos
  Widget _buildDataRow(DataTableRow row, int rowIndex) {
    // Usar selección de la fila si está definida, o la interna de la tabla
    final bool isSelected = row.isSelected || _selectedRowIndex == rowIndex;

    // Color de fondo: prioridad a backgroundColor de la fila, luego selección interna
    Color backgroundColor;
    if (row.backgroundColor != null) {
      backgroundColor = row.backgroundColor!;
    } else if (isSelected) {
      backgroundColor = AppColors.primary.withValues(alpha: 0.15);
    } else {
      backgroundColor = Colors.white;
    }

    return GestureDetector(
      onTap: () {
        // Si la fila tiene su propio onTap, usarlo
        if (row.onTap != null) {
          row.onTap!();
        } else {
          // Comportamiento por defecto: selección interna
          setState(() {
            _selectedRowIndex = rowIndex;
          });
          widget.onRowTap?.call(rowIndex);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          height: widget.rowHeight,
          child: Row(
            children: List<Widget>.generate(
              row.cells.length,
              (int index) {
                final DataTableCell cell = row.cells[index];
                final double width = _columnWidths[index];

                return SizedBox(
                  width: width,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border(
                        bottom: const BorderSide(color: AppColors.gray200, width: 0.5),
                        left: index == 0 ? const BorderSide(color: AppColors.gray200) : BorderSide.none,
                        right: const BorderSide(color: AppColors.gray200, width: 0.5),
                      ),
                    ),
                    alignment: cell.alignment ?? Alignment.centerLeft,
                    child: cell.child,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Definición de columna de tabla
class DataTableColumn {
  const DataTableColumn({
    required this.label,
    this.alignment,
  });

  final String label;
  final Alignment? alignment;
}

/// Definición de fila de tabla
class DataTableRow {
  const DataTableRow({
    required this.cells,
    this.backgroundColor,
    this.onTap,
    this.isSelected = false,
  });

  final List<DataTableCell> cells;

  /// Color de fondo personalizado para la fila (ej: para filas seleccionadas)
  final Color? backgroundColor;

  /// Callback cuando se hace clic en la fila
  final VoidCallback? onTap;

  /// Si la fila está seleccionada (para estilos visuales)
  final bool isSelected;
}

/// Definición de celda de tabla
class DataTableCell {
  const DataTableCell({
    required this.child,
    this.alignment,
  });

  final Widget child;
  final Alignment? alignment;
}
