import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de ITV y Revisiones
class ItvGestionToolbar extends StatelessWidget {
  const ItvGestionToolbar({
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
      title: 'ITV y Revisiones',
      icon: Icons.fact_check,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Nuevo',
            tooltip: 'Programar ITV/Revisión',
            primary: true,
            onPressed: onNew,
          ),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar la ITV/Revisión seleccionada (doble clic / Intro)',
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
            tooltip: 'Ver el detalle completo de la ITV/Revisión seleccionada',
            onPressed: hasSelection ? onView : null,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros de la pantalla de ITV y Revisiones
class ItvGestionFilters extends StatelessWidget {
  const ItvGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.tipo,
    required this.onTipoChanged,
    required this.resultado,
    required this.onResultadoChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final TipoItvRevision? tipo;
  final ValueChanged<TipoItvRevision?> onTipoChanged;
  final ResultadoItvRevision? resultado;
  final ValueChanged<ResultadoItvRevision?> onResultadoChanged;
  final EstadoItvRevision? estado;
  final ValueChanged<EstadoItvRevision?> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar matrícula, taller, nº documento...',
          width: 220,
        ),
        GestionFilterDropdown<TipoItvRevision?>(
          label: 'Tipo',
          value: tipo,
          options: <TipoItvRevision?, String>{
            null: 'Todos',
            for (final TipoItvRevision t in TipoItvRevision.values) t: t.displayName,
          },
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<ResultadoItvRevision?>(
          label: 'Resultado',
          value: resultado,
          options: <ResultadoItvRevision?, String>{
            null: 'Todos',
            for (final ResultadoItvRevision r in ResultadoItvRevision.values) r: r.displayName,
          },
          onChanged: onResultadoChanged,
        ),
        GestionFilterDropdown<EstadoItvRevision?>(
          label: 'Estado',
          value: estado,
          options: <EstadoItvRevision?, String>{
            null: 'Todos',
            for (final EstadoItvRevision e in EstadoItvRevision.values) e: e.displayName,
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
