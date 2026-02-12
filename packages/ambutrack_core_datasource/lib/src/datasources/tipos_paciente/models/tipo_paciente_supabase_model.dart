import '../entities/tipo_paciente_entity.dart';

/// Modelo de datos de Supabase para Tipo de Paciente
///
/// Maneja la serialización/deserialización de datos de la tabla ttipos_paciente
class TipoPacienteSupabaseModel extends TipoPacienteEntity {
  const TipoPacienteSupabaseModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.nombre,
    super.descripcion,
    required super.activo,
  });

  /// Crea un modelo desde JSON de Supabase
  factory TipoPacienteSupabaseModel.fromJson(Map<String, dynamic> json) {
    return TipoPacienteSupabaseModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
    };
  }

  /// Convierte el modelo a entidad de dominio
  TipoPacienteEntity toEntity() {
    return TipoPacienteEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nombre: nombre,
      descripcion: descripcion,
      activo: activo,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory TipoPacienteSupabaseModel.fromEntity(TipoPacienteEntity entity) {
    return TipoPacienteSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      activo: entity.activo,
    );
  }
}
