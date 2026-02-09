import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Configuración: Servicio Único
class ConfigUnicoWidget extends StatelessWidget {
  const ConfigUnicoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline, color: AppColors.info, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'El servicio se creará solo para la fecha de inicio del tratamiento',
              style: AppTextStyles.tableCellSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Configuración: Servicio Diario
class ConfigDiarioWidget extends StatelessWidget {
  const ConfigDiarioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'El servicio se repetirá todos los días durante el periodo de tratamiento',
              style: AppTextStyles.tableCellSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Configuración: Días Alternos
class ConfigDiasAlternosWidget extends StatelessWidget {
  const ConfigDiasAlternosWidget({
    super.key,
    required this.intervaloDias,
    required this.onIntervaloChanged,
  });

  final int intervaloDias;
  final void Function(int) onIntervaloChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Intervalo de días',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        IntervaloCounterWidget(
          value: intervaloDias,
          label: 'días',
          minValue: 2,
          example: 'Día 1, ${1 + intervaloDias}, ${1 + intervaloDias * 2}...',
          onDecrement: () => onIntervaloChanged(intervaloDias - 1),
          onIncrement: () => onIntervaloChanged(intervaloDias + 1),
        ),
      ],
    );
  }
}

/// Widget contador de intervalo (reutilizable)
class IntervaloCounterWidget extends StatelessWidget {
  const IntervaloCounterWidget({
    super.key,
    required this.value,
    required this.label,
    required this.minValue,
    required this.example,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final String label;
  final int minValue;
  final String example;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 24),
          color: value > minValue ? AppColors.error : AppColors.gray400,
          onPressed: value > minValue ? onDecrement : null,
          padding: const EdgeInsets.all(8),
        ),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Cada $value $label',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '(ej: $example)',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 24),
          color: AppColors.success,
          onPressed: onIncrement,
          padding: const EdgeInsets.all(8),
        ),
      ],
    );
  }
}
