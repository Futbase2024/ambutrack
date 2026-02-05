import '../entities/facultativo_entity.dart';

/// Modelo de datos de Supabase para Facultativo
///
/// Maneja la serialización/deserialización de datos de la tabla tfacultativos
/// incluyendo JOIN con tespecialidades para obtener el nombre de la especialidad.
class FacultativoSupabaseModel extends FacultativoEntity {
  const FacultativoSupabaseModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.nombre,
    required super.apellidos,
    super.numColegiado,
    super.especialidadId,
    super.especialidadNombre,
    super.telefono,
    super.email,
    required super.activo,
  });

  /// Crea un modelo desde JSON de Supabase
  ///
  /// Maneja el JOIN con tespecialidades para extraer el nombre de la especialidad.
  /// Formato del JOIN: tespecialidades!especialidad_id(nombre)
  factory FacultativoSupabaseModel.fromJson(Map<String, dynamic> json) {
    // Extraer nombre de especialidad desde JOIN si existe
    String? especialidadNombre;
    if (json['tespecialidades'] != null) {
      final Map<String, dynamic> especialidad =
          json['tespecialidades'] as Map<String, dynamic>;
      especialidadNombre = especialidad['nombre'] as String?;
    }

    return FacultativoSupabaseModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      nombre: json['nombre'] as String,
      apellidos: json['apellidos'] as String,
      numColegiado: json['num_colegiado'] as String?,
      especialidadId: json['especialidad_id'] as String?,
      especialidadNombre: especialidadNombre,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  ///
  /// IMPORTANTE: NO incluir especialidadNombre ya que es un campo calculado
  /// desde el JOIN y no existe en la tabla tfacultativos.
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre': nombre,
      'apellidos': apellidos,
      'num_colegiado': numColegiado,
      'especialidad_id': especialidadId,
      'telefono': telefono,
      'email': email,
      'activo': activo,
    };
  }

  /// Convierte el modelo a entidad de dominio
  FacultativoEntity toEntity() {
    return FacultativoEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nombre: nombre,
      apellidos: apellidos,
      numColegiado: numColegiado,
      especialidadId: especialidadId,
      especialidadNombre: especialidadNombre,
      telefono: telefono,
      email: email,
      activo: activo,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory FacultativoSupabaseModel.fromEntity(FacultativoEntity entity) {
    return FacultativoSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nombre: entity.nombre,
      apellidos: entity.apellidos,
      numColegiado: entity.numColegiado,
      especialidadId: entity.especialidadId,
      especialidadNombre: entity.especialidadNombre,
      telefono: entity.telefono,
      email: entity.email,
      activo: entity.activo,
    );
  }
}
