import 'package:json_annotation/json_annotation.dart';

import '../entities/categoria_vehiculo_entity.dart';

part 'categoria_vehiculo_supabase_model.g.dart';

/// Modelo Supabase para categorías de vehículo
@JsonSerializable()
class CategoriaVehiculoSupabaseModel {
  const CategoriaVehiculoSupabaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.nombre,
    this.descripcion,
    required this.activo,
    this.orden,
  });

  final String id;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  final String nombre;
  final String? descripcion;
  final bool activo;
  final int? orden;

  /// Convierte desde JSON
  factory CategoriaVehiculoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$CategoriaVehiculoSupabaseModelFromJson(json);

  /// Convierte a JSON
  Map<String, dynamic> toJson() => _$CategoriaVehiculoSupabaseModelToJson(this);

  /// Convierte a Entity
  CategoriaVehiculoEntity toEntity() {
    return CategoriaVehiculoEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nombre: nombre,
      descripcion: descripcion,
      activo: activo,
      orden: orden,
    );
  }

  /// Convierte desde Entity
  factory CategoriaVehiculoSupabaseModel.fromEntity(CategoriaVehiculoEntity entity) {
    return CategoriaVehiculoSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      activo: entity.activo,
      orden: entity.orden,
    );
  }
}
