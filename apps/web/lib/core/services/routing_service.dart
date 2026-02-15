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

  /// Convierte a formato lon,lat para OpenRouteService
  String toORSFormat() {
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

/// Servicio para calcular rutas reales por carretera usando OpenRouteService
///
/// OpenRouteService es una API gratuita basada en OpenStreetMap
/// Documentación: https://openrouteservice.org/dev/#/api-docs/v2/directions
@lazySingleton
class RoutingService {
  RoutingService() {
    _client = http.Client();
  }

  late final http.Client _client;

  /// API endpoints de OpenRouteService
  static const String _orsApiUrl = 'api.openrouteservice.org';
  static const String _directionsEndpoint = '/v2/directions/driving-car';

  /// Headers obligatorios para OpenRouteService
  static const Map<String, String> _headers = <String, String>{
    'Accept': 'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
    'Authorization': '', // API key opcional para uso básico
    'Content-Type': 'application/json; charset=utf-8',
  };

  /// Calcula una ruta real por carretera entre dos puntos
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
      debugPrint('🚗 Calculando ruta por carretera...');
      debugPrint('📍 Origen: ${origen.latitud}, ${origen.longitud}');
      debugPrint('📍 Destino: ${destino.latitud}, ${destino.longitud}');

      // Construir URL para OpenRouteService
      final Uri uri = Uri.https(
        _orsApiUrl,
        _directionsEndpoint,
        <String, String>{
          'start': origen.toORSFormat(),
          'end': destino.toORSFormat(),
        },
      );

      debugPrint('🌐 URL ORS: $uri');

      // Hacer request GET
      final http.Response response = await _client.get(uri, headers: _headers);

      debugPrint('📡 Status ORS: ${response.statusCode}');

      // Verificar status code
      if (response.statusCode != 200) {
        throw RoutingError(
          'Error en API OpenRouteService: ${response.statusCode}',
        );
      }

      // Parsear JSON
      final Map<String, dynamic> jsonData = json.decode(
        response.body,
      ) as Map<String, dynamic>;

      // Extraer datos de la ruta
      final Map<String, dynamic>? feature =
          (jsonData['features'] as List<dynamic>).firstOrNull as Map<String, dynamic>?;

      if (feature == null) {
        throw const RoutingError(
          'No se pudo calcular la ruta entre los puntos especificados',
        );
      }

      // Extraer propiedades
      final Map<String, dynamic> properties =
          feature['properties'] as Map<String, dynamic>;

      final double distancia = (properties['summary']['distance'] as num).toDouble() / 1000; // m a km
      final double duracion = (properties['summary']['duration'] as num).toDouble() / 60; // seg a min

      debugPrint('✅ Distancia: ${distancia.toStringAsFixed(2)} km');
      debugPrint('⏱️ Duración: ${duracion.toStringAsFixed(1)} min');

      // Extraer geometría (polyline completo)
      final Map<String, dynamic> geometry =
          feature['geometry'] as Map<String, dynamic>;

      final List<dynamic> coordinates =
          geometry['coordinates'] as List<dynamic>;

      final List<LatLng> puntosGeometria = <LatLng>[];
      for (final dynamic coord in coordinates) {
        final List<dynamic> c = coord as List<dynamic>;
        // ORS devuelve [lon, lat], LatLng necesita [lat, lon]
        puntosGeometria.add(
          LatLng(c[1] as double, c[0] as double),
        );
      }

      debugPrint('📍 Puntos en geometría: ${puntosGeometria.length}');

      return RutaCalculada(
        distanciaKm: distancia,
        duracionMinutos: duracion,
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

  /// Calcula una ruta con múltiples waypoints
  ///
  /// Útil para rutas con múltiples paradas
  Future<RutaCalculada> calcularRutaConWaypoints({
    required RutaPunto origen,
    required List<RutaPunto> waypoints,
    required RutaPunto destino,
  }) async {
    // NOTA: La versión gratuita de ORS tiene limitaciones
    // Para múltiples waypoints, necesitamos hacer múltiples requests
    // o usar la API de pago

    try {
      debugPrint('🚗 Calculando ruta con ${waypoints.length} waypoints...');

      // Construir lista de coordenadas para ORS
      final List<String> coordenadas = <String>[
        origen.toORSFormat(),
        ...waypoints.map((RutaPunto p) => p.toORSFormat()),
        destino.toORSFormat(),
      ];

      final Uri uri = Uri.https(
        _orsApiUrl,
        _directionsEndpoint,
        <String, String>{
          'coordinates': coordenadas.join(';'),
        },
      );

      debugPrint('🌐 URL ORS: $uri');

      final http.Response response = await _client.get(uri, headers: _headers);

      if (response.statusCode != 200) {
        throw RoutingError(
          'Error en API OpenRouteService: ${response.statusCode}',
        );
      }

      final Map<String, dynamic> jsonData = json.decode(
        response.body,
      ) as Map<String, dynamic>;

      final Map<String, dynamic>? feature =
          (jsonData['features'] as List<dynamic>).firstOrNull as Map<String, dynamic>?;

      if (feature == null) {
        throw const RoutingError('No se pudo calcular la ruta con waypoints');
      }

      final Map<String, dynamic> properties =
          feature['properties'] as Map<String, dynamic>;

      final double distancia = (properties['summary']['distance'] as num).toDouble() / 1000;
      final double duracion = (properties['summary']['duration'] as num).toDouble() / 60;

      final Map<String, dynamic> geometry =
          feature['geometry'] as Map<String, dynamic>;

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
      debugPrint('📊 Distancia: ${distancia.toStringAsFixed(2)} km');
      debugPrint('⏱️ Duración: ${duracion.toStringAsFixed(1)} min');

      return RutaCalculada(
        distanciaKm: distancia,
        duracionMinutos: duracion,
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
