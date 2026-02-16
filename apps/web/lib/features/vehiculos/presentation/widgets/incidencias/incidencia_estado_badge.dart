import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Badge visual para mostrar el estado de una incidencia
///
/// Muestra el estado con tonos de azul consistentes con el proyecto
class IncidenciaEstadoBadge extends StatelessWidget {
  const IncidenciaEstadoBadge({
    required this.estado,
    super.key,
  });

  final EstadoIncidencia estado;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _getBackgroundColor(estado);
    final Color textColor = _getTextColor(estado);

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: textColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            estado.nombre,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(EstadoIncidencia estado) {
    switch (estado) {
      case EstadoIncidencia.reportada:
        return AppColors.primary.withValues(alpha: 0.05);
      case EstadoIncidencia.enRevision:
        return AppColors.primary.withValues(alpha: 0.1);
      case EstadoIncidencia.enReparacion:
        return AppColors.primary.withValues(alpha: 0.15);
      case EstadoIncidencia.resuelta:
        return AppColors.primary.withValues(alpha: 0.2);
      case EstadoIncidencia.cerrada:
        return AppColors.gray100;
    }
  }

  Color _getTextColor(EstadoIncidencia estado) {
    switch (estado) {
      case EstadoIncidencia.reportada:
        return AppColors.primary.withValues(alpha: 0.7);
      case EstadoIncidencia.enRevision:
        return AppColors.primary;
      case EstadoIncidencia.enReparacion:
        return AppColors.primary.withValues(alpha: 0.9);
      case EstadoIncidencia.resuelta:
        return AppColors.primary;
      case EstadoIncidencia.cerrada:
        return AppColors.gray700;
    }
  }
}
