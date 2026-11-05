import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Configuración visual para cada tipo de notificación
class NotificacionTipoConfig {
  const NotificacionTipoConfig({
    required this.icon,
    required this.color,
    required this.label,
    this.routeName,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String? routeName;
}

/// Devuelve la configuración visual para un tipo de notificación
NotificacionTipoConfig getNotificacionTipoConfig(NotificacionTipo tipo) {
  switch (tipo) {
    case NotificacionTipo.incidenciaVehiculoReportada:
      return const NotificacionTipoConfig(
        icon: Icons.car_crash_outlined,
        color: AppColors.error,
        label: 'Incidencia de Vehículo',
        routeName: 'historial_averias',
      );
    case NotificacionTipo.ausenciaSolicitada:
      return const NotificacionTipoConfig(
        icon: Icons.calendar_today_outlined,
        color: AppColors.info,
        label: 'Ausencia Solicitada',
      );
    case NotificacionTipo.ausenciaAprobada:
      return const NotificacionTipoConfig(
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        label: 'Ausencia Aprobada',
      );
    case NotificacionTipo.ausenciaRechazada:
      return const NotificacionTipoConfig(
        icon: Icons.cancel_outlined,
        color: AppColors.error,
        label: 'Ausencia Rechazada',
      );
    case NotificacionTipo.vacacionSolicitada:
      return const NotificacionTipoConfig(
        icon: Icons.calendar_today_outlined,
        color: AppColors.info,
        label: 'Vacaciones Solicitadas',
      );
    case NotificacionTipo.vacacionAprobada:
      return const NotificacionTipoConfig(
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        label: 'Vacaciones Aprobadas',
      );
    case NotificacionTipo.vacacionRechazada:
      return const NotificacionTipoConfig(
        icon: Icons.cancel_outlined,
        color: AppColors.error,
        label: 'Vacaciones Rechazadas',
      );
    case NotificacionTipo.cambioTurno:
      return const NotificacionTipoConfig(
        icon: Icons.swap_horiz_outlined,
        color: AppColors.success,
        label: 'Cambio de Turno',
      );
    case NotificacionTipo.trasladoAsignado:
      return const NotificacionTipoConfig(
        icon: Icons.local_shipping_outlined,
        color: AppColors.success,
        label: 'Traslado Asignado',
      );
    case NotificacionTipo.trasladoDesadjudicado:
      return const NotificacionTipoConfig(
        icon: Icons.remove_circle_outline,
        color: AppColors.warning,
        label: 'Traslado Desasignado',
      );
    case NotificacionTipo.trasladoIniciado:
      return const NotificacionTipoConfig(
        icon: Icons.play_arrow_outlined,
        color: AppColors.success,
        label: 'Traslado Iniciado',
      );
    case NotificacionTipo.trasladoFinalizado:
      return const NotificacionTipoConfig(
        icon: Icons.done_all_outlined,
        color: AppColors.success,
        label: 'Traslado Finalizado',
      );
    case NotificacionTipo.trasladoCancelado:
      return const NotificacionTipoConfig(
        icon: Icons.block_outlined,
        color: AppColors.warning,
        label: 'Traslado Cancelado',
      );
    case NotificacionTipo.checklistPendiente:
      return const NotificacionTipoConfig(
        icon: Icons.checklist_outlined,
        color: AppColors.warning,
        label: 'Checklist Pendiente',
      );
    case NotificacionTipo.alerta:
      return const NotificacionTipoConfig(
        icon: Icons.warning_amber_outlined,
        color: AppColors.emergency,
        label: 'Alerta',
      );
    case NotificacionTipo.alertaCaducidad:
      return const NotificacionTipoConfig(
        icon: Icons.event_busy_outlined,
        color: AppColors.warning,
        label: 'Alerta de Caducidad',
      );
    case NotificacionTipo.agendaPendiente:
      return const NotificacionTipoConfig(
        icon: Icons.event_note_outlined,
        color: AppColors.info,
        label: 'Pendiente Programado',
        routeName: 'servicios_agenda_pendientes',
      );
    case NotificacionTipo.info:
      return const NotificacionTipoConfig(
        icon: Icons.info_outlined,
        color: AppColors.info,
        label: 'Información',
      );
  }
}
