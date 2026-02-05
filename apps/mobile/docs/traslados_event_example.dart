// ============================================================================
// ARCHIVO DE EJEMPLO: Eventos adicionales para TrasladosBloc
// ============================================================================
// Este archivo contiene los eventos que debes AGREGAR a tu archivo existente:
// lib/features/servicios/presentation/bloc/traslados_event.dart
//
// NO reemplaces el archivo completo, solo AGREGA estos dos eventos nuevos
// ============================================================================

/*
PASO 1: Agregar import en traslados_event.dart

import '../../../../core/datasources/traslados/traslados_datasource.dart';


PASO 2: Agregar estos dos eventos nuevos al archivo traslados_event.dart

/// Inicia el stream de eventos de traslados para el conductor autenticado
/// Este evento REEMPLAZA a IniciarStreamTrasladosActivos
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


PASO 3: Agregar los handlers en traslados_bloc.dart

En el constructor del BLoC:
  on<IniciarStreamEventos>(_onIniciarStreamEventos);
  on<EventoTrasladoRecibido>(_onEventoTrasladoRecibido);

Ver la documentación completa en EVENT_LEDGER_IMPLEMENTATION.md para el código
completo de los handlers.
*/
