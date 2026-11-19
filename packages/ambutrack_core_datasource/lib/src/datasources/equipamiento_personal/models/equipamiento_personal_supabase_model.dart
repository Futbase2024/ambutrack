import 'package:json_annotation/json_annotation.dart';

import '../entities/equipamiento_personal_entity.dart';

part 'equipamiento_personal_supabase_model.g.dart';

/// Modelo de Supabase para equipamiento personal
@JsonSerializable()
class EquipamientoPersonalSupabaseModel {
  const EquipamientoPersonalSupabaseModel({
    required this.id,
    required this.personalId,
    required this.tipoEquipamiento,
    required this.nombreEquipamiento,
    required this.fechaAsignacion,
    this.fechaDevolucion,
    this.numeroSerie,
    this.talla,
    this.estado,
    this.observaciones,
    this.documentoUrl,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  @JsonKey(name: 'personal_id')
  final String personalId;

  @JsonKey(name: 'tipo_equipamiento')
  final String tipoEquipamiento;

  @JsonKey(name: 'nombre_equipamiento')
  final String nombreEquipamiento;

  @JsonKey(name: 'fecha_asignacion')
  final DateTime fechaAsignacion;

  @JsonKey(name: 'fecha_devolucion')
  final DateTime? fechaDevolucion;

  @JsonKey(name: 'numero_serie')
  final String? numeroSerie;

  final String? talla;
  final String? estado;
  final String? observaciones;

  @JsonKey(name: 'documento_url')
  final String? documentoUrl;

  final bool activo;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Conversión desde JSON
  factory EquipamientoPersonalSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$EquipamientoPersonalSupabaseModelFromJson(json);

  /// Conversión a JSON
  Map<String, dynamic> toJson() => _$EquipamientoPersonalSupabaseModelToJson(this);

  /// Conversión a entidad de dominio
  EquipamientoPersonalEntity toEntity() {
    return EquipamientoPersonalEntity(
      id: id,
      personalId: personalId,
      tipoEquipamiento: tipoEquipamiento,
      nombreEquipamiento: nombreEquipamiento,
      fechaAsignacion: fechaAsignacion,
      fechaDevolucion: fechaDevolucion,
      numeroSerie: numeroSerie,
      talla: talla,
      estado: estado,
      observaciones: observaciones,
      documentoUrl: documentoUrl,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Conversión desde entidad de dominio
  factory EquipamientoPersonalSupabaseModel.fromEntity(EquipamientoPersonalEntity entity) {
    return EquipamientoPersonalSupabaseModel(
      id: entity.id,
      personalId: entity.personalId,
      tipoEquipamiento: entity.tipoEquipamiento,
      nombreEquipamiento: entity.nombreEquipamiento,
      fechaAsignacion: entity.fechaAsignacion,
      fechaDevolucion: entity.fechaDevolucion,
      numeroSerie: entity.numeroSerie,
      talla: entity.talla,
      estado: entity.estado,
      observaciones: entity.observaciones,
      documentoUrl: entity.documentoUrl,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
