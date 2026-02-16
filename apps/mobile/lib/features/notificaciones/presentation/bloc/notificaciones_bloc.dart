import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../domain/repositories/notificaciones_repository.dart';
import '../../services/local_notifications_service.dart';
import 'notificaciones_event.dart';
import 'notificaciones_state.dart';

/// BLoC de notificaciones
///
/// Maneja el estado de las notificaciones, escucha cambios en tiempo real
/// desde Supabase y muestra notificaciones locales cuando llegan nuevas
class NotificacionesBloc extends Bloc<NotificacionesEvent, NotificacionesState> {
  NotificacionesBloc({
    required NotificacionesRepository repository,
    required LocalNotificationsService localNotificationsService,
  })  : _repository = repository,
        _localNotificationsService = localNotificationsService,
        super(const NotificacionesState.initial()) {
    on<NotificacionesEvent>(_onEvent);
  }

  final NotificacionesRepository _repository;
  final LocalNotificationsService _localNotificationsService;

  StreamSubscription<List<NotificacionEntity>>? _notificacionesSubscription;
  StreamSubscription<int>? _conteoSubscription;

  Future<void> _onEvent(
    NotificacionesEvent event,
    Emitter<NotificacionesState> emit,
  ) async {
    debugPrint('📨 [NotificacionesBloc] Evento recibido: ${event.runtimeType}');

    await event.when(
      started: () async {
        debugPrint('📨 [NotificacionesBloc] Procesando evento: started');
        await _onStarted(emit);
      },
      loadRequested: () async {
        debugPrint('📨 [NotificacionesBloc] Procesando evento: loadRequested');
        await _onLoadRequested(emit);
      },
      refreshRequested: () async {
        debugPrint('📨 [NotificacionesBloc] Procesando evento: refreshRequested');
        await _onRefreshRequested(emit);
      },
      marcarComoLeida: (id) async {
        debugPrint('📨 [NotificacionesBloc] Procesando evento: marcarComoLeida ($id)');
        await _onMarcarComoLeida(emit, id);
      },
      marcarTodasLeidas: () async {
        debugPrint('📨 [NotificacionesBloc] Procesando evento: marcarTodasLeidas');
        await _onMarcarTodasLeidas(emit);
      },
      eliminar: (id) async {
        debugPrint('📨 [NotificacionesBloc] Procesando evento: eliminar ($id)');
        await _onEliminar(emit, id);
      },
      eliminarTodas: () async {
        debugPrint('📨 [NotificacionesBloc] Procesando evento: eliminarTodas');
        await _onEliminarTodas(emit);
      },
      eliminarSeleccionadas: (ids) async {
        debugPrint('📨 [NotificacionesBloc] Procesando evento: eliminarSeleccionadas (${ids.length})');
        await _onEliminarSeleccionadas(emit, ids);
      },
      realtimeReceived: (notificacion) async {
        debugPrint('📨 [NotificacionesBloc] Procesando evento: realtimeReceived');
        await _onRealtimeReceived(emit, notificacion);
      },
      conteoChanged: (conteo) async {
        debugPrint('📨 [NotificacionesBloc] Procesando evento: conteoChanged ($conteo)');
        _onConteoChanged(emit, conteo);
      },
    );
  }

  /// Inicializa el BLoC: carga notificaciones y configura listeners en tiempo real
  Future<void> _onStarted(Emitter<NotificacionesState> emit) async {
    debugPrint('🚀 [NotificacionesBloc] Iniciando...');
    emit(const NotificacionesState.loading());

    try {
      // Cargar notificaciones iniciales
      final notificaciones = await _repository.getNotificaciones();
      final conteoNoLeidas = await _repository.getConteoNoLeidas();

      debugPrint('✅ [NotificacionesBloc] Cargadas ${notificaciones.length} notificaciones ($conteoNoLeidas no leídas)');

      emit(NotificacionesState.loaded(
        notificaciones: notificaciones,
        conteoNoLeidas: conteoNoLeidas,
      ));

      // Configurar listeners de tiempo real
      _setupRealtimeListeners();
    } catch (e) {
      debugPrint('❌ [NotificacionesBloc] Error al iniciar: $e');
      emit(NotificacionesState.error(message: e.toString()));
    }
  }

  /// Configura los listeners de tiempo real de Supabase
  void _setupRealtimeListeners() {
    debugPrint('📡 [NotificacionesBloc] Configurando listeners Realtime...');

    // Listener de notificaciones
    _notificacionesSubscription?.cancel();
    _notificacionesSubscription = _repository.watchNotificaciones().listen(
      (notificaciones) {
        debugPrint('📨 [NotificacionesBloc] Recibidas ${notificaciones.length} notificaciones desde Realtime');
        debugPrint('   Estado actual: ${state.runtimeType}');

        // Si hay una nueva notificación (comparar con estado actual)
        state.maybeWhen(
          loaded: (notificacionesActuales, conteo, isRefreshing) {
            debugPrint('   - Notificaciones actuales: ${notificacionesActuales.length}');
            debugPrint('   - ¿Hay nuevas?: ${notificaciones.length > notificacionesActuales.length}');

            if (notificaciones.length > notificacionesActuales.length) {
              // Hay notificaciones nuevas, mostrar la más reciente
              final nuevas = notificaciones
                  .where((n) => !notificacionesActuales.any((actual) => actual.id == n.id))
                  .toList();

              debugPrint('   - ✅ ${nuevas.length} notificaciones NUEVAS detectadas');
              for (final nueva in nuevas) {
                debugPrint('   - 🔔 Procesando notificación: ${nueva.titulo}');
                add(NotificacionesEvent.realtimeReceived(nueva));
              }
            } else {
              debugPrint('   - ❌ No hay notificaciones nuevas (mismo número o menos)');
            }

            // Actualizar lista en el estado
            add(const NotificacionesEvent.loadRequested());
          },
          orElse: () {
            debugPrint('   - ⚠️ Estado no es "loaded", recargando...');
            // En estado inicial o loading, solo recargar
            add(const NotificacionesEvent.loadRequested());
          },
        );
      },
      onError: (error) {
        debugPrint('❌ [NotificacionesBloc] Error en stream de notificaciones: $error');
      },
    );

    // Listener de conteo de no leídas
    _conteoSubscription?.cancel();
    _conteoSubscription = _repository.watchConteoNoLeidas().listen(
      (conteo) {
        debugPrint('🔢 [NotificacionesBloc] Conteo actualizado: $conteo no leídas');
        add(NotificacionesEvent.conteoChanged(conteo));
      },
      onError: (error) {
        debugPrint('❌ [NotificacionesBloc] Error en stream de conteo: $error');
      },
    );
  }

  /// Recarga las notificaciones desde el servidor
  Future<void> _onLoadRequested(Emitter<NotificacionesState> emit) async {
    debugPrint('🔄 [NotificacionesBloc] Recargando notificaciones...');

    try {
      final notificaciones = await _repository.getNotificaciones();
      final conteoNoLeidas = await _repository.getConteoNoLeidas();

      emit(NotificacionesState.loaded(
        notificaciones: notificaciones,
        conteoNoLeidas: conteoNoLeidas,
      ));
    } catch (e) {
      debugPrint('❌ [NotificacionesBloc] Error al recargar: $e');

      // Mantener datos previos si hay error
      state.maybeWhen(
        loaded: (notificacionesPrevias, conteoPrevio, isRefreshing) {
          emit(NotificacionesState.error(
            message: e.toString(),
            notificacionesPrevias: notificacionesPrevias,
            conteoNoLeidasPrevio: conteoPrevio,
          ));
        },
        orElse: () {
          emit(NotificacionesState.error(message: e.toString()));
        },
      );
    }
  }

  /// Refresca las notificaciones con pull-to-refresh
  Future<void> _onRefreshRequested(Emitter<NotificacionesState> emit) async {
    debugPrint('🔄 [NotificacionesBloc] Refrescando...');

    state.maybeWhen(
      loaded: (notificaciones, conteo, isRefreshing) {
        emit(NotificacionesState.loaded(
          notificaciones: notificaciones,
          conteoNoLeidas: conteo,
          isRefreshing: true,
        ));
      },
      orElse: () {},
    );

    await _onLoadRequested(emit);
  }

  /// Marca una notificación como leída
  Future<void> _onMarcarComoLeida(Emitter<NotificacionesState> emit, String id) async {
    debugPrint('✅ [NotificacionesBloc] Marcando notificación $id como leída');

    try {
      await _repository.marcarComoLeida(id);

      // Recargar para reflejar el cambio
      add(const NotificacionesEvent.loadRequested());
    } catch (e) {
      debugPrint('❌ [NotificacionesBloc] Error al marcar como leída: $e');
    }
  }

  /// Marca todas las notificaciones como leídas
  Future<void> _onMarcarTodasLeidas(Emitter<NotificacionesState> emit) async {
    debugPrint('✅ [NotificacionesBloc] Marcando todas como leídas');

    try {
      await _repository.marcarTodasComoLeidas();

      // Recargar para reflejar el cambio
      add(const NotificacionesEvent.loadRequested());
    } catch (e) {
      debugPrint('❌ [NotificacionesBloc] Error al marcar todas como leídas: $e');
    }
  }

  /// Elimina una notificación
  Future<void> _onEliminar(Emitter<NotificacionesState> emit, String id) async {
    debugPrint('🗑️ [NotificacionesBloc] Eliminando notificación $id');

    try {
      await _repository.eliminar(id);

      // Cancelar notificación local si existe
      await _localNotificationsService.cancelarNotificacion(id);

      // Recargar para reflejar el cambio
      add(const NotificacionesEvent.loadRequested());
    } catch (e) {
      debugPrint('❌ [NotificacionesBloc] Error al eliminar: $e');
    }
  }

  /// Elimina todas las notificaciones del usuario
  Future<void> _onEliminarTodas(Emitter<NotificacionesState> emit) async {
    debugPrint('🗑️ [NotificacionesBloc] Eliminando todas las notificaciones');

    try {
      await _repository.eliminarTodas();

      // Cancelar todas las notificaciones locales
      await _localNotificationsService.cancelarTodas();

      // Recargar para reflejar el cambio
      add(const NotificacionesEvent.loadRequested());
    } catch (e) {
      debugPrint('❌ [NotificacionesBloc] Error al eliminar todas: $e');
    }
  }

  /// Elimina las notificaciones seleccionadas
  Future<void> _onEliminarSeleccionadas(
    Emitter<NotificacionesState> emit,
    List<String> ids,
  ) async {
    debugPrint('🗑️ [NotificacionesBloc] Eliminando ${ids.length} notificaciones seleccionadas');

    try {
      await _repository.eliminarSeleccionadas(ids);

      // Cancelar notificaciones locales
      for (final id in ids) {
        await _localNotificationsService.cancelarNotificacion(id);
      }

      // Recargar para reflejar el cambio
      add(const NotificacionesEvent.loadRequested());
    } catch (e) {
      debugPrint('❌ [NotificacionesBloc] Error al eliminar seleccionadas: $e');
    }
  }

  /// Se recibió una nueva notificación en tiempo real
  Future<void> _onRealtimeReceived(
    Emitter<NotificacionesState> emit,
    NotificacionEntity notificacion,
  ) async {
    debugPrint('📨 [NotificacionesBloc] ========================================');
    debugPrint('📨 [NotificacionesBloc] 🔔 NUEVA NOTIFICACIÓN EN TIEMPO REAL');
    debugPrint('📨 [NotificacionesBloc] Título: ${notificacion.titulo}');
    debugPrint('📨 [NotificacionesBloc] Tipo: ${notificacion.tipo.value}');
    debugPrint('📨 [NotificacionesBloc] Leída: ${notificacion.leida}');
    debugPrint('📨 [NotificacionesBloc] ========================================');

    // Mostrar notificación local solo si no está leída
    if (!notificacion.leida) {
      debugPrint('📨 [NotificacionesBloc] Mostrando notificación local...');
      try {
        await _localNotificationsService.mostrarNotificacion(
          notificacion: notificacion,
        );
        debugPrint('📨 [NotificacionesBloc] ✅ Notificación local mostrada');
      } catch (e) {
        debugPrint('📨 [NotificacionesBloc] ❌ Error al mostrar notificación local: $e');
      }
    } else {
      debugPrint('📨 [NotificacionesBloc] ⚠️ Notificación ya leída, no se muestra');
    }
  }

  /// El conteo de no leídas cambió en tiempo real
  void _onConteoChanged(Emitter<NotificacionesState> emit, int conteo) {
    debugPrint('🔢 [NotificacionesBloc] Actualizando conteo: $conteo');

    state.maybeWhen(
      loaded: (notificaciones, conteoAnterior, isRefreshing) {
        emit(NotificacionesState.loaded(
          notificaciones: notificaciones,
          conteoNoLeidas: conteo,
          isRefreshing: isRefreshing,
        ));
      },
      orElse: () {},
    );
  }

  @override
  Future<void> close() {
    debugPrint('🔌 [NotificacionesBloc] Cerrando...');
    _notificacionesSubscription?.cancel();
    _conteoSubscription?.cancel();
    _repository.dispose();
    return super.close();
  }
}
