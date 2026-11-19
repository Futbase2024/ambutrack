import 'package:json_annotation/json_annotation.dart';

import '../entities/centro_hospitalario_entity.dart';

part 'centro_hospitalario_supabase_model.g.dart';

/// Modelo de datos para Centro Hospitalario en Supabase
@JsonSerializable()
class CentroHospitalarioSupabaseModel {
  const CentroHospitalarioSupabaseModel({
    required this.id,
    required this.nombre,
    this.direccion,
    this.localidadId,
    this.localidadNombre,
    this.provinciaNombre,
    this.telefono,
    this.email,
    this.coordenadasGps,
    this.tipoCentro,
    this.especialidades,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CentroHospitalarioSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$CentroHospitalarioSupabaseModelFromJson(json);

  factory CentroHospitalarioSupabaseModel.fromEntity(
    CentroHospitalarioEntity entity,
  ) {
    return CentroHospitalarioSupabaseModel(
      id: entity.id,
      nombre: entity.nombre,
      direccion: entity.direccion,
      localidadId: entity.localidadId,
      localidadNombre: entity.localidadNombre,
      provinciaNombre: entity.provinciaNombre,
      telefono: entity.telefono,
      email: entity.email,
      coordenadasGps: entity.coordenadasGps,
      tipoCentro: entity.tipoCentro,
      especialidades: entity.especialidades,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String nombre;
  final String? direccion;

  @JsonKey(name: 'localidad_id')
  final String? localidadId;

  @JsonKey(name: 'localidad_nombre')
  final String? localidadNombre;

  @JsonKey(name: 'provincia_nombre')
  final String? provinciaNombre;

  final String? telefono;
  final String? email;

  @JsonKey(name: 'coordenadas_gps')
  final String? coordenadasGps;

  @JsonKey(name: 'tipo_centro')
  final String? tipoCentro;

  final List<String>? especialidades;
  final bool activo;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() =>
      _$CentroHospitalarioSupabaseModelToJson(this);

  CentroHospitalarioEntity toEntity() {
    return CentroHospitalarioEntity(
      id: id,
      nombre: nombre,
      direccion: direccion,
      localidadId: localidadId,
      localidadNombre: localidadNombre,
      provinciaNombre: provinciaNombre,
      telefono: telefono,
      email: email,
      coordenadasGps: coordenadasGps,
      tipoCentro: tipoCentro,
      especialidades: especialidades,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
