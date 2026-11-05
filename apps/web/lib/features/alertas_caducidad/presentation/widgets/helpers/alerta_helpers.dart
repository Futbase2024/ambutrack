import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Configuración visual para cada tipo de alerta
class AlertaTipoConfig {
  const AlertaTipoConfig({
    required this.icon,
    required this.color,
    required this.label,
    required this.routeName,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String routeName;
}

/// Devuelve la configuración visual para un tipo de alerta
AlertaTipoConfig getAlertaTipoConfig(AlertaTipo tipo) {
  switch (tipo) {
    case AlertaTipo.seguro:
      return const AlertaTipoConfig(
        icon: Icons.verified_user,
        color: AppColors.info,
        label: 'Seguro',
        routeName: 'flota_documentacion',
      );
    case AlertaTipo.itv:
      return const AlertaTipoConfig(
        icon: Icons.build,
        color: AppColors.warning,
        label: 'ITV',
        routeName: 'flota_itv',
      );
    case AlertaTipo.homologacion:
      return const AlertaTipoConfig(
        icon: Icons.description,
        color: AppColors.secondaryLight,
        label: 'Homologación',
        routeName: 'flota_documentacion',
      );
    case AlertaTipo.revisionTecnica:
      return const AlertaTipoConfig(
        icon: Icons.handyman,
        color: AppColors.secondary,
        label: 'Revisión Técnica',
        routeName: 'flota_itv',
      );
    case AlertaTipo.mantenimiento:
      return const AlertaTipoConfig(
        icon: Icons.build_circle,
        color: AppColors.primary,
        label: 'Mantenimiento',
        routeName: 'flota_mantenimiento_preventivo',
      );
    case AlertaTipo.revision:
      return const AlertaTipoConfig(
        icon: Icons.miscellaneous_services,
        color: AppColors.success,
        label: 'Revisión',
        routeName: 'flota_mantenimiento_preventivo',
      );
  }
}

/// Color según los días restantes para la caducidad
Color getDiasRestantesColor(int diasRestantes) {
  if (diasRestantes <= 0) {
    return AppColors.emergency;
  }
  if (diasRestantes <= 3) {
    return AppColors.emergency;
  }
  if (diasRestantes <= 7) {
    return AppColors.error;
  }
  return AppColors.warning;
}

/// Texto descriptivo para el badge de días restantes
String getDiasRestantesText(int diasRestantes) {
  if (diasRestantes < 0) {
    return 'VENCIDO HACE ${-diasRestantes} DÍA${-diasRestantes == 1 ? '' : 'S'}';
  }
  if (diasRestantes == 0) {
    return 'VENCE HOY';
  }
  if (diasRestantes == 1) {
    return 'VENCE MAÑANA';
  }
  return 'VENCE EN $diasRestantes DÍAS';
}

/// Nombre de ruta de navegación para una alerta concreta
String? getRouteForAlerta(AlertaCaducidadEntity alerta) {
  if (alerta.entidadKey.startsWith('VEHICULO:')) {
    return 'vehiculos';
  }
  return getAlertaTipoConfig(alerta.tipo).routeName;
}

/// Label de severidad con color
({String label, Color color}) getSeveridadConfig(AlertaSeveridad severidad) {
  switch (severidad) {
    case AlertaSeveridad.critica:
      return (label: 'CRÍTICA', color: AppColors.emergency);
    case AlertaSeveridad.alta:
      return (label: 'ALTA', color: AppColors.error);
    case AlertaSeveridad.media:
      return (label: 'MEDIA', color: AppColors.warning);
    case AlertaSeveridad.baja:
      return (
        label: 'BAJA',
        color: AppColors.info,
      );
  }
}
