import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

/// Resultado de una búsqueda de geocodificación
class GeocodingResult {
  const GeocodingResult({
    required this.latitud,
    required this.longitud,
    required this.nombre,
    this.direccion,
    this.tipo,
  });

  final double latitud;
  final double longitud;
  final String nombre;
  final String? direccion;
  final String? tipo;
}

/// Error de geocodificación
class GeocodingError implements Exception {
  const GeocodingError(this.message);

  final String message;

  @override
  String toString() => 'GeocodingError: $message';
}

/// Servicio para obtener coordenadas reales usando Nominatim (OpenStreetMap)
///
/// POLÍTICA DE USO DE NOMINATIM:
/// - API gratuita, sin requerir API key
/// - MÁXIMO 1 request por segundo
/// - Identificación obligatoria con User-Agent y email
/// - Uso: https://operations.osmfoundation.org/policies/nominatim
@lazySingleton
class GeocodingService {
  GeocodingService() {
    _client = http.Client();
    _cache = <String, GeocodingResult>{};
  }

  late final http.Client _client;
  late final Map<String, GeocodingResult> _cache;

  /// URLs de Nominatim (OpenStreetMap)
  static const String _nominatimApiUrl = 'nominatim.openstreetmap.org';
  static const String _searchEndpoint = '/search';

  /// Headers obligatorios para Nominatim (User-Agent personalizado + email)
  static const Map<String, String> _headers = <String, String>{
    'User-Agent': 'AmbuTrack-Web/1.0 (ambutrack.geocoding; contacto@ambutrack.com)',
    'Accept': 'application/json',
  };

  /// Límites geográficos de España peninsular (para filtrar resultados)
  static const double _minLatSpain = 36.0;
  static const double _maxLatSpain = 43.5;
  static const double _minLngSpain = -9.5;
  static const double _maxLngSpain = -3.0;

  /// Obtiene coordenadas reales para una ubicación
  ///
  /// Parámetros:
  /// - [query]: Nombre o dirección de la ubicación (ej: "Calle Asdegüa 21, Barbate")
  /// - [country]: Código de país para filtrar (por defecto "ES" para España)
  /// - [contexto]: Contexto adicional para mejorar la búsqueda (ej: "Cádiz", "Barbate")
  ///
  /// Retorna [GeocodingResult] con latitud, longitud y datos del lugar
  ///
  /// Lanza [GeocodingError] si:
  /// - No se encuentran resultados
  /// - Error de red
  /// - Respuesta inválida
  Future<GeocodingResult> geocodificar({
    required String query,
    String country = 'ES',
    String? contexto,
  }) async {
    // Verificar caché primero
    final String cacheKey = contexto != null ? '$query|$contexto' : query;
    if (_cache.containsKey(cacheKey)) {
      debugPrint('📦 Usando resultado en caché para: "$query"');
      return _cache[cacheKey]!;
    }

    try {
      debugPrint('🌍 Geocodificando: "$query" (país: $country${contexto != null ? ', contexto: $contexto' : ''})');

      // Estrategia 1: Búsqueda directa con contexto si está disponible
      if (contexto != null && contexto.isNotEmpty) {
        try {
          final GeocodingResult? resultado = await _intentarGeocodificacion(
            '$query, $contexto, España',
            country,
          );
          if (resultado != null && _isInMainlandSpain(resultado.latitud, resultado.longitud)) {
            _cache[cacheKey] = resultado;
            return resultado;
          }
        } catch (e) {
          debugPrint('⚠️ Búsqueda con contexto falló: $e');
        }
      }

      // Estrategia 2: Búsqueda directa del query original
      final GeocodingResult? resultadoDirecto = await _intentarGeocodificacion(
        query,
        country,
      );

      if (resultadoDirecto != null) {
        // Verificar que está en España peninsular
        if (_isInMainlandSpain(resultadoDirecto.latitud, resultadoDirecto.longitud)) {
          _cache[cacheKey] = resultadoDirecto;
          return resultadoDirecto;
        }

        // Si está en Canarias/Baleares, intentar con "España peninsular"
        debugPrint('⚠️ Ubicación encontrada fuera de España peninsular');
        debugPrint('📍 Intentando búsqueda con contexto de España peninsular...');

        final GeocodingResult? resultadoPeninsular = await _intentarGeocodificacion(
          '$query, Cádiz, España',
          country,
        );

        if (resultadoPeninsular != null && _isInMainlandSpain(resultadoPeninsular.latitud, resultadoPeninsular.longitud)) {
          _cache[cacheKey] = resultadoPeninsular;
          return resultadoPeninsular;
        }
      }

      // Si llegamos aquí, no se encontró un resultado válido
      throw GeocodingError(
        'No se encontraron resultados válidos en España peninsular para: "$query"',
      );
    } on GeocodingError {
      rethrow;
    } on http.ClientException catch (e) {
      debugPrint('❌ Error de red en geocodificación: $e');
      throw GeocodingError('Error de conexión: ${e.toString()}');
    } catch (e, stack) {
      debugPrint('❌ Error inesperado en geocodificación: $e');
      debugPrint('Stack: $stack');
      throw GeocodingError('Error inesperado: ${e.toString()}');
    }
  }

  /// Intenta geocodificar una query y retorna el resultado o null si falla
  Future<GeocodingResult?> _intentarGeocodificacion(
    String query,
    String country,
  ) async {
    try {
      // Construir URL con parámetros
      final Uri uri = Uri.https(
        _nominatimApiUrl,
        _searchEndpoint,
        <String, String>{
          'q': query,
          'countrycodes': country,
          'limit': '5', // Obtener más resultados para filtrar
          'format': 'json',
          'addressdetails': '1',
          'namedetails': '0',
        },
      );

      // Hacer request GET
      final http.Response response = await _client.get(uri, headers: _headers);

      // Verificar status code
      if (response.statusCode != 200) {
        return null;
      }

      // Parsear JSON
      final dynamic jsonData = json.decode(response.body);

      // Verificar que hay resultados
      if (jsonData is! List || jsonData.isEmpty) {
        return null;
      }

      final List<dynamic> results = jsonData;

      // Buscar el mejor resultado
      for (final dynamic result in results) {
        final Map<String, dynamic> resultMap = result as Map<String, dynamic>;

        final double lat = double.parse(resultMap['lat'] as String);
        final double lon = double.parse(resultMap['lon'] as String);

        // Priorizar resultados en España peninsular
        if (_isInMainlandSpain(lat, lon)) {
          final String displayName = resultMap['display_name'] as String? ?? query;

          final Map<String, dynamic>? addressDetails =
              resultMap['address'] as Map<String, dynamic>?;

          final String? type = resultMap['type'] as String?;
          final String? tipo = _determinarTipo(type, addressDetails);

          debugPrint('✅ Resultado válido encontrado: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)} ($tipo)');

          return GeocodingResult(
            latitud: lat,
            longitud: lon,
            nombre: query,
            direccion: displayName,
            tipo: tipo,
          );
        }
      }

      // Si no hay resultados en España peninsular, usar el primero
      final Map<String, dynamic> firstResult = results.first as Map<String, dynamic>;
      final double lat = double.parse(firstResult['lat'] as String);
      final double lon = double.parse(firstResult['lon'] as String);

      debugPrint(
        '⚠️ Usando primer resultado (fuera de España peninsular): '
        '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}',
      );

      return GeocodingResult(
        latitud: lat,
        longitud: lon,
        nombre: query,
        direccion: firstResult['display_name'] as String? ?? query,
      );
    } catch (e) {
      debugPrint('⚠️ Error en intento de geocodificación: $e');
      return null;
    }
  }

  /// Verifica si unas coordenadas están dentro de España peninsular
  bool _isInMainlandSpain(double lat, double lon) {
    return lat >= _minLatSpain &&
        lat <= _maxLatSpain &&
        lon >= _minLngSpain &&
        lon <= _maxLngSpain;
  }

  /// Obtiene coordenadas formateadas para FlutterMap
  ///
  /// Retorna mapa con 'lat' y 'lng' para compatibilidad con código existente
  Future<Map<String, double>> obtenerCoordenadas({
    required String query,
    String country = 'ES',
    String? contexto,
  }) async {
    final GeocodingResult result = await geocodificar(
      query: query,
      country: country,
      contexto: contexto,
    );

    return <String, double>{
      'lat': result.latitud,
      'lng': result.longitud,
    };
  }

  /// Obtiene coordenadas con reintentos automáticos
  ///
  /// [maxRetries]: Número máximo de intentos (por defecto 3)
  Future<GeocodingResult> geocodificarConReintento({
    required String query,
    String country = 'ES',
    String? contexto,
    int maxRetries = 3,
  }) async {
    GeocodingError? lastError;

    for (int i = 0; i < maxRetries; i++) {
      try {
        return await geocodificar(
          query: query,
          country: country,
          contexto: contexto,
        );
      } on GeocodingError catch (e) {
        lastError = e;

        if (i < maxRetries - 1) {
          // Esperar antes de reintentar (backoff exponencial)
          final int delayMs = 1000 * (i + 1);
          debugPrint(
            '⏳ Reintento ${i + 1}/$maxRetries en ${delayMs}ms...',
          );
          await Future<void>.delayed(
            Duration(milliseconds: delayMs),
          );
        }
      }
    }

    // Todos los intentos fallaron
    throw lastError ??
        const GeocodingError('Máximo de reintentos alcanzado');
  }

  /// Determina el tipo de ubicación basado en la respuesta de Nominatim
  String? _determinarTipo(
    String? osmType,
    Map<String, dynamic>? address,
  ) {
    // Si tiene 'hospital' o 'clinic' en address
    if (address != null) {
      if (address.containsKey('hospital') ||
          address.containsKey('clinic') ||
          address.containsKey('health')) {
        return 'hospital';
      }
      if (address.containsKey('building')) {
        final String building = address['building'].toString().toLowerCase();
        if (building.contains('hospital') ||
            building.contains('clinic') ||
            building.contains('health')) {
          return 'hospital';
        }
      }
    }

    // Basado en tipo OSM
    switch (osmType) {
      case 'hospital':
      case 'clinic':
      case 'health':
        return 'hospital';
      case 'house':
      case 'residential':
      case 'apartments':
        return 'domicilio';
      case 'way':
      case 'road':
        return 'calle';
      default:
        return osmType;
    }
  }

  /// Formatea coordenadas para mostrar en UI
  static String formatearCoordenadas({
    required double latitud,
    required double longitud,
  }) {
    return '${latitud.toStringAsFixed(4)}, ${longitud.toStringAsFixed(4)}';
  }

  /// Limpia el caché de geocodificación
  void limpiarCache() {
    _cache.clear();
    debugPrint('🗑️ Caché de geocodificación limpiado');
  }

  /// Cierra el cliente HTTP
  @mustCallSuper
  void dispose() {
    _client.close();
  }
}
