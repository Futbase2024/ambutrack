import 'package:json_annotation/json_annotation.dart';

import '../entities/revision_entity.dart';
import 'ambulancia_supabase_model.dart';
import 'item_revision_supabase_model.dart';

part 'revision_supabase_model.g.dart';

/// Modelo de datos para Revisión en Supabase
@JsonSerializable(explicitToJson: true)
class RevisionSupabaseModel {
  const RevisionSupabaseModel({
    required this.id,
    required this.ambulanciaId,
    required this.tipoRevision,
    required this.periodo,
    this.diaRevision,
    required this.fechaProgramada,
    this.fechaRealizada,
    this.tecnicoId,
    required this.tecnicoNombre,
    required this.estado,
    this.observaciones,
    this.incidencias,
    required this.createdAt,
    required this.updatedAt,
    this.ambulancia,
    this.items,
  });

  final String id;
  @JsonKey(name: 'ambulancia_id')
  final String ambulanciaId;
  @JsonKey(name: 'tipo_revision')
  final String tipoRevision;
  final String periodo;
  @JsonKey(name: 'dia_revision')
  final int? diaRevision;
  @JsonKey(name: 'fecha_programada')
  final DateTime fechaProgramada;
  @JsonKey(name: 'fecha_realizada')
  final DateTime? fechaRealizada;
  @JsonKey(name: 'tecnico_id')
  final String? tecnicoId;
  @JsonKey(name: 'tecnico_nombre')
  final String tecnicoNombre;
  final String estado;
  final String? observaciones;
  final List<String>? incidencias;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  // Relaciones
  @JsonKey(name: 'amb_ambulancias')
  final AmbulanciaSupabaseModel? ambulancia;
  @JsonKey(name: 'amb_items_revision')
  final List<ItemRevisionSupabaseModel>? items;

  /// Deserialización desde JSON
  factory RevisionSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$RevisionSupabaseModelFromJson(json);

  /// Serialización a JSON
  Map<String, dynamic> toJson() => _$RevisionSupabaseModelToJson(this);

  /// Conversión a Entity
  RevisionEntity toEntity() {
    return RevisionEntity(
      id: id,
      ambulanciaId: ambulanciaId,
      tipoRevision: tipoRevision,
      periodo: periodo,
      diaRevision: diaRevision,
      fechaProgramada: fechaProgramada,
      fechaRealizada: fechaRealizada,
      tecnicoId: tecnicoId,
      tecnicoNombre: tecnicoNombre,
      estado: EstadoRevision.fromString(estado),
      observaciones: observaciones,
      incidencias: incidencias,
      createdAt: createdAt,
      updatedAt: updatedAt,
      ambulancia: ambulancia?.toEntity(),
      items: items?.map((item) => item.toEntity()).toList(),
    );
  }

  /// Conversión desde Entity
  factory RevisionSupabaseModel.fromEntity(RevisionEntity entity) {
    return RevisionSupabaseModel(
      id: entity.id,
      ambulanciaId: entity.ambulanciaId,
      tipoRevision: entity.tipoRevision,
      periodo: entity.periodo,
      diaRevision: entity.diaRevision,
      fechaProgramada: entity.fechaProgramada,
      fechaRealizada: entity.fechaRealizada,
      tecnicoId: entity.tecnicoId,
      tecnicoNombre: entity.tecnicoNombre,
      estado: entity.estado.toSupabaseString(),
      observaciones: entity.observaciones,
      incidencias: entity.incidencias,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      ambulancia: entity.ambulancia != null
          ? AmbulanciaSupabaseModel.fromEntity(entity.ambulancia!)
          : null,
      items: entity.items
          ?.map((item) => ItemRevisionSupabaseModel.fromEntity(item))
          .toList(),
    );
  }
}
