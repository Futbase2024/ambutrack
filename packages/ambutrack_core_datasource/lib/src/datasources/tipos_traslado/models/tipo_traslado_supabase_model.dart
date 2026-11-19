import '../entities/tipo_traslado_entity.dart';

/// Modelo de datos para TipoTraslado desde Supabase
class TipoTrasladoSupabaseModel extends TipoTrasladoEntity {
  const TipoTrasladoSupabaseModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.nombre,
    super.descripcion,
    required super.activo,
  });

  /// Crea una instancia desde JSON de Supabase
  factory TipoTrasladoSupabaseModel.fromJson(Map<String, dynamic> json) {
    return TipoTrasladoSupabaseModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }

  /// Convierte la instancia a JSON para Supabase
  @override
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
}
