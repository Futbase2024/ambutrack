import 'dart:typed_data';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Canales Android y apariencia de cada tipo de notificación.
///
/// Los IDs de canal deben coincidir con los que usa la Edge Function `enviar-push`.
abstract final class NotificacionCanales {
  static const String emergencias = 'emergencias_v5';
  static const String traslados = 'traslados_v5';
  static const String caducidades = 'caducidades_v5';
  static const String info = 'info_v5';
  static const String soloSonido = 'sound_only';

  /// Canales que se crean al iniciar la app (Android)
  static const List<AndroidNotificationChannel> android = <AndroidNotificationChannel>[
    // playSound: true sin 'sound:' = usa sonido por defecto del sistema
    AndroidNotificationChannel(
      emergencias,
      'Emergencias',
      description: 'Notificaciones críticas de emergencias que no se pueden silenciar',
      importance: Importance.max,
    ),
    AndroidNotificationChannel(
      traslados,
      'Traslados',
      description: 'Nuevos traslados asignados y cambios de estado',
      importance: Importance.high,
    ),
    AndroidNotificationChannel(
      caducidades,
      'Caducidades',
      description: 'Alertas de productos próximos a caducar',
      importance: Importance.high,
    ),
    AndroidNotificationChannel(
      info,
      'Información',
      description: 'Notificaciones informativas generales',
      enableVibration: false,
    ),
    AndroidNotificationChannel(
      soloSonido,
      'Sonidos',
      description: 'Canal para reproducir sonidos en notificaciones in-app',
      importance: Importance.high,
      showBadge: false,
    ),
  ];

  /// Tipos con prioridad alta (aparecen como banner aunque la app esté abierta)
  static bool _esAlta(NotificacionTipo tipo) =>
      tipo == NotificacionTipo.trasladoAsignado ||
      tipo == NotificacionTipo.trasladoDesadjudicado ||
      tipo == NotificacionTipo.alertaCaducidad ||
      tipo == NotificacionTipo.incidenciaVehiculoReportada;

  static String canalId(NotificacionTipo tipo) {
    switch (tipo) {
      case NotificacionTipo.alerta:
        return emergencias;
      case NotificacionTipo.trasladoAsignado:
      case NotificacionTipo.trasladoDesadjudicado:
      case NotificacionTipo.trasladoIniciado:
      case NotificacionTipo.trasladoFinalizado:
      case NotificacionTipo.trasladoCancelado:
      case NotificacionTipo.incidenciaVehiculoReportada:
        return traslados;
      case NotificacionTipo.alertaCaducidad:
        return caducidades;
      default:
        return info;
    }
  }

  static AndroidNotificationChannel canal(String id) =>
      android.firstWhere((AndroidNotificationChannel c) => c.id == id, orElse: () => android[3]);

  static Importance importancia(NotificacionTipo tipo) {
    if (tipo == NotificacionTipo.alerta) {
      return Importance.max;
    }
    return _esAlta(tipo) ? Importance.high : Importance.defaultImportance;
  }

  static Priority prioridad(NotificacionTipo tipo) {
    if (tipo == NotificacionTipo.alerta) {
      return Priority.max;
    }
    return _esAlta(tipo) ? Priority.high : Priority.defaultPriority;
  }

  /// Patrón de vibración Android (ms)
  static Int64List vibracion(NotificacionTipo tipo) {
    switch (tipo) {
      case NotificacionTipo.alerta:
        return Int64List.fromList(<int>[0, 500, 200, 500, 200, 500]);
      case NotificacionTipo.trasladoAsignado:
      case NotificacionTipo.trasladoDesadjudicado:
      case NotificacionTipo.incidenciaVehiculoReportada:
        return Int64List.fromList(<int>[0, 300, 200, 300]);
      case NotificacionTipo.alertaCaducidad:
        return Int64List.fromList(<int>[0, 250, 100, 250]);
      default:
        return Int64List.fromList(<int>[0, 200]);
    }
  }

  static AndroidNotificationCategory? categoriaAndroid(NotificacionTipo tipo) {
    switch (tipo) {
      case NotificacionTipo.alerta:
        return AndroidNotificationCategory.alarm;
      case NotificacionTipo.trasladoAsignado:
      case NotificacionTipo.trasladoDesadjudicado:
        return AndroidNotificationCategory.message;
      default:
        return null;
    }
  }

  /// Sonido iOS: 'default' (más fuerte) para alertas; null = sonido estándar
  static String? sonidoIos(NotificacionTipo tipo) => tipo == NotificacionTipo.alerta ? 'default' : null;

  static InterruptionLevel interrupcionIos(NotificacionTipo tipo) {
    if (tipo == NotificacionTipo.alerta) {
      return InterruptionLevel.critical;
    }
    return _esAlta(tipo) ? InterruptionLevel.timeSensitive : InterruptionLevel.active;
  }
}
