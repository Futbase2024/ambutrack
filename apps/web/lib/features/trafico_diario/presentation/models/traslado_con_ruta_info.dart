import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'traslado_con_ruta_info.freezed.dart';

/// Información de un traslado con datos calculados de ruta
@freezed
class TrasladoConRutaInfo with _$TrasladoConRutaInfo {
  const factory TrasladoConRutaInfo({
    /// Orden en la secuencia de la ruta (1, 2, 3...)
    required int orden,

    /// Entidad del traslado
    required TrasladoEntity traslado,

    /// Punto de origen con coordenadas
    required PuntoUbicacion origen,

    /// Punto de destino con coordenadas
    required PuntoUbicacion destino,

    /// Distancia en kilómetros desde el punto anterior (null para el primero)
    double? distanciaDesdeAnteriorKm,

    /// Tiempo estimado en minutos desde el punto anterior (null para el primero)
    int? tiempoDesdeAnteriorMinutos,

    /// Hora estimada de llegada al destino
    DateTime? horaEstimadaLlegada,

    /// Distancia total del traslado (origen → destino) en km
    double? distanciaTotalTrasladoKm,

    /// Tiempo estimado del traslado (origen → destino) en minutos
    int? tiempoTotalTrasladoMinutos,

    /// Geometría real de la ruta por carretera (polyline con todos los puntos)
    /// Si es null, se usa línea recta entre origen y destino
    List<LatLng>? geometriaRuta,
  }) = _TrasladoConRutaInfo;
}

/// Punto de ubicación con coordenadas geográficas
@freezed
class PuntoUbicacion with _$PuntoUbicacion {
  const factory PuntoUbicacion({
    /// Nombre del punto (ej: "Hospital Universitario")
    required String nombre,

    /// Latitud
    required double latitud,

    /// Longitud
    required double longitud,

    /// Dirección completa (opcional)
    String? direccion,

    /// Tipo de ubicación (hospital, domicilio, centro, etc.)
    String? tipo,
  }) = _PuntoUbicacion;
}

/// Información de un traslado con retraso
@freezed
class TrasladoConRetrasoInfo with _$TrasladoConRetrasoInfo {
  const factory TrasladoConRetrasoInfo({
    /// Orden del traslado (1-based)
    required int orden,

    /// Minutos de retraso estimado
    required int minutosRetraso,
  }) = _TrasladoConRetrasoInfo;
}

/// Resumen de la ruta completa
@freezed
class RutaResumen with _$RutaResumen {
  const factory RutaResumen({
    /// Total de traslados en la ruta
    required int totalTraslados,

    /// Distancia total de la ruta en kilómetros
    required double distanciaTotalKm,

    /// Tiempo total estimado en minutos
    required int tiempoTotalMinutos,

    /// Hora de inicio estimada (primer traslado)
    DateTime? horaInicio,

    /// Hora de fin estimada (último traslado)
    DateTime? horaFin,

    /// Velocidad promedio asumida (km/h)
    @Default(50.0) double velocidadPromedioKmh,

    /// Indica si la ruta es factible (todos los traslados a tiempo)
    @Default(true) bool esFactible,

    /// Lista de traslados con información de retrasos (si los hay)
    @Default(<TrasladoConRetrasoInfo>[]) List<TrasladoConRetrasoInfo> trasladosConRetraso,
  }) = _RutaResumen;

  const RutaResumen._();

  /// Calcula horas y minutos del tiempo total
  String get tiempoTotalFormateado {
    final int horas = tiempoTotalMinutos ~/ 60;
    final int minutos = tiempoTotalMinutos % 60;
    if (horas > 0) {
      return '${horas}h ${minutos}min';
    }
    return '${minutos}min';
  }
}
