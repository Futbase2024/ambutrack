import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/evaluaciones/evaluacion_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de filtros de las evaluaciones de desempeño
class EvaluacionGestionFilters extends StatelessWidget {
  const EvaluacionGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.valoracion,
    required this.onValoracionChanged,
    required this.columnFilters,
    required this.columns,
    required this.onColumnFiltersChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValoracionEvaluacion? valoracion;
  final ValueChanged<ValoracionEvaluacion?> onValoracionChanged;
  final VoidCallback? onClear;
  final GestionColumnFilters columnFilters;
  final List<GestionColumn<EvaluacionDesempenoEntity>> columns;
  final ValueChanged<GestionColumnFilters> onColumnFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar personal, evaluador, periodo...',
        ),
        GestionFilterDropdown<ValoracionEvaluacion?>(
          label: 'Valoración',
          value: valoracion,
          options: <ValoracionEvaluacion?, String>{
            null: 'Todas',
            for (final ValoracionEvaluacion v in ValoracionEvaluacion.values) v: v.label,
          },
          onChanged: onValoracionChanged,
        ),
        GestionColumnFilterChips<EvaluacionDesempenoEntity>(
          filters: columnFilters,
          columns: columns,
          onChanged: onColumnFiltersChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
