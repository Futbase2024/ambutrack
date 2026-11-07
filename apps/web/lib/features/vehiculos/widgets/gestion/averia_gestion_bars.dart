import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de historial de averías
class AveriaGestionToolbar extends StatelessWidget {
  const AveriaGestionToolbar({
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
      title: 'Historial de Averías',
      icon: Icons.report_problem_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Nuevo',
            tooltip: 'Reportar avería',
            primary: true,
            onPressed: onNew,
          ),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar la avería seleccionada (doble clic / Intro)',
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

/// Barra de filtros de la pantalla de historial de averías.
///
/// Estado, prioridad y tipo los filtra el BLoC; la búsqueda de texto se aplica
/// en la vista sobre el listado completo.
class AveriaGestionFilters extends StatelessWidget {
  const AveriaGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.prioridad,
    required this.onPrioridadChanged,
    required this.tipo,
    required this.onTipoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final EstadoIncidencia? estado;
  final ValueChanged<EstadoIncidencia?> onEstadoChanged;
  final PrioridadIncidencia? prioridad;
  final ValueChanged<PrioridadIncidencia?> onPrioridadChanged;
  final TipoIncidencia? tipo;
  final ValueChanged<TipoIncidencia?> onTipoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar título, vehículo, reportado por...',
          width: 220,
        ),
        GestionFilterDropdown<EstadoIncidencia?>(
          label: 'Estado',
          value: estado,
          options: <EstadoIncidencia?, String>{
            null: 'Todos',
            for (final EstadoIncidencia e in EstadoIncidencia.values) e: e.nombre,
          },
          onChanged: onEstadoChanged,
        ),
        GestionFilterDropdown<PrioridadIncidencia?>(
          label: 'Prioridad',
          value: prioridad,
          options: <PrioridadIncidencia?, String>{
            null: 'Todas',
            for (final PrioridadIncidencia p in PrioridadIncidencia.values) p: p.nombre,
          },
          onChanged: onPrioridadChanged,
        ),
        GestionFilterDropdown<TipoIncidencia?>(
          label: 'Tipo',
          value: tipo,
          options: <TipoIncidencia?, String>{
            null: 'Todos',
            for (final TipoIncidencia t in TipoIncidencia.values) t: t.nombre,
          },
          onChanged: onTipoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
