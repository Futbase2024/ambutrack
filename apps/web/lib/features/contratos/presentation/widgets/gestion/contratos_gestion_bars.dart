import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/gestion/contratos_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de contratos
class ContratosGestionToolbar extends StatelessWidget {
  const ContratosGestionToolbar({
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
      title: 'Contratos',
      icon: Icons.description,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nuevo', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar el contrato seleccionado (doble clic / Intro)',
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

/// Barra de filtros de la pantalla de contratos
class ContratosGestionFilters extends StatelessWidget {
  const ContratosGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.tipo,
    required this.onTipoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ContratoEstadoFiltro estado;
  final ValueChanged<ContratoEstadoFiltro> onEstadoChanged;
  final String? tipo;
  final ValueChanged<String?> onTipoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar código, hospital, tipo, descripción...',
        ),
        GestionFilterDropdown<ContratoEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <ContratoEstadoFiltro, String>{
            ContratoEstadoFiltro.todos: 'Todos',
            ContratoEstadoFiltro.activos: 'Activos',
            ContratoEstadoFiltro.inactivos: 'Inactivos',
          },
          onChanged: onEstadoChanged,
        ),
        GestionFilterDropdown<String?>(
          label: 'Tipo',
          value: tipo,
          options: const <String?, String>{null: 'Todos', ...contratoTipos},
          onChanged: onTipoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
