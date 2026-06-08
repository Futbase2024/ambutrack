import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Fila de datos para la tabla del dashboard
class DashboardTableRow {
  const DashboardTableRow({
    required this.id,
    required this.nombre,
    required this.identificacion,
    required this.telefono,
    required this.direccion,
    required this.estado,
    this.avatarUrl,
  });

  final String id;
  final String nombre;
  final String identificacion;
  final String telefono;
  final String direccion;
  final String estado;
  final String? avatarUrl;
}

/// Tabla de datos para el dashboard con estilo Material Design 3
///
/// Incluye:
/// - Checkbox de selección
/// - Columnas: ID, Paciente, Identificación, Teléfono, Dirección, Estado, Acciones
/// - Fila de acciones sticky a la derecha
/// - Paginación en la parte inferior
class DashboardDataTable extends StatelessWidget {
  const DashboardDataTable({
    super.key,
    required this.data,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalRecords = 0,
    this.onPageChanged,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.onSelectionChanged,
  });

  final List<DashboardTableRow> data;
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<Set<String>>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Tabla con scroll horizontal
          _TableContent(
            data: data,
            onView: onView,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          // Paginación
          _TablePagination(
            currentPage: currentPage,
            totalPages: totalPages,
            totalRecords: totalRecords,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }
}

/// Contenido de la tabla con scroll horizontal
class _TableContent extends StatelessWidget {
  const _TableContent({
    required this.data,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  final List<DashboardTableRow> data;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.gray50),
        headingTextStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.gray500,
          letterSpacing: 0.5,
        ),
        dataTextStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.gray900,
        ),
        columnSpacing: 24,
        horizontalMargin: 16,
        columns: const <DataColumn>[
          DataColumn(
            label: SizedBox(
              width: 40,
              child: Checkbox(
                value: false,
                onChanged: null,
              ),
            ),
          ),
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('PACIENTE')),
          DataColumn(label: Text('IDENTIFICACIÓN')),
          DataColumn(label: Text('TELÉFONO')),
          DataColumn(label: Text('DIRECCIÓN')),
          DataColumn(
            label: Center(
              child: Text('ESTADO'),
            ),
          ),
          DataColumn(label: Text('ACCIONES')),
        ],
        rows: data.map((DashboardTableRow row) {
          return DataRow(
            cells: <DataCell>[
              DataCell(
                Checkbox(
                  value: false,
                  onChanged: (bool? value) {},
                  activeColor: AppColors.primary,
                ),
              ),
              DataCell(
                Text(
                  row.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: row.avatarUrl != null
                          ? NetworkImage(row.avatarUrl!)
                          : null,
                      backgroundColor: AppColors.gray200,
                      child: row.avatarUrl == null
                          ? Text(
                              row.nombre.isNotEmpty
                                  ? row.nombre.substring(0, 2).toUpperCase()
                                  : '??',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray600,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      row.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  row.identificacion,
                  style: const TextStyle(color: AppColors.gray600),
                ),
              ),
              DataCell(
                Text(
                  row.telefono,
                  style: const TextStyle(color: AppColors.gray600),
                ),
              ),
              DataCell(
                Text(
                  row.direccion,
                  style: const TextStyle(color: AppColors.gray500),
                ),
              ),
              DataCell(
                Center(
                  child: _EstadoBadge(estado: row.estado),
                ),
              ),
              DataCell(
                _ActionButtons(
                  onView: onView,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Badge de estado con colores según el valor
class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final (Color bgColor, Color textColor) = _getEstadoColors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  (Color, Color) _getEstadoColors() {
    final String estadoLower = estado.toLowerCase();
    if (estadoLower.contains('activo') || estadoLower.contains('disponible')) {
      return (AppColors.badgeDisponibleBg, AppColors.badgeDisponibleText);
    }
    if (estadoLower.contains('pendiente')) {
      return (AppColors.badgeMantenimientoBg, AppColors.badgeMantenimientoText);
    }
    if (estadoLower.contains('servicio') || estadoLower.contains('ruta')) {
      return (AppColors.badgeServicioBg, AppColors.badgeServicioText);
    }
    return (AppColors.badgeInactivoBg, AppColors.badgeInactivoText);
  }
}

/// Botones de acción para cada fila
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _ActionButton(
          icon: Icons.visibility_outlined,
          tooltip: 'Ver',
          color: AppColors.info,
          onPressed: onView,
        ),
        const SizedBox(width: 4),
        _ActionButton(
          icon: Icons.edit_outlined,
          tooltip: 'Editar',
          color: AppColors.secondaryLight,
          onPressed: onEdit,
        ),
        const SizedBox(width: 4),
        _ActionButton(
          icon: Icons.delete_outline,
          tooltip: 'Eliminar',
          color: AppColors.error,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

/// Botón de acción individual
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null ? color : AppColors.gray300,
          ),
        ),
      ),
    );
  }
}

/// Barra de paginación
class _TablePagination extends StatelessWidget {
  const _TablePagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(color: AppColors.gray100),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Mostrando ${(currentPage - 1) * 10 + 1}-${(currentPage * 10).clamp(0, totalRecords)} de $totalRecords registros',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.gray500,
              letterSpacing: 0.3,
            ),
          ),
          Row(
            children: <Widget>[
              // Botón anterior
              _PageButton(
                icon: Icons.chevron_left,
                onPressed: currentPage > 1
                    ? () => onPageChanged?.call(currentPage - 1)
                    : null,
              ),
              const SizedBox(width: 4),
              // Números de página
              ..._buildPageNumbers(),
              const SizedBox(width: 4),
              // Botón siguiente
              _PageButton(
                icon: Icons.chevron_right,
                onPressed: currentPage < totalPages
                    ? () => onPageChanged?.call(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> pages = <Widget>[];

    for (int i = 1; i <= totalPages.clamp(1, 3); i++) {
      final bool isCurrentPage = i == currentPage;
      pages.add(
        _PageNumber(
          number: i,
          isSelected: isCurrentPage,
          onPressed: () => onPageChanged?.call(i),
        ),
      );
      if (i < totalPages.clamp(1, 3)) {
        pages.add(const SizedBox(width: 4));
      }
    }

    return pages;
  }
}

/// Botón de navegación de página
class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null ? AppColors.gray400 : AppColors.gray300,
          ),
        ),
      ),
    );
  }
}

/// Número de página seleccionable
class _PageNumber extends StatelessWidget {
  const _PageNumber({
    required this.number,
    required this.isSelected,
    this.onPressed,
  });

  final int number;
  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSelected ? null : onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : null,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.gray600,
            ),
          ),
        ),
      ),
    );
  }
}
