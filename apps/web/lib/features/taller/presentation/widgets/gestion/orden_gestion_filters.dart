import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/orden_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de filtros de órdenes de reparación
class OrdenGestionFilters extends StatelessWidget {
  const OrdenGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.prioridad,
    required this.onPrioridadChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String estado;
  final ValueChanged<String> onEstadoChanged;
  final PrioridadOrdenReparacion? prioridad;
  final ValueChanged<PrioridadOrdenReparacion?> onPrioridadChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nº orden, matrícula o taller...',
        ),
        GestionFilterDropdown<String>(
          label: 'Estado',
          value: estado,
          options: ordenEstadoFiltroOptions,
          onChanged: onEstadoChanged,
        ),
        GestionFilterDropdown<PrioridadOrdenReparacion?>(
          label: 'Prioridad',
          value: prioridad,
          options: <PrioridadOrdenReparacion?, String>{
            null: 'Todas',
            for (final PrioridadOrdenReparacion p in PrioridadOrdenReparacion.values) p: p.displayName,
          },
          onChanged: onPrioridadChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
