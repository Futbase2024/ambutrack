import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Indicador visual del progreso del wizard
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Círculos con líneas de conexión
        Row(
          children: List<Widget>.generate(totalSteps, (int index) {
            final bool isCompleted = index < currentStep;
            final bool isCurrent = index == currentStep;

            return Expanded(
              child: Row(
                children: <Widget>[
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted
                            ? AppColors.success
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  _StepCircle(
                    stepNumber: index + 1,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: AppSizes.spacingSmall),

        // Labels de pasos
        Row(
          children: stepLabels
              .asMap()
              .entries
              .map(
                (MapEntry<int, String> entry) => _StepLabel(
                  label: entry.value,
                  stepIndex: entry.key,
                  isCurrent: entry.key == currentStep,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/// Círculo indicador de un paso
class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.stepNumber,
    required this.isCompleted,
    required this.isCurrent,
  });

  final int stepNumber;
  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? AppColors.success
            : (isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.3)),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Text(
                stepNumber.toString(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCurrent ? AppColors.primary : Colors.white.withValues(alpha: 0.7),
                ),
              ),
      ),
    );
  }
}

/// Label de un paso
class _StepLabel extends StatelessWidget {
  const _StepLabel({
    required this.label,
    required this.stepIndex,
    required this.isCurrent,
  });

  final String label;
  final int stepIndex;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            color: Colors.white.withValues(alpha: isCurrent ? 1.0 : 0.7),
          ),
        ),
      ),
    );
  }
}
