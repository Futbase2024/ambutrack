import 'package:ambutrack_core/ambutrack_core.dart';

/// Contrato del repositorio de notificaciones para mobile
///
/// Define las operaciones disponibles para gestionar notificaciones
/// del usuario autenticado en la aplicación móvil
abstract class NotificacionesRepository {
  /// Obtiene todas las notificaciones del usuario autenticado
  ///
  /// [limit] - Cantidad máxima de notificaciones a retornar (default: 50)
  /// [soloNoLeidas] - Si es true, solo retorna notificaciones no leídas
  Future<List<NotificacionEntity>> getNotificaciones({
    int limit = 50,
    bool soloNoLeidas = false,
  });

  /// Obtiene el conteo de notificaciones no leídas del usuario autenticado
  Future<int> getConteoNoLeidas();

  /// Marca una notificación como leída
  ///
  /// [id] - ID de la notificación
  Future<void> marcarComoLeida(String id);

  /// Marca todas las notificaciones del usuario autenticado como leídas
  Future<void> marcarTodasComoLeidas();

  /// Stream de notificaciones en tiempo real para el usuario autenticado
  ///
  /// Emite actualizaciones cuando:
  /// - Se crea una nueva notificación
  /// - Se actualiza una notificación existente
  /// - Se elimina una notificación
  Stream<List<NotificacionEntity>> watchNotificaciones();

  /// Stream del conteo de notificaciones no leídas en tiempo real
  ///
  /// Emite actualizaciones cuando cambia el conteo de no leídas
  Stream<int> watchConteoNoLeidas();

  /// Elimina una notificación
  ///
  /// [id] - ID de la notificación a eliminar
  Future<void> eliminar(String id);

  /// Elimina todas las notificaciones del usuario autenticado
  Future<void> eliminarTodas();

  /// Elimina múltiples notificaciones por sus IDs
  ///
  /// [ids] - Lista de IDs de notificaciones a eliminar
  Future<void> eliminarSeleccionadas(List<String> ids);

  /// Notifica a los jefes de personal sobre una solicitud de trámite
  ///
  /// [tipo] - Tipo de notificación (ej: 'vacacion_solicitada', 'ausencia_solicitada')
  /// [titulo] - Título de la notificación
  /// [mensaje] - Mensaje descriptivo de la notificación
  /// [entidadTipo] - Tipo de entidad relacionada (ej: 'vacacion', 'ausencia')
  /// [entidadId] - ID de la entidad relacionada
  /// [metadata] - Metadatos adicionales
  Future<void> notificarJefesPersonal({
    required String tipo,
    required String titulo,
    required String mensaje,
    String? entidadTipo,
    String? entidadId,
    Map<String, dynamic> metadata = const {},
  });

  /// Cierra todos los canales Realtime activos
  Future<void> dispose();
}
