import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';

/// Botones de navegación del wizard (Atrás/Siguiente/Crear)
class FormNavigationButtons extends StatelessWidget {
  const FormNavigationButtons({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    this.onPrevious,
    this.isProcessing = false,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final bool isLastStep = currentStep == totalSteps - 1;
    final bool showBackButton = currentStep > 0;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.gray200),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radius),
          bottomRight: Radius.circular(AppSizes.radius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Botón Atrás
          if (showBackButton)
            AppButton(
              onPressed: isProcessing ? null : onPrevious,
              label: 'Atrás',
              icon: Icons.arrow_back,
              variant: AppButtonVariant.text,
            )
          else
            const SizedBox.shrink(),

          // Botón Siguiente/Crear
          AppButton(
            onPressed: isProcessing ? null : onNext,
            label: isLastStep ? 'Crear Servicio' : 'Siguiente',
            icon: isLastStep ? Icons.check : Icons.arrow_forward,
          ),
        ],
      ),
    );
  }
}
