import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
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
  final _pacienteDataSource = PacienteDataSourceFactory.createSupabase();

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

  /// Carga un traslado específico y su paciente asociado
  Future<void> _onCargarTraslado(
    CargarTraslado event,
    Emitter<TrasladosState> emit,
  ) async {
    try {
      debugPrint('🎯 [TrasladosBloc] Cargando traslado: ${event.id}');

      final traslado = await _repository.getById(event.id);

      // Cargar paciente completo
      PacienteEntity? paciente;
      if (traslado.idPaciente != null) {
        try {
          debugPrint('👤 [TrasladosBloc] Cargando paciente: ${traslado.idPaciente}');
          paciente = await _pacienteDataSource.getById(traslado.idPaciente!);
          debugPrint('✅ [TrasladosBloc] Paciente cargado: ${paciente.nombreCompleto}');
        } catch (e) {
          debugPrint('⚠️  [TrasladosBloc] No se pudo cargar paciente: $e');
          // Continuamos sin el paciente completo
        }
      }

      if (state is TrasladosLoaded) {
        final currentState = state as TrasladosLoaded;
        emit(currentState.copyWith(
          trasladoSeleccionado: traslado,
          pacienteSeleccionado: paciente,
        ));
      } else {
        emit(TrasladosLoaded(
          traslados: [traslado],
          trasladoSeleccionado: traslado,
          pacienteSeleccionado: paciente,
        ));
      }

      debugPrint('✅ [TrasladosBloc] Traslado y paciente cargados');
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

      // Guardar estado anterior para poder restaurarlo
      final estadoAnteriorBloc = state;

      // Obtener traslado actual para guardar el estado anterior
      final trasladoActual = await _repository.getById(event.idTraslado);
      final estadoAnterior = EstadoTraslado.fromValue(trasladoActual.estado) ?? EstadoTraslado.pendiente;

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

      // Emitir estado de éxito (transitorio para el listener)
      emit(EstadoCambiadoSuccess(
        traslado: trasladoActualizado,
        estadoAnterior: estadoAnterior,
      ));

      // Recargar traslados y volver a TrasladosLoaded
      if (estadoAnteriorBloc is TrasladosLoaded) {
        final trasladosActualizados = estadoAnteriorBloc.traslados.map((t) {
          return t.id == trasladoActualizado.id ? trasladoActualizado : t;
        }).toList();

        emit(estadoAnteriorBloc.copyWith(
          traslados: trasladosActualizados,
          trasladoSeleccionado: trasladoActualizado,
        ));
      } else {
        // Si no había estado previo, crear uno nuevo
        emit(TrasladosLoaded(
          traslados: [trasladoActualizado],
          trasladoSeleccionado: trasladoActualizado,
        ));
      }

      debugPrint('✅ [TrasladosBloc] Estado actualizado a TrasladosLoaded con traslado actualizado');
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
    try {
      debugPrint('🔄 [TrasladosBloc] Refrescando traslados manualmente...');

      // Obtener ID del conductor desde el estado actual
      if (state is! TrasladosLoaded) {
        debugPrint('⚠️  [TrasladosBloc] No se puede refrescar sin traslados cargados');
        return;
      }

      // Recargar traslados desde la base de datos
      final currentState = state as TrasladosLoaded;

      // Para obtener el ID del conductor, necesitamos extraerlo del primer traslado
      // O podríamos almacenarlo en el estado. Por ahora, simplemente recargamos
      // basándonos en los IDs de los traslados existentes

      if (currentState.traslados.isEmpty) {
        debugPrint('✅ [TrasladosBloc] No hay traslados para refrescar');
        return;
      }

      // Obtener el ID del conductor del primer traslado
      final idConductor = currentState.traslados.first.idConductor;
      if (idConductor == null) {
        debugPrint('⚠️  [TrasladosBloc] No se pudo obtener ID del conductor');
        return;
      }

      // Recargar traslados
      final trasladosActualizados = await _repository.getActivosByIdConductor(idConductor);

      // Actualizar estado conservando el traslado seleccionado si existe
      final trasladoSeleccionadoActualizado = currentState.trasladoSeleccionado != null
          ? trasladosActualizados.firstWhere(
              (t) => t.id == currentState.trasladoSeleccionado!.id,
              orElse: () => currentState.trasladoSeleccionado!,
            )
          : null;

      emit(currentState.copyWith(
        traslados: trasladosActualizados,
        trasladoSeleccionado: trasladoSeleccionadoActualizado,
      ));

      debugPrint('✅ [TrasladosBloc] Traslados refrescados: ${trasladosActualizados.length}');
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosBloc] Error al refrescar traslados: $e');
      debugPrint('Stack trace: $stackTrace');
      // No emitir error para no interrumpir la experiencia del usuario
    }
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

    debugPrint('');
    debugPrint('🔔 ============ EVENTO RECIBIDO ============');
    debugPrint('🔔 Tipo: ${evento.eventType.label} (${evento.eventType.value})');
    debugPrint('🔔 Traslado ID: ${evento.trasladoId}');
    debugPrint('🔔 Old Conductor: ${evento.oldConductorId}');
    debugPrint('🔔 New Conductor: ${evento.newConductorId}');
    debugPrint('🔔 Mi ID: $miId');
    debugPrint('🔔 =========================================');
    debugPrint('');

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

            // 🔒 PROTECCIÓN: Verificar que el traslado no tenga un estado avanzado o final inconsistente
            // Si el backend funciona correctamente, esto no debería ocurrir
            // Pero es una capa extra de seguridad
            // Nota: "enviado" es válido porque el datasource mobile establece estado="enviado" al asignar
            const estadosInvalidos = [
              // Estados avanzados (en progreso)
              EstadoTraslado.recibido,
              EstadoTraslado.enOrigen,
              EstadoTraslado.saliendoOrigen,
              EstadoTraslado.enTransito,
              EstadoTraslado.enDestino,
              // Estados finales (no se pueden reasignar traslados finalizados/cancelados)
              EstadoTraslado.finalizado,
              EstadoTraslado.cancelado,
              EstadoTraslado.noRealizado,
            ];

            final estadoActual = EstadoTraslado.fromValue(traslado.estado);
            if (estadoActual != null && estadosInvalidos.contains(estadoActual)) {
              debugPrint(
                '⚠️ [TrasladosBloc] ADVERTENCIA: Traslado reasignado con estado inválido "${estadoActual.value}"',
              );
              debugPrint('   Este traslado debería haber sido reseteado a "asignado" por el backend');
              debugPrint('   Ignorando este traslado hasta que el backend lo corrija');

              // No agregar el traslado a la lista hasta que tenga un estado válido
              return;
            }

            // ✅ Crear nueva lista con el traslado actualizado/añadido
            final List<TrasladoEntity> nuevosTraslados;
            final index = traslados.indexWhere((t) => t.id == traslado.id);
            if (index != -1) {
              // Reemplazar traslado existente
              nuevosTraslados = List<TrasladoEntity>.from(traslados);
              nuevosTraslados[index] = traslado;
              debugPrint('📝 [TrasladosBloc] Traslado actualizado en lista');
            } else {
              // Añadir nuevo traslado
              nuevosTraslados = [...traslados, traslado];
              debugPrint('➕ [TrasladosBloc] Traslado añadido a lista');
            }

            // Emitir estado de asignación para mostrar diálogo
            final esReasignacion = evento.eventType == EventoTrasladoType.reassigned;
            emit(TrasladoAsignado(
              traslado: traslado,
              esReasignacion: esReasignacion,
            ));

            // ✅ Si el trasladoSeleccionado es null o es el mismo traslado que se reasignó,
            // actualizarlo para que la página de detalle lo muestre correctamente
            final TrasladoEntity? nuevoTrasladoSeleccionado;
            if (currentState.trasladoSeleccionado == null ||
                currentState.trasladoSeleccionado?.id == traslado.id) {
              nuevoTrasladoSeleccionado = traslado;
              debugPrint('🎯 [TrasladosBloc] Actualizando trasladoSeleccionado con traslado reasignado');
            } else {
              nuevoTrasladoSeleccionado = currentState.trasladoSeleccionado;
            }

            // Luego emitir el estado normal con la lista actualizada
            emit(currentState.copyWith(
              traslados: nuevosTraslados,
              trasladoSeleccionado: nuevoTrasladoSeleccionado,
            ));
          }

          // ME QUITARON (en caso de reassigned de mí a otro)
          if (evento.oldConductorId == miId && evento.newConductorId != miId) {
            debugPrint('🗑️ [TrasladosBloc] Traslado ${evento.trasladoId} reasignado a otro conductor');

            // Buscar el traslado en la lista ANTES de eliminarlo
            final trasladoDesasignado = traslados.firstWhere(
              (t) => t.id == evento.trasladoId,
              orElse: () => throw Exception('Traslado no encontrado en la lista'),
            );

            // Emitir estado de desasignación con los datos del traslado
            emit(TrasladoDesasignado(traslado: trasladoDesasignado));

            // Crear nueva lista sin el traslado
            final nuevosTraslados = traslados.where((t) => t.id != evento.trasladoId).toList();
            debugPrint('➖ [TrasladosBloc] Traslado eliminado de lista. Restantes: ${nuevosTraslados.length}');

            // Si el traslado reasignado es el que está seleccionado, limpiarlo
            final esElSeleccionado = currentState.trasladoSeleccionado?.id == evento.trasladoId;
            if (esElSeleccionado) {
              debugPrint('🧹 [TrasladosBloc] Limpiando trasladoSeleccionado');
            }

            emit(currentState.copyWith(
              traslados: nuevosTraslados,
              clearTrasladoSeleccionado: esElSeleccionado,
              clearPaciente: esElSeleccionado,
            ));
          }
          break;

        // ====================================================================
        // CASO 2: Me desasignaron
        // ====================================================================
        case EventoTrasladoType.unassigned:
          debugPrint('🔄 [TrasladosBloc] Procesando evento UNASSIGNED');
          debugPrint('   - oldConductorId: ${evento.oldConductorId}');
          debugPrint('   - miId: $miId');
          debugPrint('   - ¿Son iguales?: ${evento.oldConductorId == miId}');

          if (evento.oldConductorId == miId) {
            debugPrint('🗑️ [TrasladosBloc] ✅ Traslado ${evento.trasladoId} desasignado DE MÍ');

            // Buscar el traslado en la lista ANTES de eliminarlo
            final trasladoDesasignado = traslados.firstWhere(
              (t) => t.id == evento.trasladoId,
              orElse: () => throw Exception('Traslado no encontrado en la lista'),
            );

            // Emitir estado de desasignación con los datos del traslado
            emit(TrasladoDesasignado(traslado: trasladoDesasignado));

            // Luego crear nueva lista sin el traslado
            final nuevosTraslados = traslados.where((t) => t.id != evento.trasladoId).toList();
            debugPrint('➖ [TrasladosBloc] Traslado eliminado de lista. Traslados restantes: ${nuevosTraslados.length}');

            // Si el traslado desasignado es el que está seleccionado, limpiarlo
            final esElSeleccionado = currentState.trasladoSeleccionado?.id == evento.trasladoId;
            if (esElSeleccionado) {
              debugPrint('🧹 [TrasladosBloc] Limpiando trasladoSeleccionado');
            }

            emit(currentState.copyWith(
              traslados: nuevosTraslados,
              clearTrasladoSeleccionado: esElSeleccionado,
              clearPaciente: esElSeleccionado,
            ));
          } else {
            debugPrint('ℹ️ [TrasladosBloc] Traslado desasignado pero no era mío');
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

            // ✅ Crear nueva lista con el traslado actualizado
            final nuevosTraslados = List<TrasladoEntity>.from(traslados);
            nuevosTraslados[index] = traslado;
            debugPrint('📝 [TrasladosBloc] Traslado actualizado en lista');

            emit(currentState.copyWith(traslados: nuevosTraslados));
          }
          break;

        // Eventos que no requieren acción especial (solo logueo)
        case EventoTrasladoType.cancelled:
        case EventoTrasladoType.started:
        case EventoTrasladoType.completed:
        case EventoTrasladoType.inTransit:
          debugPrint('ℹ️  [TrasladosBloc] Evento ${evento.eventType.label} recibido (sin acción específica)');
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
    // ❌ NO cerrar los canales Realtime aquí porque múltiples BLoCs comparten el mismo cliente de Supabase
    // Si un BLoC cierra los canales con removeAllChannels(), afecta a TODOS los demás BLoCs activos
    // Los canales se cerrarán automáticamente cuando el usuario cierre sesión o la app se cierre
    // _repository.disposeRealtimeChannels();
    _connectionManager.dispose();
    return super.close();
  }
}
