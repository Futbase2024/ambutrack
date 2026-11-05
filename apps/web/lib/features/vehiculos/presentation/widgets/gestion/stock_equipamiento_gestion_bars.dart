import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/gestion/stock_equipamiento_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de stock de equipamiento.
///
/// Esta pantalla es un resumen por vehículo: no hay alta/edición/borrado de
/// vehículos, solo consulta del equipamiento y alta manual de items.
class StockEquipamientoGestionToolbar extends StatelessWidget {
  const StockEquipamientoGestionToolbar({
    required this.hasSelection,
    required this.refreshing,
    required this.onVer,
    required this.onAdd,
    required this.onRefresh,
    required this.onPrint,
    super.key,
  });

  final bool hasSelection;
  final bool refreshing;
  final VoidCallback onVer;
  final VoidCallback onAdd;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Stock de Equipamiento',
      icon: Icons.medical_services_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.visibility_outlined,
            label: 'Ver equipamiento',
            tooltip: 'Ver el equipamiento del vehículo seleccionado (doble clic / Intro)',
            onPressed: hasSelection ? onVer : null,
          ),
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Añadir item',
            tooltip: 'Añadir stock manual al vehículo seleccionado',
            primary: true,
            onPressed: hasSelection ? onAdd : null,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.refresh,
            label: 'Actualizar',
            onPressed: refreshing ? null : onRefresh,
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

/// Barra de filtros de la pantalla de stock de equipamiento
class StockEquipamientoGestionFilters extends StatelessWidget {
  const StockEquipamientoGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final EstadoStockGeneral? estado;
  final ValueChanged<EstadoStockGeneral?> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar por matrícula, marca o modelo...',
        ),
        GestionFilterDropdown<EstadoStockGeneral?>(
          label: 'Estado',
          value: estado,
          options: <EstadoStockGeneral?, String>{
            null: 'Todos',
            for (final EstadoStockGeneral e in EstadoStockGeneral.values) e: stockGeneralLabel(e),
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
