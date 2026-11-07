import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/notificaciones/domain/repositories/notificaciones_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'notificacion_event.dart';
import 'notificacion_state.dart';

/// BLoC para gestión de notificaciones en tiempo real
@injectable
class NotificacionBloc extends Bloc<NotificacionEvent, NotificacionState> {
  NotificacionBloc(this._repository) : super(const NotificacionState.initial()) {
    on<NotificacionEvent>(_onEvent);
  }

  final NotificacionesRepository _repository;
  StreamSubscription<List<NotificacionEntity>>? _notificacionesSubscription;
  StreamSubscription<int>? _conteoSubscription;

  Future<void> _onEvent(
    NotificacionEvent event,
    Emitter<NotificacionState> emit,
  ) async {
    event.when(
      started: () => _onStarted(emit),
      subscribeNotificaciones: (String usuarioId) => _onSubscribeNotificaciones(usuarioId, emit),
      notificacionesUpdated: (List<NotificacionEntity> notificaciones) => _onNotificacionesUpdated(notificaciones, emit),
      conteoUpdated: (int conteo) => _onConteoUpdated(conteo, emit),
      marcarComoLeida: (String id) => _onMarcarComoLeida(id, emit),
      marcarTodasComoLeidas: (String usuarioId) => _onMarcarTodasComoLeidas(usuarioId, emit),
      eliminarNotificacion: (String id) => _onEliminarNotificacion(id, emit),
      eliminarTodasNotificaciones: (String usuarioId) => _onEliminarTodasNotificaciones(usuarioId, emit),
      eliminarMultiplesNotificaciones: (List<String> ids) => _onEliminarMultiplesNotificaciones(ids, emit),
      errorOccurred: (String message) => _onErrorOccurred(message, emit),
    );
  }

  Future<void> _onStarted(Emitter<NotificacionState> emit) async {
    debugPrint('🔔 NotificacionBloc: Inicializando...');
    emit(const NotificacionState.loading());
  }

  Future<void> _onSubscribeNotificaciones(String usuarioId, Emitter<NotificacionState> emit) async {
    debugPrint('🔔 NotificacionBloc: Suscribiendo a notificaciones de usuario $usuarioId');

    // Cancelar suscripciones anteriores
    await _notificacionesSubscription?.cancel();
    await _conteoSubscription?.cancel();

    // Suscribirse a notificaciones
    _notificacionesSubscription = _repository.watchNotificaciones(usuarioId).listen(
      (List<NotificacionEntity> notificaciones) {
        debugPrint('🔔 NotificacionBloc: ${notificaciones.length} notificaciones actualizadas');
        add(NotificacionEvent.notificacionesUpdated(notificaciones));
      },
      onError: (Object error) {
        debugPrint('🔔 NotificacionBloc: Error en stream de notificaciones: $error');
        add(NotificacionEvent.errorOccurred(error.toString()));
      },
    );

    // Suscribirse al conteo
    _conteoSubscription = _repository.watchConteoNoLeidas(usuarioId).listen(
      (int conteo) {
        debugPrint('🔔 NotificacionBloc: Conteo actualizado: $conteo');
        add(NotificacionEvent.conteoUpdated(conteo));
      },
      onError: (Object error) {
        debugPrint('🔔 NotificacionBloc: Error en stream de conteo: $error');
        add(NotificacionEvent.errorOccurred(error.toString()));
      },
    );

    // Cargar datos iniciales
    try {
      final List<NotificacionEntity> notificaciones = await _repository.getByUsuario(usuarioId);
      final int conteo = await _repository.getConteoNoLeidas(usuarioId);
      if (!emit.isDone) {
        emit(NotificacionState.loaded(
          notificaciones: notificaciones,
          conteoNoLeidas: conteo,
        ));
      }
    } catch (e) {
      debugPrint('🔔 NotificacionBloc: Error al cargar datos iniciales: $e');
      if (!emit.isDone) {
        emit(NotificacionState.error(e.toString()));
      }
    }
  }

  void _onNotificacionesUpdated(List<NotificacionEntity> notificaciones, Emitter<NotificacionState> emit) {
    debugPrint('🔔 NotificacionBloc: _onNotificacionesUpdated - emit.isDone: ${emit.isDone}, state: ${state.runtimeType}');

    if (!emit.isDone) {
      state.when(
        initial: () {
          // Si aún no tenemos estado loaded, crear uno con conteo 0 temporal
          debugPrint('🔔 NotificacionBloc: Estado inicial, creando loaded con ${notificaciones.length} notificaciones');
          emit(NotificacionState.loaded(
            notificaciones: notificaciones,
            conteoNoLeidas: notificaciones.where((NotificacionEntity n) => !n.leida).length,
          ));
        },
        loading: () {
          // Si está cargando, crear estado loaded
          debugPrint('🔔 NotificacionBloc: Estado loading, creando loaded con ${notificaciones.length} notificaciones');
          emit(NotificacionState.loaded(
            notificaciones: notificaciones,
            conteoNoLeidas: notificaciones.where((NotificacionEntity n) => !n.leida).length,
          ));
        },
        loaded: (List<NotificacionEntity> currentNotificaciones, int conteoNoLeidas) {
          debugPrint('🔔 NotificacionBloc: Emitiendo loaded con ${notificaciones.length} notificaciones y $conteoNoLeidas no leídas');
          emit(NotificacionState.loaded(
            notificaciones: notificaciones,
            conteoNoLeidas: conteoNoLeidas,
          ));
        },
        error: (String message) {
          // Si hay error, crear estado loaded
          debugPrint('🔔 NotificacionBloc: Estado error, creando loaded con ${notificaciones.length} notificaciones');
          emit(NotificacionState.loaded(
            notificaciones: notificaciones,
            conteoNoLeidas: notificaciones.where((NotificacionEntity n) => !n.leida).length,
          ));
        },
      );
    } else {
      debugPrint('⚠️ NotificacionBloc: No se emitió porque emit.isDone es true');
    }
  }

  void _onConteoUpdated(int conteo, Emitter<NotificacionState> emit) {
    debugPrint('🔔 NotificacionBloc: _onConteoUpdated - emit.isDone: ${emit.isDone}, state: ${state.runtimeType}');

    if (!emit.isDone) {
      state.when(
        initial: () {
          // Si aún no tenemos estado loaded, crear uno con lista vacía temporal
          debugPrint('🔔 NotificacionBloc: Estado inicial, creando loaded con conteo $conteo');
          emit(NotificacionState.loaded(
            notificaciones: const <NotificacionEntity>[],
            conteoNoLeidas: conteo,
          ));
        },
        loading: () {
          // Si está cargando, crear estado loaded
          debugPrint('🔔 NotificacionBloc: Estado loading, creando loaded con conteo $conteo');
          emit(NotificacionState.loaded(
            notificaciones: const <NotificacionEntity>[],
            conteoNoLeidas: conteo,
          ));
        },
        loaded: (List<NotificacionEntity> notificaciones, int currentConteo) {
          debugPrint('🔔 NotificacionBloc: Emitiendo loaded con ${notificaciones.length} notificaciones y $conteo no leídas');
          emit(NotificacionState.loaded(
            notificaciones: notificaciones,
            conteoNoLeidas: conteo,
          ));
        },
        error: (String message) {
          // Si hay error, crear estado loaded
          debugPrint('🔔 NotificacionBloc: Estado error, creando loaded con conteo $conteo');
          emit(NotificacionState.loaded(
            notificaciones: const <NotificacionEntity>[],
            conteoNoLeidas: conteo,
          ));
        },
      );
    } else {
      debugPrint('⚠️ NotificacionBloc: No se emitió porque emit.isDone es true');
    }
  }

  Future<void> _onMarcarComoLeida(String id, Emitter<NotificacionState> emit) async {
    debugPrint('🔔 NotificacionBloc: Marcando notificación $id como leída');
    try {
      await _repository.marcarComoLeida(id);
      debugPrint('✅ NotificacionBloc: Notificación marcada como leída correctamente');

      // Actualizar estado inmediatamente sin esperar al real-time
      if (!emit.isDone) {
        state.whenOrNull(
          loaded: (List<NotificacionEntity> notificaciones, int conteoNoLeidas) {
            final List<NotificacionEntity> updated = notificaciones
                .map((NotificacionEntity n) => n.id == id
                    ? n.copyWith(leida: true, fechaLectura: DateTime.now())
                    : n)
                .toList();
            final int newConteo = conteoNoLeidas > 0 ? conteoNoLeidas - 1 : 0;
            emit(NotificacionState.loaded(
              notificaciones: updated,
              conteoNoLeidas: newConteo,
            ));
          },
        );
      }
    } catch (e) {
      debugPrint('❌ NotificacionBloc: Error al marcar como leída: $e');

      // Extraer mensaje de error más específico
      String errorMessage = e.toString();
      if (e is DataSourceException) {
        if (e.code == 'UNAUTHENTICATED') {
          errorMessage = 'Tu sesión ha expirado. Por favor, vuelve a iniciar sesión.';
        } else if (e.code == 'RLS_BLOCKED') {
          errorMessage = 'No tienes permisos para modificar esta notificación.';
        } else {
          errorMessage = e.message;
        }
      }

      if (!emit.isDone) {
        emit(NotificacionState.error(errorMessage));
      }
    }
  }

  Future<void> _onMarcarTodasComoLeidas(String usuarioId, Emitter<NotificacionState> emit) async {
    debugPrint('🔔 NotificacionBloc: Marcando todas como leídas para usuario $usuarioId');
    try {
      await _repository.marcarTodasComoLeidas(usuarioId);
      debugPrint('✅ NotificacionBloc: Todas las notificaciones marcadas como leídas correctamente');

      // Actualizar estado inmediatamente sin esperar al real-time
      if (!emit.isDone) {
        state.whenOrNull(
          loaded: (List<NotificacionEntity> notificaciones, int _) {
            final DateTime now = DateTime.now();
            final List<NotificacionEntity> updated = notificaciones
                .map((NotificacionEntity n) => n.leida
                    ? n
                    : n.copyWith(leida: true, fechaLectura: now))
                .toList();
            emit(NotificacionState.loaded(
              notificaciones: updated,
              conteoNoLeidas: 0,
            ));
          },
        );
      }
    } catch (e) {
      debugPrint('❌ NotificacionBloc: Error al marcar todas como leídas: $e');

      // Extraer mensaje de error más específico
      String errorMessage = e.toString();
      if (e is DataSourceException) {
        if (e.code == 'UNAUTHENTICATED') {
          errorMessage = 'Tu sesión ha expirado. Por favor, vuelve a iniciar sesión.';
        } else {
          errorMessage = e.message;
        }
      }

      if (!emit.isDone) {
        emit(NotificacionState.error(errorMessage));
      }
    }
  }

  Future<void> _onEliminarNotificacion(String id, Emitter<NotificacionState> emit) async {
    debugPrint('🔔 NotificacionBloc: Eliminando notificación $id');
    try {
      await _repository.delete(id);
      debugPrint('✅ NotificacionBloc: Notificación eliminada correctamente');
    } catch (e) {
      debugPrint('❌ NotificacionBloc: Error al eliminar notificación: $e');

      // Extraer mensaje de error más específico si es un DataSourceException
      String errorMessage = e.toString();
      if (e is DataSourceException) {
        if (e.code == 'UNAUTHENTICATED') {
          errorMessage = 'Tu sesión ha expirado. Por favor, vuelve a iniciar sesión.';
        } else if (e.code == 'PERMISSION_DENIED') {
          errorMessage = 'No tienes permisos para eliminar esta notificación. Pertenece a otro usuario.';
        } else if (e.code == 'RLS_BLOCKED') {
          errorMessage = 'No tienes permisos para eliminar esta notificación.';
        } else {
          errorMessage = e.message;
        }
      }

      if (!emit.isDone) {
        emit(NotificacionState.error(errorMessage));
      }
    }
  }

  Future<void> _onEliminarTodasNotificaciones(String usuarioId, Emitter<NotificacionState> emit) async {
    debugPrint('🔔 NotificacionBloc: Eliminando todas las notificaciones para usuario $usuarioId');
    try {
      await _repository.deleteAll(usuarioId);
      debugPrint('✅ NotificacionBloc: Todas las notificaciones eliminadas correctamente');
    } catch (e) {
      debugPrint('❌ NotificacionBloc: Error al eliminar todas las notificaciones: $e');

      // Extraer mensaje de error más específico
      String errorMessage = e.toString();
      if (e is DataSourceException) {
        if (e.code == 'UNAUTHENTICATED') {
          errorMessage = 'Tu sesión ha expirado. Por favor, vuelve a iniciar sesión.';
        } else {
          errorMessage = e.message;
        }
      }

      if (!emit.isDone) {
        emit(NotificacionState.error(errorMessage));
      }
    }
  }

  Future<void> _onEliminarMultiplesNotificaciones(List<String> ids, Emitter<NotificacionState> emit) async {
    debugPrint('🔔 NotificacionBloc: Eliminando ${ids.length} notificaciones');
    try {
      await _repository.deleteMultiple(ids);
      debugPrint('✅ NotificacionBloc: ${ids.length} notificaciones eliminadas correctamente');
    } catch (e) {
      debugPrint('❌ NotificacionBloc: Error al eliminar notificaciones: $e');

      // Extraer mensaje de error más específico
      String errorMessage = e.toString();
      if (e is DataSourceException) {
        if (e.code == 'UNAUTHENTICATED') {
          errorMessage = 'Tu sesión ha expirado. Por favor, vuelve a iniciar sesión.';
        } else if (e.code == 'RLS_BLOCKED') {
          errorMessage = 'No se pudieron eliminar algunas notificaciones por permisos.';
        } else {
          errorMessage = e.message;
        }
      }

      if (!emit.isDone) {
        emit(NotificacionState.error(errorMessage));
      }
    }
  }

  void _onErrorOccurred(String message, Emitter<NotificacionState> emit) {
    debugPrint('🔔 NotificacionBloc: Error ocurrido: $message');
    if (!emit.isDone) {
      emit(NotificacionState.error(message));
    }
  }

  @override
  Future<void> close() {
    _notificacionesSubscription?.cancel();
    _conteoSubscription?.cancel();
    return super.close();
  }
}
