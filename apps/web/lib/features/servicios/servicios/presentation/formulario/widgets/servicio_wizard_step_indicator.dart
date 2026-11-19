import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Indicador de pasos compacto: "① Básicos ── ② Modalidad ── ③ …"
///
/// Paso actual en color primario, completados en verde con check y pendientes en gris.
class ServicioWizardStepIndicator extends StatelessWidget {
  const ServicioWizardStepIndicator({required this.steps, required this.currentStep, super.key});

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < steps.length; i++) ...<Widget>[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: i <= currentStep ? AppColors.primary : AppColors.gray200,
                ),
              ),
            _StepItem(
              number: i + 1,
              label: steps[i],
              isCurrent: i == currentStep,
              isCompleted: i < currentStep,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.label,
    required this.isCurrent,
    required this.isCompleted,
  });

  final int number;
  final String label;
  final bool isCurrent;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final Color color = isCompleted
        ? AppColors.success
        : (isCurrent ? AppColors.primary : AppColors.gray400);
    final bool filled = isCurrent || isCompleted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.white,
            border: Border.all(color: color, width: 1.5),
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 13, color: Colors.white)
              : Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: filled ? Colors.white : AppColors.gray500,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? AppColors.primary : (isCompleted ? AppColors.gray700 : AppColors.gray500),
          ),
        ),
      ],
    );
  }
}
