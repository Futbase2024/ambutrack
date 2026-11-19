import 'package:json_annotation/json_annotation.dart';

import '../entities/item_checklist_entity.dart';

part 'item_checklist_supabase_model.g.dart';

/// Modelo de datos para Item de Checklist en Supabase
@JsonSerializable(explicitToJson: true)
class ItemChecklistSupabaseModel {
  const ItemChecklistSupabaseModel({
    required this.id,
    required this.checklistId,
    required this.categoria,
    required this.itemNombre,
    this.cantidadRequerida,
    required this.resultado,
    this.observaciones,
    required this.orden,
    required this.createdAt,
  });

  final String id;
  @JsonKey(name: 'checklist_id')
  final String checklistId;
  final String categoria;
  @JsonKey(name: 'item_nombre')
  final String itemNombre;
  @JsonKey(name: 'cantidad_requerida')
  final int? cantidadRequerida;
  final String resultado;
  final String? observaciones;
  final int orden;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Deserialización desde JSON
  factory ItemChecklistSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$ItemChecklistSupabaseModelFromJson(json);

  /// Serialización a JSON
  Map<String, dynamic> toJson() => _$ItemChecklistSupabaseModelToJson(this);

  /// Conversión a Entity
  ItemChecklistEntity toEntity() {
    return ItemChecklistEntity(
      id: id,
      checklistId: checklistId,
      categoria: CategoriaChecklistExtension.fromJson(categoria),
      itemNombre: itemNombre,
      cantidadRequerida: cantidadRequerida,
      resultado: ResultadoItemExtension.fromJson(resultado),
      observaciones: observaciones,
      orden: orden,
      createdAt: createdAt,
    );
  }

  /// Conversión desde Entity
  factory ItemChecklistSupabaseModel.fromEntity(ItemChecklistEntity entity) {
    return ItemChecklistSupabaseModel(
      id: entity.id,
      checklistId: entity.checklistId,
      categoria: entity.categoria.toJson(),
      itemNombre: entity.itemNombre,
      cantidadRequerida: entity.cantidadRequerida,
      resultado: entity.resultado.toJson(),
      observaciones: entity.observaciones,
      orden: entity.orden,
      createdAt: entity.createdAt,
    );
  }
}
