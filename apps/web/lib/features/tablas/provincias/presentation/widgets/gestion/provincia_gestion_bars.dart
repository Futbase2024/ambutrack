import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de provincias
class ProvinciaGestionToolbar extends StatelessWidget {
  const ProvinciaGestionToolbar({
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
      title: 'Provincias',
      icon: Icons.map,
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

/// Barra de filtros de la pantalla de provincias
class ProvinciaGestionFilters extends StatelessWidget {
  const ProvinciaGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.comunidadId,
    required this.comunidades,
    required this.onComunidadChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  /// Comunidad autónoma seleccionada: null = todas
  final String? comunidadId;

  /// Comunidades disponibles (id → nombre)
  final Map<String, String> comunidades;
  final ValueChanged<String?> onComunidadChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar provincia, código o comunidad...',
        ),
        GestionFilterDropdown<String?>(
          label: 'Comunidad',
          value: comunidades.containsKey(comunidadId) ? comunidadId : null,
          options: <String?, String>{
            null: 'Todas',
            ...comunidades,
          },
          onChanged: onComunidadChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
