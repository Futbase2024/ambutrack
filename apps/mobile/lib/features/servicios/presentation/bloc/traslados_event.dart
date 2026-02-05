import 'package:equatable/equatable.dart';

import 'package:ambutrack_core/ambutrack_core.dart';

/// Eventos del BLoC de traslados
abstract class TrasladosEvent extends Equatable {
  const TrasladosEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar traslados activos del conductor
class CargarTrasladosActivos extends TrasladosEvent {
  const CargarTrasladosActivos(this.idConductor);

  final String idConductor;

  @override
  List<Object?> get props => [idConductor];
}

/// Evento para cargar un traslado específico
class CargarTraslado extends TrasladosEvent {
  const CargarTraslado(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Evento para cambiar el estado de un traslado
class CambiarEstadoTraslado extends TrasladosEvent {
  const CambiarEstadoTraslado({
    required this.idTraslado,
    required this.nuevoEstado,
    required this.idUsuario,
    this.ubicacion,
    this.observaciones,
  });

  final String idTraslado;
  final EstadoTraslado nuevoEstado;
  final String idUsuario;
  final UbicacionEntity? ubicacion;
  final String? observaciones;

  @override
  List<Object?> get props => [
        idTraslado,
        nuevoEstado,
        idUsuario,
        ubicacion,
        observaciones,
      ];
}

/// Evento para iniciar el stream de traslados activos
class IniciarStreamTrasladosActivos extends TrasladosEvent {
  const IniciarStreamTrasladosActivos(this.idConductor);

  final String idConductor;

  @override
  List<Object?> get props => [idConductor];
}

/// Evento interno cuando se actualiza el stream de traslados
class TrasladosStreamActualizado extends TrasladosEvent {
  const TrasladosStreamActualizado(this.traslados);

  final List<TrasladoEntity> traslados;

  @override
  List<Object?> get props => [traslados];
}

/// Evento para cargar historial de estados de un traslado
class CargarHistorialEstados extends TrasladosEvent {
  const CargarHistorialEstados(this.idTraslado);

  final String idTraslado;

  @override
  List<Object?> get props => [idTraslado];
}

/// Evento para refrescar los traslados
class RefrescarTraslados extends TrasladosEvent {
  const RefrescarTraslados();
}

// --------------------------------------------------------------------------
// Event Ledger: Nuevos eventos para Realtime sin polling
// --------------------------------------------------------------------------

/// Inicia el stream de eventos de traslados para el conductor autenticado
/// Este evento REEMPLAZA a IniciarStreamTrasladosActivos para eliminar polling
class IniciarStreamEventos extends TrasladosEvent {
  const IniciarStreamEventos(this.idConductor);

  final String idConductor;

  @override
  List<Object?> get props => [idConductor];
}

/// Evento recibido cuando llega un evento desde Realtime
/// Se dispara automáticamente cuando:
/// - Me asignan un traslado (assigned/reassigned)
/// - Me quitan un traslado (unassigned/reassigned a otro)
/// - Cambia el estado de un traslado mío (status_changed)
class EventoTrasladoRecibido extends TrasladosEvent {
  const EventoTrasladoRecibido(this.evento, this.idConductor);

  final TrasladoEventoEntity evento;
  final String idConductor;

  @override
  List<Object?> get props => [evento, idConductor];
}
