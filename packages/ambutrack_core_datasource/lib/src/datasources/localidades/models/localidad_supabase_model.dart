import '../entities/localidad_entity.dart';

/// Modelo de Supabase para Localidades
///
/// Maneja la serialización desde/hacia la tabla tpoblaciones
/// Incluye JOIN con tprovincias para obtener el nombre de la provincia
class LocalidadSupabaseModel {
  const LocalidadSupabaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.codigo,
    required this.nombre,
    this.provinciaId,
    this.provinciaNombre,
    this.codigoPostal,
  });

  /// Crea un modelo desde JSON de Supabase
  ///
  /// Maneja el JOIN con tprovincias para extraer el nombre de la provincia
  factory LocalidadSupabaseModel.fromJson(Map<String, dynamic> json) {
    // Extraer el nombre de la provincia del JOIN
    String? provinciaNombre;
    if (json['tprovincias'] != null && json['tprovincias'] is Map) {
      final provinciaData = json['tprovincias'] as Map<String, dynamic>;
      provinciaNombre = provinciaData['nombre'] as String?;
    }

    return LocalidadSupabaseModel(
      id: json['id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      codigo: json['codigo'] as String?,
      nombre: json['nombre'] as String? ?? '',
      provinciaId: json['provincia_id'] as String?,
      provinciaNombre: provinciaNombre,
      codigoPostal: json['codigo_postal'] as String?,
    );
  }

  /// Crea un modelo desde una entity
  factory LocalidadSupabaseModel.fromEntity(LocalidadEntity entity) {
    return LocalidadSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      codigo: entity.codigo,
      nombre: entity.nombre,
      provinciaId: entity.provinciaId,
      provinciaNombre: entity.provinciaNombre,
      codigoPostal: entity.codigoPostal,
    );
  }

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? codigo;
  final String nombre;
  final String? provinciaId;
  final String? provinciaNombre; // Del JOIN con tprovincias
  final String? codigoPostal;

  /// Convierte el modelo a JSON para Supabase
  ///
  /// NO incluye provincia_nombre ya que es un campo calculado del JOIN
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (codigo != null) 'codigo': codigo,
      'nombre': nombre,
      if (provinciaId != null) 'provincia_id': provinciaId,
      if (codigoPostal != null) 'codigo_postal': codigoPostal,
    };
  }

  /// Convierte el modelo a entity
  LocalidadEntity toEntity() {
    return LocalidadEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      codigo: codigo,
      nombre: nombre,
      provinciaId: provinciaId,
      provinciaNombre: provinciaNombre,
      codigoPostal: codigoPostal,
    );
  }
}
