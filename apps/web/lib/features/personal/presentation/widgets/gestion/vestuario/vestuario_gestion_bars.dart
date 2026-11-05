import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/vestuario/vestuario_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de vestuario
class VestuarioGestionToolbar extends StatelessWidget {
  const VestuarioGestionToolbar({
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
      title: 'Vestuario',
      icon: Icons.checkroom_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Nuevo',
            tooltip: 'Nueva asignación de vestuario',
            primary: true,
            onPressed: onNew,
          ),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar la asignación seleccionada (doble clic / Intro)',
            onPressed: hasSelection ? onEdit : null,
          ),
          GestionToolbarAction(
            icon: Icons.delete_outline,
            label: 'Eliminar',
            tooltip: 'Eliminar la asignación (devuelve las unidades al stock)',
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

/// Barra de filtros de la pantalla de vestuario
class VestuarioGestionFilters extends StatelessWidget {
  const VestuarioGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.prenda,
    required this.prendas,
    required this.onPrendaChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VestuarioEstadoFiltro estado;
  final ValueChanged<VestuarioEstadoFiltro> onEstadoChanged;
  final String? prenda;
  final List<String> prendas;
  final ValueChanged<String?> onPrendaChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar trabajador, prenda, talla, marca...',
        ),
        GestionFilterDropdown<String?>(
          label: 'Prenda',
          value: prendas.contains(prenda) ? prenda : null,
          options: <String?, String>{
            null: 'Todas',
            for (final String p in prendas) p: p,
          },
          onChanged: onPrendaChanged,
        ),
        GestionFilterDropdown<VestuarioEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <VestuarioEstadoFiltro, String>{
            VestuarioEstadoFiltro.todos: 'Todos',
            VestuarioEstadoFiltro.asignados: 'Asignados',
            VestuarioEstadoFiltro.devueltos: 'Devueltos',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
