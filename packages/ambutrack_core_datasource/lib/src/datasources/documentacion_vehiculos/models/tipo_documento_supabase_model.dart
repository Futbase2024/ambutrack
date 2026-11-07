import 'package:json_annotation/json_annotation.dart';

import '../entities/tipo_documento_entity.dart';

part 'tipo_documento_supabase_model.g.dart';

/// Modelo de datos para Tipos de Documento de Vehículo desde/hacia Supabase
/// DTO con serialización JSON automática
@JsonSerializable(explicitToJson: true)
class TipoDocumentoSupabaseModel {
  const TipoDocumentoSupabaseModel({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.categoria,
    required this.vigenciaMeses,
    required this.obligatorio,
    required this.activo,
    this.fechaBaja,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String codigo;

  @JsonKey(name: 'nombre')
  final String nombre;

  @JsonKey(name: 'descripcion')
  final String? descripcion;

  @JsonKey(name: 'categoria')
  final String categoria;

  @JsonKey(name: 'vigencia_meses')
  final int vigenciaMeses;

  @JsonKey(name: 'obligatorio')
  final bool obligatorio;

  @JsonKey(name: 'activo')
  final bool activo;

  @JsonKey(name: 'fecha_baja')
  final DateTime? fechaBaja;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Deserialización desde JSON (Supabase → Model)
  factory TipoDocumentoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$TipoDocumentoSupabaseModelFromJson(json);

  /// Serialización a JSON (Model → Supabase)
  Map<String, dynamic> toJson() => _$TipoDocumentoSupabaseModelToJson(this);

  /// Conversión desde Entity (Domain → Model)
  factory TipoDocumentoSupabaseModel.fromEntity(TipoDocumentoEntity entity) {
    return TipoDocumentoSupabaseModel(
      id: entity.id,
      codigo: entity.codigo,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      categoria: entity.categoria,
      vigenciaMeses: entity.vigenciaMeses,
      obligatorio: entity.obligatorio,
      activo: entity.activo,
      fechaBaja: entity.fechaBaja,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Conversión a Entity (Model → Domain)
  TipoDocumentoEntity toEntity() {
    return TipoDocumentoEntity(
      id: id,
      codigo: codigo,
      nombre: nombre,
      descripcion: descripcion,
      categoria: categoria,
      vigenciaMeses: vigenciaMeses,
      obligatorio: obligatorio,
      activo: activo,
      fechaBaja: fechaBaja,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
