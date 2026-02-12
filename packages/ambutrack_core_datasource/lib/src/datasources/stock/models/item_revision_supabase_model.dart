import 'package:json_annotation/json_annotation.dart';

import '../entities/item_revision_entity.dart';

part 'item_revision_supabase_model.g.dart';

/// Modelo Supabase para items de revisión
@JsonSerializable(explicitToJson: true)
class ItemRevisionSupabaseModel {
  final String id;
  @JsonKey(name: 'revision_id')
  final String revisionId;
  @JsonKey(name: 'producto_id')
  final String productoId;
  final bool verificado;
  @JsonKey(name: 'cantidad_encontrada')
  final int? cantidadEncontrada;
  @JsonKey(name: 'caducidad_ok')
  final bool caducidadOk;
  final String estado;
  final String? observacion;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const ItemRevisionSupabaseModel({
    required this.id,
    required this.revisionId,
    required this.productoId,
    this.verificado = false,
    this.cantidadEncontrada,
    this.caducidadOk = true,
    this.estado = 'pendiente',
    this.observacion,
    required this.createdAt,
  });

  factory ItemRevisionSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$ItemRevisionSupabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemRevisionSupabaseModelToJson(this);

  ItemRevisionEntity toEntity() {
    return ItemRevisionEntity(
      id: id,
      revisionId: revisionId,
      productoId: productoId,
      verificado: verificado,
      cantidadEncontrada: cantidadEncontrada,
      caducidadOk: caducidadOk,
      estado: EstadoItemRevisionExtension.fromJson(estado),
      observacion: observacion,
      createdAt: createdAt,
    );
  }

  factory ItemRevisionSupabaseModel.fromEntity(ItemRevisionEntity entity) {
    return ItemRevisionSupabaseModel(
      id: entity.id,
      revisionId: entity.revisionId,
      productoId: entity.productoId,
      verificado: entity.verificado,
      cantidadEncontrada: entity.cantidadEncontrada,
      caducidadOk: entity.caducidadOk,
      estado: entity.estado.toJson(),
      observacion: entity.observacion,
      createdAt: entity.createdAt,
    );
  }
}
