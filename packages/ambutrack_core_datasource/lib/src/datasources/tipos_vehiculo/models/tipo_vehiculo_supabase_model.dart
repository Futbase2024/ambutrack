import '../entities/tipo_vehiculo_entity.dart';

/// Modelo de datos para tipo de vehículo desde Supabase
class TipoVehiculoSupabaseModel {
  const TipoVehiculoSupabaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.nombre,
    this.descripcion,
    required this.activo,
    this.orden,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String nombre;
  final String? descripcion;
  final bool activo;
  final int? orden;

  /// Convierte el modelo a Entity
  TipoVehiculoEntity toEntity() {
    return TipoVehiculoEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nombre: nombre,
      descripcion: descripcion,
      activo: activo,
      orden: orden,
    );
  }

  /// Crea un modelo desde Entity
  factory TipoVehiculoSupabaseModel.fromEntity(TipoVehiculoEntity entity) {
    return TipoVehiculoSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      activo: entity.activo,
      orden: entity.orden,
    );
  }

  /// Deserializa desde JSON de Supabase
  factory TipoVehiculoSupabaseModel.fromJson(Map<String, dynamic> json) {
    return TipoVehiculoSupabaseModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.parse(json['created_at'] as String),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? true,
      orden: json['orden'] as int?,
    );
  }

  /// Serializa a JSON para Supabase
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      'activo': activo,
      if (orden != null) 'orden': orden,
    };
  }
}
