import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_stock_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de stock de un vehículo.
///
/// Los items de stock solo se pueden añadir (alta manual); no existe edición
/// ni borrado de items en esta pantalla.
class VehiculoStockToolbar extends StatelessWidget {
  const VehiculoStockToolbar({
    required this.title,
    required this.loading,
    required this.onAdd,
    required this.onRefresh,
    required this.onPrint,
    required this.onClose,
    super.key,
  });

  final String title;
  final bool loading;
  final VoidCallback onAdd;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: title,
      icon: Icons.medical_services_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Añadir',
            tooltip: 'Añadir stock manual a este vehículo',
            primary: true,
            onPressed: onAdd,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.refresh,
            label: 'Actualizar',
            onPressed: loading ? null : onRefresh,
          ),
          GestionToolbarAction(
            icon: Icons.print_outlined,
            label: 'Imprimir',
            tooltip: 'Imprimir o guardar como PDF el listado filtrado',
            onPressed: onPrint,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.close,
            label: 'Cerrar',
            tooltip: 'Volver al listado de vehículos',
            destructive: true,
            onPressed: onClose,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros de la pantalla de stock de un vehículo
class VehiculoStockFilters extends StatelessWidget {
  const VehiculoStockFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.categorias,
    required this.categoria,
    required this.onCategoriaChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  /// Categorías presentes en el stock del vehículo
  final List<String> categorias;
  final String? categoria;
  final ValueChanged<String?> onCategoriaChanged;
  final String? estado;
  final ValueChanged<String?> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar producto, lote, ubicación...',
        ),
        GestionFilterDropdown<String?>(
          label: 'Categoría',
          value: categorias.contains(categoria) ? categoria : null,
          options: <String?, String>{null: 'Todas', for (final String c in categorias) c: c},
          onChanged: onCategoriaChanged,
        ),
        GestionFilterDropdown<String?>(
          label: 'Estado',
          value: estado,
          options: <String?, String>{null: 'Todos', for (final String e in stockItemEstados) e: e},
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
