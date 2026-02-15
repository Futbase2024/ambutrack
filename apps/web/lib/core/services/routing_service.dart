import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

/// Punto de una ruta
class RutaPunto {
  const RutaPunto({
    required this.latitud,
    required this.longitud,
    this.nombre,
  });

  final double latitud;
  final double longitud;
  final String? nombre;

  /// Convierte a LatLng de latlong2
  LatLng toLatLng() {
    return LatLng(latitud, longitud);
  }

  /// Convierte a formato lon,lat para OSRM
  String toOSRMFormat() {
    return '$longitud,$latitud';
  }
}

/// Resultado de una ruta calculada
class RutaCalculada {
  const RutaCalculada({
    required this.distanciaKm,
    required this.duracionMinutos,
    required this.puntos,
    required this.geometria,
  });

  /// Distancia total de la ruta en kilómetros
  final double distanciaKm;

  /// Duración estimada en minutos
  final double duracionMinutos;

  /// Puntos de paso (origen, destino, waypoints)
  final List<RutaPunto> puntos;

  /// Geometría completa de la ruta (todos los puntos del polyline)
  final List<LatLng> geometria;

  /// Formatea la distancia para mostrar
  String get distanciaFormateada {
    if (distanciaKm < 1) {
      return '${(distanciaKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanciaKm.toStringAsFixed(1)} km';
  }

  /// Formatea la duración para mostrar
  String get duracionFormateada {
    final int horas = duracionMinutos ~/ 60;
    final int minutos = (duracionMinutos % 60).toInt();
    if (horas > 0) {
      return '${horas}h ${minutos}min';
    }
    return '${minutos}min';
  }
}

/// Error de routing
class RoutingError implements Exception {
  const RoutingError(this.message);

  final String message;

  @override
  String toString() => 'RoutingError: $message';
}

/// Servicio para calcular rutas reales por carretera usando OSRM
///
/// OSRM (Open Source Routing Machine) es un motor de routing de código abierto
/// Documentación: http://project-osrm.org/docs/v5.24.0/api/
/// API pública gratuita: https://router.project-osrm.org
///
/// Ventajas sobre OpenRouteService:
/// - Sin restricciones CORS para aplicaciones web
/// - No requiere API key
/// - Respuestas más rápidas
/// - Soporte nativo para múltiples waypoints
@lazySingleton
class RoutingService {
  RoutingService() {
    _client = http.Client();
  }

  late final http.Client _client;

  /// API endpoints de OSRM (más amigable para web que ORS)
  static const String _osrmApiUrl = 'router.project-osrm.org';
  static const String _routeEndpoint = '/route/v1/driving';

  /// Headers para OSRM
  static const Map<String, String> _headers = <String, String>{
    'Accept': 'application/json, application/geo+json',
  };

  /// Calcula una ruta real por carretera entre dos puntos usando OSRM
  ///
  /// Parámetros:
  /// - [origen]: Punto de origen (latitud, longitud)
  /// - [destino]: Punto de destino (latitud, longitud)
  ///
  /// Retorna [RutaCalculada] con:
  /// - Distancia real por carretera
  /// - Duración estimada
  /// - Geometría completa (todos los puntos del polyline)
  Future<RutaCalculada> calcularRuta({
    required RutaPunto origen,
    required RutaPunto destino,
  }) async {
    try {
      debugPrint('🚗 Calculando ruta por carretera con OSRM...');
      debugPrint('📍 Origen: ${origen.latitud}, ${origen.longitud} (${origen.nombre})');
      debugPrint('📍 Destino: ${destino.latitud}, ${destino.longitud} (${destino.nombre})');

      // Construir URL para OSRM
      // Formato: /route/v1/driving/lon1,lat1;lon2,lat2?overview=full&geometries=geojson
      final String coordenadas = '${origen.toOSRMFormat()};${destino.toOSRMFormat()}';

      final Uri uri = Uri.https(
        _osrmApiUrl,
        '$_routeEndpoint/$coordenadas',
        <String, String>{
          'overview': 'full', // Geometría completa
          'geometries': 'geojson', // Formato GeoJSON
          'steps': 'false', // No necesitamos pasos detallados
        },
      );

      debugPrint('🌐 URL OSRM: $uri');

      // Hacer request GET
      final http.Response response = await _client.get(uri, headers: _headers);

      debugPrint('📡 Status OSRM: ${response.statusCode}');

      // Verificar status code
      if (response.statusCode != 200) {
        throw RoutingError(
          'Error en API OSRM: ${response.statusCode} - ${response.body}',
        );
      }

      // Parsear JSON
      final Map<String, dynamic> jsonData = json.decode(
        response.body,
      ) as Map<String, dynamic>;

      // Verificar que hay ruta
      final String? code = jsonData['code'] as String?;
      if (code != 'Ok') {
        throw RoutingError(
          'OSRM returned error: $code',
        );
      }

      // Extraer ruta
      final List<dynamic>? routes = jsonData['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        throw const RoutingError(
          'No se encontraron rutas entre los puntos especificados',
        );
      }

      final Map<String, dynamic> route = routes.first as Map<String, dynamic>;

      // Extraer distancia (en metros) y duración (en segundos)
      final double distanciaMetros = (route['distance'] as num).toDouble();
      final double duracionSegundos = (route['duration'] as num).toDouble();

      final double distanciaKm = distanciaMetros / 1000;
      final double duracionMinutos = duracionSegundos / 60;

      debugPrint('✅ Distancia: ${distanciaKm.toStringAsFixed(2)} km');
      debugPrint('⏱️ Duración: ${duracionMinutos.toStringAsFixed(1)} min');

      // Extraer geometría (polyline completo)
      final Map<String, dynamic> geometry =
          route['geometry'] as Map<String, dynamic>;

      final String geoJsonType = geometry['type'] as String;
      if (geoJsonType != 'LineString') {
        throw RoutingError(
          'Tipo de geometría no soportado: $geoJsonType',
        );
      }

      final List<dynamic> coordinates =
          geometry['coordinates'] as List<dynamic>;

      final List<LatLng> puntosGeometria = <LatLng>[];
      for (final dynamic coord in coordinates) {
        final List<dynamic> c = coord as List<dynamic>;
        // OSRM devuelve [lon, lat], LatLng necesita [lat, lon]
        puntosGeometria.add(
          LatLng(c[1] as double, c[0] as double),
        );
      }

      debugPrint('📍 Puntos en geometría: ${puntosGeometria.length}');

      return RutaCalculada(
        distanciaKm: distanciaKm,
        duracionMinutos: duracionMinutos,
        puntos: <RutaPunto>[origen, destino],
        geometria: puntosGeometria,
      );
    } on RoutingError {
      rethrow;
    } on http.ClientException catch (e) {
      debugPrint('❌ Error de red en routing: $e');
      throw RoutingError('Error de conexión: ${e.toString()}');
    } catch (e, stack) {
      debugPrint('❌ Error inesperado en routing: $e');
      debugPrint('Stack: $stack');
      throw RoutingError('Error inesperado: ${e.toString()}');
    }
  }

  /// Calcula una ruta con múltiples waypoints usando OSRM
  ///
  /// Útil para rutas con múltiples paradas
  Future<RutaCalculada> calcularRutaConWaypoints({
    required RutaPunto origen,
    required List<RutaPunto> waypoints,
    required RutaPunto destino,
  }) async {
    try {
      debugPrint('🚗 Calculando ruta con ${waypoints.length} waypoints...');

      // Construir lista de coordenadas para OSRM
      // Formato: lon1,lat1;lon2,lat2;lon3,lat3;...
      final List<String> coordenadas = <String>[
        origen.toOSRMFormat(),
        ...waypoints.map((RutaPunto p) => p.toOSRMFormat()),
        destino.toOSRMFormat(),
      ];

      final String coordenadasStr = coordenadas.join(';');

      final Uri uri = Uri.https(
        _osrmApiUrl,
        '$_routeEndpoint/$coordenadasStr',
        <String, String>{
          'overview': 'full',
          'geometries': 'geojson',
          'steps': 'false',
        },
      );

      debugPrint('🌐 URL OSRM: $uri');

      final http.Response response = await _client.get(uri, headers: _headers);

      if (response.statusCode != 200) {
        throw RoutingError(
          'Error en API OSRM: ${response.statusCode} - ${response.body}',
        );
      }

      final Map<String, dynamic> jsonData = json.decode(
        response.body,
      ) as Map<String, dynamic>;

      final String? code = jsonData['code'] as String?;
      if (code != 'Ok') {
        throw RoutingError('OSRM returned error: $code');
      }

      final List<dynamic>? routes = jsonData['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        throw const RoutingError('No se pudo calcular la ruta con waypoints');
      }

      final Map<String, dynamic> route = routes.first as Map<String, dynamic>;

      final double distanciaMetros = (route['distance'] as num).toDouble();
      final double duracionSegundos = (route['duration'] as num).toDouble();

      final double distanciaKm = distanciaMetros / 1000;
      final double duracionMinutos = duracionSegundos / 60;

      final Map<String, dynamic> geometry =
          route['geometry'] as Map<String, dynamic>;

      final List<dynamic> coordinates =
          geometry['coordinates'] as List<dynamic>;

      final List<LatLng> puntosGeometria = <LatLng>[];
      for (final dynamic coord in coordinates) {
        final List<dynamic> c = coord as List<dynamic>;
        puntosGeometria.add(
          LatLng(c[1] as double, c[0] as double),
        );
      }

      debugPrint('✅ Ruta con waypoints calculada');
      debugPrint('📊 Distancia: ${distanciaKm.toStringAsFixed(2)} km');
      debugPrint('⏱️ Duración: ${duracionMinutos.toStringAsFixed(1)} min');

      return RutaCalculada(
        distanciaKm: distanciaKm,
        duracionMinutos: duracionMinutos,
        puntos: <RutaPunto>[origen, ...waypoints, destino],
        geometria: puntosGeometria,
      );
    } on RoutingError {
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ Error en routing con waypoints: $e');
      debugPrint('Stack: $stack');
      throw RoutingError('Error: ${e.toString()}');
    }
  }

  /// Calcula múltiples rutas y las une en una sola
  ///
  /// Útil cuando ORS no soporta todos los waypoints en una sola llamada
  Future<List<RutaCalculada>> calcularMultiplesRutas({
    required List<RutaPunto> puntos,
  }) async {
    if (puntos.length < 2) {
      throw const RoutingError(
        'Se necesitan al menos 2 puntos para calcular rutas',
      );
    }

    final List<RutaCalculada> rutas = <RutaCalculada>[];

    for (int i = 0; i < puntos.length - 1; i++) {
      try {
        final RutaCalculada ruta = await calcularRuta(
          origen: puntos[i],
          destino: puntos[i + 1],
        );
        rutas.add(ruta);

        // Pequeña pausa para no saturar la API (1 req/seg recomendado)
        if (i < puntos.length - 2) {
          await Future<void>.delayed(const Duration(milliseconds: 1100));
        }
      } catch (e) {
        debugPrint('⚠️ Error calculando ruta ${i + 1}: $e');
        // Continuar con las siguientes rutas
      }
    }

    return rutas;
  }

  /// Combina múltiples rutas en una sola geometría
  static List<LatLng> combinarGeometrias(List<RutaCalculada> rutas) {
    final List<LatLng> geometriaCombinada = <LatLng>[];

    for (final RutaCalculada ruta in rutas) {
      geometriaCombinada.addAll(ruta.geometria);
    }

    return geometriaCombinada;
  }

  /// Calcula métricas totales de múltiples rutas
  static ({double distanciaKm, double duracionMinutos}) calcularTotal(
    List<RutaCalculada> rutas,
  ) {
    final double distanciaTotal = rutas.fold<double>(
      0.0,
      (double sum, RutaCalculada r) => sum + r.distanciaKm,
    );

    final double duracionTotal = rutas.fold<double>(
      0.0,
      (double sum, RutaCalculada r) => sum + r.duracionMinutos,
    );

    return (distanciaKm: distanciaTotal, duracionMinutos: duracionTotal);
  }

  /// Cierra el cliente HTTP
  @mustCallSuper
  void dispose() {
    _client.close();
  }
}
