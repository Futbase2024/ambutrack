import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de asignaciones de cuadrante
abstract class CuadranteAsignacionesEvent extends Equatable {
  const CuadranteAsignacionesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todas las asignaciones
class CuadranteAsignacionesLoadAllRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesLoadAllRequested();
}

/// Evento para cargar asignaciones de una fecha específica
class CuadranteAsignacionesLoadByFechaRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesLoadByFechaRequested(this.fecha);

  final DateTime fecha;

  @override
  List<Object?> get props => <Object?>[fecha];
}

/// Evento para cargar asignaciones de un rango de fechas
class CuadranteAsignacionesLoadByRangoRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesLoadByRangoRequested({
    required this.fechaInicio,
    required this.fechaFin,
  });

  final DateTime fechaInicio;
  final DateTime fechaFin;

  @override
  List<Object?> get props => <Object?>[fechaInicio, fechaFin];
}

/// Evento para cargar asignaciones de un personal
class CuadranteAsignacionesLoadByPersonalRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesLoadByPersonalRequested({
    required this.idPersonal,
    this.fecha,
  });

  final String idPersonal;
  final DateTime? fecha;

  @override
  List<Object?> get props => <Object?>[idPersonal, fecha];
}

/// Evento para cargar asignaciones de un vehículo
class CuadranteAsignacionesLoadByVehiculoRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesLoadByVehiculoRequested({
    required this.idVehiculo,
    this.fecha,
  });

  final String idVehiculo;
  final DateTime? fecha;

  @override
  List<Object?> get props => <Object?>[idVehiculo, fecha];
}

/// Evento para cargar asignaciones de una dotación
class CuadranteAsignacionesLoadByDotacionRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesLoadByDotacionRequested({
    required this.idDotacion,
    this.fecha,
  });

  final String idDotacion;
  final DateTime? fecha;

  @override
  List<Object?> get props => <Object?>[idDotacion, fecha];
}

/// Evento para crear una nueva asignación
class CuadranteAsignacionesCreateRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesCreateRequested(this.asignacion);

  final CuadranteAsignacionEntity asignacion;

  @override
  List<Object?> get props => <Object?>[asignacion];
}

/// Evento para actualizar una asignación
class CuadranteAsignacionesUpdateRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesUpdateRequested(this.asignacion);

  final CuadranteAsignacionEntity asignacion;

  @override
  List<Object?> get props => <Object?>[asignacion];
}

/// Evento para eliminar una asignación
class CuadranteAsignacionesDeleteRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Evento para confirmar una asignación
class CuadranteAsignacionesConfirmarRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesConfirmarRequested({
    required this.id,
    required this.confirmadaPor,
  });

  final String id;
  final String confirmadaPor;

  @override
  List<Object?> get props => <Object?>[id, confirmadaPor];
}

/// Evento para cancelar una asignación
class CuadranteAsignacionesCancelarRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesCancelarRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Evento para completar una asignación
class CuadranteAsignacionesCompletarRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesCompletarRequested({
    required this.id,
    this.kmFinal,
    this.serviciosRealizados,
    this.observaciones,
  });

  final String id;
  final double? kmFinal;
  final int? serviciosRealizados;
  final String? observaciones;

  @override
  List<Object?> get props => <Object?>[id, kmFinal, serviciosRealizados, observaciones];
}

/// Evento para verificar conflictos de personal
class CuadranteAsignacionesCheckConflictPersonalRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesCheckConflictPersonalRequested({
    required this.idPersonal,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.cruzaMedianoche,
    this.excludeId,
  });

  final String idPersonal;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final bool cruzaMedianoche;
  final String? excludeId;

  @override
  List<Object?> get props => <Object?>[idPersonal, fecha, horaInicio, horaFin, cruzaMedianoche, excludeId];
}

/// Evento para verificar conflictos de vehículo
class CuadranteAsignacionesCheckConflictVehiculoRequested extends CuadranteAsignacionesEvent {
  const CuadranteAsignacionesCheckConflictVehiculoRequested({
    required this.idVehiculo,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.cruzaMedianoche,
    this.excludeId,
  });

  final String idVehiculo;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final bool cruzaMedianoche;
  final String? excludeId;

  @override
  List<Object?> get props => <Object?>[idVehiculo, fecha, horaInicio, horaFin, cruzaMedianoche, excludeId];
}
