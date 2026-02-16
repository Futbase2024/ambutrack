import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Badge visual para mostrar el tipo de incidencia
///
/// Muestra el tipo con colores sobrios y uniformes
class IncidenciaTipoBadge extends StatelessWidget {
  const IncidenciaTipoBadge({
    required this.tipo,
    super.key,
  });

  final TipoIncidencia tipo;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Text(
            tipo.nombre,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
            ),
          ),
        ),
      ),
    );
  }
}
