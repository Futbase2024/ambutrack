import '../entities/registro_horario_entity.dart';

/// Model DTO para serialización JSON con Supabase
///
/// Mapea nombres snake_case de Supabase a camelCase de Dart.
class RegistroHorarioSupabaseModel {
  const RegistroHorarioSupabaseModel({
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
  final String tipoFichaje;
  final DateTime fechaHora;
  final double? latitud;
  final double? longitud;
  final double? precisionGps;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Convierte JSON de Supabase al Model
  factory RegistroHorarioSupabaseModel.fromJson(Map<String, dynamic> json) {
    return RegistroHorarioSupabaseModel(
      id: json['id'] as String,
      personalId: json['personal_id'] as String,
      tipoFichaje: json['tipo_fichaje'] as String,
      fechaHora: DateTime.parse(json['fecha_hora'] as String),
      latitud: json['latitud'] as double?,
      longitud: json['longitud'] as double?,
      precisionGps: json['precision_gps'] as double?,
      observaciones: json['observaciones'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convierte el Model a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personal_id': personalId,
      'tipo_fichaje': tipoFichaje,
      'fecha_hora': fechaHora.toIso8601String(),
      'latitud': latitud,
      'longitud': longitud,
      'precision_gps': precisionGps,
      'observaciones': observaciones,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convierte el Model a Entity (dominio puro)
  RegistroHorarioEntity toEntity() {
    return RegistroHorarioEntity(
      id: id,
      personalId: personalId,
      tipoFichaje: TipoFichaje.fromString(tipoFichaje),
      fechaHora: fechaHora,
      latitud: latitud,
      longitud: longitud,
      precisionGps: precisionGps,
      observaciones: observaciones,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convierte una Entity a Model (para crear/actualizar en Supabase)
  factory RegistroHorarioSupabaseModel.fromEntity(RegistroHorarioEntity entity) {
    return RegistroHorarioSupabaseModel(
      id: entity.id,
      personalId: entity.personalId,
      tipoFichaje: entity.tipoFichaje.value,
      fechaHora: entity.fechaHora,
      latitud: entity.latitud,
      longitud: entity.longitud,
      precisionGps: entity.precisionGps,
      observaciones: entity.observaciones,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
