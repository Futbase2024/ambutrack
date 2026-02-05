/// Modelo que representa un conductor con su vehículo asignado en el turno
class ConductorConVehiculo {
  const ConductorConVehiculo({
    required this.idConductor,
    required this.nombreConductor,
    required this.idVehiculo,
    required this.matriculaVehiculo,
  });

  /// ID del conductor (personal)
  final String idConductor;

  /// Nombre completo del conductor
  final String nombreConductor;

  /// ID del vehículo asignado en el turno
  final String idVehiculo;

  /// Matrícula del vehículo asignado
  final String matriculaVehiculo;

  @override
  String toString() => '$nombreConductor ($matriculaVehiculo)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConductorConVehiculo &&
          runtimeType == other.runtimeType &&
          idConductor == other.idConductor &&
          idVehiculo == other.idVehiculo &&
          matriculaVehiculo == other.matriculaVehiculo;

  @override
  int get hashCode => idConductor.hashCode ^ idVehiculo.hashCode ^ matriculaVehiculo.hashCode;
}
