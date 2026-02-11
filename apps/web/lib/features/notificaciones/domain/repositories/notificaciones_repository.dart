import 'package:ambutrack_core/ambutrack_core.dart';

/// Contrato del repositorio de notificaciones
abstract class NotificacionesRepository {
  /// Obtiene todas las notificaciones de un usuario
  Future<List<NotificacionEntity>> getByUsuario(String usuarioId);

  /// Obtiene notificaciones no leídas de un usuario
  Future<List<NotificacionEntity>> getNoLeidas(String usuarioId);

  /// Obtiene el conteo de notificaciones no leídas
  Future<int> getConteoNoLeidas(String usuarioId);

  /// Marca una notificación como leída
  Future<void> marcarComoLeida(String id);

  /// Marca todas las notificaciones de un usuario como leídas
  Future<void> marcarTodasComoLeidas(String usuarioId);

  /// Crea una nueva notificación
  Future<NotificacionEntity> create(NotificacionEntity notificacion);

  /// Elimina una notificación
  Future<void> delete(String id);

  /// Stream de notificaciones en tiempo real para un usuario
  Stream<List<NotificacionEntity>> watchNotificaciones(String usuarioId);

  /// Stream del conteo de notificaciones no leídas
  Stream<int> watchConteoNoLeidas(String usuarioId);

  /// Notifica a los jefes de personal sobre una solicitud
  Future<void> notificarJefesPersonal({
    required String tipo,
    required String titulo,
    required String mensaje,
    String? entidadTipo,
    String? entidadId,
    Map<String, dynamic> metadata,
  });
}
