import 'package:json_annotation/json_annotation.dart';

import '../entities/formacion_personal_entity.dart';

part 'formacion_personal_supabase_model.g.dart';

/// Modelo de Supabase para registros de formación personal
@JsonSerializable()
class FormacionPersonalSupabaseModel {
  const FormacionPersonalSupabaseModel({
    required this.id,
    required this.personalId,
    this.certificacionId,
    this.cursoId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.fechaExpiracion,
    required this.horasAcumuladas,
    required this.estado,
    this.observaciones,
    this.certificadoUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  @JsonKey(name: 'personal_id')
  final String personalId;

  @JsonKey(name: 'certificacion_id')
  final String? certificacionId;

  @JsonKey(name: 'curso_id')
  final String? cursoId;

  @JsonKey(name: 'fecha_inicio')
  final DateTime fechaInicio;

  @JsonKey(name: 'fecha_fin')
  final DateTime fechaFin;

  @JsonKey(name: 'fecha_expiracion')
  final DateTime fechaExpiracion;

  @JsonKey(name: 'horas_acumuladas')
  final int horasAcumuladas;

  @JsonKey(name: 'estado')
  final String estado;

  @JsonKey(name: 'observaciones')
  final String? observaciones;

  @JsonKey(name: 'certificado_url')
  final String? certificadoUrl;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Conversión desde JSON
  factory FormacionPersonalSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$FormacionPersonalSupabaseModelFromJson(json);

  /// Conversión a JSON
  Map<String, dynamic> toJson() => _$FormacionPersonalSupabaseModelToJson(this);

  /// Conversión a entidad de dominio
  FormacionPersonalEntity toEntity() {
    return FormacionPersonalEntity(
      id: id,
      personalId: personalId,
      certificacionId: certificacionId,
      cursoId: cursoId,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      fechaExpiracion: fechaExpiracion,
      horasAcumuladas: horasAcumuladas,
      estado: estado,
      observaciones: observaciones,
      certificadoUrl: certificadoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Conversión desde entidad de dominio
  factory FormacionPersonalSupabaseModel.fromEntity(FormacionPersonalEntity entity) {
    return FormacionPersonalSupabaseModel(
      id: entity.id,
      personalId: entity.personalId,
      certificacionId: entity.certificacionId,
      cursoId: entity.cursoId,
      fechaInicio: entity.fechaInicio,
      fechaFin: entity.fechaFin,
      fechaExpiracion: entity.fechaExpiracion,
      horasAcumuladas: entity.horasAcumuladas,
      estado: entity.estado,
      observaciones: entity.observaciones,
      certificadoUrl: entity.certificadoUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
