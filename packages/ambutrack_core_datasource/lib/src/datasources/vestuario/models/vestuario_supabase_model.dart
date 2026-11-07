import 'package:json_annotation/json_annotation.dart';

import '../entities/vestuario_entity.dart';

part 'vestuario_supabase_model.g.dart';

/// Modelo de Supabase para Vestuario
@JsonSerializable()
class VestuarioSupabaseModel {
  const VestuarioSupabaseModel({
    required this.id,
    required this.personalId,
    required this.prenda,
    required this.talla,
    required this.fechaEntrega,
    this.fechaDevolucion,
    this.cantidad,
    this.marca,
    this.color,
    this.estado,
    this.observaciones,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  @JsonKey(name: 'personal_id')
  final String personalId;

  final String prenda;
  final String talla;

  @JsonKey(name: 'fecha_entrega')
  final DateTime fechaEntrega;

  @JsonKey(name: 'fecha_devolucion')
  final DateTime? fechaDevolucion;

  final int? cantidad;
  final String? marca;
  final String? color;
  final String? estado;
  final String? observaciones;
  final bool activo;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  factory VestuarioSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$VestuarioSupabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VestuarioSupabaseModelToJson(this);

  /// Convierte el modelo a entidad de dominio
  VestuarioEntity toEntity() {
    return VestuarioEntity(
      id: id,
      personalId: personalId,
      prenda: prenda,
      talla: talla,
      fechaEntrega: fechaEntrega,
      fechaDevolucion: fechaDevolucion,
      cantidad: cantidad,
      marca: marca,
      color: color,
      estado: estado,
      observaciones: observaciones,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory VestuarioSupabaseModel.fromEntity(VestuarioEntity entity) {
    return VestuarioSupabaseModel(
      id: entity.id,
      personalId: entity.personalId,
      prenda: entity.prenda,
      talla: entity.talla,
      fechaEntrega: entity.fechaEntrega,
      fechaDevolucion: entity.fechaDevolucion,
      cantidad: entity.cantidad,
      marca: entity.marca,
      color: entity.color,
      estado: entity.estado,
      observaciones: entity.observaciones,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
