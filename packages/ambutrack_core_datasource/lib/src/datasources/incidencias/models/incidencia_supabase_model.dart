import 'package:json_annotation/json_annotation.dart';

import '../entities/incidencia_entity.dart';

part 'incidencia_supabase_model.g.dart';

@JsonSerializable()
class IncidenciaSupabaseModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'titulo')
  final String titulo;

  @JsonKey(name: 'descripcion')
  final String? descripcion;

  @JsonKey(name: 'categoria')
  final String categoria;

  @JsonKey(name: 'prioridad')
  final String prioridad;

  @JsonKey(name: 'estado')
  final String estado;

  @JsonKey(name: 'fecha_incidencia')
  final DateTime fechaIncidencia;

  @JsonKey(name: 'responsable_id')
  final String? responsableId;

  @JsonKey(name: 'responsable_nombre')
  final String? responsableNombre;

  @JsonKey(name: 'reportado_por')
  final String? reportadoPor;

  @JsonKey(name: 'reportado_por_nombre')
  final String? reportadoPorNombre;

  @JsonKey(name: 'fecha_resolucion')
  final DateTime? fechaResolucion;

  @JsonKey(name: 'resolucion')
  final String? resolucion;

  @JsonKey(name: 'vehiculo_id')
  final String? vehiculoId;

  @JsonKey(name: 'vehiculo_matricula')
  final String? vehiculoMatricula;

  @JsonKey(name: 'empresa_id')
  final String? empresaId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(name: 'created_by')
  final String? createdBy;

  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  const IncidenciaSupabaseModel({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.categoria,
    required this.prioridad,
    required this.estado,
    required this.fechaIncidencia,
    this.responsableId,
    this.responsableNombre,
    this.reportadoPor,
    this.reportadoPorNombre,
    this.fechaResolucion,
    this.resolucion,
    this.vehiculoId,
    this.vehiculoMatricula,
    this.empresaId,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory IncidenciaSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$IncidenciaSupabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$IncidenciaSupabaseModelToJson(this);

  IncidenciaEntity toEntity() {
    return IncidenciaEntity(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      categoria: CategoriaIncidencia.fromString(categoria),
      prioridad: PrioridadIncidencia.fromString(prioridad),
      estado: EstadoIncidencia.fromString(estado),
      fechaIncidencia: fechaIncidencia,
      responsableId: responsableId,
      responsableNombre: responsableNombre,
      reportadoPor: reportadoPor,
      reportadoPorNombre: reportadoPorNombre,
      fechaResolucion: fechaResolucion,
      resolucion: resolucion,
      vehiculoId: vehiculoId,
      vehiculoMatricula: vehiculoMatricula,
      empresaId: empresaId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  static IncidenciaSupabaseModel fromEntity(IncidenciaEntity entity) {
    return IncidenciaSupabaseModel(
      id: entity.id,
      titulo: entity.titulo,
      descripcion: entity.descripcion,
      categoria: entity.categoria.toDbValue(),
      prioridad: entity.prioridad.toDbValue(),
      estado: entity.estado.toDbValue(),
      fechaIncidencia: entity.fechaIncidencia,
      responsableId: entity.responsableId,
      responsableNombre: entity.responsableNombre,
      reportadoPor: entity.reportadoPor,
      reportadoPorNombre: entity.reportadoPorNombre,
      fechaResolucion: entity.fechaResolucion,
      resolucion: entity.resolucion,
      vehiculoId: entity.vehiculoId,
      vehiculoMatricula: entity.vehiculoMatricula,
      empresaId: entity.empresaId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }
}
