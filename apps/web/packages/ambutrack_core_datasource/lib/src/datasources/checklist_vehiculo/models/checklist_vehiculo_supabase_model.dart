import 'package:json_annotation/json_annotation.dart';

import '../entities/checklist_vehiculo_entity.dart';
import '../entities/item_checklist_entity.dart';

part 'checklist_vehiculo_supabase_model.g.dart';

/// Modelo de datos para Checklist de Vehículo en Supabase
@JsonSerializable(explicitToJson: true)
class ChecklistVehiculoSupabaseModel {
  const ChecklistVehiculoSupabaseModel({
    required this.id,
    required this.vehiculoId,
    required this.realizadoPor,
    required this.realizadoPorNombre,
    required this.fechaRealizacion,
    required this.tipo,
    required this.kilometraje,
    required this.itemsPresentes,
    required this.itemsAusentes,
    required this.checklistCompleto,
    this.observacionesGenerales,
    this.firmaUrl,
    required this.empresaId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  @JsonKey(name: 'vehiculo_id')
  final String vehiculoId;
  @JsonKey(name: 'realizado_por')
  final String realizadoPor;
  @JsonKey(name: 'realizado_por_nombre')
  final String realizadoPorNombre;
  @JsonKey(name: 'fecha_realizacion')
  final DateTime fechaRealizacion;
  final String tipo;
  final double kilometraje;
  @JsonKey(name: 'items_presentes')
  final int itemsPresentes;
  @JsonKey(name: 'items_ausentes')
  final int itemsAusentes;
  @JsonKey(name: 'checklist_completo')
  final bool checklistCompleto;
  @JsonKey(name: 'observaciones_generales')
  final String? observacionesGenerales;
  @JsonKey(name: 'firma_url')
  final String? firmaUrl;
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// Deserialización desde JSON
  factory ChecklistVehiculoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$ChecklistVehiculoSupabaseModelFromJson(json);

  /// Serialización a JSON
  Map<String, dynamic> toJson() => _$ChecklistVehiculoSupabaseModelToJson(this);

  /// Conversión a Entity (sin items, deben cargarse por separado)
  ChecklistVehiculoEntity toEntity({List<ItemChecklistEntity>? items}) {
    return ChecklistVehiculoEntity(
      id: id,
      vehiculoId: vehiculoId,
      realizadoPor: realizadoPor,
      realizadoPorNombre: realizadoPorNombre,
      fechaRealizacion: fechaRealizacion,
      tipo: TipoChecklistExtension.fromJson(tipo),
      kilometraje: kilometraje,
      items: items ?? [],
      itemsPresentes: itemsPresentes,
      itemsAusentes: itemsAusentes,
      checklistCompleto: checklistCompleto,
      observacionesGenerales: observacionesGenerales,
      firmaUrl: firmaUrl,
      empresaId: empresaId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Conversión desde Entity
  factory ChecklistVehiculoSupabaseModel.fromEntity(
      ChecklistVehiculoEntity entity) {
    return ChecklistVehiculoSupabaseModel(
      id: entity.id,
      vehiculoId: entity.vehiculoId,
      realizadoPor: entity.realizadoPor,
      realizadoPorNombre: entity.realizadoPorNombre,
      fechaRealizacion: entity.fechaRealizacion,
      tipo: entity.tipo.toJson(),
      kilometraje: entity.kilometraje,
      itemsPresentes: entity.itemsPresentes,
      itemsAusentes: entity.itemsAusentes,
      checklistCompleto: entity.checklistCompleto,
      observacionesGenerales: entity.observacionesGenerales,
      firmaUrl: entity.firmaUrl,
      empresaId: entity.empresaId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt ?? DateTime.now(),
    );
  }
}
