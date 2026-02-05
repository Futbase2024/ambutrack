import 'package:json_annotation/json_annotation.dart';

import '../entities/contrato_entity.dart';

part 'contrato_model.g.dart';

/// Modelo de datos para serialización de contratos
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ContratoModel {

  const ContratoModel({
    required this.id,
    required this.codigo,
    required this.hospitalId,
    required this.fechaInicio,
    this.fechaFin,
    this.descripcion,
    this.tipoContrato,
    this.importeMensual,
    this.condicionesEspeciales,
    required this.activo,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Crea un modelo desde una entidad de dominio
  factory ContratoModel.fromEntity(ContratoEntity entity) {
    return ContratoModel(
      id: entity.id,
      codigo: entity.codigo,
      hospitalId: entity.hospitalId,
      fechaInicio: entity.fechaInicio,
      fechaFin: entity.fechaFin,
      descripcion: entity.descripcion,
      tipoContrato: entity.tipoContrato,
      importeMensual: entity.importeMensual,
      condicionesEspeciales: entity.condicionesEspeciales,
      activo: entity.activo,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }

  factory ContratoModel.fromJson(Map<String, dynamic> json) =>
      _$ContratoModelFromJson(json);
  final String id;
  final String codigo;
  @JsonKey(name: 'hospital_id')
  final String hospitalId;
  @JsonKey(name: 'fecha_inicio')
  final DateTime fechaInicio;
  @JsonKey(name: 'fecha_fin')
  final DateTime? fechaFin;
  final String? descripcion;
  @JsonKey(name: 'tipo_contrato')
  final String? tipoContrato;
  @JsonKey(name: 'importe_mensual')
  final double? importeMensual;
  @JsonKey(name: 'condiciones_especiales')
  final Map<String, dynamic>? condicionesEspeciales;
  final bool activo;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  /// Convierte el modelo a entidad de dominio
  ContratoEntity toEntity() {
    return ContratoEntity(
      id: id,
      codigo: codigo,
      hospitalId: hospitalId,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      descripcion: descripcion,
      tipoContrato: tipoContrato,
      importeMensual: importeMensual,
      condicionesEspeciales: condicionesEspeciales,
      activo: activo,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  Map<String, dynamic> toJson() => _$ContratoModelToJson(this);
}
