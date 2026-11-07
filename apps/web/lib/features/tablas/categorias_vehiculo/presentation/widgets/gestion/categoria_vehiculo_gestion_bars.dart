import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/widgets/gestion/categoria_vehiculo_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de categorías de vehículo
class CategoriaVehiculoGestionToolbar extends StatelessWidget {
  const CategoriaVehiculoGestionToolbar({
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
      title: 'Categorías de Vehículo',
      icon: Icons.category_outlined,
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
            tooltip: 'Editar la categoría seleccionada (doble clic / Intro)',
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

/// Barra de filtros de la pantalla de categorías de vehículo
class CategoriaVehiculoGestionFilters extends StatelessWidget {
  const CategoriaVehiculoGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final CategoriaVehiculoEstadoFiltro estado;
  final ValueChanged<CategoriaVehiculoEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nombre o descripción...',
        ),
        GestionFilterDropdown<CategoriaVehiculoEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <CategoriaVehiculoEstadoFiltro, String>{
            CategoriaVehiculoEstadoFiltro.todos: 'Todos',
            CategoriaVehiculoEstadoFiltro.activos: 'Activos',
            CategoriaVehiculoEstadoFiltro.inactivos: 'Inactivos',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
