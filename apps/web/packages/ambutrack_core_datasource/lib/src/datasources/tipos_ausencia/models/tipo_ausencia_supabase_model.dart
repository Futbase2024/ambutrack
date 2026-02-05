import 'package:json_annotation/json_annotation.dart';

import '../entities/tipo_ausencia_entity.dart';

part 'tipo_ausencia_supabase_model.g.dart';

/// Modelo de datos para Tipo de Ausencia en Supabase
@JsonSerializable(explicitToJson: true)
class TipoAusenciaSupabaseModel {
  const TipoAusenciaSupabaseModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.requiereAprobacion,
    required this.requiereDocumento,
    required this.color,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String nombre;
  final String? descripcion;
  @JsonKey(name: 'requiere_aprobacion')
  final bool requiereAprobacion;
  @JsonKey(name: 'requiere_documento')
  final bool requiereDocumento;
  final String color;
  final bool activo;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// Deserialización desde JSON
  factory TipoAusenciaSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$TipoAusenciaSupabaseModelFromJson(json);

  /// Serialización a JSON
  Map<String, dynamic> toJson() => _$TipoAusenciaSupabaseModelToJson(this);

  /// Conversión a Entity
  TipoAusenciaEntity toEntity() {
    return TipoAusenciaEntity(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      requiereAprobacion: requiereAprobacion,
      requiereDocumento: requiereDocumento,
      color: color,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Conversión desde Entity
  factory TipoAusenciaSupabaseModel.fromEntity(TipoAusenciaEntity entity) {
    return TipoAusenciaSupabaseModel(
      id: entity.id,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      requiereAprobacion: entity.requiereAprobacion,
      requiereDocumento: entity.requiereDocumento,
      color: entity.color,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
