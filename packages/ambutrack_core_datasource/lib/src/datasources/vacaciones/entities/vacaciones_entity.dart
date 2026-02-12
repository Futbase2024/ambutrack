import 'package:equatable/equatable.dart';

/// Entidad de dominio para Vacaciones
class VacacionesEntity extends Equatable {
  const VacacionesEntity({
    required this.id,
    required this.idPersonal,
    required this.fechaInicio,
    required this.fechaFin,
    required this.diasSolicitados,
    required this.estado,
    this.observaciones,
    this.documentoAdjunto,
    this.fechaSolicitud,
    this.aprobadoPor,
    this.fechaAprobacion,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String idPersonal;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int diasSolicitados;
  final String estado; // 'pendiente', 'aprobada', 'rechazada', 'cancelada'
  final String? observaciones;
  final String? documentoAdjunto;
  final DateTime? fechaSolicitud;
  final String? aprobadoPor;
  final DateTime? fechaAprobacion;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        idPersonal,
        fechaInicio,
        fechaFin,
        diasSolicitados,
        estado,
        observaciones,
        documentoAdjunto,
        fechaSolicitud,
        aprobadoPor,
        fechaAprobacion,
        activo,
        createdAt,
        updatedAt,
      ];

  VacacionesEntity copyWith({
    String? id,
    String? idPersonal,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? diasSolicitados,
    String? estado,
    String? observaciones,
    String? documentoAdjunto,
    DateTime? fechaSolicitud,
    String? aprobadoPor,
    DateTime? fechaAprobacion,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VacacionesEntity(
      id: id ?? this.id,
      idPersonal: idPersonal ?? this.idPersonal,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      diasSolicitados: diasSolicitados ?? this.diasSolicitados,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      documentoAdjunto: documentoAdjunto ?? this.documentoAdjunto,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      aprobadoPor: aprobadoPor ?? this.aprobadoPor,
      fechaAprobacion: fechaAprobacion ?? this.fechaAprobacion,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
