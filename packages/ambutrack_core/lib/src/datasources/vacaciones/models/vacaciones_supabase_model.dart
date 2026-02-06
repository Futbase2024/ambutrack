import 'package:ambutrack_core/src/datasources/vacaciones/entities/vacaciones_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vacaciones_supabase_model.g.dart';

/// Modelo DTO para Vacaciones con serialización JSON para Supabase
@JsonSerializable()
class VacacionesSupabaseModel {
  const VacacionesSupabaseModel({
    required this.id,
    required this.idPersonal,
    required this.fechaInicio,
    required this.fechaFin,
    required this.diasSolicitados,
    required this.estado,
    this.observaciones,
    this.documentoAdjunto,
    this.fechaSolicitud,
    this.aprobadoPor,
    this.fechaAprobacion,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  @JsonKey(name: 'id_personal')
  final String idPersonal;
  @JsonKey(name: 'fecha_inicio')
  final DateTime fechaInicio;
  @JsonKey(name: 'fecha_fin')
  final DateTime fechaFin;
  @JsonKey(name: 'dias_solicitados')
  final int diasSolicitados;
  final String estado;
  final String? observaciones;
  @JsonKey(name: 'documento_adjunto')
  final String? documentoAdjunto;
  @JsonKey(name: 'fecha_solicitud')
  final DateTime? fechaSolicitud;
  @JsonKey(name: 'aprobado_por')
  final String? aprobadoPor;
  @JsonKey(name: 'fecha_aprobacion')
  final DateTime? fechaAprobacion;
  final bool activo;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Crea instancia desde JSON (Supabase → Modelo)
  factory VacacionesSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$VacacionesSupabaseModelFromJson(json);

  /// Convierte a JSON (Modelo → Supabase)
  Map<String, dynamic> toJson() => _$VacacionesSupabaseModelToJson(this);

  /// Convierte a entidad de dominio (Modelo → Entity)
  VacacionesEntity toEntity() {
    return VacacionesEntity(
      id: id,
      idPersonal: idPersonal,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      diasSolicitados: diasSolicitados,
      estado: estado,
      observaciones: observaciones,
      documentoAdjunto: documentoAdjunto,
      fechaSolicitud: fechaSolicitud,
      aprobadoPor: aprobadoPor,
      fechaAprobacion: fechaAprobacion,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea modelo desde entidad de dominio (Entity → Modelo)
  factory VacacionesSupabaseModel.fromEntity(VacacionesEntity entity) {
    return VacacionesSupabaseModel(
      id: entity.id,
      idPersonal: entity.idPersonal,
      fechaInicio: entity.fechaInicio,
      fechaFin: entity.fechaFin,
      diasSolicitados: entity.diasSolicitados,
      estado: entity.estado,
      observaciones: entity.observaciones,
      documentoAdjunto: entity.documentoAdjunto,
      fechaSolicitud: entity.fechaSolicitud,
      aprobadoPor: entity.aprobadoPor,
      fechaAprobacion: entity.fechaAprobacion,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
