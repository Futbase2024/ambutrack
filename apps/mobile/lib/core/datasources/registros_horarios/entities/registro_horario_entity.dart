import 'package:equatable/equatable.dart';

/// Enum para el tipo de fichaje
enum TipoFichaje {
  entrada('entrada'),
  salida('salida');

  const TipoFichaje(this.value);
  final String value;

  /// Convierte un String a TipoFichaje
  static TipoFichaje fromString(String value) {
    switch (value.toLowerCase()) {
      case 'entrada':
        return TipoFichaje.entrada;
      case 'salida':
        return TipoFichaje.salida;
      default:
        throw ArgumentError('Tipo de fichaje inválido: $value');
    }
  }
}

/// Entity de dominio pura para registros horarios
///
/// Representa un fichaje de entrada o salida del personal con geolocalización.
class RegistroHorarioEntity extends Equatable {
  const RegistroHorarioEntity({
    required this.id,
    required this.personalId,
    required this.tipoFichaje,
    required this.fechaHora,
    this.latitud,
    this.longitud,
    this.precisionGps,
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String personalId;
  final TipoFichaje tipoFichaje;
  final DateTime fechaHora;
  final double? latitud;
  final double? longitud;
  final double? precisionGps;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Crea una copia con los campos opcionales actualizados
  RegistroHorarioEntity copyWith({
    String? id,
    String? personalId,
    TipoFichaje? tipoFichaje,
    DateTime? fechaHora,
    double? latitud,
    double? longitud,
    double? precisionGps,
    String? observaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegistroHorarioEntity(
      id: id ?? this.id,
      personalId: personalId ?? this.personalId,
      tipoFichaje: tipoFichaje ?? this.tipoFichaje,
      fechaHora: fechaHora ?? this.fechaHora,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      precisionGps: precisionGps ?? this.precisionGps,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        personalId,
        tipoFichaje,
        fechaHora,
        latitud,
        longitud,
        precisionGps,
        observaciones,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'RegistroHorarioEntity(id: $id, personalId: $personalId, tipo: ${tipoFichaje.value}, fecha: $fechaHora, lat: $latitud, lon: $longitud)';
  }
}
