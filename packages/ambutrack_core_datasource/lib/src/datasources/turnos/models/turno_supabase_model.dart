import 'package:json_annotation/json_annotation.dart';

import '../entities/turno_entity.dart';

part 'turno_supabase_model.g.dart';

/// Modelo DTO para Turno en Supabase (mapeo tabla `turnos`)
@JsonSerializable()
class TurnoSupabaseModel {
  const TurnoSupabaseModel({
    required this.id,
    required this.idPersonal,
    required this.nombrePersonal,
    required this.tipoTurno,
    required this.fechaInicio,
    required this.fechaFin,
    required this.horaInicio,
    required this.horaFin,
    this.idContrato,
    this.idBase,
    this.categoriaPersonal,
    this.idVehiculo,
    this.idDotacion,
    this.observaciones,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  /// ID único del turno
  final String id;

  /// ID del personal (FK → personal.id)
  @JsonKey(name: 'idPersonal')
  final String idPersonal;

  /// Nombre del personal (desnormalizado)
  @JsonKey(name: 'nombrePersonal')
  final String nombrePersonal;

  /// Tipo de turno como string (enum.name)
  @JsonKey(name: 'tipoTurno')
  final String tipoTurno;

  /// Fecha de inicio del turno
  @JsonKey(name: 'fechaInicio')
  final DateTime fechaInicio;

  /// Fecha de fin del turno
  @JsonKey(name: 'fechaFin')
  final DateTime fechaFin;

  /// Hora de inicio en formato HH:mm
  @JsonKey(name: 'horaInicio')
  final String horaInicio;

  /// Hora de fin en formato HH:mm
  @JsonKey(name: 'horaFin')
  final String horaFin;

  /// ID del contrato asociado al turno (FK → contratos)
  @JsonKey(name: 'idContrato')
  final String? idContrato;

  /// ID de la base operativa (opcional)
  @JsonKey(name: 'idBase')
  final String? idBase;

  /// Categoría/Función del personal (TES, Camillero, Conductor, Médico, etc.)
  @JsonKey(name: 'categoriaPersonal')
  final String? categoriaPersonal;

  /// ID del vehículo asignado (opcional, solo para técnicos/conductores/TES)
  @JsonKey(name: 'idVehiculo')
  final String? idVehiculo;

  /// ID de la dotación asociada al turno (FK → dotaciones)
  @JsonKey(name: 'idDotacion')
  final String? idDotacion;

  /// Observaciones opcionales
  final String? observaciones;

  /// Estado activo (soft delete)
  final bool activo;

  /// Fecha de creación en BD
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Fecha de última actualización en BD
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Deserialización desde JSON (Supabase)
  factory TurnoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$TurnoSupabaseModelFromJson(json);

  /// Serialización a JSON (Supabase)
  Map<String, dynamic> toJson() => _$TurnoSupabaseModelToJson(this);

  /// Crea un modelo desde una entidad de dominio
  factory TurnoSupabaseModel.fromEntity(TurnoEntity entity) {
    return TurnoSupabaseModel(
      id: entity.id,
      idPersonal: entity.idPersonal,
      nombrePersonal: entity.nombrePersonal,
      tipoTurno: entity.tipoTurno.name,
      fechaInicio: entity.fechaInicio,
      fechaFin: entity.fechaFin,
      horaInicio: entity.horaInicio,
      horaFin: entity.horaFin,
      idContrato: entity.idContrato,
      idBase: entity.idBase,
      categoriaPersonal: entity.categoriaPersonal,
      idVehiculo: entity.idVehiculo,
      idDotacion: entity.idDotacion,
      observaciones: entity.observaciones,
      activo: entity.activo,
    );
  }

  /// Convierte el modelo a entidad de dominio
  TurnoEntity toEntity() {
    return TurnoEntity(
      id: id,
      idPersonal: idPersonal,
      nombrePersonal: nombrePersonal,
      tipoTurno: _parseTipoTurno(tipoTurno),
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      horaInicio: horaInicio,
      horaFin: horaFin,
      idContrato: idContrato,
      idBase: idBase,
      categoriaPersonal: categoriaPersonal,
      idVehiculo: idVehiculo,
      idDotacion: idDotacion,
      observaciones: observaciones,
      activo: activo,
    );
  }

  /// Convierte a JSON para operación INSERT (sin id, created_at, updated_at)
  Map<String, dynamic> toJsonForInsert() {
    final json = toJson();
    json
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');
    return json;
  }

  /// Parsea string a enum TipoTurno
  static TipoTurno _parseTipoTurno(String value) {
    return TipoTurno.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TipoTurno.personalizado,
    );
  }
}
