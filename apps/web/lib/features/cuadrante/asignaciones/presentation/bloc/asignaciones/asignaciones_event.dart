import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Asignaciones
abstract class AsignacionesEvent extends Equatable {
  const AsignacionesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar todas las asignaciones
class AsignacionesLoadAllRequested extends AsignacionesEvent {
  const AsignacionesLoadAllRequested();
}

/// Cargar asignaciones por fecha
class AsignacionesLoadByFechaRequested extends AsignacionesEvent {
  const AsignacionesLoadByFechaRequested(this.fecha);

  final DateTime fecha;

  @override
  List<Object?> get props => <Object?>[fecha];
}

/// Cargar asignaciones por rango de fechas
class AsignacionesLoadByRangoRequested extends AsignacionesEvent {
  const AsignacionesLoadByRangoRequested(this.inicio, this.fin);

  final DateTime inicio;
  final DateTime fin;

  @override
  List<Object?> get props => <Object?>[inicio, fin];
}

/// Cargar asignaciones por vehículo
class AsignacionesLoadByVehiculoRequested extends AsignacionesEvent {
  const AsignacionesLoadByVehiculoRequested({
    required this.vehiculoId,
    required this.fecha,
  });

  final String vehiculoId;
  final DateTime fecha;

  @override
  List<Object?> get props => <Object?>[vehiculoId, fecha];
}

/// Cargar asignaciones por estado
class AsignacionesLoadByEstadoRequested extends AsignacionesEvent {
  const AsignacionesLoadByEstadoRequested(this.estado);

  final String estado;

  @override
  List<Object?> get props => <Object?>[estado];
}

/// Crear una asignación
class AsignacionCreateRequested extends AsignacionesEvent {
  const AsignacionCreateRequested(this.asignacion);

  final AsignacionVehiculoTurnoEntity asignacion;

  @override
  List<Object?> get props => <Object?>[asignacion];
}

/// Actualizar una asignación
class AsignacionUpdateRequested extends AsignacionesEvent {
  const AsignacionUpdateRequested(this.asignacion);

  final AsignacionVehiculoTurnoEntity asignacion;

  @override
  List<Object?> get props => <Object?>[asignacion];
}

/// Eliminar una asignación
class AsignacionDeleteRequested extends AsignacionesEvent {
  const AsignacionDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
