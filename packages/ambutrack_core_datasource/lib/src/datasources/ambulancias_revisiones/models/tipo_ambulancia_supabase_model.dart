import 'package:json_annotation/json_annotation.dart';

import '../entities/tipo_ambulancia_entity.dart';

part 'tipo_ambulancia_supabase_model.g.dart';

/// Modelo de datos para Tipo de Ambulancia en Supabase
@JsonSerializable(explicitToJson: true)
class TipoAmbulanciaSupabaseModel {
  const TipoAmbulanciaSupabaseModel({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.nivelEquipamiento,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String codigo;
  final String nombre;
  final String? descripcion;
  @JsonKey(name: 'nivel_equipamiento')
  final String nivelEquipamiento;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// Deserialización desde JSON
  factory TipoAmbulanciaSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$TipoAmbulanciaSupabaseModelFromJson(json);

  /// Serialización a JSON
  Map<String, dynamic> toJson() => _$TipoAmbulanciaSupabaseModelToJson(this);

  /// Conversión a Entity
  TipoAmbulanciaEntity toEntity() {
    return TipoAmbulanciaEntity(
      id: id,
      codigo: codigo,
      nombre: nombre,
      descripcion: descripcion,
      nivelEquipamiento: nivelEquipamiento,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Conversión desde Entity
  factory TipoAmbulanciaSupabaseModel.fromEntity(TipoAmbulanciaEntity entity) {
    return TipoAmbulanciaSupabaseModel(
      id: entity.id,
      codigo: entity.codigo,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      nivelEquipamiento: entity.nivelEquipamiento,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
