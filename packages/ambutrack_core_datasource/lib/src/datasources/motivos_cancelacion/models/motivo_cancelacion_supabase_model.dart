import '../entities/motivo_cancelacion_entity.dart';

/// Modelo de datos para Supabase de motivos de cancelación
///
/// Maneja la serialización/deserialización entre JSON de Supabase y [MotivoCancelacionEntity].
/// Utiliza snake_case para los campos de la base de datos.
class MotivoCancelacionSupabaseModel {
  const MotivoCancelacionSupabaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.nombre,
    this.descripcion,
    required this.activo,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String nombre;
  final String? descripcion;
  final bool activo;

  /// Crea un modelo desde JSON de Supabase
  factory MotivoCancelacionSupabaseModel.fromJson(Map<String, dynamic> json) {
    final DateTime now = DateTime.now();

    return MotivoCancelacionSupabaseModel(
      id: json['id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : now,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : now,
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      'activo': activo,
    };
  }

  /// Convierte el modelo a entidad de dominio
  MotivoCancelacionEntity toEntity() {
    return MotivoCancelacionEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nombre: nombre,
      descripcion: descripcion,
      activo: activo,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory MotivoCancelacionSupabaseModel.fromEntity(
    MotivoCancelacionEntity entity,
  ) {
    return MotivoCancelacionSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      activo: entity.activo,
    );
  }
}
