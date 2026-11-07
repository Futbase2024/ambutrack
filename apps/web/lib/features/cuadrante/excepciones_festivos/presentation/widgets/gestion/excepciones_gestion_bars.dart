import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/gestion/excepciones_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de excepciones/festivos
class ExcepcionesGestionToolbar extends StatelessWidget {
  const ExcepcionesGestionToolbar({
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
      title: 'Excepciones y Festivos',
      icon: Icons.event_busy,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nuevo', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar el registro seleccionado (doble clic / Intro)',
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

/// Barra de filtros de la pantalla de excepciones/festivos
class ExcepcionesGestionFilters extends StatelessWidget {
  const ExcepcionesGestionFilters({
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
  final String? tipo;
  final ValueChanged<String?> onTipoChanged;
  final ExcepcionEstadoFiltro estado;
  final ValueChanged<ExcepcionEstadoFiltro> onEstadoChanged;
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
        GestionFilterDropdown<String?>(
          label: 'Tipo',
          value: tipo,
          options: const <String?, String>{null: 'Todos', ...excepcionTipos},
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<ExcepcionEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <ExcepcionEstadoFiltro, String>{
            ExcepcionEstadoFiltro.todos: 'Todos',
            ExcepcionEstadoFiltro.activos: 'Activos',
            ExcepcionEstadoFiltro.inactivos: 'Inactivos',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
