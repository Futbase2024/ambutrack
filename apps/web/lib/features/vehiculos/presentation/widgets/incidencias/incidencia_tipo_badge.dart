import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Badge visual para mostrar el tipo de incidencia
///
/// Muestra el tipo con colores diferenciados:
/// - Mecánica: Rojo (error)
/// - Eléctrica: Naranja (warning)
/// - Carrocería: Azul (info)
/// - Neumáticos: Gris oscuro (gray700)
/// - Limpieza: Verde (success)
/// - Equipamiento: Amarillo (secondary)
/// - Documentación: Azul primario (primary)
/// - Otra: Gris (gray600)
class IncidenciaTipoBadge extends StatelessWidget {
  const IncidenciaTipoBadge({
    required this.tipo,
    super.key,
  });

  final TipoIncidencia tipo;

  @override
  Widget build(BuildContext context) {
    final BadgeConfig config = _getConfig(tipo);

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: config.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            tipo.nombre,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ),
      ),
    );
  }

  BadgeConfig _getConfig(TipoIncidencia tipo) {
    switch (tipo) {
      case TipoIncidencia.mecanica:
        return const BadgeConfig(color: AppColors.error);
      case TipoIncidencia.electrica:
        return const BadgeConfig(color: AppColors.warning);
      case TipoIncidencia.carroceria:
        return const BadgeConfig(color: AppColors.info);
      case TipoIncidencia.neumaticos:
        return const BadgeConfig(color: AppColors.gray700);
      case TipoIncidencia.limpieza:
        return const BadgeConfig(color: AppColors.success);
      case TipoIncidencia.equipamiento:
        return const BadgeConfig(color: AppColors.secondary);
      case TipoIncidencia.documentacion:
        return const BadgeConfig(color: AppColors.primary);
      case TipoIncidencia.otra:
        return const BadgeConfig(color: AppColors.gray600);
    }
  }
}

/// Configuración de colores para el badge
class BadgeConfig {
  const BadgeConfig({
    required this.color,
  });

  final Color color;
}
