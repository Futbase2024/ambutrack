import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Color asociado a cada prioridad de incidencia
Color colorPrioridadIncidencia(String? prioridad) {
  return switch (prioridad) {
    'critica' => AppColors.emergency,
    'alta' => AppColors.highPriority,
    'media' => AppColors.mediumPriority,
    'baja' => AppColors.lowPriority,
    _ => AppColors.gray500,
  };
}

/// Chips de matrícula y prioridad para las notificaciones de incidencia de vehículo
class IncidenciaNotificacionChips extends StatelessWidget {
  const IncidenciaNotificacionChips({super.key, required this.notificacion});

  final NotificacionEntity notificacion;

  @override
  Widget build(BuildContext context) {
    final Object? matricula = notificacion.metadata['matricula'];
    final Object? prioridad = notificacion.metadata['prioridad'];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: <Widget>[
        if (matricula is String && matricula.isNotEmpty)
          IncidenciaChip(
            icon: Icons.directions_car_filled_rounded,
            texto: matricula,
            color: AppColors.primary,
          ),
        if (prioridad is String && prioridad.isNotEmpty)
          IncidenciaChip(
            icon: Icons.flag_rounded,
            texto: 'Prioridad ${prioridad.toUpperCase()}',
            color: colorPrioridadIncidencia(prioridad),
          ),
      ],
    );
  }
}

/// Badge ajustado al texto con icono
class IncidenciaChip extends StatelessWidget {
  const IncidenciaChip({super.key, required this.icon, required this.texto, required this.color});

  final IconData icon;
  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
