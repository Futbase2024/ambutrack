import 'package:json_annotation/json_annotation.dart';

import '../entities/curso_entity.dart';

part 'curso_supabase_model.g.dart';

/// Modelo de Supabase para cursos
@JsonSerializable()
class CursoSupabaseModel {
  const CursoSupabaseModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tipo,
    required this.duracionHoras,
    required this.certificaciones,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  @JsonKey(name: 'nombre')
  final String nombre;

  @JsonKey(name: 'descripcion')
  final String? descripcion;

  @JsonKey(name: 'tipo')
  final String tipo;

  @JsonKey(name: 'duracion_horas')
  final int duracionHoras;

  @JsonKey(name: 'certificaciones')
  final List<String> certificaciones;

  @JsonKey(name: 'activo')
  final bool activo;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Conversión desde JSON
  factory CursoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$CursoSupabaseModelFromJson(json);

  /// Conversión a JSON
  Map<String, dynamic> toJson() => _$CursoSupabaseModelToJson(this);

  /// Conversión a entidad de dominio
  CursoEntity toEntity() {
    return CursoEntity(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      tipo: tipo,
      duracionHoras: duracionHoras,
      certificaciones: certificaciones,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Conversión desde entidad de dominio
  factory CursoSupabaseModel.fromEntity(CursoEntity entity) {
    return CursoSupabaseModel(
      id: entity.id,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      tipo: entity.tipo,
      duracionHoras: entity.duracionHoras,
      certificaciones: entity.certificaciones,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
