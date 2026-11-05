import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/gestion/agenda_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la agenda de pendientes
class AgendaGestionToolbar extends StatelessWidget {
  const AgendaGestionToolbar({
    required this.hasSelection,
    required this.selectedCompletado,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleCompletado,
    required this.onRefresh,
    required this.onPrint,
    super.key,
  });

  final bool hasSelection;

  /// Estado del pendiente seleccionado (para el texto del botón de marcar)
  final bool selectedCompletado;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleCompletado;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Agenda de Pendientes',
      icon: Icons.event_note,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nuevo', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar el pendiente seleccionado (doble clic / Intro)',
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
          GestionToolbarAction(
            icon: selectedCompletado ? Icons.undo_outlined : Icons.check_circle_outline,
            label: selectedCompletado ? 'Marcar pendiente' : 'Marcar completado',
            onPressed: hasSelection ? onToggleCompletado : null,
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

/// Barra de filtros de la agenda de pendientes
class AgendaGestionFilters extends StatelessWidget {
  const AgendaGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.fecha,
    required this.onFechaChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final AgendaEstadoFiltro estado;
  final ValueChanged<AgendaEstadoFiltro> onEstadoChanged;
  final AgendaFechaFiltro fecha;
  final ValueChanged<AgendaFechaFiltro> onFechaChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nombre, domicilio, localidad...',
        ),
        GestionFilterDropdown<AgendaEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <AgendaEstadoFiltro, String>{
            AgendaEstadoFiltro.todos: 'Todos',
            AgendaEstadoFiltro.pendientes: 'Pendientes',
            AgendaEstadoFiltro.completados: 'Completados',
          },
          onChanged: onEstadoChanged,
        ),
        GestionFilterDropdown<AgendaFechaFiltro>(
          label: 'Fecha',
          value: fecha,
          options: const <AgendaFechaFiltro, String>{
            AgendaFechaFiltro.todas: 'Todas',
            AgendaFechaFiltro.hoy: 'Hoy',
            AgendaFechaFiltro.proximas: 'Próximas',
            AgendaFechaFiltro.anteriores: 'Anteriores',
          },
          onChanged: onFechaChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
