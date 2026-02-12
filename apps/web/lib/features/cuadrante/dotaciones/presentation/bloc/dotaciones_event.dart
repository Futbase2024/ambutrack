import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Dotaciones
abstract class DotacionesEvent extends Equatable {
  const DotacionesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todas las dotaciones
class DotacionesLoadRequested extends DotacionesEvent {
  const DotacionesLoadRequested();
}

/// Evento para cargar solo dotaciones activas
class DotacionesActivasLoadRequested extends DotacionesEvent {
  const DotacionesActivasLoadRequested();
}

/// Evento para crear una nueva dotación
class DotacionCreateRequested extends DotacionesEvent {
  const DotacionCreateRequested(this.dotacion);

  final DotacionEntity dotacion;

  @override
  List<Object?> get props => <Object?>[dotacion];
}

/// Evento para actualizar una dotación existente
class DotacionUpdateRequested extends DotacionesEvent {
  const DotacionUpdateRequested(this.dotacion);

  final DotacionEntity dotacion;

  @override
  List<Object?> get props => <Object?>[dotacion];
}

/// Evento para eliminar una dotación
class DotacionDeleteRequested extends DotacionesEvent {
  const DotacionDeleteRequested(this.dotacionId);

  final String dotacionId;

  @override
  List<Object?> get props => <Object?>[dotacionId];
}

/// Evento para desactivar una dotación (soft delete)
class DotacionDeactivateRequested extends DotacionesEvent {
  const DotacionDeactivateRequested(this.dotacionId);

  final String dotacionId;

  @override
  List<Object?> get props => <Object?>[dotacionId];
}

/// Evento para reactivar una dotación
class DotacionReactivateRequested extends DotacionesEvent {
  const DotacionReactivateRequested(this.dotacionId);

  final String dotacionId;

  @override
  List<Object?> get props => <Object?>[dotacionId];
}

/// Evento para filtrar dotaciones por hospital
class DotacionesFiltrarPorHospitalRequested extends DotacionesEvent {
  const DotacionesFiltrarPorHospitalRequested(this.hospitalId);

  final String hospitalId;

  @override
  List<Object?> get props => <Object?>[hospitalId];
}

/// Evento para filtrar dotaciones por base
class DotacionesFiltrarPorBaseRequested extends DotacionesEvent {
  const DotacionesFiltrarPorBaseRequested(this.baseId);

  final String baseId;

  @override
  List<Object?> get props => <Object?>[baseId];
}

/// Evento para filtrar dotaciones por contrato
class DotacionesFiltrarPorContratoRequested extends DotacionesEvent {
  const DotacionesFiltrarPorContratoRequested(this.contratoId);

  final String contratoId;

  @override
  List<Object?> get props => <Object?>[contratoId];
}

/// Evento para filtrar dotaciones por tipo de vehículo
class DotacionesFiltrarPorTipoVehiculoRequested extends DotacionesEvent {
  const DotacionesFiltrarPorTipoVehiculoRequested(this.tipoVehiculoId);

  final String tipoVehiculoId;

  @override
  List<Object?> get props => <Object?>[tipoVehiculoId];
}

/// Evento para obtener dotaciones vigentes en una fecha
class DotacionesVigentesEnFechaRequested extends DotacionesEvent {
  const DotacionesVigentesEnFechaRequested(this.fecha);

  final DateTime fecha;

  @override
  List<Object?> get props => <Object?>[fecha];
}

/// Evento para actualizar cantidad de unidades de una dotación
class DotacionUpdateCantidadUnidadesRequested extends DotacionesEvent {
  const DotacionUpdateCantidadUnidadesRequested(this.dotacionId, this.nuevaCantidad);

  final String dotacionId;
  final int nuevaCantidad;

  @override
  List<Object?> get props => <Object?>[dotacionId, nuevaCantidad];
}

/// Evento para actualizar prioridad de una dotación
class DotacionUpdatePrioridadRequested extends DotacionesEvent {
  const DotacionUpdatePrioridadRequested(this.dotacionId, this.nuevaPrioridad);

  final String dotacionId;
  final int nuevaPrioridad;

  @override
  List<Object?> get props => <Object?>[dotacionId, nuevaPrioridad];
}
