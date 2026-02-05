import 'package:equatable/equatable.dart';

/// Estados posibles de una solicitud de intercambio
enum EstadoSolicitud {
  /// Esperando aprobación del trabajador destino
  pendienteAprobacionTrabajador,

  /// Esperando aprobación del responsable
  pendienteAprobacionResponsable,

  /// Solicitud aprobada y turnos intercambiados
  aprobada,

  /// Rechazada por el trabajador destino
  rechazadaPorTrabajador,

  /// Rechazada por el responsable
  rechazadaPorResponsable,

  /// Cancelada por el solicitante
  cancelada,
}

/// Extensión para obtener texto legible del estado
extension EstadoSolicitudExtension on EstadoSolicitud {
  /// Texto descriptivo del estado
  String get displayText {
    switch (this) {
      case EstadoSolicitud.pendienteAprobacionTrabajador:
        return 'Pendiente de Aprobación del Trabajador';
      case EstadoSolicitud.pendienteAprobacionResponsable:
        return 'Pendiente de Aprobación del Responsable';
      case EstadoSolicitud.aprobada:
        return 'Aprobada';
      case EstadoSolicitud.rechazadaPorTrabajador:
        return 'Rechazada por Trabajador';
      case EstadoSolicitud.rechazadaPorResponsable:
        return 'Rechazada por Responsable';
      case EstadoSolicitud.cancelada:
        return 'Cancelada';
    }
  }

  /// Verifica si la solicitud está pendiente de aprobación
  bool get isPendiente =>
      this == EstadoSolicitud.pendienteAprobacionTrabajador ||
      this == EstadoSolicitud.pendienteAprobacionResponsable;

  /// Verifica si la solicitud fue rechazada
  bool get isRechazada =>
      this == EstadoSolicitud.rechazadaPorTrabajador ||
      this == EstadoSolicitud.rechazadaPorResponsable;

  /// Verifica si la solicitud está completada (aprobada, rechazada o cancelada)
  bool get isCompletada =>
      this == EstadoSolicitud.aprobada ||
      this == EstadoSolicitud.rechazadaPorTrabajador ||
      this == EstadoSolicitud.rechazadaPorResponsable ||
      this == EstadoSolicitud.cancelada;
}

/// Entidad que representa una solicitud de intercambio de turnos
class SolicitudIntercambioEntity extends Equatable {
  const SolicitudIntercambioEntity({
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

  /// ID del turno del solicitante (el que quiere intercambiar)
  final String idTurnoSolicitante;

  /// ID del personal solicitante (FK → personal)
  final String idPersonalSolicitante;

  /// Nombre del personal solicitante (desnormalizado)
  final String nombrePersonalSolicitante;

  /// ID del turno destino (con quien quiere intercambiar)
  final String idTurnoDestino;

  /// ID del personal destino (FK → personal)
  final String idPersonalDestino;

  /// Nombre del personal destino (desnormalizado)
  final String nombrePersonalDestino;

  /// Estado actual de la solicitud
  final EstadoSolicitud estado;

  /// Motivo por el cual se solicita el intercambio
  final String? motivoSolicitud;

  /// Motivo del rechazo (si aplica)
  final String? motivoRechazo;

  /// Fecha en que se creó la solicitud
  final DateTime fechaSolicitud;

  /// Fecha de respuesta del trabajador destino
  final DateTime? fechaRespuestaTrabajador;

  /// Fecha de respuesta del responsable
  final DateTime? fechaRespuestaResponsable;

  /// ID del responsable que aprobó/rechazó (FK → personal)
  final String? idResponsable;

  /// Nombre del responsable (desnormalizado)
  final String? nombreResponsable;

  /// Fecha de creación del registro en BD
  final DateTime? createdAt;

  /// Fecha de última actualización en BD
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[
        id,
        idTurnoSolicitante,
        idPersonalSolicitante,
        nombrePersonalSolicitante,
        idTurnoDestino,
        idPersonalDestino,
        nombrePersonalDestino,
        estado,
        motivoSolicitud,
        motivoRechazo,
        fechaSolicitud,
        fechaRespuestaTrabajador,
        fechaRespuestaResponsable,
        idResponsable,
        nombreResponsable,
        createdAt,
        updatedAt,
      ];

  /// Copia de la entidad con campos modificados
  SolicitudIntercambioEntity copyWith({
    String? id,
    String? idTurnoSolicitante,
    String? idPersonalSolicitante,
    String? nombrePersonalSolicitante,
    String? idTurnoDestino,
    String? idPersonalDestino,
    String? nombrePersonalDestino,
    EstadoSolicitud? estado,
    String? motivoSolicitud,
    String? motivoRechazo,
    DateTime? fechaSolicitud,
    DateTime? fechaRespuestaTrabajador,
    DateTime? fechaRespuestaResponsable,
    String? idResponsable,
    String? nombreResponsable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SolicitudIntercambioEntity(
      id: id ?? this.id,
      idTurnoSolicitante: idTurnoSolicitante ?? this.idTurnoSolicitante,
      idPersonalSolicitante:
          idPersonalSolicitante ?? this.idPersonalSolicitante,
      nombrePersonalSolicitante:
          nombrePersonalSolicitante ?? this.nombrePersonalSolicitante,
      idTurnoDestino: idTurnoDestino ?? this.idTurnoDestino,
      idPersonalDestino: idPersonalDestino ?? this.idPersonalDestino,
      nombrePersonalDestino:
          nombrePersonalDestino ?? this.nombrePersonalDestino,
      estado: estado ?? this.estado,
      motivoSolicitud: motivoSolicitud ?? this.motivoSolicitud,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      fechaRespuestaTrabajador:
          fechaRespuestaTrabajador ?? this.fechaRespuestaTrabajador,
      fechaRespuestaResponsable:
          fechaRespuestaResponsable ?? this.fechaRespuestaResponsable,
      idResponsable: idResponsable ?? this.idResponsable,
      nombreResponsable: nombreResponsable ?? this.nombreResponsable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idTurnoSolicitante': idTurnoSolicitante,
      'idPersonalSolicitante': idPersonalSolicitante,
      'nombrePersonalSolicitante': nombrePersonalSolicitante,
      'idTurnoDestino': idTurnoDestino,
      'idPersonalDestino': idPersonalDestino,
      'nombrePersonalDestino': nombrePersonalDestino,
      'estado': estado.name,
      'motivoSolicitud': motivoSolicitud,
      'motivoRechazo': motivoRechazo,
      'fechaSolicitud': fechaSolicitud.toIso8601String(),
      'fechaRespuestaTrabajador': fechaRespuestaTrabajador?.toIso8601String(),
      'fechaRespuestaResponsable':
          fechaRespuestaResponsable?.toIso8601String(),
      'idResponsable': idResponsable,
      'nombreResponsable': nombreResponsable,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una entidad desde JSON
  factory SolicitudIntercambioEntity.fromJson(Map<String, dynamic> json) {
    return SolicitudIntercambioEntity(
      id: json['id'] as String,
      idTurnoSolicitante: json['idTurnoSolicitante'] as String,
      idPersonalSolicitante: json['idPersonalSolicitante'] as String,
      nombrePersonalSolicitante: json['nombrePersonalSolicitante'] as String,
      idTurnoDestino: json['idTurnoDestino'] as String,
      idPersonalDestino: json['idPersonalDestino'] as String,
      nombrePersonalDestino: json['nombrePersonalDestino'] as String,
      estado: _parseEstadoSolicitud(json['estado'] as String),
      motivoSolicitud: json['motivoSolicitud'] as String?,
      motivoRechazo: json['motivoRechazo'] as String?,
      fechaSolicitud: DateTime.parse(json['fechaSolicitud'] as String),
      fechaRespuestaTrabajador: json['fechaRespuestaTrabajador'] != null
          ? DateTime.parse(json['fechaRespuestaTrabajador'] as String)
          : null,
      fechaRespuestaResponsable: json['fechaRespuestaResponsable'] != null
          ? DateTime.parse(json['fechaRespuestaResponsable'] as String)
          : null,
      idResponsable: json['idResponsable'] as String?,
      nombreResponsable: json['nombreResponsable'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Parsea string a enum EstadoSolicitud
  static EstadoSolicitud _parseEstadoSolicitud(String value) {
    return EstadoSolicitud.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoSolicitud.cancelada,
    );
  }

  @override
  bool get stringify => true;
}
