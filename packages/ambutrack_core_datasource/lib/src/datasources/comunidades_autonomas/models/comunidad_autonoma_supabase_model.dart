import '../entities/comunidad_autonoma_entity.dart';

/// Modelo de datos para Supabase de comunidades autónomas
class ComunidadAutonomaSupabaseModel {
  const ComunidadAutonomaSupabaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.nombre,
    this.codigo,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String nombre;
  final String? codigo;

  factory ComunidadAutonomaSupabaseModel.fromJson(Map<String, dynamic> json) {
    final DateTime now = DateTime.now();

    return ComunidadAutonomaSupabaseModel(
      id: json['id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : now,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : now,
      nombre: json['nombre'] as String? ?? '',
      codigo: json['codigo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre': nombre,
      if (codigo != null) 'codigo': codigo,
    };
  }

  ComunidadAutonomaEntity toEntity() {
    return ComunidadAutonomaEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nombre: nombre,
      codigo: codigo,
    );
  }

  factory ComunidadAutonomaSupabaseModel.fromEntity(
    ComunidadAutonomaEntity entity,
  ) {
    return ComunidadAutonomaSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nombre: entity.nombre,
      codigo: entity.codigo,
    );
  }
}
