import 'package:json_annotation/json_annotation.dart';

import '../entities/solicitud_intercambio_entity.dart';

part 'solicitud_intercambio_supabase_model.g.dart';

/// Modelo DTO para SolicitudIntercambio en Supabase
/// (mapeo tabla `solicitudes_intercambio_turnos`)
@JsonSerializable()
class SolicitudIntercambioSupabaseModel {
  const SolicitudIntercambioSupabaseModel({
    required this.id,
    required this.idTurnoSolicitante,
    required this.idPersonalSolicitante,
    required this.nombrePersonalSolicitante,
    required this.idTurnoDestino,
    required this.idPersonalDestino,
    required this.nombrePersonalDestino,
    required this.estado,
    this.motivoSolicitud,
    this.motivoRechazo,
    required this.fechaSolicitud,
    this.fechaRespuestaTrabajador,
    this.fechaRespuestaResponsable,
    this.idResponsable,
    this.nombreResponsable,
    this.createdAt,
    this.updatedAt,
  });

  /// ID único de la solicitud
  final String id;

  /// ID del turno del solicitante (FK → turnos.id)
  @JsonKey(name: 'idTurnoSolicitante')
  final String idTurnoSolicitante;

  /// ID del personal solicitante (FK → personal.id)
  @JsonKey(name: 'idPersonalSolicitante')
  final String idPersonalSolicitante;

  /// Nombre del personal solicitante (desnormalizado)
  @JsonKey(name: 'nombrePersonalSolicitante')
  final String nombrePersonalSolicitante;

  /// ID del turno destino (FK → turnos.id)
  @JsonKey(name: 'idTurnoDestino')
  final String idTurnoDestino;

  /// ID del personal destino (FK → personal.id)
  @JsonKey(name: 'idPersonalDestino')
  final String idPersonalDestino;

  /// Nombre del personal destino (desnormalizado)
  @JsonKey(name: 'nombrePersonalDestino')
  final String nombrePersonalDestino;

  /// Estado de la solicitud como string (enum.name)
  final String estado;

  /// Motivo de la solicitud
  @JsonKey(name: 'motivoSolicitud')
  final String? motivoSolicitud;

  /// Motivo del rechazo (si aplica)
  @JsonKey(name: 'motivoRechazo')
  final String? motivoRechazo;

  /// Fecha de creación de la solicitud
  @JsonKey(name: 'fechaSolicitud')
  final DateTime fechaSolicitud;

  /// Fecha de respuesta del trabajador destino
  @JsonKey(name: 'fechaRespuestaTrabajador')
  final DateTime? fechaRespuestaTrabajador;

  /// Fecha de respuesta del responsable
  @JsonKey(name: 'fechaRespuestaResponsable')
  final DateTime? fechaRespuestaResponsable;

  /// ID del responsable (FK → personal.id)
  @JsonKey(name: 'idResponsable')
  final String? idResponsable;

  /// Nombre del responsable (desnormalizado)
  @JsonKey(name: 'nombreResponsable')
  final String? nombreResponsable;

  /// Fecha de creación en BD
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Fecha de última actualización en BD
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Deserialización desde JSON (Supabase)
  factory SolicitudIntercambioSupabaseModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SolicitudIntercambioSupabaseModelFromJson(json);

  /// Serialización a JSON (Supabase)
  Map<String, dynamic> toJson() =>
      _$SolicitudIntercambioSupabaseModelToJson(this);

  /// Crea un modelo desde una entidad de dominio
  factory SolicitudIntercambioSupabaseModel.fromEntity(
    SolicitudIntercambioEntity entity,
  ) {
    return SolicitudIntercambioSupabaseModel(
      id: entity.id,
      idTurnoSolicitante: entity.idTurnoSolicitante,
      idPersonalSolicitante: entity.idPersonalSolicitante,
      nombrePersonalSolicitante: entity.nombrePersonalSolicitante,
      idTurnoDestino: entity.idTurnoDestino,
      idPersonalDestino: entity.idPersonalDestino,
      nombrePersonalDestino: entity.nombrePersonalDestino,
      estado: entity.estado.name,
      motivoSolicitud: entity.motivoSolicitud,
      motivoRechazo: entity.motivoRechazo,
      fechaSolicitud: entity.fechaSolicitud,
      fechaRespuestaTrabajador: entity.fechaRespuestaTrabajador,
      fechaRespuestaResponsable: entity.fechaRespuestaResponsable,
      idResponsable: entity.idResponsable,
      nombreResponsable: entity.nombreResponsable,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convierte el modelo a entidad de dominio
  SolicitudIntercambioEntity toEntity() {
    return SolicitudIntercambioEntity(
      id: id,
      idTurnoSolicitante: idTurnoSolicitante,
      idPersonalSolicitante: idPersonalSolicitante,
      nombrePersonalSolicitante: nombrePersonalSolicitante,
      idTurnoDestino: idTurnoDestino,
      idPersonalDestino: idPersonalDestino,
      nombrePersonalDestino: nombrePersonalDestino,
      estado: _parseEstadoSolicitud(estado),
      motivoSolicitud: motivoSolicitud,
      motivoRechazo: motivoRechazo,
      fechaSolicitud: fechaSolicitud,
      fechaRespuestaTrabajador: fechaRespuestaTrabajador,
      fechaRespuestaResponsable: fechaRespuestaResponsable,
      idResponsable: idResponsable,
      nombreResponsable: nombreResponsable,
      createdAt: createdAt,
      updatedAt: updatedAt,
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

  /// Parsea string a enum EstadoSolicitud
  static EstadoSolicitud _parseEstadoSolicitud(String value) {
    return EstadoSolicitud.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoSolicitud.cancelada,
    );
  }
}
