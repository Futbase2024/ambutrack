import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Cómo se usa el dispositivo
enum ModoDispositivo {
  /// Un técnico por dispositivo: DNI recordado + huella/Face ID
  personal('personal', 'Personal (un técnico)'),

  /// Tablet/móvil de la ambulancia: varios técnicos, se cierra sesión al acabar
  compartido('compartido', 'Compartido (por ambulancia)');

  const ModoDispositivo(this.value, this.label);

  final String value;
  final String label;

  static ModoDispositivo fromString(String? value) {
    return value == compartido.value ? compartido : personal;
  }
}

/// Usuario que ha iniciado sesión en el dispositivo (modo compartido)
class UsuarioReciente {
  const UsuarioReciente({required this.dni, required this.nombre});

  final String dni;
  final String nombre;

  Map<String, String> toMap() => <String, String>{'dni': dni, 'nombre': nombre};

  static UsuarioReciente? fromMap(dynamic value) {
    if (value is! Map) {
      return null;
    }
    final Object? dni = value['dni'];
    final Object? nombre = value['nombre'];
    return dni is String && nombre is String ? UsuarioReciente(dni: dni, nombre: nombre) : null;
  }
}

/// Preferencias locales del dispositivo (Hive)
///
/// No guarda credenciales: solo el DNI recordado, el modo del dispositivo,
/// si la biometría está activa y los últimos usuarios (modo compartido).
class PreferenciasDispositivoService extends ChangeNotifier {
  static const String _box = 'preferencias_dispositivo';
  static const String _kModo = 'modo';
  static const String _kRecordarDni = 'recordar_dni';
  static const String _kDni = 'dni';
  static const String _kBiometria = 'biometria';
  static const String _kRecientes = 'usuarios_recientes';
  static const String _kBiometriaPreguntada = 'biometria_preguntada';
  static const int _maxRecientes = 6;

  Box<dynamic>? _prefs;

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _prefs = await Hive.openBox<dynamic>(_box);
      debugPrint('✅ [PreferenciasDispositivo] Cargadas (modo: ${modo.value})');
    } catch (e) {
      debugPrint('❌ [PreferenciasDispositivo] No se pudieron abrir: $e');
    }
  }

  ModoDispositivo get modo => ModoDispositivo.fromString(_prefs?.get(_kModo) as String?);

  bool get esCompartido => modo == ModoDispositivo.compartido;

  bool get recordarDni => _prefs?.get(_kRecordarDni, defaultValue: true) as bool? ?? true;

  String? get dniRecordado => recordarDni && !esCompartido ? _prefs?.get(_kDni) as String? : null;

  /// La biometría solo se usa en modo personal
  bool get biometriaActiva => !esCompartido && (_prefs?.get(_kBiometria, defaultValue: false) as bool? ?? false);

  /// Ya se ofreció activar la biometría tras el primer login
  bool get biometriaPreguntada => _prefs?.get(_kBiometriaPreguntada, defaultValue: false) as bool? ?? false;

  Future<void> marcarBiometriaPreguntada() async {
    await _prefs?.put(_kBiometriaPreguntada, true);
  }

  List<UsuarioReciente> get usuariosRecientes {
    final List<dynamic> raw = _prefs?.get(_kRecientes, defaultValue: <dynamic>[]) as List<dynamic>? ?? <dynamic>[];
    return raw.map(UsuarioReciente.fromMap).whereType<UsuarioReciente>().toList();
  }

  Future<void> setModo(ModoDispositivo modo) async {
    await _prefs?.put(_kModo, modo.value);
    if (modo == ModoDispositivo.compartido) {
      await _prefs?.put(_kBiometria, false);
      await _prefs?.delete(_kDni);
    }
    notifyListeners();
  }

  Future<void> setBiometria({required bool activa}) async {
    await _prefs?.put(_kBiometria, activa);
    notifyListeners();
  }

  /// Guarda lo necesario tras un login correcto
  Future<void> registrarLogin({
    required String dni,
    required String nombre,
    required bool recordar,
  }) async {
    if (esCompartido) {
      final List<UsuarioReciente> lista = usuariosRecientes.where((UsuarioReciente u) => u.dni != dni).toList()
        ..insert(0, UsuarioReciente(dni: dni, nombre: nombre));
      await _prefs?.put(
        _kRecientes,
        lista.take(_maxRecientes).map((UsuarioReciente u) => u.toMap()).toList(),
      );
    } else {
      await _prefs?.put(_kRecordarDni, recordar);
      if (recordar) {
        await _prefs?.put(_kDni, dni);
      } else {
        await _prefs?.delete(_kDni);
      }
    }
    notifyListeners();
  }

  Future<void> quitarUsuarioReciente(String dni) async {
    final List<UsuarioReciente> lista = usuariosRecientes.where((UsuarioReciente u) => u.dni != dni).toList();
    await _prefs?.put(_kRecientes, lista.map((UsuarioReciente u) => u.toMap()).toList());
    notifyListeners();
  }
}
