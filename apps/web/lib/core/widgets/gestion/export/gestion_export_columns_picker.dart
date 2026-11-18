import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Selector de columnas a exportar: una casilla por columna + "Todas" / "Ninguna".
/// [selected] son los índices (sobre [labels]) de las columnas marcadas.
class GestionExportColumnsPicker extends StatelessWidget {
  const GestionExportColumnsPicker({
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final List<String> labels;
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;
  final bool enabled;

  void _toggle(int i) {
    final Set<int> next = Set<int>.of(selected);
    if (!next.remove(i)) {
      next.add(i);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              '${selected.length} de ${labels.length} columnas',
              style: const TextStyle(fontSize: 12, color: AppColors.gray600),
            ),
            const Spacer(),
            TextButton(
              onPressed: enabled ? () => onChanged(<int>{for (int i = 0; i < labels.length; i++) i}) : null,
              child: const Text('Todas'),
            ),
            TextButton(
              onPressed: enabled ? () => onChanged(<int>{}) : null,
              child: const Text('Ninguna'),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: <Widget>[
            for (int i = 0; i < labels.length; i++)
              _ColumnChip(
                label: labels[i],
                selected: selected.contains(i),
                onTap: enabled ? () => _toggle(i) : null,
              ),
          ],
        ),
        if (selected.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Marca al menos una columna para exportar',
              style: TextStyle(fontSize: 11.5, color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

class _ColumnChip extends StatelessWidget {
  const _ColumnChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.only(left: 6, right: 10, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? AppColors.primary : AppColors.gray300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 16,
              color: selected ? AppColors.primary : AppColors.gray400,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12.5, color: selected ? AppColors.primary : AppColors.gray700),
            ),
          ],
        ),
      ),
    );
  }
}
