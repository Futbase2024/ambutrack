import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/gestion/plantilla_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de plantillas de turnos
class PlantillaGestionToolbar extends StatelessWidget {
  const PlantillaGestionToolbar({
    required this.hasSelection,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onRefresh,
    required this.onPrint,
    super.key,
  });

  final bool hasSelection;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Plantillas de Turnos',
      icon: Icons.schedule,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nuevo', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar la plantilla seleccionada (doble clic / Intro)',
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
            icon: Icons.copy_outlined,
            label: 'Duplicar',
            tooltip: 'Crear una copia de la plantilla seleccionada',
            onPressed: hasSelection ? onDuplicate : null,
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

/// Barra de filtros de la pantalla de plantillas de turnos
class PlantillaGestionFilters extends StatelessWidget {
  const PlantillaGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.tipo,
    required this.onTipoChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final TipoTurno? tipo;
  final ValueChanged<TipoTurno?> onTipoChanged;
  final PlantillaEstadoFiltro estado;
  final ValueChanged<PlantillaEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nombre, tipo, descripción...',
        ),
        GestionFilterDropdown<TipoTurno?>(
          label: 'Tipo',
          value: tipo,
          options: <TipoTurno?, String>{
            null: 'Todos',
            for (final TipoTurno t in TipoTurno.values) t: t.nombre,
          },
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<PlantillaEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <PlantillaEstadoFiltro, String>{
            PlantillaEstadoFiltro.todos: 'Todas',
            PlantillaEstadoFiltro.activas: 'Activas',
            PlantillaEstadoFiltro.inactivas: 'Inactivas',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
