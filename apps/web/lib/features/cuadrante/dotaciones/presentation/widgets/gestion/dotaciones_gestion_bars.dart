import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/gestion/dotaciones_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de dotaciones
class DotacionesGestionToolbar extends StatelessWidget {
  const DotacionesGestionToolbar({
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
      title: 'Dotaciones',
      icon: Icons.assignment,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nueva', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar la dotación seleccionada (doble clic / Intro)',
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

/// Barra de filtros de la pantalla de dotaciones
class DotacionesGestionFilters extends StatelessWidget {
  const DotacionesGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.tipoDestino,
    required this.onTipoDestinoChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String? tipoDestino;
  final ValueChanged<String?> onTipoDestinoChanged;
  final DotacionEstadoFiltro estado;
  final ValueChanged<DotacionEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nombre, código, descripción...',
        ),
        GestionFilterDropdown<String?>(
          label: 'Destino',
          value: tipoDestino,
          options: <String?, String>{
            null: 'Todos',
            for (final String t in dotacionTiposDestino) t: t,
          },
          onChanged: onTipoDestinoChanged,
        ),
        GestionFilterDropdown<DotacionEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <DotacionEstadoFiltro, String>{
            DotacionEstadoFiltro.todos: 'Todos',
            DotacionEstadoFiltro.activas: 'Activas',
            DotacionEstadoFiltro.inactivas: 'Inactivas',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
