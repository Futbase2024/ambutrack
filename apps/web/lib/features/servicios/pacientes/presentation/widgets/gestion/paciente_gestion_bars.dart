import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/gestion/paciente_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de pacientes
class PacienteGestionToolbar extends StatelessWidget {
  const PacienteGestionToolbar({
    required this.hasSelection,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onCreateServicio,
    required this.onRefresh,
    required this.onPrint,
    super.key,
  });

  final bool hasSelection;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCreateServicio;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Pacientes',
      icon: Icons.people_outline,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Nuevo',
            primary: true,
            onPressed: onNew,
          ),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar el paciente seleccionado (doble clic / Intro)',
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
            icon: Icons.add_circle_outline,
            label: 'Crear servicio',
            tooltip: 'Crear un servicio para el paciente seleccionado',
            onPressed: hasSelection ? onCreateServicio : null,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.refresh,
            label: 'Actualizar',
            onPressed: onRefresh,
          ),
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

/// Barra de filtros de la pantalla de pacientes
class PacienteGestionFilters extends StatelessWidget {
  const PacienteGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final PacienteEstadoFiltro estado;
  final ValueChanged<PacienteEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          width: 360,
          hint: 'Buscar identificación, nombre, documento, teléfono, dirección...',
        ),
        GestionFilterDropdown<PacienteEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <PacienteEstadoFiltro, String>{
            PacienteEstadoFiltro.todos: 'Todos',
            PacienteEstadoFiltro.activos: 'Activos',
            PacienteEstadoFiltro.inactivos: 'Inactivos',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
