import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

part 'notificaciones_event.freezed.dart';

/// Eventos del BLoC de notificaciones
@freezed
class NotificacionesEvent with _$NotificacionesEvent {
  /// Evento inicial - Carga notificaciones y configura listeners
  const factory NotificacionesEvent.started() = _Started;

  /// Solicita carga de notificaciones desde el servidor
  const factory NotificacionesEvent.loadRequested() = _LoadRequested;

  /// Refresca la lista de notificaciones
  const factory NotificacionesEvent.refreshRequested() = _RefreshRequested;

  /// Marca una notificación como leída
  const factory NotificacionesEvent.marcarComoLeida(String id) = _MarcarComoLeida;

  /// Marca todas las notificaciones como leídas
  const factory NotificacionesEvent.marcarTodasLeidas() = _MarcarTodasLeidas;

  /// Elimina una notificación
  const factory NotificacionesEvent.eliminar(String id) = _Eliminar;

  /// Elimina todas las notificaciones del usuario
  const factory NotificacionesEvent.eliminarTodas() = _EliminarTodas;

  /// Elimina las notificaciones seleccionadas
  const factory NotificacionesEvent.eliminarSeleccionadas(List<String> ids) = _EliminarSeleccionadas;

  /// Se recibió una nueva notificación en tiempo real desde Supabase
  const factory NotificacionesEvent.realtimeReceived(
    NotificacionEntity notificacion,
  ) = _RealtimeReceived;

  /// El contador de no leídas cambió en tiempo real
  const factory NotificacionesEvent.conteoChanged(int conteo) = _ConteoChanged;
}
