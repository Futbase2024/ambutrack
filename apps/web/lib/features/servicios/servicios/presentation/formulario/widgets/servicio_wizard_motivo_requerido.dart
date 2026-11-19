import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Aviso del paso 2 cuando aún no se ha elegido el motivo de traslado en el paso 1
class ServicioWizardMotivoRequerido extends StatelessWidget {
  const ServicioWizardMotivoRequerido({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.info_outline, size: 22, color: AppColors.warning),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Selecciona un motivo de traslado en el Paso 1',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.gray900),
                ),
                SizedBox(height: 4),
                Text(
                  'El motivo de traslado es necesario para configurar los horarios y tiempos de espera',
                  style: TextStyle(fontSize: 12.5, color: AppColors.gray600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
