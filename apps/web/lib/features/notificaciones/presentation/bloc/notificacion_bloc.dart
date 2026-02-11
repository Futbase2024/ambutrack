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
      onError: (error) {
        debugPrint('🔔 NotificacionBloc: Error en stream de notificaciones: $error');
        emit(NotificacionState.error(error.toString()));
      },
    );

    // Suscribirse al conteo
    _conteoSubscription = _repository.watchConteoNoLeidas(usuarioId).listen(
      (int conteo) {
        debugPrint('🔔 NotificacionBloc: Conteo actualizado: $conteo');
        add(NotificacionEvent.conteoUpdated(conteo));
      },
      onError: (error) {
        debugPrint('🔔 NotificacionBloc: Error en stream de conteo: $error');
      },
    );

    // Cargar datos iniciales
    try {
      final List<NotificacionEntity> notificaciones = await _repository.getByUsuario(usuarioId);
      final int conteo = await _repository.getConteoNoLeidas(usuarioId);
      emit(NotificacionState.loaded(
        notificaciones: notificaciones,
        conteoNoLeidas: conteo,
      ));
    } catch (e) {
      debugPrint('🔔 NotificacionBloc: Error al cargar datos iniciales: $e');
      emit(NotificacionState.error(e.toString()));
    }
  }

  void _onNotificacionesUpdated(List<NotificacionEntity> notificaciones, Emitter<NotificacionState> emit) {
    state.maybeMap(
      loaded: (value) => emit(value.copyWith(notificaciones: notificaciones)),
      orElse: () {},
    );
  }

  void _onConteoUpdated(int conteo, Emitter<NotificacionState> emit) {
    state.maybeMap(
      loaded: (value) => emit(value.copyWith(conteoNoLeidas: conteo)),
      orElse: () {},
    );
  }

  Future<void> _onMarcarComoLeida(String id, Emitter<NotificacionState> emit) async {
    debugPrint('🔔 NotificacionBloc: Marcando notificación $id como leída');
    try {
      await _repository.marcarComoLeida(id);
    } catch (e) {
      debugPrint('🔔 NotificacionBloc: Error al marcar como leída: $e');
      emit(NotificacionState.error(e.toString()));
    }
  }

  Future<void> _onMarcarTodasComoLeidas(String usuarioId, Emitter<NotificacionState> emit) async {
    debugPrint('🔔 NotificacionBloc: Marcando todas como leídas para usuario $usuarioId');
    try {
      await _repository.marcarTodasComoLeidas(usuarioId);
    } catch (e) {
      debugPrint('🔔 NotificacionBloc: Error al marcar todas como leídas: $e');
      emit(NotificacionState.error(e.toString()));
    }
  }

  Future<void> _onEliminarNotificacion(String id, Emitter<NotificacionState> emit) async {
    debugPrint('🔔 NotificacionBloc: Eliminando notificación $id');
    try {
      await _repository.delete(id);
    } catch (e) {
      debugPrint('🔔 NotificacionBloc: Error al eliminar notificación: $e');
      emit(NotificacionState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _notificacionesSubscription?.cancel();
    _conteoSubscription?.cancel();
    return super.close();
  }
}
