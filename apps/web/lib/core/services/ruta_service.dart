import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../features/trafico_diario/presentation/models/traslado_con_ruta_info.dart';

/// Servicio para cálculos relacionados con rutas y distancias
@lazySingleton
class RutaService {
  /// Radio de la Tierra en kilómetros
  static const double _radioTierraKm = 6371.0;

  /// Velocidad promedio asumida en km/h para cálculos de tiempo
  /// (valor conservador considerando tráfico urbano)
  static const double _velocidadPromedioKmh = 50.0;

  /// Calcula la distancia entre dos puntos geográficos usando la fórmula de Haversine
  ///
  /// Retorna la distancia en kilómetros
  double calcularDistancia({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distancia = _radioTierraKm * c;

    debugPrint(
      '📏 Distancia calculada: ${distancia.toStringAsFixed(2)} km '
      'entre (${lat1.toStringAsFixed(4)}, ${lon1.toStringAsFixed(4)}) '
      'y (${lat2.toStringAsFixed(4)}, ${lon2.toStringAsFixed(4)})',
    );

    return distancia;
  }

  /// Calcula el tiempo estimado en minutos basado en la distancia
  ///
  /// Usa una velocidad promedio de [velocidadKmh] (por defecto 50 km/h)
  int calcularTiempoEstimado({
    required double distanciaKm,
    double velocidadKmh = _velocidadPromedioKmh,
  }) {
    final double tiempoHoras = distanciaKm / velocidadKmh;
    final int tiempoMinutos = (tiempoHoras * 60).ceil();
    return tiempoMinutos;
  }

  /// Calcula la distancia entre dos puntos de ubicación
  double calcularDistanciaEntrePuntos({
    required PuntoUbicacion punto1,
    required PuntoUbicacion punto2,
  }) {
    return calcularDistancia(
      lat1: punto1.latitud,
      lon1: punto1.longitud,
      lat2: punto2.latitud,
      lon2: punto2.longitud,
    );
  }

  /// Convierte grados a radianes
  double _toRadians(double grados) {
    return grados * pi / 180;
  }

  /// Calcula la distancia total de una ruta (suma de distancias entre puntos consecutivos)
  double calcularDistanciaTotal(List<PuntoUbicacion> puntos) {
    if (puntos.length < 2) {
      return 0.0;
    }

    double distanciaTotal = 0.0;
    for (int i = 0; i < puntos.length - 1; i++) {
      distanciaTotal += calcularDistanciaEntrePuntos(
        punto1: puntos[i],
        punto2: puntos[i + 1],
      );
    }

    debugPrint('📊 Distancia total de ruta: ${distanciaTotal.toStringAsFixed(2)} km para ${puntos.length} puntos');

    return distanciaTotal;
  }

  /// Calcula métricas completas de una ruta con traslados
  RutaResumen calcularResumenRuta({
    required List<TrasladoConRutaInfo> traslados,
    double velocidadPromedioKmh = _velocidadPromedioKmh,
  }) {
    if (traslados.isEmpty) {
      return const RutaResumen(
        totalTraslados: 0,
        distanciaTotalKm: 0.0,
        tiempoTotalMinutos: 0,
      );
    }

    double distanciaTotal = 0.0;
    int tiempoTotal = 0;

    for (final TrasladoConRutaInfo traslado in traslados) {
      // Sumar distancia desde punto anterior (si existe)
      if (traslado.distanciaDesdeAnteriorKm != null) {
        distanciaTotal += traslado.distanciaDesdeAnteriorKm!;
      }

      // Sumar distancia del traslado en sí (origen → destino)
      if (traslado.distanciaTotalTrasladoKm != null) {
        distanciaTotal += traslado.distanciaTotalTrasladoKm!;
      }

      // Sumar tiempo desde punto anterior
      if (traslado.tiempoDesdeAnteriorMinutos != null) {
        tiempoTotal += traslado.tiempoDesdeAnteriorMinutos!;
      }

      // Sumar tiempo del traslado
      if (traslado.tiempoTotalTrasladoMinutos != null) {
        tiempoTotal += traslado.tiempoTotalTrasladoMinutos!;
      }
    }

    final TrasladoConRutaInfo primerTraslado = traslados.first;
    final TrasladoConRutaInfo ultimoTraslado = traslados.last;

    // Validar factibilidad de la ruta
    final List<TrasladoConRetrasoInfo> trasladosConRetraso = <TrasladoConRetrasoInfo>[];
    bool esFactible = true;
    const int margenMinutos = 15;

    for (int i = 0; i < traslados.length; i++) {
      final TrasladoConRutaInfo traslado = traslados[i];
      final DateTime? horaProgramada = traslado.traslado.horaProgramada;
      final DateTime? horaEstimada = traslado.horaEstimadaLlegada;

      if (horaProgramada != null && horaEstimada != null) {
        final int diferencia = horaEstimada.difference(horaProgramada).inMinutes;

        if (diferencia > margenMinutos) {
          esFactible = false;
          trasladosConRetraso.add(
            TrasladoConRetrasoInfo(
              orden: i + 1, // Orden del traslado (1-based)
              minutosRetraso: diferencia,
            ),
          );
          debugPrint(
            '⚠️ Traslado ${i + 1} con retraso: '
            '${diferencia}min después de lo programado',
          );
        }
      }
    }

    debugPrint(
      '📊 Resumen de ruta calculado:\n'
      '   - Total traslados: ${traslados.length}\n'
      '   - Distancia total: ${distanciaTotal.toStringAsFixed(2)} km\n'
      '   - Tiempo total: $tiempoTotal minutos\n'
      '   - Factible: ${esFactible ? "Sí" : "No (${trasladosConRetraso.length} con retraso)"}',
    );

    return RutaResumen(
      totalTraslados: traslados.length,
      distanciaTotalKm: distanciaTotal,
      tiempoTotalMinutos: tiempoTotal,
      horaInicio: primerTraslado.traslado.horaProgramada,
      horaFin: ultimoTraslado.horaEstimadaLlegada,
      velocidadPromedioKmh: velocidadPromedioKmh,
      esFactible: esFactible,
      trasladosConRetraso: trasladosConRetraso,
    );
  }

  /// Optimiza el orden de traslados usando algoritmo greedy (vecino más cercano)
  ///
  /// NOTA: Este algoritmo respeta las horas programadas si [respetarHorarios] es true
  List<TrasladoConRutaInfo> optimizarRuta({
    required List<TrasladoConRutaInfo> traslados,
    bool respetarHorarios = true,
  }) {
    if (traslados.length <= 1) {
      return traslados;
    }

    if (respetarHorarios) {
      // Si respetamos horarios, solo ordenar por hora programada
      debugPrint('🔄 Optimizando ruta respetando horarios programados');
      final List<TrasladoConRutaInfo> trasladosOrdenados = List<TrasladoConRutaInfo>.from(traslados);
      // ignore: cascade_invocations
      trasladosOrdenados.sort((TrasladoConRutaInfo a, TrasladoConRutaInfo b) {
        final DateTime? horaA = a.traslado.horaProgramada;
        final DateTime? horaB = b.traslado.horaProgramada;
        if (horaA == null && horaB == null) {
          return 0;
        }
        if (horaA == null) {
          return 1;
        }
        if (horaB == null) {
          return -1;
        }
        return horaA.compareTo(horaB);
      });
      return trasladosOrdenados;
    }

    // Algoritmo greedy (vecino más cercano)
    debugPrint('🔄 Optimizando ruta con algoritmo greedy (vecino más cercano)');

    final List<TrasladoConRutaInfo> pendientes = List<TrasladoConRutaInfo>.from(traslados);
    final List<TrasladoConRutaInfo> optimizados = <TrasladoConRutaInfo>[];

    // Empezar con el primer traslado (o el más temprano)
    TrasladoConRutaInfo actual = pendientes.removeAt(0);
    optimizados.add(actual);

    while (pendientes.isNotEmpty) {
      // Encontrar el traslado más cercano al destino actual
      double distanciaMinima = double.infinity;
      int indiceMinimo = 0;

      for (int i = 0; i < pendientes.length; i++) {
        final double distancia = calcularDistanciaEntrePuntos(
          punto1: actual.destino,
          punto2: pendientes[i].origen,
        );

        if (distancia < distanciaMinima) {
          distanciaMinima = distancia;
          indiceMinimo = i;
        }
      }

      actual = pendientes.removeAt(indiceMinimo);
      optimizados.add(actual);
    }

    debugPrint('✅ Ruta optimizada con ${optimizados.length} traslados');

    return optimizados;
  }

  /// Valida si una ruta es factible en términos de tiempo
  ///
  /// Retorna true si todos los traslados pueden completarse a tiempo
  bool validarFactibilidad({
    required List<TrasladoConRutaInfo> traslados,
    int margenMinutos = 15,
  }) {
    for (int i = 0; i < traslados.length; i++) {
      final TrasladoConRutaInfo traslado = traslados[i];
      final DateTime? horaProgramada = traslado.traslado.horaProgramada;
      final DateTime? horaEstimada = traslado.horaEstimadaLlegada;

      if (horaProgramada != null && horaEstimada != null) {
        final int diferencia = horaEstimada.difference(horaProgramada).inMinutes;

        if (diferencia > margenMinutos) {
          debugPrint(
            '⚠️ Traslado ${i + 1} no es factible: '
            'llegada estimada ${diferencia}min después de lo programado',
          );
          return false;
        }
      }
    }

    return true;
  }
}
