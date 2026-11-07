import 'package:json_annotation/json_annotation.dart';

import '../entities/motivo_traslado_entity.dart';

part 'motivo_traslado_supabase_model.g.dart';

/// Modelo de datos para Motivo de Traslado en Supabase (PostgreSQL)
///
/// Este modelo se serializa/deserializa a/desde JSON usando json_serializable.
/// Representa la estructura de la tabla tmotivos_traslado en PostgreSQL.
@JsonSerializable()
class MotivoTrasladoSupabaseModel {
  const MotivoTrasladoSupabaseModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.tiempo = 0,
    this.vuelta = false,
  });

  factory MotivoTrasladoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$MotivoTrasladoSupabaseModelFromJson(json);

  /// Convierte una entidad de dominio a modelo Supabase
  factory MotivoTrasladoSupabaseModel.fromEntity(
    MotivoTrasladoEntity entity,
  ) {
    return MotivoTrasladoSupabaseModel(
      id: entity.id,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      tiempo: entity.tiempo,
      vuelta: entity.vuelta,
    );
  }

  final String id;
  final String nombre;
  final String descripcion;
  final bool activo;
  final int tiempo;
  final bool vuelta;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$MotivoTrasladoSupabaseModelToJson(this);

  /// Convierte el modelo Supabase a entidad de dominio
  MotivoTrasladoEntity toEntity() {
    return MotivoTrasladoEntity(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tiempo: tiempo,
      vuelta: vuelta,
    );
  }
}
