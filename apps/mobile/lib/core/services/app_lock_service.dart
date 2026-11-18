import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import 'preferencias_dispositivo_service.dart';

/// Bloqueo de la app por inactividad (la sesión de Supabase sigue abierta)
///
/// - Modo personal: 15 min sin uso → pide huella/Face ID o PIN
/// - Modo compartido: 5 min sin uso → pide PIN (o cambiar de usuario)
/// - Al volver de segundo plano tras superar el tiempo también se bloquea
class AppLockService extends ChangeNotifier {
  AppLockService(this._preferencias);

  final PreferenciasDispositivoService _preferencias;
  final LocalAuthentication _localAuth = LocalAuthentication();

  static const Duration _inactividadPersonal = Duration(minutes: 15);
  static const Duration _inactividadCompartido = Duration(minutes: 5);

  bool _bloqueada = false;
  bool _activo = false;
  DateTime _ultimaActividad = DateTime.now();
  Timer? _timer;

  bool get bloqueada => _bloqueada;

  Duration get _limite => _preferencias.esCompartido ? _inactividadCompartido : _inactividadPersonal;

  /// Activa/desactiva el control (solo con sesión iniciada)
  ///
  /// [sesionRestaurada]: la sesión venía guardada al abrir la app. Si hay
  /// biometría activa o el dispositivo es compartido se pide desbloqueo.
  void setSesionActiva({required bool value, bool sesionRestaurada = false}) {
    _activo = value;
    if (!value) {
      _timer?.cancel();
      _actualizar(bloqueada: false);
      return;
    }
    if (sesionRestaurada && (_preferencias.biometriaActiva || _preferencias.esCompartido)) {
      bloquear();
      return;
    }
    registrarActividad();
  }

  /// Cualquier toque en pantalla reinicia el contador
  void registrarActividad() {
    if (!_activo || _bloqueada) {
      return;
    }
    _ultimaActividad = DateTime.now();
    _timer?.cancel();
    _timer = Timer(_limite, bloquear);
  }

  void irASegundoPlano() {
    _timer?.cancel();
  }

  void volverAPrimerPlano() {
    if (!_activo || _bloqueada) {
      return;
    }
    final Duration inactivo = DateTime.now().difference(_ultimaActividad);
    if (inactivo >= _limite) {
      bloquear();
    } else {
      _timer = Timer(_limite - inactivo, bloquear);
    }
  }

  void bloquear() {
    if (!_activo) {
      return;
    }
    debugPrint('🔒 [AppLock] App bloqueada por inactividad');
    _timer?.cancel();
    _actualizar(bloqueada: true);
  }

  void desbloquear() {
    debugPrint('🔓 [AppLock] App desbloqueada');
    _actualizar(bloqueada: false);
    registrarActividad();
  }

  /// El dispositivo tiene huella/cara configurada
  Future<bool> biometriaDisponible() async {
    try {
      final bool soportado = await _localAuth.isDeviceSupported();
      final bool puede = await _localAuth.canCheckBiometrics;
      if (!soportado || !puede) {
        return false;
      }
      final List<BiometricType> tipos = await _localAuth.getAvailableBiometrics();
      return tipos.isNotEmpty;
    } catch (e) {
      debugPrint('⚠️ [AppLock] Biometría no disponible: $e');
      return false;
    }
  }

  /// Pide huella/cara. true = verificado
  Future<bool> autenticarBiometria() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Desbloquea EmerTrack',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint('⚠️ [AppLock] Error en biometría: $e');
      return false;
    }
  }

  void _actualizar({required bool bloqueada}) {
    if (_bloqueada == bloqueada) {
      return;
    }
    _bloqueada = bloqueada;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
