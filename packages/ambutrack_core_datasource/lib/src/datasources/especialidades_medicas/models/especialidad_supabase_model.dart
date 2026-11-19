import '../entities/especialidad_entity.dart';

/// Modelo de Supabase para Especialidades Médicas
///
/// Maneja la serialización desde/hacia la tabla tespecialidades
class EspecialidadSupabaseModel {
  const EspecialidadSupabaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.nombre,
    this.descripcion,
    required this.requiereCertificacion,
    required this.tipoEspecialidad,
    required this.activo,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String nombre;
  final String? descripcion;
  final bool requiereCertificacion;
  final String tipoEspecialidad;
  final bool activo;

  /// Crea un modelo desde JSON de Supabase
  factory EspecialidadSupabaseModel.fromJson(Map<String, dynamic> json) {
    return EspecialidadSupabaseModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      requiereCertificacion: json['requiere_certificacion'] as bool? ?? false,
      tipoEspecialidad: json['tipo_especialidad'] as String? ?? 'medica',
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
      'requiere_certificacion': requiereCertificacion,
      'tipo_especialidad': tipoEspecialidad,
      'activo': activo,
    };
  }

  /// Convierte el modelo a entidad de dominio
  EspecialidadEntity toEntity() {
    return EspecialidadEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nombre: nombre,
      descripcion: descripcion,
      requiereCertificacion: requiereCertificacion,
      tipoEspecialidad: tipoEspecialidad,
      activo: activo,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory EspecialidadSupabaseModel.fromEntity(EspecialidadEntity entity) {
    return EspecialidadSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      requiereCertificacion: entity.requiereCertificacion,
      tipoEspecialidad: entity.tipoEspecialidad,
      activo: entity.activo,
    );
  }
}
