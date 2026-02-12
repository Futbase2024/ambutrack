import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notificacion_event.freezed.dart';

/// Eventos del BLoC de notificaciones
@freezed
class NotificacionEvent with _$NotificacionEvent {
  const factory NotificacionEvent.started() = _Started;

  const factory NotificacionEvent.subscribeNotificaciones(String usuarioId) = _SubscribeNotificaciones;

  const factory NotificacionEvent.notificacionesUpdated(List<NotificacionEntity> notificaciones) = _NotificacionesUpdated;

  const factory NotificacionEvent.conteoUpdated(int conteo) = _ConteoUpdated;

  const factory NotificacionEvent.marcarComoLeida(String id) = _MarcarComoLeida;

  const factory NotificacionEvent.marcarTodasComoLeidas(String usuarioId) = _MarcarTodasComoLeidas;

  const factory NotificacionEvent.eliminarNotificacion(String id) = _EliminarNotificacion;

  const factory NotificacionEvent.eliminarTodasNotificaciones(String usuarioId) = _EliminarTodasNotificaciones;

  const factory NotificacionEvent.eliminarMultiplesNotificaciones(List<String> ids) = _EliminarMultiplesNotificaciones;

  const factory NotificacionEvent.errorOccurred(String message) = _ErrorOccurred;
}
