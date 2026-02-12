import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Badge visual para mostrar la prioridad de una incidencia
///
/// Muestra la prioridad con colores diferenciados según el nivel:
/// - Baja: Gris (gray600)
/// - Media: Naranja (warning)
/// - Alta: Rojo (error)
/// - Crítica: Rojo oscuro (emergency)
class IncidenciaPrioridadBadge extends StatelessWidget {
  const IncidenciaPrioridadBadge({
    required this.prioridad,
    super.key,
  });

  final PrioridadIncidencia prioridad;

  @override
  Widget build(BuildContext context) {
    final BadgeConfig config = _getConfig(prioridad);

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: config.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                config.icon,
                size: 14,
                color: config.color,
              ),
              const SizedBox(width: 4),
              Text(
                prioridad.nombre,
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

  BadgeConfig _getConfig(PrioridadIncidencia prioridad) {
    switch (prioridad) {
      case PrioridadIncidencia.baja:
        return const BadgeConfig(
          color: AppColors.gray600,
          icon: Icons.arrow_downward,
        );
      case PrioridadIncidencia.media:
        return const BadgeConfig(
          color: AppColors.warning,
          icon: Icons.remove,
        );
      case PrioridadIncidencia.alta:
        return const BadgeConfig(
          color: AppColors.error,
          icon: Icons.arrow_upward,
        );
      case PrioridadIncidencia.critica:
        return const BadgeConfig(
          color: AppColors.emergency,
          icon: Icons.priority_high,
        );
    }
  }
}

/// Configuración de colores e iconos para el badge
class BadgeConfig {
  const BadgeConfig({
    required this.color,
    required this.icon,
  });

  final Color color;
  final IconData icon;
}
