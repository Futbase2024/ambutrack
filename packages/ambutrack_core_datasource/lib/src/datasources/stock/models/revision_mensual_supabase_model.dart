import 'package:json_annotation/json_annotation.dart';

import '../entities/revision_mensual_entity.dart';

part 'revision_mensual_supabase_model.g.dart';

/// Modelo Supabase para revisiones mensuales
@JsonSerializable(explicitToJson: true)
class RevisionMensualSupabaseModel {
  final String id;
  @JsonKey(name: 'vehiculo_id')
  final String vehiculoId;
  final DateTime fecha;
  final int mes;
  final int anio;
  @JsonKey(name: 'dia_revision')
  final int diaRevision;
  @JsonKey(name: 'tecnico_id')
  final String? tecnicoId;
  @JsonKey(name: 'tecnico_nombre')
  final String? tecnicoNombre;
  final bool completada;
  @JsonKey(name: 'firma_base64')
  final String? firmaBase64;
  @JsonKey(name: 'observaciones_generales')
  final String? observacionesGenerales;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;

  const RevisionMensualSupabaseModel({
    required this.id,
    required this.vehiculoId,
    required this.fecha,
    required this.mes,
    required this.anio,
    required this.diaRevision,
    this.tecnicoId,
    this.tecnicoNombre,
    this.completada = false,
    this.firmaBase64,
    this.observacionesGenerales,
    required this.createdAt,
    this.completedAt,
  });

  factory RevisionMensualSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$RevisionMensualSupabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$RevisionMensualSupabaseModelToJson(this);

  RevisionMensualEntity toEntity() {
    return RevisionMensualEntity(
      id: id,
      vehiculoId: vehiculoId,
      fecha: fecha,
      mes: mes,
      anio: anio,
      diaRevision: diaRevision,
      tecnicoId: tecnicoId,
      tecnicoNombre: tecnicoNombre,
      completada: completada,
      firmaBase64: firmaBase64,
      observacionesGenerales: observacionesGenerales,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }

  factory RevisionMensualSupabaseModel.fromEntity(
    RevisionMensualEntity entity,
  ) {
    return RevisionMensualSupabaseModel(
      id: entity.id,
      vehiculoId: entity.vehiculoId,
      fecha: entity.fecha,
      mes: entity.mes,
      anio: entity.anio,
      diaRevision: entity.diaRevision,
      tecnicoId: entity.tecnicoId,
      tecnicoNombre: entity.tecnicoNombre,
      completada: entity.completada,
      firmaBase64: entity.firmaBase64,
      observacionesGenerales: entity.observacionesGenerales,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
    );
  }
}
