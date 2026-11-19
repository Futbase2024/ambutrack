import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/registro_horario/presentation/bloc/registro_horario_bloc.dart';
import '../../features/registro_horario/presentation/bloc/registro_horario_state.dart';

/// Decide si se debe enviar la posición GPS en este momento.
///
/// Solo con la jornada fichada ("dentro"), la app en primer plano, sesión
/// iniciada y sin haber detectado que el usuario no tiene vehículo hoy.
@visibleForTesting
bool debeEnviarGps({
  required bool fichado,
  required bool enPrimerPlano,
  required bool autenticado,
  required bool sinVehiculo,
}) =>
    fichado && enPrimerPlano && autenticado && !sinVehiculo;

/// Estado de fichaje a partir del estado del [RegistroHorarioBloc].
/// Devuelve `null` si el estado no informa del fichaje (cargando, error...).
@visibleForTesting
EstadoFichaje? estadoFichajeDe(RegistroHorarioState state) {
  return switch (state) {
    RegistroHorarioLoaded(:final EstadoFichaje estadoActual) => estadoActual,
    RegistroHorarioLoadedWithContext(:final EstadoFichaje estadoActual) => estadoActual,
    _ => null,
  };
}

/// Error del servidor que indica que el usuario no tiene vehículo en su turno
@visibleForTesting
bool esErrorSinVehiculo(Object error) {
  final String msg = error.toString();
  return msg.contains('P0002') || msg.contains('vehículo asignado');
}

/// Envía periódicamente la posición del vehículo mientras la tripulación
/// tiene la jornada fichada y la app está abierta.
///
/// El vehículo NO se envía: el servidor (`fn_registrar_ubicacion`) lo deduce
/// del turno de hoy del usuario, de modo que nadie puede enviar posiciones
/// de otra ambulancia.
class GpsTrackingService {
  GpsTrackingService({
    required RegistroHorarioBloc registroHorarioBloc,
    UbicacionesVehiculoDataSource? dataSource,
    this.intervalo = const Duration(seconds: 30),
  })  : _registroBloc = registroHorarioBloc,
        _dataSource = dataSource ?? UbicacionesVehiculoDataSourceFactory.createSupabase();

  final RegistroHorarioBloc _registroBloc;
  final UbicacionesVehiculoDataSource _dataSource;

  /// Cada cuánto se envía la posición
  final Duration intervalo;

  StreamSubscription<RegistroHorarioState>? _registroSub;
  Timer? _timer;
  bool _fichado = false;
  bool _enPrimerPlano = true;
  bool _autenticado = false;
  bool _sinVehiculo = false;
  bool _enviando = false;

  /// El permiso de ubicación solo se pide una vez por sesión (no insistir)
  bool _permisoSolicitado = false;

  bool get activo => _timer != null;

  /// Empieza a escuchar el fichaje (llamar una vez al arrancar la app)
  void iniciar() {
    _registroSub ??= _registroBloc.stream.listen(_onRegistro);
    _onRegistro(_registroBloc.state);
  }

  /// Sesión iniciada o cerrada
  void setAutenticado({required bool value}) {
    _autenticado = value;
    if (!value) {
      _sinVehiculo = false;
      _permisoSolicitado = false;
    }
    _evaluar();
  }

  /// App en primer plano (resumed) o en segundo plano
  void setPrimerPlano({required bool value}) {
    _enPrimerPlano = value;
    _evaluar();
  }

  void _onRegistro(RegistroHorarioState state) {
    final EstadoFichaje? estado = estadoFichajeDe(state);
    if (estado == null) {
      return;
    }
    final bool fichado = estado == EstadoFichaje.dentro;
    if (fichado != _fichado) {
      // Un nuevo fichaje puede traer un turno con vehículo: se reintenta
      _sinVehiculo = false;
    }
    _fichado = fichado;
    _evaluar();
  }

  void _evaluar() {
    final bool debe = debeEnviarGps(
      fichado: _fichado,
      enPrimerPlano: _enPrimerPlano,
      autenticado: _autenticado,
      sinVehiculo: _sinVehiculo,
    );
    if (debe && _timer == null) {
      debugPrint('📍 [GPS] Seguimiento iniciado (cada ${intervalo.inSeconds}s)');
      _timer = Timer.periodic(intervalo, (_) => unawaited(_enviar()));
      unawaited(_enviar());
    } else if (!debe && _timer != null) {
      debugPrint('📍 [GPS] Seguimiento detenido');
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<bool> _tienePermiso() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied && !_permisoSolicitado) {
      _permisoSolicitado = true;
      permiso = await Geolocator.requestPermission();
    }
    return permiso == LocationPermission.always || permiso == LocationPermission.whileInUse;
  }

  Future<void> _enviar() async {
    if (_enviando) {
      return;
    }
    _enviando = true;
    try {
      if (!await _tienePermiso()) {
        debugPrint('⚠️ [GPS] Sin permiso o GPS desactivado; no se envía la posición');
        return;
      }
      final Position p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)),
      );
      await _dataSource.registrar(
        latitud: p.latitude,
        longitud: p.longitude,
        velocidadKmh: p.speed >= 0 ? p.speed * 3.6 : null,
        precisionMetros: p.accuracy >= 0 ? p.accuracy : null,
        direccionGrados: p.heading >= 0 ? p.heading : null,
      );
    } catch (e) {
      if (esErrorSinVehiculo(e)) {
        debugPrint('ℹ️ [GPS] Sin vehículo en el turno de hoy; se pausa el seguimiento');
        _sinVehiculo = true;
        _evaluar();
      } else {
        debugPrint('❌ [GPS] Error al enviar la posición: $e');
      }
    } finally {
      _enviando = false;
    }
  }

  Future<void> dispose() async {
    _timer?.cancel();
    _timer = null;
    await _registroSub?.cancel();
    _registroSub = null;
  }
}
