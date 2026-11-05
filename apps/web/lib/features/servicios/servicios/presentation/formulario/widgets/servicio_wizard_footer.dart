import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Pie del asistente con el aspecto del pie de los formularios de gestión
/// (gris claro, botones de 36px y radio 6): Cancelar · Anterior · Siguiente/Guardar.
class ServicioWizardFooter extends StatelessWidget {
  const ServicioWizardFooter({
    required this.currentStep,
    required this.totalSteps,
    required this.isSaving,
    required this.finalLabel,
    required this.onPrevious,
    required this.onNext,
    required this.onCancel,
    super.key,
  });

  final int currentStep;
  final int totalSteps;
  final bool isSaving;
  final String finalLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCancel;

  static final ButtonStyle _outlined = OutlinedButton.styleFrom(
    foregroundColor: AppColors.gray700,
    side: const BorderSide(color: AppColors.gray300),
    minimumSize: const Size(96, 36),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  );

  @override
  Widget build(BuildContext context) {
    final bool isLast = currentStep == totalSteps - 1;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: 'Paso ${currentStep + 1} de $totalSteps',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray700),
                ),
                const TextSpan(text: '     '),
                const TextSpan(text: '*', style: TextStyle(color: AppColors.error)),
                TextSpan(
                  text: ' Obligatorio     Ctrl+Intro ${isLast ? 'guardar' : 'siguiente'} · Esc cancelar',
                ),
              ],
            ),
            style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: isSaving ? null : onCancel,
            style: _outlined,
            child: const Text('Cancelar'),
          ),
          if (currentStep > 0) ...<Widget>[
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: isSaving ? null : onPrevious,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Anterior'),
              style: _outlined,
            ),
          ],
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: isSaving ? null : onNext,
            icon: _NextIcon(isSaving: isSaving, isLast: isLast),
            label: Text(isLast ? finalLabel : 'Siguiente'),
            style: FilledButton.styleFrom(
              backgroundColor: isLast ? AppColors.success : AppColors.primary,
              minimumSize: const Size(112, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextIcon extends StatelessWidget {
  const _NextIcon({required this.isSaving, required this.isLast});

  final bool isSaving;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    if (isSaving) {
      return const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    return Icon(isLast ? Icons.check : Icons.arrow_forward, size: 16);
  }
}
