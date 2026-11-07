import 'package:equatable/equatable.dart';

/// Posición GPS de un vehículo (tabla `thistorial_ubicaciones`)
class UbicacionVehiculoEntity extends Equatable {
  const UbicacionVehiculoEntity({
    required this.vehiculoId,
    required this.timestamp,
    required this.latitud,
    required this.longitud,
    this.matricula,
    this.tipoVehiculo,
    this.velocidadKmh,
    this.enServicio = false,
  });

  final String vehiculoId;
  final DateTime timestamp;
  final double latitud;
  final double longitud;

  /// Solo en las últimas posiciones (fn_ultimas_ubicaciones)
  final String? matricula;
  final String? tipoVehiculo;
  final double? velocidadKmh;
  final bool enServicio;

  /// Minutos desde la última posición
  int get minutosDesde => DateTime.now().difference(timestamp).inMinutes;

  UbicacionVehiculoEntity copyWithPosicion(UbicacionVehiculoEntity nueva) => UbicacionVehiculoEntity(
        vehiculoId: vehiculoId,
        timestamp: nueva.timestamp,
        latitud: nueva.latitud,
        longitud: nueva.longitud,
        matricula: matricula,
        tipoVehiculo: tipoVehiculo,
        velocidadKmh: nueva.velocidadKmh,
        enServicio: nueva.enServicio,
      );

  @override
  List<Object?> get props => <Object?>[vehiculoId, timestamp, latitud, longitud, velocidadKmh, enServicio];
}
