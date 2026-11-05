import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/stock_vestuario/stock_vestuario_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de stock de vestuario
class StockVestuarioGestionToolbar extends StatelessWidget {
  const StockVestuarioGestionToolbar({
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
      title: 'Stock de Vestuario',
      icon: Icons.inventory_2_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Nuevo',
            tooltip: 'Nuevo artículo de stock',
            primary: true,
            onPressed: onNew,
          ),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar el artículo seleccionado (doble clic / Intro)',
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

/// Barra de filtros de la pantalla de stock de vestuario
class StockVestuarioGestionFilters extends StatelessWidget {
  const StockVestuarioGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.nivel,
    required this.onNivelChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final NivelStock? nivel;
  final ValueChanged<NivelStock?> onNivelChanged;
  final StockEstadoFiltro estado;
  final ValueChanged<StockEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar prenda, talla, marca, color, proveedor...',
        ),
        GestionFilterDropdown<NivelStock?>(
          label: 'Nivel',
          value: nivel,
          options: <NivelStock?, String>{
            null: 'Todos',
            for (final NivelStock n in NivelStock.values) n: n.label,
          },
          onChanged: onNivelChanged,
        ),
        GestionFilterDropdown<StockEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <StockEstadoFiltro, String>{
            StockEstadoFiltro.todos: 'Todos',
            StockEstadoFiltro.activos: 'Activos',
            StockEstadoFiltro.inactivos: 'Inactivos',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
