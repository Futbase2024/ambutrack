import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/gestion/asignaciones_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de asignaciones
class AsignacionesGestionToolbar extends StatelessWidget {
  const AsignacionesGestionToolbar({
    required this.hasSelection,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
    required this.onPrint,
    super.key,
  });

  final bool hasSelection;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Asignaciones',
      icon: Icons.assignment_ind,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nueva', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar la asignación seleccionada (doble clic / Intro)',
            onPressed: hasSelection ? onEdit : null,
          ),
          GestionToolbarAction(
            icon: Icons.delete_outline,
            label: 'Eliminar',
            destructive: true,
            onPressed: hasSelection ? onDelete : null,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: onRefresh),
          GestionToolbarAction(
            icon: Icons.print_outlined,
            label: 'Imprimir',
            tooltip: 'Imprimir o guardar como PDF el listado filtrado',
            onPressed: onPrint,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros: día consultado + búsqueda + estado
class AsignacionesGestionFilters extends StatelessWidget {
  const AsignacionesGestionFilters({
    required this.fecha,
    required this.onMoveDays,
    required this.onToday,
    required this.onPickDate,
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final DateTime fecha;
  final ValueChanged<int> onMoveDays;
  final VoidCallback onToday;
  final VoidCallback onPickDate;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String? estado;
  final ValueChanged<String?> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        _FechaSelector(fecha: fecha, onMoveDays: onMoveDays, onToday: onToday, onPickDate: onPickDate),
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar vehículo, dotación, destino, turno...',
        ),
        GestionFilterDropdown<String?>(
          label: 'Estado',
          value: estado,
          options: const <String?, String>{null: 'Todos', ...asignacionEstados},
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}

/// Selector compacto del día consultado (‹ fecha › Hoy)
class _FechaSelector extends StatelessWidget {
  const _FechaSelector({
    required this.fecha,
    required this.onMoveDays,
    required this.onToday,
    required this.onPickDate,
  });

  final DateTime fecha;
  final ValueChanged<int> onMoveDays;
  final VoidCallback onToday;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    const BoxConstraints small = BoxConstraints(minWidth: 30, minHeight: 30);
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 18),
            constraints: small,
            padding: EdgeInsets.zero,
            tooltip: 'Día anterior',
            onPressed: () => onMoveDays(-1),
          ),
          TextButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_today, size: 14),
            label: Text(GestionFormatters.fecha(fecha)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gray900,
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 18),
            constraints: small,
            padding: EdgeInsets.zero,
            tooltip: 'Día siguiente',
            onPressed: () => onMoveDays(1),
          ),
          TextButton(
            onPressed: onToday,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: const Text('Hoy'),
          ),
        ],
      ),
    );
  }
}
