import 'package:equatable/equatable.dart';

/// Entidad que representa una ubicación GPS
class UbicacionEntity extends Equatable {
  const UbicacionEntity({
    required this.latitud,
    required this.longitud,
    this.precision,
    this.timestamp,
  });

  final double latitud;
  final double longitud;
  final double? precision; // Precisión en metros
  final DateTime? timestamp;

  @override
  List<Object?> get props => [latitud, longitud, precision, timestamp];

  UbicacionEntity copyWith({
    double? latitud,
    double? longitud,
    double? precision,
    DateTime? timestamp,
  }) {
    return UbicacionEntity(
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      precision: precision ?? this.precision,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convierte a Map para JSONB de Supabase
  Map<String, dynamic> toJson() {
    return {
      'latitud': latitud,
      'longitud': longitud,
      if (precision != null) 'precision': precision,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  /// Crea desde Map de JSONB de Supabase
  factory UbicacionEntity.fromJson(Map<String, dynamic> json) {
    return UbicacionEntity(
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      precision: json['precision'] != null
          ? (json['precision'] as num).toDouble()
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }
}
