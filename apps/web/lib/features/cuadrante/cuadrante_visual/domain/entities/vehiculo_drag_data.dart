/// Datos del vehículo que se está arrastrando
class VehiculoDragData {
  const VehiculoDragData({
    required this.vehiculoId,
    required this.matricula,
    required this.tipo,
    this.modelo,
  });

  /// ID del vehículo
  final String vehiculoId;

  /// Matrícula
  final String matricula;

  /// Tipo de vehículo ('ambulancia', 'vehiculo_medico', etc.)
  final String tipo;

  /// Modelo (ej: 'Mercedes Sprinter')
  final String? modelo;

  @override
  String toString() => 'VehiculoDrag($matricula - $tipo)';
}
