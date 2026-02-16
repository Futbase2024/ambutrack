import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Badge visual para mostrar la prioridad de una incidencia
///
/// Muestra la prioridad con tonos de azul consistentes con el proyecto
class IncidenciaPrioridadBadge extends StatelessWidget {
  const IncidenciaPrioridadBadge({
    required this.prioridad,
    super.key,
  });

  final PrioridadIncidencia prioridad;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _getBackgroundColor(prioridad);
    final Color textColor = _getTextColor(prioridad);

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
            prioridad.nombre,
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

  Color _getBackgroundColor(PrioridadIncidencia prioridad) {
    switch (prioridad) {
      case PrioridadIncidencia.baja:
        return AppColors.primary.withValues(alpha: 0.05);
      case PrioridadIncidencia.media:
        return AppColors.primary.withValues(alpha: 0.1);
      case PrioridadIncidencia.alta:
        return AppColors.primary.withValues(alpha: 0.15);
      case PrioridadIncidencia.critica:
        return AppColors.primary.withValues(alpha: 0.2);
    }
  }

  Color _getTextColor(PrioridadIncidencia prioridad) {
    switch (prioridad) {
      case PrioridadIncidencia.baja:
        return AppColors.primary.withValues(alpha: 0.7);
      case PrioridadIncidencia.media:
        return AppColors.primary;
      case PrioridadIncidencia.alta:
        return AppColors.primary.withValues(alpha: 0.9);
      case PrioridadIncidencia.critica:
        return AppColors.primary;
    }
  }
}
