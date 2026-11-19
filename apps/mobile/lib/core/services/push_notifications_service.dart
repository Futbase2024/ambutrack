import 'dart:async';
import 'dart:io';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../features/notificaciones/services/local_notifications_service.dart';

/// Notificaciones push (Firebase Cloud Messaging, solo como canal de envío)
///
/// - Sin la configuración de Firebase (`google-services.json` /
///   `GoogleService-Info.plist`) el servicio queda desactivado y la app sigue
///   funcionando como antes (avisos por Realtime con la app abierta).
/// - Con sesión iniciada registra el token del móvil en `dispositivos_push`;
///   cada aviso nuevo de `tnotificaciones` llega entonces aunque la app esté cerrada.
/// - Con la app abierta y visible NO se pinta el push: el aviso llega por Realtime y
///   se muestra como diálogo in-app. Si la app está viva pero no visible (persiana,
///   multitarea), el push se pinta en el sistema con [LocalNotificationsService].
class PushNotificationsService {
  PushNotificationsService({
    required LocalNotificationsService local,
    DispositivosPushDataSource? dispositivos,
  })  : _local = local,
        _dispositivos = dispositivos ?? DispositivosPushDataSourceFactory.createSupabase();

  final LocalNotificationsService _local;
  final DispositivosPushDataSource _dispositivos;

  bool _disponible = false;
  bool _sesionActiva = false;
  String? _tokenRegistrado;
  DateTime? _ultimoRegistro;
  static const Duration _intervaloReafirmar = Duration(minutes: 5);
  StreamSubscription<String>? _refreshSub;

  /// Notificación tocada antes de que hubiera sesión (app abierta desde el push)
  RemoteMessage? _pendiente;

  /// Se llama al tocar un push: (id de la notificación, tipo)
  void Function(String? notificacionId, NotificacionTipo tipo)? onAbrirNotificacion;

  /// Inicializa Firebase. Llamar una vez al arrancar, tras Supabase y la DI.
  Future<void> inicializar() async {
    try {
      await Firebase.initializeApp();
      _disponible = true;
    } catch (e) {
      debugPrint('ℹ️ [Push] Desactivado: falta la configuración de Firebase ($e)');
      return;
    }
    // Con la app abierta el aviso es el diálogo in-app: iOS no presenta banner ni sonido
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );
    FirebaseMessaging.onMessage.listen(_enPrimerPlano);
    FirebaseMessaging.onMessageOpenedApp.listen(_abrir);
    final RemoteMessage? inicial = await FirebaseMessaging.instance.getInitialMessage();
    if (inicial != null) {
      _abrir(inicial);
    }
    debugPrint('✅ [Push] Firebase Messaging inicializado');
  }

  /// Con sesión iniciada: pide permiso y registra este móvil para el usuario
  Future<void> activarParaUsuarioActual() async {
    if (!_disponible || _sesionActiva) {
      _entregarPendiente();
      return;
    }
    _sesionActiva = true;
    _entregarPendiente();
    try {
      final NotificationSettings permisos = await FirebaseMessaging.instance.requestPermission();
      if (permisos.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('⚠️ [Push] Permiso de notificaciones denegado');
        return;
      }
      if (Platform.isIOS && !await _esperarTokenApns()) {
        debugPrint('⚠️ [Push] iOS sin token APNs: revisa la capacidad Push Notifications');
        return;
      }
      final String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _registrar(token);
      }
      _refreshSub ??= FirebaseMessaging.instance.onTokenRefresh.listen(_registrar);
    } catch (e) {
      debugPrint('❌ [Push] No se pudo registrar el dispositivo: $e');
    }
  }

  /// Al volver a primer plano: reafirma el registro del token (upsert idempotente).
  /// Si el servidor lo borró (rechazo de FCM), el móvil se recupera solo.
  Future<void> reafirmarRegistro() async {
    if (!_disponible || !_sesionActiva) {
      return;
    }
    final DateTime ahora = DateTime.now();
    final DateTime? ultimo = _ultimoRegistro;
    if (ultimo != null && ahora.difference(ultimo) < _intervaloReafirmar) {
      return;
    }
    try {
      final String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _registrar(token);
      }
    } catch (e) {
      debugPrint('⚠️ [Push] No se pudo reafirmar el registro: $e');
    }
  }

  /// Antes de cerrar sesión: este móvil deja de recibir los avisos del usuario
  Future<void> desactivar() async {
    final String? token = _tokenRegistrado;
    marcarSesionCerrada();
    if (!_disponible || token == null) {
      return;
    }
    try {
      await _dispositivos.eliminar(token);
    } catch (e) {
      debugPrint('⚠️ [Push] No se pudo dar de baja el dispositivo: $e');
    }
  }

  /// La sesión terminó sin pasar por [desactivar] (caducada, etc.).
  /// En el siguiente login el token se reasigna al nuevo usuario.
  void marcarSesionCerrada() {
    _sesionActiva = false;
    _tokenRegistrado = null;
    _ultimoRegistro = null;
    _local.pushActivo = false;
    unawaited(_refreshSub?.cancel());
    _refreshSub = null;
  }

  Future<void> _registrar(String token) async {
    await _dispositivos.registrar(token: token, plataforma: Platform.isIOS ? 'ios' : 'android');
    _tokenRegistrado = token;
    _ultimoRegistro = DateTime.now();
    _local.pushActivo = true;
    debugPrint('✅ [Push] Dispositivo registrado');
  }

  /// En iOS el token FCM necesita antes el de APNs (puede tardar unos segundos)
  Future<bool> _esperarTokenApns() async {
    for (int i = 0; i < 5; i++) {
      if (await FirebaseMessaging.instance.getAPNSToken() != null) {
        return true;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  /// Push recibido con el proceso de la app vivo.
  /// Visible → nada (diálogo in-app por Realtime). No visible → notificación del sistema.
  void _enPrimerPlano(RemoteMessage mensaje) {
    if (_local.enPrimerPlano) {
      debugPrint('📱 [Push] App visible: el aviso se muestra como diálogo in-app');
      return;
    }
    final RemoteNotification? n = mensaje.notification;
    final String? entidadId = mensaje.data['entidad_id'] as String?;
    unawaited(_local.mostrarEnSistema(
      id: mensaje.data['notificacion_id'] as String? ?? mensaje.messageId ?? '${DateTime.now().millisecondsSinceEpoch}',
      tipo: NotificacionTipo.fromString(mensaje.data['tipo'] as String? ?? ''),
      titulo: n?.title ?? '',
      mensaje: n?.body ?? '',
      entidadId: entidadId == null || entidadId.isEmpty ? null : entidadId,
    ));
  }

  void _abrir(RemoteMessage mensaje) {
    if (_sesionActiva && onAbrirNotificacion != null) {
      final String? id = mensaje.data['notificacion_id'] as String?;
      final String tipo = mensaje.data['tipo'] as String? ?? '';
      onAbrirNotificacion!(id, NotificacionTipo.fromString(tipo));
    } else {
      _pendiente = mensaje;
    }
  }

  void _entregarPendiente() {
    final RemoteMessage? pendiente = _pendiente;
    if (pendiente != null && _sesionActiva && onAbrirNotificacion != null) {
      _pendiente = null;
      _abrir(pendiente);
    }
  }
}
