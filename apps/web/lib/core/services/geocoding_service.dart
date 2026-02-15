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
  }

  late final http.Client _client;

  /// URLs de Nominatim (OpenStreetMap)
  static const String _nominatimApiUrl = 'nominatim.openstreetmap.org';
  static const String _searchEndpoint = '/search';

  /// Headers obligatorios para Nominatim (User-Agent personalizado + email)
  static const Map<String, String> _headers = <String, String>{
    'User-Agent': 'AmbuTrack-Web/1.0 (ambutrack.geocoding; contacto@ambutrack.com)',
    'Accept': 'application/json',
  };

  /// Obtiene coordenadas reales para una ubicación
  ///
  /// Parámetros:
  /// - [query]: Nombre o dirección de la ubicación (ej: "Calle Asdegüa 21, Barbate")
  /// - [country]: Código de país para filtrar (por defecto "ES" para España)
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
  }) async {
    try {
      debugPrint('🌍 Geocodificando: "$query" (país: $country)');

      // Construir URL con parámetros
      final Uri uri = Uri.https(
        _nominatimApiUrl,
        _searchEndpoint,
        <String, String>{
          'q': query,
          'countrycodes': country,
          'limit': '1', // Solo el primer resultado
          'format': 'json',
          'addressdetails': '1', // Incluir detalles de dirección
          'namedetails': '0', // No incluir nombres alternativos
        },
      );

      // Hacer request GET
      final http.Response response = await _client.get(uri, headers: _headers);

      debugPrint('📍 Status Nominatim: ${response.statusCode}');

      // Verificar status code
      if (response.statusCode != 200) {
        throw GeocodingError(
          'Error en API Nominatim: ${response.statusCode}',
        );
      }

      // Parsear JSON
      final dynamic jsonData = json.decode(response.body);

      // Verificar que hay resultados
      if (jsonData is! List || jsonData.isEmpty) {
        throw GeocodingError(
          'No se encontraron resultados para: "$query"',
        );
      }

      final List<dynamic> results = jsonData;
      final Map<String, dynamic> firstResult = results.first as Map<String, dynamic>;

      // Extraer coordenadas
      final double lat = double.parse(firstResult['lat'] as String);
      final double lon = double.parse(firstResult['lon'] as String);

      // Extraer nombre y detalles
      final String displayName = firstResult['display_name'] as String? ?? query;

      final Map<String, dynamic>? addressDetails =
          firstResult['address'] as Map<String, dynamic>?;

      // Determinar tipo de ubicación
      final String? type = firstResult['type'] as String?;
      final String? tipo = _determinarTipo(type, addressDetails);

      final GeocodingResult result = GeocodingResult(
        latitud: lat,
        longitud: lon,
        nombre: query,
        direccion: displayName,
        tipo: tipo,
      );

      debugPrint(
        '✅ Geocodificación exitosa: ${result.latitud.toStringAsFixed(4)}, ${result.longitud.toStringAsFixed(4)} (${result.tipo})',
      );

      return result;
    } on GeocodingError {
      // Re-lanzar errores de geocodificación
      rethrow;
    } on http.ClientException catch (e) {
      // Errores de red
      debugPrint('❌ Error de red en geocodificación: $e');
      throw GeocodingError('Error de conexión: ${e.toString()}');
    } catch (e, stack) {
      // Errores inesperados
      debugPrint('❌ Error inesperado en geocodificación: $e');
      debugPrint('Stack: $stack');
      throw GeocodingError('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtiene coordenadas formateadas para FlutterMap
  ///
  /// Retorna mapa con 'lat' y 'lng' para compatibilidad con código existente
  Future<Map<String, double>> obtenerCoordenadas({
    required String query,
    String country = 'ES',
  }) async {
    final GeocodingResult result = await geocodificar(
      query: query,
      country: country,
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
    int maxRetries = 3,
  }) async {
    GeocodingError? lastError;

    for (int i = 0; i < maxRetries; i++) {
      try {
        return await geocodificar(
          query: query,
          country: country,
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

  /// Cierra el cliente HTTP
  @mustCallSuper
  void dispose() {
    _client.close();
  }
}
