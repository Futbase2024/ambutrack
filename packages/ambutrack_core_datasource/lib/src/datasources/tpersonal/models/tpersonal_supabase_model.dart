import 'package:json_annotation/json_annotation.dart';
import '../entities/tpersonal_entity.dart';

part 'tpersonal_supabase_model.g.dart';

/// Modelo Supabase para la tabla tpersonal
///
/// Maneja la serialización/deserialización de datos desde/hacia Supabase
@JsonSerializable(explicitToJson: true)
class TPersonalSupabaseModel {
  const TPersonalSupabaseModel({
    required this.id,
    required this.nombre,
    required this.apellidos,
    this.dni,
    this.nass,
    this.direccion,
    this.codigoPostal,
    this.telefono,
    this.movil,
    this.fechaInicio,
    this.fechaNacimiento,
    this.email,
    this.fechaAlta,
    this.createdAt,
    this.poblacionId,
    this.provinciaId,
    this.puestoTrabajoId,
    this.contratoId,
    this.empresaId,
    this.categoriaId,
    this.usuarioId,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.activo = true,
    this.categoriaServicio,
    this.categoria,
  });

  final String id;
  final String nombre;
  final String apellidos;
  final String? dni;
  final String? nass;
  final String? direccion;
  @JsonKey(name: 'codigo_postal')
  final String? codigoPostal;
  final String? telefono;
  final String? movil;
  @JsonKey(name: 'fecha_inicio')
  final DateTime? fechaInicio;
  @JsonKey(name: 'fecha_nacimiento')
  final DateTime? fechaNacimiento;
  final String? email;
  @JsonKey(name: 'fecha_alta')
  final DateTime? fechaAlta;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'poblacion_id')
  final String? poblacionId;
  @JsonKey(name: 'provincia_id')
  final String? provinciaId;
  @JsonKey(name: 'puesto_trabajo_id')
  final String? puestoTrabajoId;
  @JsonKey(name: 'contrato_id')
  final String? contratoId;
  @JsonKey(name: 'empresa_id')
  final String? empresaId;
  @JsonKey(name: 'categoria_id')
  final String? categoriaId;
  @JsonKey(name: 'usuario_id')
  final String? usuarioId;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'updated_by')
  final String? updatedBy;
  final bool activo;
  @JsonKey(name: 'categoria_servicio')
  final String? categoriaServicio;
  final String? categoria;

  /// Crea una instancia desde JSON
  factory TPersonalSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$TPersonalSupabaseModelFromJson(json);

  /// Convierte a JSON
  Map<String, dynamic> toJson() => _$TPersonalSupabaseModelToJson(this);

  /// Convierte el modelo a entidad
  TPersonalEntity toEntity() {
    return TPersonalEntity(
      id: id,
      nombre: nombre,
      apellidos: apellidos,
      dni: dni,
      nass: nass,
      direccion: direccion,
      codigoPostal: codigoPostal,
      telefono: telefono,
      movil: movil,
      fechaInicio: fechaInicio,
      fechaNacimiento: fechaNacimiento,
      email: email,
      fechaAlta: fechaAlta,
      createdAt: createdAt,
      poblacionId: poblacionId,
      provinciaId: provinciaId,
      puestoTrabajoId: puestoTrabajoId,
      contratoId: contratoId,
      empresaId: empresaId,
      categoriaId: categoriaId,
      usuarioId: usuarioId,
      createdBy: createdBy,
      updatedAt: updatedAt,
      updatedBy: updatedBy,
      activo: activo,
      categoriaServicio: categoriaServicio,
      categoria: categoria,
    );
  }

  /// Crea un modelo desde una entidad
  factory TPersonalSupabaseModel.fromEntity(TPersonalEntity entity) {
    return TPersonalSupabaseModel(
      id: entity.id,
      nombre: entity.nombre,
      apellidos: entity.apellidos,
      dni: entity.dni,
      nass: entity.nass,
      direccion: entity.direccion,
      codigoPostal: entity.codigoPostal,
      telefono: entity.telefono,
      movil: entity.movil,
      fechaInicio: entity.fechaInicio,
      fechaNacimiento: entity.fechaNacimiento,
      email: entity.email,
      fechaAlta: entity.fechaAlta,
      createdAt: entity.createdAt,
      poblacionId: entity.poblacionId,
      provinciaId: entity.provinciaId,
      puestoTrabajoId: entity.puestoTrabajoId,
      contratoId: entity.contratoId,
      empresaId: entity.empresaId,
      categoriaId: entity.categoriaId,
      usuarioId: entity.usuarioId,
      createdBy: entity.createdBy,
      updatedAt: entity.updatedAt,
      updatedBy: entity.updatedBy,
      activo: entity.activo,
      categoriaServicio: entity.categoriaServicio,
      categoria: entity.categoria,
    );
  }
}
