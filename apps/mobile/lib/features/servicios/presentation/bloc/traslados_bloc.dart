import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ambutrack_core/ambutrack_core.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/realtime/connection_manager.dart';
import '../../domain/repositories/traslados_repository.dart';
import 'traslados_event.dart';
import 'traslados_state.dart';

/// BLoC para gestionar el estado de los traslados
class TrasladosBloc extends Bloc<TrasladosEvent, TrasladosState> {
  TrasladosBloc(this._repository) : super(const TrasladosInitial()) {
    on<CargarTrasladosActivos>(_onCargarTrasladosActivos);
    on<CargarTraslado>(_onCargarTraslado);
    on<CambiarEstadoTraslado>(_onCambiarEstadoTraslado);
    on<IniciarStreamTrasladosActivos>(_onIniciarStreamTrasladosActivos);
    on<TrasladosStreamActualizado>(_onTrasladosStreamActualizado);
    on<CargarHistorialEstados>(_onCargarHistorialEstados);
    on<RefrescarTraslados>(_onRefrescarTraslados);
    // Event Ledger: Nuevos handlers para Realtime sin polling
    on<IniciarStreamEventos>(_onIniciarStreamEventos);
    on<EventoTrasladoRecibido>(_onEventoTrasladoRecibido);
  }

  static const String _tag = 'TrasladosBloc';

  final TrasladosRepository _repository;
  final _connectionManager = RealtimeConnectionManager();

  StreamSubscription? _trasladosStreamSubscription;
  StreamSubscription? _eventosStreamSubscription;

  /// Acceso al ConnectionManager para la UI
  RealtimeConnectionManager get connectionManager => _connectionManager;

  /// Stream de estados de conexión Realtime para la UI
  Stream<RealtimeConnectionState> get connectionState =>
      _connectionManager.connectionState;

  /// Carga los traslados activos del conductor
  Future<void> _onCargarTrasladosActivos(
    CargarTrasladosActivos event,
    Emitter<TrasladosState> emit,
  ) async {
    try {
      AppLogger.startOperation(
        'Cargando traslados activos del conductor: ${event.idConductor}',
        tag: _tag,
      );
      emit(const TrasladosLoading());

      final traslados = await _repository.getActivosByIdConductor(event.idConductor);

      AppLogger.endOperation(
        'Traslados cargados: ${traslados.length}',
        tag: _tag,
      );
      emit(TrasladosLoaded(traslados: traslados));
    } catch (e, stackTrace) {
      AppLogger.failOperation(
        'Cargar traslados',
        e,
        stackTrace,
        tag: _tag,
      );
      emit(TrasladosError('Error al cargar traslados: $e'));
    }
  }

  /// Carga un traslado específico
  Future<void> _onCargarTraslado(
    CargarTraslado event,
    Emitter<TrasladosState> emit,
  ) async {
    try {
      debugPrint('🎯 [TrasladosBloc] Cargando traslado: ${event.id}');

      final traslado = await _repository.getById(event.id);

      if (state is TrasladosLoaded) {
        final currentState = state as TrasladosLoaded;
        emit(currentState.copyWith(trasladoSeleccionado: traslado));
      } else {
        emit(TrasladosLoaded(
          traslados: [traslado],
          trasladoSeleccionado: traslado,
        ));
      }

      debugPrint('✅ [TrasladosBloc] Traslado cargado');
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosBloc] Error al cargar traslado: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(TrasladosError('Error al cargar traslado: $e'));
    }
  }

  /// Cambia el estado de un traslado
  Future<void> _onCambiarEstadoTraslado(
    CambiarEstadoTraslado event,
    Emitter<TrasladosState> emit,
  ) async {
    try {
      debugPrint('🎯 [TrasladosBloc] Cambiando estado del traslado ${event.idTraslado} a ${event.nuevoEstado.value}');

      // Obtener traslado actual para guardar el estado anterior
      final trasladoActual = await _repository.getById(event.idTraslado);
      final estadoAnterior = trasladoActual.estado;

      // Emitir estado de carga
      emit(CambiandoEstadoTraslado(
        idTraslado: event.idTraslado,
        estadoActual: estadoAnterior,
        estadoNuevo: event.nuevoEstado,
      ));

      // Cambiar estado en el repositorio
      final trasladoActualizado = await _repository.cambiarEstado(
        idTraslado: event.idTraslado,
        nuevoEstado: event.nuevoEstado,
        idUsuario: event.idUsuario,
        ubicacion: event.ubicacion,
        observaciones: event.observaciones,
      );

      debugPrint('✅ [TrasladosBloc] Estado cambiado exitosamente');

      // Emitir estado de éxito
      emit(EstadoCambiadoSuccess(
        traslado: trasladoActualizado,
        estadoAnterior: estadoAnterior,
      ));

      // Recargar traslados si estaban cargados
      if (state is TrasladosLoaded) {
        final currentState = state as TrasladosLoaded;
        final trasladosActualizados = currentState.traslados.map((t) {
          return t.id == trasladoActualizado.id ? trasladoActualizado : t;
        }).toList();

        emit(currentState.copyWith(
          traslados: trasladosActualizados,
          trasladoSeleccionado: trasladoActualizado,
        ));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosBloc] Error al cambiar estado: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(TrasladosError('Error al cambiar estado: $e'));
    }
  }

  /// Inicia el stream de traslados activos en tiempo real
  Future<void> _onIniciarStreamTrasladosActivos(
    IniciarStreamTrasladosActivos event,
    Emitter<TrasladosState> emit,
  ) async {
    try {
      debugPrint('📡 [TrasladosBloc] Iniciando stream de traslados activos');

      // Cancelar subscription anterior si existe
      await _trasladosStreamSubscription?.cancel();

      // Iniciar nuevo stream
      _trasladosStreamSubscription = _repository
          .watchActivosByIdConductor(event.idConductor)
          .listen(
            (traslados) {
              debugPrint('📡 [TrasladosBloc] Stream actualizado: ${traslados.length} traslados');
              add(TrasladosStreamActualizado(traslados));
            },
            onError: (error) {
              debugPrint('❌ [TrasladosBloc] Error en stream: $error');
              add(const RefrescarTraslados());
            },
          );

      debugPrint('✅ [TrasladosBloc] Stream iniciado');
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosBloc] Error al iniciar stream: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(TrasladosError('Error al iniciar actualizaciones en tiempo real: $e'));
    }
  }

  /// Maneja las actualizaciones del stream
  Future<void> _onTrasladosStreamActualizado(
    TrasladosStreamActualizado event,
    Emitter<TrasladosState> emit,
  ) async {
    try {
      debugPrint('🔄 [TrasladosBloc] Actualizando desde stream');

      if (state is TrasladosLoaded) {
        final currentState = state as TrasladosLoaded;

        // Mantener el traslado seleccionado actualizado si existe
        final trasladoSeleccionado = currentState.trasladoSeleccionado != null
            ? event.traslados.firstWhere(
                (t) => t.id == currentState.trasladoSeleccionado!.id,
                orElse: () => currentState.trasladoSeleccionado!,
              )
            : null;

        emit(currentState.copyWith(
          traslados: event.traslados,
          trasladoSeleccionado: trasladoSeleccionado,
        ));
      } else {
        emit(TrasladosLoaded(traslados: event.traslados));
      }

      debugPrint('✅ [TrasladosBloc] Estado actualizado desde stream');
    } catch (e) {
      debugPrint('❌ [TrasladosBloc] Error al procesar actualización: $e');
    }
  }

  /// Carga el historial de estados de un traslado
  Future<void> _onCargarHistorialEstados(
    CargarHistorialEstados event,
    Emitter<TrasladosState> emit,
  ) async {
    try {
      debugPrint('🎯 [TrasladosBloc] Cargando historial de estados del traslado: ${event.idTraslado}');

      if (state is! TrasladosLoaded) {
        debugPrint('⚠️  [TrasladosBloc] No se puede cargar historial sin traslados cargados');
        return;
      }

      final historial = await _repository.getHistorialEstados(event.idTraslado);

      final currentState = state as TrasladosLoaded;
      emit(currentState.copyWith(historialEstados: historial));

      debugPrint('✅ [TrasladosBloc] Historial cargado: ${historial.length} cambios');
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosBloc] Error al cargar historial: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(TrasladosError('Error al cargar historial: $e'));
    }
  }

  /// Refresca los traslados manualmente
  Future<void> _onRefrescarTraslados(
    RefrescarTraslados event,
    Emitter<TrasladosState> emit,
  ) async {
    debugPrint('🔄 [TrasladosBloc] Refrescando traslados...');
    // El stream se encargará de actualizar automáticamente
    // Este evento es principalmente para manejar errores del stream
  }

  // --------------------------------------------------------------------------
  // Event Ledger: Handlers para Realtime sin polling
  // --------------------------------------------------------------------------

  /// Inicia el stream de eventos Realtime (REEMPLAZA watchActivosByIdConductor)
  Future<void> _onIniciarStreamEventos(
    IniciarStreamEventos event,
    Emitter<TrasladosState> emit,
  ) async {
    try {
      AppLogger.startOperation('Stream de eventos Realtime', tag: _tag);

      // Cancelar subscriptions anteriores
      await _trasladosStreamSubscription?.cancel();
      await _eventosStreamSubscription?.cancel();

      // Cargar traslados iniciales
      emit(const TrasladosLoading());
      final traslados = await _repository.getActivosByIdConductor(event.idConductor);
      emit(TrasladosLoaded(traslados: traslados));

      AppLogger.info(
        '${traslados.length} traslados cargados inicialmente',
        tag: _tag,
      );

      // Suscribirse a eventos Realtime
      _eventosStreamSubscription = _repository
          .streamEventosConductor()
          .listen(
            (evento) {
              AppLogger.debug(
                'Evento Realtime: ${evento.eventType.label} - Traslado: ${evento.trasladoId}',
                tag: _tag,
              );
              add(EventoTrasladoRecibido(evento, event.idConductor));
            },
            onError: (error) {
              AppLogger.error(
                'Error en stream de eventos',
                error,
                null,
                tag: _tag,
              );
              _connectionManager.onSubscribeStatus(
                RealtimeSubscribeStatus.channelError,
                error,
              );
              emit(TrasladosError('Error en Realtime: $error'));
            },
            onDone: () {
              AppLogger.warning('Stream de eventos cerrado', tag: _tag);
            },
          );

      AppLogger.endOperation('Stream de eventos Realtime', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.failOperation(
        'Iniciar stream de eventos',
        e,
        stackTrace,
        tag: _tag,
      );
      emit(TrasladosError('Error al iniciar eventos Realtime: $e'));
    }
  }

  /// Procesa eventos recibidos desde Realtime y actualiza la lista local
  Future<void> _onEventoTrasladoRecibido(
    EventoTrasladoRecibido event,
    Emitter<TrasladosState> emit,
  ) async {
    if (state is! TrasladosLoaded) {
      debugPrint('⚠️ [TrasladosBloc] Evento recibido pero estado no es Loaded');
      return;
    }

    final currentState = state as TrasladosLoaded;
    final traslados = List<TrasladoEntity>.from(currentState.traslados);
    final evento = event.evento;
    final miId = event.idConductor;

    try {
      switch (evento.eventType) {
        // ====================================================================
        // CASO 1: Me asignaron o me reasignaron
        // ====================================================================
        case EventoTrasladoType.assigned:
        case EventoTrasladoType.reassigned:
          // ME ASIGNARON A MÍ
          if (evento.newConductorId == miId) {
            debugPrint('✅ [TrasladosBloc] Traslado ${evento.trasladoId} asignado a mí');

            // Fetch traslado completo desde la BD
            final traslado = await _repository.getById(evento.trasladoId);

            // Reemplazar si existe, añadir si no
            final index = traslados.indexWhere((t) => t.id == traslado.id);
            if (index != -1) {
              traslados[index] = traslado;
              debugPrint('📝 [TrasladosBloc] Traslado actualizado en lista');
            } else {
              traslados.add(traslado);
              debugPrint('➕ [TrasladosBloc] Traslado añadido a lista');
            }

            emit(currentState.copyWith(traslados: traslados));
          }

          // ME QUITARON (en caso de reassigned de mí a otro)
          if (evento.oldConductorId == miId && evento.newConductorId != miId) {
            debugPrint('🗑️ [TrasladosBloc] Traslado ${evento.trasladoId} reasignado a otro conductor');
            traslados.removeWhere((t) => t.id == evento.trasladoId);
            debugPrint('➖ [TrasladosBloc] Traslado eliminado de lista');
            emit(currentState.copyWith(traslados: traslados));
          }
          break;

        // ====================================================================
        // CASO 2: Me desasignaron
        // ====================================================================
        case EventoTrasladoType.unassigned:
          if (evento.oldConductorId == miId) {
            debugPrint('🗑️ [TrasladosBloc] Traslado ${evento.trasladoId} desasignado');
            traslados.removeWhere((t) => t.id == evento.trasladoId);
            debugPrint('➖ [TrasladosBloc] Traslado eliminado de lista');
            emit(currentState.copyWith(traslados: traslados));
          }
          break;

        // ====================================================================
        // CASO 3: Cambió el estado de un traslado mío
        // ====================================================================
        case EventoTrasladoType.statusChanged:
          final index = traslados.indexWhere((t) => t.id == evento.trasladoId);
          if (index != -1) {
            debugPrint('📊 [TrasladosBloc] Traslado ${evento.trasladoId} cambió estado: ${evento.oldEstado} -> ${evento.newEstado}');

            // Refrescar traslado desde la BD
            final traslado = await _repository.getById(evento.trasladoId);
            traslados[index] = traslado;
            debugPrint('📝 [TrasladosBloc] Traslado actualizado en lista');

            emit(currentState.copyWith(traslados: traslados));
          }
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosBloc] Error procesando evento: $e');
      debugPrint('Stack trace: $stackTrace');
      // No emitimos error para no bloquear el stream, solo logueamos
    }
  }

  @override
  Future<void> close() {
    AppLogger.info('Cerrando BLoC y cancelando streams', tag: _tag);
    _trasladosStreamSubscription?.cancel();
    _eventosStreamSubscription?.cancel();
    _repository.disposeRealtimeChannels();
    _connectionManager.dispose();
    return super.close();
  }
}
