import 'package:flutter/foundation.dart';

/// Servicio de caché para alertas de caducidad revisadas
///
/// Almacena cuando el usuario revisó las alertas para no mostrarlas
/// repetidamente el mismo día (durante la sesión actual de la app)
class AlertasCaducidadCacheService {
  AlertasCaducidadCacheService._();

  static final AlertasCaducidadCacheService _instance =
      AlertasCaducidadCacheService._();

  static AlertasCaducidadCacheService get instance => _instance;

  /// Caché en memoria: vehiculoId -> fecha de revisión
  static final Map<String, String> _alertasRevisadas = {};

  /// Marca las alertas como revisadas para hoy
  void marcarComoRevisadas(String vehiculoId) {
    final hoy = DateTime.now();
    final fechaStr =
        '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

    _alertasRevisadas[vehiculoId] = fechaStr;

    debugPrint(
        '✅ AlertasCaducidadCache: Marcadas como revisadas - $fechaStr para vehículo $vehiculoId');
  }

  /// Verifica si las alertas ya fueron revisadas hoy
  bool fueronRevisadasHoy(String vehiculoId) {
    final fechaGuardada = _alertasRevisadas[vehiculoId];

    // Si no hay datos guardados, no fueron revisadas
    if (fechaGuardada == null) {
      return false;
    }

    // Verificar si la fecha guardada es hoy
    final hoy = DateTime.now();
    final fechaHoyStr =
        '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

    final revisadasHoy = fechaGuardada == fechaHoyStr;

    if (revisadasHoy) {
      debugPrint(
          'ℹ️ AlertasCaducidadCache: Ya fueron revisadas hoy ($fechaHoyStr)');
    } else {
      // Si la fecha es de otro día, limpiarla
      _alertasRevisadas.remove(vehiculoId);
      debugPrint(
          '🗑️ AlertasCaducidadCache: Fecha antigua detectada, limpiando caché');
    }

    return revisadasHoy;
  }

  /// Limpia la caché (útil para testing o para forzar mostrar alertas)
  void limpiarCache() {
    _alertasRevisadas.clear();
    debugPrint('🗑️ AlertasCaducidadCache: Caché limpiada');
  }

  /// Limpia la caché de un vehículo específico
  void limpiarCacheVehiculo(String vehiculoId) {
    _alertasRevisadas.remove(vehiculoId);
    debugPrint(
        '🗑️ AlertasCaducidadCache: Caché limpiada para vehículo $vehiculoId');
  }
}
