import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/gestion/vacacion_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de vacaciones
class VacacionGestionToolbar extends StatelessWidget {
  const VacacionGestionToolbar({
    required this.hasSelection,
    required this.calendario,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onGestionar,
    required this.onRefresh,
    required this.onPrint,
    required this.onToggleVista,
    super.key,
  });

  final bool hasSelection;

  /// true si se está mostrando la vista de calendario
  final bool calendario;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onGestionar;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;
  final VoidCallback onToggleVista;

  @override
  Widget build(BuildContext context) {
    final bool enabled = hasSelection && !calendario;
    return GestionToolbar(
      title: 'Vacaciones',
      icon: Icons.beach_access,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nuevo', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar las vacaciones seleccionadas (doble clic / Intro)',
            onPressed: enabled ? onEdit : null,
          ),
          GestionToolbarAction(
            icon: Icons.delete_outline,
            label: 'Eliminar',
            destructive: true,
            onPressed: enabled ? onDelete : null,
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
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.fact_check_outlined,
            label: 'Gestionar',
            tooltip: 'Aprobar, rechazar, volver a pendiente o eliminar días',
            onPressed: enabled ? onGestionar : null,
          ),
          GestionToolbarAction(
            icon: calendario ? Icons.table_rows_outlined : Icons.calendar_month_outlined,
            label: calendario ? 'Listado' : 'Calendario',
            tooltip: calendario ? 'Volver al listado' : 'Ver el calendario mensual de vacaciones',
            onPressed: onToggleVista,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros de la pantalla de vacaciones
class VacacionGestionFilters extends StatelessWidget {
  const VacacionGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.year,
    required this.onYearChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final int year;
  final ValueChanged<int> onYearChanged;
  final String? estado;
  final ValueChanged<String?> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final int actual = DateTime.now().year;
    final List<int> years = <int>{
      for (int y = actual - 3; y <= actual + 1; y++) y,
      year,
    }.toList()
      ..sort();
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar personal, observaciones, fecha...',
        ),
        GestionFilterDropdown<int>(
          label: 'Año',
          value: year,
          options: <int, String>{for (final int y in years) y: '$y'},
          onChanged: onYearChanged,
        ),
        GestionFilterDropdown<String?>(
          label: 'Estado',
          value: estado,
          options: <String?, String>{
            null: 'Todos',
            for (final String e in vacacionEstados) e: vacacionEstadoLabel(e),
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
