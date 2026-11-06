import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de Mantenimiento Preventivo
class MantenimientoGestionToolbar extends StatelessWidget {
  const MantenimientoGestionToolbar({
    required this.hasSelection,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
    required this.onPrint,
    required this.onView,
    super.key,
  });

  final bool hasSelection;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Mantenimiento Preventivo',
      icon: Icons.build_circle,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Nuevo',
            tooltip: 'Programar mantenimiento',
            primary: true,
            onPressed: onNew,
          ),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar el mantenimiento seleccionado (doble clic / Intro)',
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
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.visibility_outlined,
            label: 'Ver',
            tooltip: 'Ver el detalle completo del mantenimiento seleccionado',
            onPressed: hasSelection ? onView : null,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros de la pantalla de Mantenimiento Preventivo
class MantenimientoGestionFilters extends StatelessWidget {
  const MantenimientoGestionFilters({
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
  final TipoMantenimiento? tipo;
  final ValueChanged<TipoMantenimiento?> onTipoChanged;
  final EstadoMantenimiento? estado;
  final ValueChanged<EstadoMantenimiento?> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar matrícula, descripción, taller, nº orden...',
          width: 260,
        ),
        GestionFilterDropdown<TipoMantenimiento?>(
          label: 'Tipo',
          value: tipo,
          options: <TipoMantenimiento?, String>{
            null: 'Todos',
            for (final TipoMantenimiento t in TipoMantenimiento.values) t: t.displayName,
          },
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<EstadoMantenimiento?>(
          label: 'Estado',
          value: estado,
          options: <EstadoMantenimiento?, String>{
            null: 'Todos',
            for (final EstadoMantenimiento e in EstadoMantenimiento.values) e: e.displayName,
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
