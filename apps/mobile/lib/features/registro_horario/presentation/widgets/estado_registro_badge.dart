import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../bloc/registro_horario_state.dart';

/// Badge que muestra el estado actual del registro (En turno / Fuera de turno)
///
/// Usa el patrón IntrinsicWidth + Align para ajustarse al tamaño del texto.
class EstadoRegistroBadge extends StatelessWidget {
  const EstadoRegistroBadge({
    required this.estadoActual,
    super.key,
  });

  final EstadoFichaje estadoActual;

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(estadoActual);

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: config.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                config.icon,
                size: 16,
                color: config.color,
              ),
              const SizedBox(width: 6),
              Text(
                config.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: config.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Configuración de colores e iconos según el estado
  _BadgeConfig _getConfig(EstadoFichaje estado) {
    switch (estado) {
      case EstadoFichaje.dentro:
        return const _BadgeConfig(
          label: 'En turno',
          color: AppColors.success,
          icon: Icons.work,
        );
      case EstadoFichaje.fuera:
        return const _BadgeConfig(
          label: 'Fuera de turno',
          color: AppColors.gray500,
          icon: Icons.work_off,
        );
    }
  }
}

/// Configuración interna del badge
class _BadgeConfig {
  const _BadgeConfig({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}
