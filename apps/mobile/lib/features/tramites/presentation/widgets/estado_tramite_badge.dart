import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// Badge para mostrar el estado de un trámite (vacación o ausencia).
/// Ajusta automáticamente su ancho al contenido del texto.
class EstadoTramiteBadge extends StatelessWidget {
  const EstadoTramiteBadge({
    required this.estado,
    this.isAusencia = false,
    super.key,
  });

  final String estado;
  final bool isAusencia;

  @override
  Widget build(BuildContext context) {
    final EstadoConfig config = _getEstadoConfig();

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: config.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: config.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                config.icon,
                size: 14,
                color: config.color,
              ),
              const SizedBox(width: 4),
              Text(
                config.label,
                style: TextStyle(
                  color: config.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  EstadoConfig _getEstadoConfig() {
    if (isAusencia) {
      // Estados de ausencia (enum EstadoAusencia)
      switch (estado.toLowerCase()) {
        case 'pendiente':
          return EstadoConfig(
            label: 'PENDIENTE',
            color: AppColors.warning,
            icon: Icons.access_time_rounded,
          );
        case 'aprobada':
          return EstadoConfig(
            label: 'APROBADA',
            color: AppColors.success,
            icon: Icons.check_circle_rounded,
          );
        case 'rechazada':
          return EstadoConfig(
            label: 'RECHAZADA',
            color: AppColors.error,
            icon: Icons.cancel_rounded,
          );
        case 'cancelada':
          return EstadoConfig(
            label: 'CANCELADA',
            color: AppColors.gray500,
            icon: Icons.block_rounded,
          );
        default:
          return EstadoConfig(
            label: estado.toUpperCase(),
            color: AppColors.gray500,
            icon: Icons.help_outline_rounded,
          );
      }
    } else {
      // Estados de vacaciones (string)
      switch (estado.toLowerCase()) {
        case 'pendiente':
          return EstadoConfig(
            label: 'PENDIENTE',
            color: AppColors.warning,
            icon: Icons.access_time_rounded,
          );
        case 'aprobada':
          return EstadoConfig(
            label: 'APROBADA',
            color: AppColors.success,
            icon: Icons.check_circle_rounded,
          );
        case 'rechazada':
          return EstadoConfig(
            label: 'RECHAZADA',
            color: AppColors.error,
            icon: Icons.cancel_rounded,
          );
        case 'cancelada':
          return EstadoConfig(
            label: 'CANCELADA',
            color: AppColors.gray500,
            icon: Icons.block_rounded,
          );
        default:
          return EstadoConfig(
            label: estado.toUpperCase(),
            color: AppColors.gray500,
            icon: Icons.help_outline_rounded,
          );
      }
    }
  }
}

/// Configuración de visualización del estado.
class EstadoConfig {
  const EstadoConfig({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}
