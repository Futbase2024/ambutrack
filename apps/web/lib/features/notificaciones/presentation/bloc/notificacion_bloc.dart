import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
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
    if (!emit.isDone) {
      state.whenOrNull(
        loaded: (List<NotificacionEntity> currentNotificaciones, int conteoNoLeidas) {
          if (!emit.isDone) {
            emit(NotificacionState.loaded(
              notificaciones: notificaciones,
              conteoNoLeidas: conteoNoLeidas,
            ));
          }
        },
      );
    }
  }

  void _onConteoUpdated(int conteo, Emitter<NotificacionState> emit) {
    if (!emit.isDone) {
      state.whenOrNull(
        loaded: (List<NotificacionEntity> notificaciones, int currentConteo) {
          if (!emit.isDone) {
            emit(NotificacionState.loaded(
              notificaciones: notificaciones,
              conteoNoLeidas: conteo,
            ));
          }
        },
      );
    }
  }

  Future<void> _onMarcarComoLeida(String id, Emitter<NotificacionState> emit) async {
    debugPrint('🔔 NotificacionBloc: Marcando notificación $id como leída');
    try {
      await _repository.marcarComoLeida(id);
    } catch (e) {
      debugPrint('🔔 NotificacionBloc: Error al marcar como leída: $e');
      if (!emit.isDone) {
        emit(NotificacionState.error(e.toString()));
      }
    }
  }

  Future<void> _onMarcarTodasComoLeidas(String usuarioId, Emitter<NotificacionState> emit) async {
    debugPrint('🔔 NotificacionBloc: Marcando todas como leídas para usuario $usuarioId');
    try {
      await _repository.marcarTodasComoLeidas(usuarioId);
    } catch (e) {
      debugPrint('🔔 NotificacionBloc: Error al marcar todas como leídas: $e');
      if (!emit.isDone) {
        emit(NotificacionState.error(e.toString()));
      }
    }
  }

  Future<void> _onEliminarNotificacion(String id, Emitter<NotificacionState> emit) async {
    debugPrint('🔔 NotificacionBloc: Eliminando notificación $id');
    try {
      await _repository.delete(id);
    } catch (e) {
      debugPrint('🔔 NotificacionBloc: Error al eliminar notificación: $e');
      if (!emit.isDone) {
        emit(NotificacionState.error(e.toString()));
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
