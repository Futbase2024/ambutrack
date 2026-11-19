import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import 'notificacion_canales.dart';

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

  /// true = este móvil recibe push FCM: la notificación del sistema la pone el
  /// push (app abierta, en segundo plano o cerrada), no este servicio
  bool pushActivo = false;

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
    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    for (final AndroidNotificationChannel canal in NotificacionCanales.android) {
      await android?.createNotificationChannel(canal);
    }
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
    debugPrint('🔔 [LocalNotifications] ========================================');
    debugPrint('🔔 [LocalNotifications] Mostrando notificación: ${notificacion.titulo}');
    debugPrint('🔔 [LocalNotifications] Tipo: ${notificacion.tipo.value}');
    debugPrint('🔔 [LocalNotifications] App en primer plano: $_isAppInForeground');
    debugPrint('🔔 [LocalNotifications] Callback configurado: ${onShowInAppNotification != null}');
    debugPrint('🔔 [LocalNotifications] ========================================');

    // Con push FCM activo, el push muestra la notificación del sistema en cualquier
    // estado de la app (también abierta): ni diálogo in-app ni local, para no duplicar
    if (pushActivo) {
      debugPrint('📱 [LocalNotifications] Push activo - la notificación la muestra FCM');
      return;
    }

    // Sin push (p.ej. sin config de Firebase): diálogo in-app en primer plano
    if (_isAppInForeground) {
      debugPrint('📱 [LocalNotifications] App en primer plano - mostrando diálogo in-app');
      onShowInAppNotification?.call(notificacion);
      debugPrint('📱 [LocalNotifications] Callback llamado');
      return;
    }

    debugPrint('📱 [LocalNotifications] App en segundo plano - mostrando notificación push');
    await mostrarEnSistema(
      id: notificacion.id,
      tipo: notificacion.tipo,
      titulo: notificacion.titulo,
      mensaje: notificacion.mensaje,
      entidadId: notificacion.entidadId,
    );
  }

  /// Muestra la notificación en la bandeja/banner del sistema (cualquier estado de la app)
  Future<void> mostrarEnSistema({
    required String id,
    required NotificacionTipo tipo,
    required String titulo,
    required String mensaje,
    String? entidadId,
  }) async {
    final AndroidNotificationChannel canal = NotificacionCanales.canal(NotificacionCanales.canalId(tipo));

    try {
      await _plugin.show(
        id.hashCode,
        titulo,
        mensaje,
        NotificationDetails(
          android: AndroidNotificationDetails(
            canal.id,
            canal.name,
            channelDescription: canal.description,
            importance: NotificacionCanales.importancia(tipo),
            priority: NotificacionCanales.prioridad(tipo),
            playSound: true,
            enableVibration: true,
            vibrationPattern: NotificacionCanales.vibracion(tipo),
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: BigTextStyleInformation(
              mensaje,
              contentTitle: titulo,
            ),
            category: NotificacionCanales.categoriaAndroid(tipo),
          ),
          iOS: DarwinNotificationDetails(
            presentSound: true,
            presentBadge: true,
            presentAlert: true,
            sound: NotificacionCanales.sonidoIos(tipo),
            subtitle: tipo.label,
            interruptionLevel: NotificacionCanales.interrupcionIos(tipo),
          ),
        ),
        payload: jsonEncode({
          'id': id,
          'tipo': tipo.value,
          'entidadId': entidadId,
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
}
