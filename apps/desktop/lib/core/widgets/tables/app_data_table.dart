// ignore_for_file: deprecated_member_use_from_same_package

import 'package:ambutrack_desktop/core/theme/app_colors.dart';
import 'package:ambutrack_desktop/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modelo para una columna del DataTable
@Deprecated('Use DataGridColumn from app_data_grid_v5.dart instead')
class AppDataColumn {
  const AppDataColumn({
    required this.label,
    this.numeric = false,
    this.width,
  });

  final String label;
  final bool numeric;
  final double? width;
}

/// Modelo para una celda del DataTable
@Deprecated('Use DataGridCell from app_data_grid_v5.dart instead')
class AppDataCell {
  const AppDataCell({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;
}

/// Widget de DataTable común y reutilizable para toda la aplicación
///
/// @deprecated Use AppDataGridV5 instead. This version is kept for legacy compatibility only.
/// Reason: AppDataGridV5 uses ListView.builder for better performance with large datasets.
///
/// Características:
/// - Responsivo y ocupa todo el ancho disponible
/// - Scroll horizontal automático
/// - Diseño consistente con AppColors
/// - Fácil configuración de columnas y filas
///
/// Ejemplo de uso:
/// ```dart
/// AppDataTable(
///   columns: [
///     AppDataColumn(label: 'Código'),
///     AppDataColumn(label: 'Nombre'),
///     AppDataColumn(label: 'Acciones'),
///   ],
///   rows: provincias.map((p) => [
///     AppDataCell(child: Text(p.codigo ?? '-')),
///     AppDataCell(child: Text(p.nombre)),
///     AppDataCell(child: _buildAcciones(p)),
///   ]).toList(),
/// )
/// ```
class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyMessage = 'No hay datos disponibles',
    this.emptyIcon = Icons.inbox_outlined,
  });

  /// Columnas de la tabla
  final List<AppDataColumn> columns;

  /// Filas de la tabla (cada fila es una lista de celdas)
  final List<List<AppDataCell>> rows;

  /// Mensaje cuando no hay datos
  final String emptyMessage;

  /// Icono cuando no hay datos
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    // Verificar si hay datos
    if (rows.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(color: AppColors.gray200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.gray50),
                  headingRowHeight: 56,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 72,
                  columnSpacing: 24,
                  horizontalMargin: 24,
                  columns: columns.map((AppDataColumn column) {
                    return DataColumn(
                      label: Expanded(
                        child: Text(
                          column.label,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      numeric: column.numeric,
                    );
                  }).toList(),
                  rows: rows.asMap().entries.map((MapEntry<int, List<AppDataCell>> entry) {
                    final int index = entry.key;
                    final List<AppDataCell> row = entry.value;

                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.hovered)) {
                            return AppColors.gray50;
                          }
                          return index.isEven ? Colors.white : AppColors.gray50.withValues(alpha: 0.3);
                        },
                      ),
                      cells: row.map((AppDataCell cell) {
                        return DataCell(
                          cell.child,
                          onTap: cell.onTap,
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construye el estado vacío
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(emptyIcon, color: AppColors.gray400, size: 64),
          const SizedBox(height: AppSizes.spacing),
          Text(
            emptyMessage,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
