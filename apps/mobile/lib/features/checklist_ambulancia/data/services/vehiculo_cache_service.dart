import 'package:flutter/foundation.dart';

/// Servicio de caché para vehículo asignado
///
/// Almacena en memoria el vehículo asignado para evitar consultas repetidas
/// durante la misma sesión de la app
class VehiculoCacheService {
  VehiculoCacheService._();

  static final VehiculoCacheService instance = VehiculoCacheService._();

  // Cache: Map<personalId, VehiculoCache>
  final Map<String, _VehiculoCache> _cache = {};

  /// Duración de la caché (5 minutos)
  static const _cacheDuration = Duration(minutes: 5);

  /// Obtiene el vehículo asignado desde la caché
  ///
  /// Retorna null si no está en caché o si expiró
  String? getVehiculoAsignado(String personalId) {
    final cached = _cache[personalId];

    if (cached == null) {
      debugPrint('🚗 VehiculoCache: No hay caché para $personalId');
      return null;
    }

    final now = DateTime.now();
    final expired = now.difference(cached.timestamp) > _cacheDuration;

    if (expired) {
      debugPrint('🚗 VehiculoCache: Caché expirada para $personalId');
      _cache.remove(personalId);
      return null;
    }

    debugPrint(
      '🚗 VehiculoCache: Hit - vehiculoId: ${cached.vehiculoId}',
    );
    return cached.vehiculoId;
  }

  /// Almacena el vehículo asignado en la caché
  void setVehiculoAsignado(String personalId, String? vehiculoId) {
    if (vehiculoId == null) {
      debugPrint('🚗 VehiculoCache: Limpiando caché para $personalId');
      _cache.remove(personalId);
      return;
    }

    _cache[personalId] = _VehiculoCache(
      vehiculoId: vehiculoId,
      timestamp: DateTime.now(),
    );

    debugPrint(
      '🚗 VehiculoCache: Almacenado - '
      'personalId: $personalId, vehiculoId: $vehiculoId',
    );
  }

  /// Invalida la caché para un personal específico
  void invalidate(String personalId) {
    debugPrint('🚗 VehiculoCache: Invalidando caché para $personalId');
    _cache.remove(personalId);
  }

  /// Limpia toda la caché
  void clear() {
    debugPrint('🚗 VehiculoCache: Limpiando toda la caché');
    _cache.clear();
  }

  /// Obtiene información de la caché (para debug)
  Map<String, dynamic> getDebugInfo() {
    return {
      'cacheSize': _cache.length,
      'entries': _cache.entries.map((e) {
        final age = DateTime.now().difference(e.value.timestamp);
        return {
          'personalId': e.key,
          'vehiculoId': e.value.vehiculoId,
          'age': '${age.inMinutes}m ${age.inSeconds % 60}s',
          'expired': age > _cacheDuration,
        };
      }).toList(),
    };
  }
}

/// Entrada de caché con timestamp
class _VehiculoCache {
  const _VehiculoCache({
    required this.vehiculoId,
    required this.timestamp,
  });

  final String vehiculoId;
  final DateTime timestamp;
}
