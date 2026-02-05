import '../entities/provincia_entity.dart';

/// Modelo de datos para Supabase de provincias
///
/// Maneja la serialización/deserialización entre JSON de Supabase y [ProvinciaEntity].
/// Utiliza snake_case para los campos de la base de datos.
class ProvinciaSupabaseModel {
  const ProvinciaSupabaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.codigo,
    required this.nombre,
    this.comunidadId,
    this.comunidadAutonoma,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? codigo;
  final String nombre;
  final String? comunidadId;
  final String? comunidadAutonoma;

  /// Crea un modelo desde JSON de Supabase
  factory ProvinciaSupabaseModel.fromJson(Map<String, dynamic> json) {
    final DateTime now = DateTime.now();

    // Extraer el nombre de la comunidad autónoma del JOIN
    String? comunidadNombre;
    if (json['tcomunidades'] != null && json['tcomunidades'] is Map) {
      comunidadNombre =
          (json['tcomunidades'] as Map<String, dynamic>)['nombre'] as String?;
    }

    return ProvinciaSupabaseModel(
      id: json['id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : now,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : now,
      codigo: json['codigo'] as String?,
      nombre: json['nombre'] as String? ?? '',
      comunidadId: json['comunidad_id'] as String?,
      comunidadAutonoma: comunidadNombre ?? json['comunidad_autonoma'] as String?,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (codigo != null) 'codigo': codigo,
      'nombre': nombre,
      if (comunidadId != null) 'comunidad_id': comunidadId,
      // comunidad_autonoma es un campo calculado (JOIN), no se envía
    };
  }

  /// Convierte el modelo a entidad de dominio
  ProvinciaEntity toEntity() {
    return ProvinciaEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      codigo: codigo,
      nombre: nombre,
      comunidadId: comunidadId,
      comunidadAutonoma: comunidadAutonoma,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory ProvinciaSupabaseModel.fromEntity(ProvinciaEntity entity) {
    return ProvinciaSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      codigo: entity.codigo,
      nombre: entity.nombre,
      comunidadId: entity.comunidadId,
      comunidadAutonoma: entity.comunidadAutonoma,
    );
  }
}
