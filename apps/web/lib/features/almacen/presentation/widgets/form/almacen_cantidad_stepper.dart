import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Selector de cantidad con botones −/+ con el alto estándar de un campo de gestión
class AlmacenCantidadStepper extends StatelessWidget {
  const AlmacenCantidadStepper({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max,
    this.unit,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;

  /// El botón − se desactiva cuando el valor no supera [min]
  final double min;

  /// El botón + se desactiva cuando el valor alcanza [max] (sin límite si es null)
  final double? max;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final bool canDec = value > min;
    final bool canInc = max == null || value < max!;
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Row(
        children: <Widget>[
          _StepButton(icon: Icons.remove, onPressed: canDec ? () => onChanged(value - 1) : null),
          const VerticalDivider(width: 1, color: AppColors.gray200),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '${value.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.w600),
                children: <InlineSpan>[
                  if (unit != null && unit!.isNotEmpty)
                    TextSpan(
                      text: '  $unit',
                      style: const TextStyle(fontSize: 12, color: AppColors.gray500, fontWeight: FontWeight.w400),
                    ),
                ],
              ),
              textAlign: TextAlign.center,
              style: GestionFormStyle.text,
            ),
          ),
          const VerticalDivider(width: 1, color: AppColors.gray200),
          _StepButton(icon: Icons.add, onPressed: canInc ? () => onChanged(value + 1) : null),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        color: AppColors.primary,
        disabledColor: AppColors.gray300,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
