import 'package:json_annotation/json_annotation.dart';

import '../entities/categoria_equipamiento_entity.dart';

part 'categoria_equipamiento_supabase_model.g.dart';

/// Modelo Supabase para categorías de equipamiento
@JsonSerializable(explicitToJson: true)
class CategoriaEquipamientoSupabaseModel {
  /// Identificador único
  final String id;

  /// Código de la categoría
  final String codigo;

  /// Nombre de la categoría
  final String nombre;

  /// Descripción
  final String? descripcion;

  /// Orden de visualización
  final int orden;

  /// Día de revisión (1, 2 o 3)
  @JsonKey(name: 'dia_revision')
  final int diaRevision;

  /// Icono Material
  final String? icono;

  /// Fecha de creación
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const CategoriaEquipamientoSupabaseModel({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.orden,
    required this.diaRevision,
    this.icono,
    required this.createdAt,
  });

  /// Crea una instancia desde JSON de Supabase
  factory CategoriaEquipamientoSupabaseModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$CategoriaEquipamientoSupabaseModelFromJson(json);

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() =>
      _$CategoriaEquipamientoSupabaseModelToJson(this);

  /// Convierte el modelo a entidad de dominio
  CategoriaEquipamientoEntity toEntity() {
    return CategoriaEquipamientoEntity(
      id: id,
      codigo: codigo,
      nombre: nombre,
      descripcion: descripcion,
      orden: orden,
      diaRevision: diaRevision,
      icono: icono,
      createdAt: createdAt,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory CategoriaEquipamientoSupabaseModel.fromEntity(
    CategoriaEquipamientoEntity entity,
  ) {
    return CategoriaEquipamientoSupabaseModel(
      id: entity.id,
      codigo: entity.codigo,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      orden: entity.orden,
      diaRevision: entity.diaRevision,
      icono: entity.icono,
      createdAt: entity.createdAt,
    );
  }
}
