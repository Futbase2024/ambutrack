import 'package:equatable/equatable.dart';

/// Estados posibles de una ausencia
enum EstadoAusencia {
  pendiente,
  aprobada,
  rechazada,
  cancelada,
}

/// Extensión para convertir string a EstadoAusencia
extension EstadoAusenciaExtension on EstadoAusencia {
  String toJson() {
    switch (this) {
      case EstadoAusencia.pendiente:
        return 'Pendiente';
      case EstadoAusencia.aprobada:
        return 'Aprobada';
      case EstadoAusencia.rechazada:
        return 'Rechazada';
      case EstadoAusencia.cancelada:
        return 'Cancelada';
    }
  }

  static EstadoAusencia fromString(String estado) {
    switch (estado) {
      case 'Pendiente':
        return EstadoAusencia.pendiente;
      case 'Aprobada':
        return EstadoAusencia.aprobada;
      case 'Rechazada':
        return EstadoAusencia.rechazada;
      case 'Cancelada':
        return EstadoAusencia.cancelada;
      default:
        return EstadoAusencia.pendiente;
    }
  }
}

/// Entidad de dominio para Ausencia
class AusenciaEntity extends Equatable {
  const AusenciaEntity({
    required this.id,
    required this.idPersonal,
    required this.idTipoAusencia,
    required this.fechaInicio,
    required this.fechaFin,
    this.motivo,
    required this.estado,
    this.documentoAdjunto,
    this.documentoStoragePath,
    this.observaciones,
    this.aprobadoPor,
    this.fechaAprobacion,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String idPersonal;
  final String idTipoAusencia;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? motivo;
  final EstadoAusencia estado;
  final String? documentoAdjunto;
  final String? documentoStoragePath;
  final String? observaciones;
  final String? aprobadoPor;
  final DateTime? fechaAprobacion;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Calcula los días de ausencia (incluyendo inicio y fin)
  int get diasAusencia {
    return fechaFin.difference(fechaInicio).inDays + 1;
  }

  /// Verifica si la ausencia está pendiente de aprobación
  bool get isPendiente => estado == EstadoAusencia.pendiente;

  /// Verifica si la ausencia está aprobada
  bool get isAprobada => estado == EstadoAusencia.aprobada;

  /// Verifica si la ausencia está en el futuro
  bool get isFutura => fechaInicio.isAfter(DateTime.now());

  /// Verifica si la ausencia está actualmente en curso
  bool get isEnCurso {
    final now = DateTime.now();
    return now.isAfter(fechaInicio) && now.isBefore(fechaFin);
  }

  @override
  List<Object?> get props => [
        id,
        idPersonal,
        idTipoAusencia,
        fechaInicio,
        fechaFin,
        motivo,
        estado,
        documentoAdjunto,
        documentoStoragePath,
        observaciones,
        aprobadoPor,
        fechaAprobacion,
        activo,
        createdAt,
        updatedAt,
      ];

  AusenciaEntity copyWith({
    String? id,
    String? idPersonal,
    String? idTipoAusencia,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? motivo,
    EstadoAusencia? estado,
    String? documentoAdjunto,
    String? documentoStoragePath,
    String? observaciones,
    String? aprobadoPor,
    DateTime? fechaAprobacion,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AusenciaEntity(
      id: id ?? this.id,
      idPersonal: idPersonal ?? this.idPersonal,
      idTipoAusencia: idTipoAusencia ?? this.idTipoAusencia,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      motivo: motivo ?? this.motivo,
      estado: estado ?? this.estado,
      documentoAdjunto: documentoAdjunto ?? this.documentoAdjunto,
      documentoStoragePath: documentoStoragePath ?? this.documentoStoragePath,
      observaciones: observaciones ?? this.observaciones,
      aprobadoPor: aprobadoPor ?? this.aprobadoPor,
      fechaAprobacion: fechaAprobacion ?? this.fechaAprobacion,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
