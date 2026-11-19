import 'package:equatable/equatable.dart';

/// Entidad de dominio para Ubicación Geográfica
///
/// Representa una ubicación GPS con latitud, longitud, precisión y timestamp
class UbicacionEntity extends Equatable {
  const UbicacionEntity({
    required this.latitud,
    required this.longitud,
    this.precision,
    required this.timestamp,
    this.velocidad,
    this.altitud,
    this.rumbo,
  });

  /// Latitud en grados decimales
  final double latitud;

  /// Longitud en grados decimales
  final double longitud;

  /// Precisión en metros (accuracy)
  final double? precision;

  /// Marca de tiempo cuando se capturó la ubicación
  final DateTime timestamp;

  /// Velocidad en metros por segundo (opcional)
  final double? velocidad;

  /// Altitud en metros sobre el nivel del mar (opcional)
  final double? altitud;

  /// Rumbo en grados (0-360) (opcional)
  final double? rumbo;

  /// Convierte la ubicación a Map<String, dynamic>
  /// Compatible con el formato que se guarda en JSONB en Supabase
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'lat': latitud,
      'lng': longitud,
      if (precision != null) 'precision': precision,
      'timestamp': timestamp.toIso8601String(),
      if (velocidad != null) 'velocidad': velocidad,
      if (altitud != null) 'altitud': altitud,
      if (rumbo != null) 'rumbo': rumbo,
    };
  }

  /// Crea una UbicacionEntity desde Map<String, dynamic>
  /// Compatible con el formato que se lee de JSONB en Supabase
  factory UbicacionEntity.fromJson(Map<String, dynamic> json) {
    return UbicacionEntity(
      latitud: (json['lat'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['lng'] as num?)?.toDouble() ?? 0.0,
      precision: (json['precision'] as num?)?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      velocidad: (json['velocidad'] as num?)?.toDouble(),
      altitud: (json['altitud'] as num?)?.toDouble(),
      rumbo: (json['rumbo'] as num?)?.toDouble(),
    );
  }

  /// Crea una copia con campos modificados
  UbicacionEntity copyWith({
    double? latitud,
    double? longitud,
    double? precision,
    DateTime? timestamp,
    double? velocidad,
    double? altitud,
    double? rumbo,
  }) {
    return UbicacionEntity(
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      precision: precision ?? this.precision,
      timestamp: timestamp ?? this.timestamp,
      velocidad: velocidad ?? this.velocidad,
      altitud: altitud ?? this.altitud,
      rumbo: rumbo ?? this.rumbo,
    );
  }

  @override
  List<Object?> get props => [
        latitud,
        longitud,
        precision,
        timestamp,
        velocidad,
        altitud,
        rumbo,
      ];

  @override
  String toString() {
    return 'UbicacionEntity(lat: $latitud, lng: $longitud, precision: $precision, timestamp: $timestamp)';
  }
}
