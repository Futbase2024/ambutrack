import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_column_filters.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_grid_column.dart';
import 'package:flutter/material.dart';

/// Etiquetas de los filtros de columna activos ("Estado: Baja, Mantenimiento ✕")
/// para la barra de filtros. No pinta nada si no hay filtros de columna.
class GestionColumnFilterChips<T> extends StatelessWidget {
  const GestionColumnFilterChips({
    required this.filters,
    required this.columns,
    required this.onChanged,
    super.key,
  });

  final GestionColumnFilters filters;
  final List<GestionColumn<T>> columns;
  final ValueChanged<GestionColumnFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<int> activos = filters.values.keys.where((int i) => i < columns.length).toList()..sort();
    if (activos.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final int i in activos)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _FilterChip(
              label: columns[i].label,
              values: filters.of(i)!,
              onRemove: () => onChanged(filters.withColumn(i, null)),
            ),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.values, required this.onRemove});

  final String label;
  final Set<String> values;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final String texto = values.join(', ');
    return Tooltip(
      message: '$label: $texto',
      child: Container(
        height: 26,
        padding: const EdgeInsets.only(left: 10, right: 4),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.filter_alt, size: 13, color: AppColors.primary),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                '$label: $texto',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
              ),
            ),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(Icons.close, size: 14, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
