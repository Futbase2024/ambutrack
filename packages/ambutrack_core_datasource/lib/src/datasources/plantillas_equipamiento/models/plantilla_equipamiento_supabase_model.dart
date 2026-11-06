import 'package:json_annotation/json_annotation.dart';

import '../entities/plantilla_equipamiento_entity.dart';

part 'plantilla_equipamiento_supabase_model.g.dart';

/// Lee el contador embebido `plantilla_equipamiento_items(count)` de Supabase
Object? _readNumItems(Map<dynamic, dynamic> json, String key) {
  final Object? items = json['plantilla_equipamiento_items'];
  if (items is List && items.isNotEmpty) {
    final Object? first = items.first;
    if (first is Map) {
      return first['count'];
    }
  }
  return null;
}

/// DTO de `plantillas_equipamiento`
@JsonSerializable(explicitToJson: true)
class PlantillaEquipamientoSupabaseModel {
  const PlantillaEquipamientoSupabaseModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.tiposVehiculo = const <String>[],
    this.fechaVersion,
    this.activo = true,
    this.empresaId,
    this.createdAt,
    this.updatedAt,
    this.numItems,
  });

  /// Deserialización desde JSON (Supabase → Model)
  factory PlantillaEquipamientoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$PlantillaEquipamientoSupabaseModelFromJson(json);

  /// Crea el modelo desde la entidad
  factory PlantillaEquipamientoSupabaseModel.fromEntity(PlantillaEquipamientoEntity e) {
    return PlantillaEquipamientoSupabaseModel(
      id: e.id,
      nombre: e.nombre,
      descripcion: e.descripcion,
      tiposVehiculo: e.tiposVehiculo,
      fechaVersion: e.fechaVersion,
      activo: e.activo,
      empresaId: e.empresaId,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      numItems: e.numItems,
    );
  }

  final String id;
  final String nombre;
  final String? descripcion;

  @JsonKey(name: 'tipos_vehiculo')
  final List<String> tiposVehiculo;

  @JsonKey(name: 'fecha_version')
  final DateTime? fechaVersion;

  @JsonKey(defaultValue: true)
  final bool activo;

  @JsonKey(name: 'empresa_id')
  final String? empresaId;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'num_items', readValue: _readNumItems, includeToJson: false)
  final int? numItems;

  /// Serialización completa (Model → JSON)
  Map<String, dynamic> toJson() => _$PlantillaEquipamientoSupabaseModelToJson(this);

  /// JSON para INSERT/UPDATE: solo columnas editables de la tabla
  Map<String, dynamic> toWriteJson() {
    return <String, dynamic>{
      'nombre': nombre,
      'descripcion': descripcion,
      'tipos_vehiculo': tiposVehiculo,
      'fecha_version': fechaVersion == null ? null : _soloFecha(fechaVersion!),
      'activo': activo,
      'empresa_id': empresaId,
    };
  }

  /// Convierte a entidad de dominio
  PlantillaEquipamientoEntity toEntity() {
    return PlantillaEquipamientoEntity(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      tiposVehiculo: tiposVehiculo,
      fechaVersion: fechaVersion,
      activo: activo,
      empresaId: empresaId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      numItems: numItems,
    );
  }

  static String _soloFecha(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
