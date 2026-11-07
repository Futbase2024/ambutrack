import 'package:json_annotation/json_annotation.dart';

import '../entities/almacen_entity.dart';

part 'almacen_supabase_model.g.dart';

/// Modelo de Supabase para Almacén
///
/// DTO que mapea directamente desde/hacia la tabla `almacenes` en PostgreSQL.
@JsonSerializable()
class AlmacenSupabaseModel {
  const AlmacenSupabaseModel({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.tipo,
    this.idVehiculo,
    this.direccion,
    this.capacidadMax,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String codigo;
  final String nombre;
  final String tipo; // 'BASE_CENTRAL' | 'VEHICULO'

  @JsonKey(name: 'id_vehiculo')
  final String? idVehiculo;

  final String? direccion;

  @JsonKey(name: 'capacidad_max')
  final double? capacidadMax;

  final bool activo;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Convierte desde JSON de Supabase
  factory AlmacenSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$AlmacenSupabaseModelFromJson(json);

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() => _$AlmacenSupabaseModelToJson(this);

  /// Convierte el modelo a entidad de dominio
  AlmacenEntity toEntity() {
    return AlmacenEntity(
      id: id,
      codigo: codigo,
      nombre: nombre,
      tipo: TipoAlmacen.fromCode(tipo),
      idVehiculo: idVehiculo,
      direccion: direccion,
      capacidadMax: capacidadMax,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea el modelo desde una entidad de dominio
  factory AlmacenSupabaseModel.fromEntity(AlmacenEntity entity) {
    return AlmacenSupabaseModel(
      id: entity.id,
      codigo: entity.codigo,
      nombre: entity.nombre,
      tipo: entity.tipo.code,
      idVehiculo: entity.idVehiculo,
      direccion: entity.direccion,
      capacidadMax: entity.capacidadMax,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
