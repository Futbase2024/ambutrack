import 'package:json_annotation/json_annotation.dart';

import '../entities/ausencia_entity.dart';

part 'ausencia_supabase_model.g.dart';

/// Modelo de datos para Ausencia en Supabase
@JsonSerializable(explicitToJson: true)
class AusenciaSupabaseModel {
  const AusenciaSupabaseModel({
    required this.id,
    required this.idPersonal,
    required this.idTipoAusencia,
    required this.fechaInicio,
    required this.fechaFin,
    this.motivo,
    required this.estado,
    this.documentoAdjunto,
    this.documentoStoragePath,
    this.observaciones,
    this.aprobadoPor,
    this.fechaAprobacion,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  @JsonKey(name: 'id_personal')
  final String idPersonal;
  @JsonKey(name: 'id_tipo_ausencia')
  final String idTipoAusencia;
  @JsonKey(name: 'fecha_inicio')
  final DateTime fechaInicio;
  @JsonKey(name: 'fecha_fin')
  final DateTime fechaFin;
  final String? motivo;
  final String estado;
  @JsonKey(name: 'documento_adjunto')
  final String? documentoAdjunto;
  @JsonKey(name: 'documento_storage_path')
  final String? documentoStoragePath;
  final String? observaciones;
  @JsonKey(name: 'aprobado_por')
  final String? aprobadoPor;
  @JsonKey(name: 'fecha_aprobacion')
  final DateTime? fechaAprobacion;
  final bool activo;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// Deserialización desde JSON
  factory AusenciaSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$AusenciaSupabaseModelFromJson(json);

  /// Serialización a JSON
  Map<String, dynamic> toJson() => _$AusenciaSupabaseModelToJson(this);

  /// Conversión a Entity
  AusenciaEntity toEntity() {
    return AusenciaEntity(
      id: id,
      idPersonal: idPersonal,
      idTipoAusencia: idTipoAusencia,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      motivo: motivo,
      estado: EstadoAusenciaExtension.fromString(estado),
      documentoAdjunto: documentoAdjunto,
      documentoStoragePath: documentoStoragePath,
      observaciones: observaciones,
      aprobadoPor: aprobadoPor,
      fechaAprobacion: fechaAprobacion,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Conversión desde Entity
  factory AusenciaSupabaseModel.fromEntity(AusenciaEntity entity) {
    return AusenciaSupabaseModel(
      id: entity.id,
      idPersonal: entity.idPersonal,
      idTipoAusencia: entity.idTipoAusencia,
      fechaInicio: entity.fechaInicio,
      fechaFin: entity.fechaFin,
      motivo: entity.motivo,
      estado: entity.estado.toJson(),
      documentoAdjunto: entity.documentoAdjunto,
      documentoStoragePath: entity.documentoStoragePath,
      observaciones: entity.observaciones,
      aprobadoPor: entity.aprobadoPor,
      fechaAprobacion: entity.fechaAprobacion,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
