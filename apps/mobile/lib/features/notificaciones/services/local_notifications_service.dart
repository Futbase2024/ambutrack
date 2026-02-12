import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Servicio de notificaciones locales
///
/// Maneja notificaciones push locales con sonido, vibración y navegación
class LocalNotificationsService {
  LocalNotificationsService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Callback para manejar la navegación cuando se toca una notificación
  Function(String notificacionId, NotificacionTipo tipo, String? entidadId)? onNotificationTap;

  /// Callback para mostrar notificación in-app (cuando la app está en primer plano)
  Function(NotificacionEntity notificacion)? onShowInAppNotification;

  /// Indica si la app está en primer plano (abierta y visible)
  var _isAppInForeground = true;

  /// Actualiza el estado de la aplicación (primer plano o segundo plano)
  void setAppLifecycleState(bool isInForeground) {
    _isAppInForeground = isInForeground;
    debugPrint('📱 [LocalNotifications] App en ${isInForeground ? "primer plano" : "segundo plano"}');
  }

  /// Reproduce el sonido de notificación (para notificaciones in-app)
  Future<void> reproducirSonido() async {
    debugPrint('🔊 [LocalNotifications] Reproduciendo sonido de notificación');

    try {
      // Mostrar notificación silenciosa temporal solo para reproducir sonido
      // Se cancela inmediatamente después
      const notificationId = 999999; // ID temporal

      await _plugin.show(
        notificationId,
        '', // Sin título
        '', // Sin mensaje
        NotificationDetails(
          android: AndroidNotificationDetails(
            'sound_only', // Canal especial solo para sonido
            'Sonidos',
            channelDescription: 'Canal para reproducir sonidos',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 200]), // Vibración corta
            showWhen: false,
            onlyAlertOnce: true,
            visibility: NotificationVisibility.secret, // No mostrar en lockscreen
            styleInformation: const DefaultStyleInformation(false, false),
          ),
          iOS: const DarwinNotificationDetails(
            presentSound: true,
            presentBadge: false,
            presentAlert: false,
          ),
        ),
      );

      // Cancelar la notificación después de 100ms
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await _plugin.cancel(notificationId);

      debugPrint('✅ [LocalNotifications] Sonido reproducido');
    } catch (e) {
      debugPrint('❌ [LocalNotifications] Error al reproducir sonido: $e');
    }
  }

  /// Inicializa el servicio de notificaciones locales
  Future<void> initialize() async {
    debugPrint('🔔 [LocalNotifications] Inicializando servicio...');

    // Configuración para Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Crear canales de notificación (Android)
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    debugPrint('✅ [LocalNotifications] Servicio inicializado correctamente');
  }

  /// Crea los canales de notificación para Android
  Future<void> _createNotificationChannels() async {
    debugPrint('📱 [LocalNotifications] Creando canales Android...');

    // Canal para emergencias (urgente, no silenciable)
    // playSound: true sin 'sound:' = usa sonido por defecto del sistema
    const emergenciaChannel = AndroidNotificationChannel(
      'emergencias_v5',
      'Emergencias',
      description: 'Notificaciones críticas de emergencias que no se pueden silenciar',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Canal para traslados asignados (alta prioridad)
    const trasladosChannel = AndroidNotificationChannel(
      'traslados_v5',
      'Traslados',
      description: 'Nuevos traslados asignados y cambios de estado',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Canal para información general (normal)
    const infoChannel = AndroidNotificationChannel(
      'info_v5',
      'Información',
      description: 'Notificaciones informativas generales',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: false,
      showBadge: true,
    );

    // Canal especial solo para reproducir sonido (notificaciones in-app)
    const soundOnlyChannel = AndroidNotificationChannel(
      'sound_only',
      'Sonidos',
      description: 'Canal para reproducir sonidos en notificaciones in-app',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: false, // No mostrar badge
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(emergenciaChannel);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(trasladosChannel);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(infoChannel);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(soundOnlyChannel);

    debugPrint('✅ [LocalNotifications] Canales Android creados');
  }

  /// Solicita permisos al usuario
  Future<bool> solicitarPermisos() async {
    debugPrint('🔐 [LocalNotifications] Solicitando permisos...');

    // Android 13+ requiere permiso explícito
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      final granted = status.isGranted;
      debugPrint('📱 [LocalNotifications] Permisos Android: ${granted ? "✅" : "❌"}');
      return granted;
    }

    // iOS solicita permisos en initialize, verificamos el estado
    if (Platform.isIOS) {
      final granted = await _plugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
      debugPrint('🍎 [LocalNotifications] Permisos iOS: ${granted ? "✅" : "❌"}');
      return granted;
    }

    return true;
  }

  /// Muestra una notificación local
  Future<void> mostrarNotificacion({
    required NotificacionEntity notificacion,
  }) async {
    debugPrint('🔔 [LocalNotifications] Mostrando notificación: ${notificacion.titulo}');

    // Si la app está en primer plano, mostrar notificación in-app
    if (_isAppInForeground) {
      debugPrint('📱 [LocalNotifications] App en primer plano - mostrando diálogo in-app');
      onShowInAppNotification?.call(notificacion);
      return;
    }

    // Si la app está en segundo plano, mostrar notificación push normal
    debugPrint('📱 [LocalNotifications] App en segundo plano - mostrando notificación push');

    final channelId = _getChannelId(notificacion.tipo);
    final channelName = _getChannelName(channelId);
    final importance = _getImportance(notificacion.tipo);
    final priority = _getPriority(notificacion.tipo);
    final vibrationPattern = _getVibrationPattern(notificacion.tipo);

    try {
      await _plugin.show(
        notificacion.id.hashCode,
        notificacion.titulo,
        notificacion.mensaje,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: _getChannelDescription(channelId),
            importance: importance,
            priority: priority,
            playSound: true,
            enableVibration: true,
            vibrationPattern: vibrationPattern,
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: BigTextStyleInformation(
              notificacion.mensaje,
              contentTitle: notificacion.titulo,
            ),
            category: _getAndroidCategory(notificacion.tipo),
          ),
          iOS: DarwinNotificationDetails(
            presentSound: true,
            presentBadge: true,
            presentAlert: true,
            sound: _getIosSound(notificacion.tipo),
            subtitle: _getIosSubtitle(notificacion.tipo),
            interruptionLevel: _getInterruptionLevel(notificacion.tipo),
          ),
        ),
        payload: jsonEncode({
          'id': notificacion.id,
          'tipo': notificacion.tipo.value,
          'entidadId': notificacion.entidadId,
        }),
      );

      debugPrint('✅ [LocalNotifications] Notificación mostrada correctamente');
    } catch (e) {
      debugPrint('❌ [LocalNotifications] Error al mostrar notificación: $e');
    }
  }

  /// Maneja el tap en una notificación
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('👆 [LocalNotifications] Notificación tocada');

    if (response.payload != null) {
      try {
        final payload = jsonDecode(response.payload!) as Map<String, dynamic>;
        final notificacionId = payload['id'] as String;
        final tipoValue = payload['tipo'] as String;
        final entidadId = payload['entidadId'] as String?;
        final tipo = NotificacionTipo.fromString(tipoValue);

        debugPrint('📍 [LocalNotifications] Navegando a: $tipoValue (entidad: $entidadId)');

        // Llamar al callback si está definido
        onNotificationTap?.call(notificacionId, tipo, entidadId);
      } catch (e) {
        debugPrint('❌ [LocalNotifications] Error al procesar payload: $e');
      }
    }
  }

  /// Cancela una notificación
  Future<void> cancelarNotificacion(String notificacionId) async {
    await _plugin.cancel(notificacionId.hashCode);
    debugPrint('🚫 [LocalNotifications] Notificación cancelada: $notificacionId');
  }

  /// Cancela todas las notificaciones
  Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
    debugPrint('🚫 [LocalNotifications] Todas las notificaciones canceladas');
  }

  // ===== HELPERS =====

  /// Obtiene el ID del canal según el tipo de notificación
  String _getChannelId(NotificacionTipo tipo) {
    switch (tipo) {
      case NotificacionTipo.alerta:
        return 'emergencias_v5';
      case NotificacionTipo.trasladoAsignado:
      case NotificacionTipo.trasladoDesadjudicado:
      case NotificacionTipo.trasladoIniciado:
      case NotificacionTipo.trasladoFinalizado:
      case NotificacionTipo.trasladoCancelado:
        return 'traslados_v5';
      default:
        return 'info_v5';
    }
  }

  /// Obtiene el nombre del canal
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'emergencias_v5':
        return 'Emergencias';
      case 'traslados_v5':
        return 'Traslados';
      default:
        return 'Información';
    }
  }

  /// Obtiene la descripción del canal
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'emergencias_v5':
        return 'Notificaciones críticas de emergencias';
      case 'traslados_v5':
        return 'Nuevos traslados asignados y cambios de estado';
      default:
        return 'Notificaciones informativas generales';
    }
  }

  /// Obtiene la importancia para Android
  Importance _getImportance(NotificacionTipo tipo) {
    switch (tipo) {
      case NotificacionTipo.alerta:
        return Importance.max;
      case NotificacionTipo.trasladoAsignado:
      case NotificacionTipo.trasladoDesadjudicado:
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  /// Obtiene la prioridad para Android
  Priority _getPriority(NotificacionTipo tipo) {
    switch (tipo) {
      case NotificacionTipo.alerta:
        return Priority.max;
      case NotificacionTipo.trasladoAsignado:
      case NotificacionTipo.trasladoDesadjudicado:
        return Priority.high;
      default:
        return Priority.defaultPriority;
    }
  }

  /// Obtiene el patrón de vibración para Android (en milisegundos)
  Int64List? _getVibrationPattern(NotificacionTipo tipo) {
    switch (tipo) {
      case NotificacionTipo.alerta:
        // Patrón agresivo para emergencias: vibración continua
        return Int64List.fromList([0, 500, 200, 500, 200, 500]);
      case NotificacionTipo.trasladoAsignado:
      case NotificacionTipo.trasladoDesadjudicado:
        // Patrón distintivo para traslados
        return Int64List.fromList([0, 300, 200, 300]);
      default:
        // Patrón suave para info
        return Int64List.fromList([0, 200]);
    }
  }

  /// Obtiene la categoría de Android
  AndroidNotificationCategory? _getAndroidCategory(NotificacionTipo tipo) {
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

  /// Obtiene el sonido para iOS
  String? _getIosSound(NotificacionTipo tipo) {
    // Usar sonidos del sistema de iOS
    switch (tipo) {
      case NotificacionTipo.alerta:
        return 'default'; // Sonido por defecto (más fuerte)
      default:
        return null; // Sin sonido personalizado
    }
  }

  /// Obtiene el subtítulo para iOS
  String? _getIosSubtitle(NotificacionTipo tipo) {
    return tipo.label;
  }

  /// Obtiene el nivel de interrupción para iOS
  InterruptionLevel _getInterruptionLevel(NotificacionTipo tipo) {
    switch (tipo) {
      case NotificacionTipo.alerta:
        return InterruptionLevel.critical;
      case NotificacionTipo.trasladoAsignado:
      case NotificacionTipo.trasladoDesadjudicado:
        return InterruptionLevel.timeSensitive;
      default:
        return InterruptionLevel.active;
    }
  }
}
