import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/gestion/facultativo_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de facultativos
class FacultativoGestionToolbar extends StatelessWidget {
  const FacultativoGestionToolbar({
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
      title: 'Facultativos',
      icon: Icons.badge_outlined,
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
            tooltip: 'Editar el facultativo seleccionado (doble clic / Intro)',
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

/// Barra de filtros de la pantalla de facultativos
class FacultativoGestionFilters extends StatelessWidget {
  const FacultativoGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.especialidades,
    required this.especialidadId,
    required this.onEspecialidadChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final Map<String, String> especialidades;
  final String? especialidadId;
  final ValueChanged<String?> onEspecialidadChanged;
  final FacultativoEstadoFiltro estado;
  final ValueChanged<FacultativoEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nombre, colegiado, especialidad, teléfono...',
        ),
        GestionFilterDropdown<String?>(
          label: 'Especialidad',
          value: especialidades.containsKey(especialidadId) ? especialidadId : null,
          options: <String?, String>{
            null: 'Todas',
            ...especialidades,
          },
          onChanged: onEspecialidadChanged,
        ),
        GestionFilterDropdown<FacultativoEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <FacultativoEstadoFiltro, String>{
            FacultativoEstadoFiltro.todos: 'Todos',
            FacultativoEstadoFiltro.activos: 'Activos',
            FacultativoEstadoFiltro.inactivos: 'Inactivos',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
