import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Badge visual para mostrar el estado de una incidencia
///
/// Muestra el estado con colores diferenciados según el tipo:
/// - Reportada: Azul (info)
/// - En Revisión: Naranja (warning)
/// - En Reparación: Amarillo (secondary)
/// - Resuelta: Verde (success)
/// - Cerrada: Gris (gray600)
class IncidenciaEstadoBadge extends StatelessWidget {
  const IncidenciaEstadoBadge({
    required this.estado,
    super.key,
  });

  final EstadoIncidencia estado;

  @override
  Widget build(BuildContext context) {
    final BadgeConfig config = _getConfig(estado);

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
                estado.nombre,
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

  BadgeConfig _getConfig(EstadoIncidencia estado) {
    switch (estado) {
      case EstadoIncidencia.reportada:
        return const BadgeConfig(
          color: AppColors.info,
          icon: Icons.report_problem,
        );
      case EstadoIncidencia.enRevision:
        return const BadgeConfig(
          color: AppColors.warning,
          icon: Icons.search,
        );
      case EstadoIncidencia.enReparacion:
        return const BadgeConfig(
          color: AppColors.secondary,
          icon: Icons.build,
        );
      case EstadoIncidencia.resuelta:
        return const BadgeConfig(
          color: AppColors.success,
          icon: Icons.check_circle,
        );
      case EstadoIncidencia.cerrada:
        return const BadgeConfig(
          color: AppColors.gray600,
          icon: Icons.archive,
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
