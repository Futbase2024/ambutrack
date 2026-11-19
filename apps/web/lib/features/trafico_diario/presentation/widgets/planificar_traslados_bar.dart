import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Barra superior de la rejilla de planificación: título o recuento de
/// marcados, acciones sobre los marcados y filtros de columna activos.
class PlanificarTrasladosBar extends StatelessWidget {
  const PlanificarTrasladosBar({
    required this.seleccionados,
    required this.columns,
    required this.filters,
    required this.onFiltersChanged,
    required this.onLimpiarSeleccion,
    required this.onAsignar,
    super.key,
  });

  final int seleccionados;
  final List<GestionColumn<TrasladoEntity>> columns;
  final GestionColumnFilters filters;
  final ValueChanged<GestionColumnFilters> onFiltersChanged;
  final VoidCallback onLimpiarSeleccion;
  final VoidCallback onAsignar;

  @override
  Widget build(BuildContext context) {
    final bool hayMarcados = seleccionados > 0;
    final String plural = seleccionados == 1 ? '' : 's';
    return GestionFilterBar(
      children: <Widget>[
        Text(
          hayMarcados ? '$seleccionados traslado$plural marcado$plural' : 'Traslados pendientes de asignar',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: hayMarcados ? AppColors.primary : AppColors.gray900,
          ),
        ),
        if (hayMarcados) ...<Widget>[
          FilledButton.icon(
            onPressed: onAsignar,
            icon: const Icon(Icons.assignment_ind_outlined, size: 16),
            label: const Text('Asignar conductor', style: TextStyle(fontSize: 13)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          TextButton.icon(
            onPressed: onLimpiarSeleccion,
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Desmarcar', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gray600,
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
        GestionColumnFilterChips<TrasladoEntity>(
          filters: filters,
          columns: columns,
          onChanged: onFiltersChanged,
        ),
        if (!filters.isEmpty)
          GestionClearFiltersButton(
            onPressed: () => onFiltersChanged(const GestionColumnFilters()),
          ),
      ],
    );
  }
}
