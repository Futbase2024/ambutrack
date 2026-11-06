import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/stock_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Categorías que se gestionan en el almacén general (en orden)
const List<CategoriaProducto> almacenCategorias = <CategoriaProducto>[
  CategoriaProducto.medicacion,
  CategoriaProducto.electromedicina,
  CategoriaProducto.fungibles,
  CategoriaProducto.materialAmbulancia,
  CategoriaProducto.gasesMedicinales,
  CategoriaProducto.otros,
];

/// Barra de herramientas del stock del almacén general
class StockGestionToolbar extends StatelessWidget {
  const StockGestionToolbar({
    required this.hasSelection,
    required this.onNew,
    required this.onEdit,
    required this.onTransfer,
    required this.onRefresh,
    required this.onPrint,
    required this.onView,
    super.key,
  });

  final bool hasSelection;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onTransfer;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Almacén General',
      icon: Icons.warehouse,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Nueva entrada',
            tooltip: 'Registrar una entrada de stock',
            primary: true,
            onPressed: onNew,
          ),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar la línea de stock seleccionada (doble clic / Intro)',
            onPressed: hasSelection ? onEdit : null,
          ),
          GestionToolbarAction(
            icon: Icons.local_shipping_outlined,
            label: 'Transferir',
            tooltip: 'Transferir la línea de stock seleccionada a un vehículo',
            onPressed: hasSelection ? onTransfer : null,
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
            tooltip: 'Ver la ficha de la línea de stock seleccionada',
            onPressed: hasSelection ? onView : null,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros del stock del almacén general
class StockGestionFilters extends StatelessWidget {
  const StockGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.categoria,
    required this.onCategoriaChanged,
    required this.situacion,
    required this.onSituacionChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final CategoriaProducto? categoria;
  final ValueChanged<CategoriaProducto?> onCategoriaChanged;
  final StockSituacion? situacion;
  final ValueChanged<StockSituacion?> onSituacionChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar producto, código, ubicación, lote...',
          width: 260,
        ),
        GestionFilterDropdown<CategoriaProducto?>(
          label: 'Categoría',
          value: categoria,
          options: <CategoriaProducto?, String>{
            null: 'Todas',
            for (final CategoriaProducto c in almacenCategorias) c: '${c.icon} ${c.label}',
          },
          onChanged: onCategoriaChanged,
        ),
        GestionFilterDropdown<StockSituacion?>(
          label: 'Estado',
          value: situacion,
          options: <StockSituacion?, String>{
            null: 'Todos',
            for (final StockSituacion e in StockSituacion.values) e: e.label,
          },
          onChanged: onSituacionChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
