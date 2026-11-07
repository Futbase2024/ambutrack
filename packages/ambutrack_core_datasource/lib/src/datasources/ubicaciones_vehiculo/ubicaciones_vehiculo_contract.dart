import 'entities/ubicacion_vehiculo_entity.dart';

/// Seguimiento GPS de la flota (tabla `thistorial_ubicaciones`)
abstract class UbicacionesVehiculoDataSource {
  /// Última posición de cada vehículo (últimos 7 días)
  Future<List<UbicacionVehiculoEntity>> getUltimas();

  /// Posiciones de un vehículo entre [desde] y [hasta], en orden cronológico
  Future<List<UbicacionVehiculoEntity>> getRecorrido(String vehiculoId, {required DateTime desde, DateTime? hasta});

  /// Nuevas posiciones en tiempo real (Realtime, respeta las reglas de lectura)
  Stream<UbicacionVehiculoEntity> watchNuevas();

  /// App móvil: registra la posición del vehículo del turno de hoy del usuario
  Future<void> registrar({
    required double latitud,
    required double longitud,
    double? velocidadKmh,
    double? precisionMetros,
    double? direccionGrados,
    String? servicioId,
  });
}
