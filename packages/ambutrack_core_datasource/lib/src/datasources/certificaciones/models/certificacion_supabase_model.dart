import 'package:json_annotation/json_annotation.dart';

import '../entities/certificacion_entity.dart';

part 'certificacion_supabase_model.g.dart';

/// Modelo de Supabase para certificaciones
@JsonSerializable()
class CertificacionSupabaseModel {
  const CertificacionSupabaseModel({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.vigenciaMeses,
    required this.horasRequeridas,
    required this.activa,
    this.fechaBaja,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  @JsonKey(name: 'codigo')
  final String codigo;

  @JsonKey(name: 'nombre')
  final String nombre;

  @JsonKey(name: 'descripcion')
  final String? descripcion;

  @JsonKey(name: 'vigencia_meses')
  final int vigenciaMeses;

  @JsonKey(name: 'horas_requeridas')
  final int horasRequeridas;

  @JsonKey(name: 'activa')
  final bool activa;

  @JsonKey(name: 'fecha_baja')
  final DateTime? fechaBaja;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Conversión desde JSON
  factory CertificacionSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$CertificacionSupabaseModelFromJson(json);

  /// Conversión a JSON
  Map<String, dynamic> toJson() => _$CertificacionSupabaseModelToJson(this);

  /// Conversión a entidad de dominio
  CertificacionEntity toEntity() {
    return CertificacionEntity(
      id: id,
      codigo: codigo,
      nombre: nombre,
      descripcion: descripcion,
      vigenciaMeses: vigenciaMeses,
      horasRequeridas: horasRequeridas,
      activa: activa,
      fechaBaja: fechaBaja,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Conversión desde entidad de dominio
  factory CertificacionSupabaseModel.fromEntity(CertificacionEntity entity) {
    return CertificacionSupabaseModel(
      id: entity.id,
      codigo: entity.codigo,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      vigenciaMeses: entity.vigenciaMeses,
      horasRequeridas: entity.horasRequeridas,
      activa: entity.activa,
      fechaBaja: entity.fechaBaja,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
