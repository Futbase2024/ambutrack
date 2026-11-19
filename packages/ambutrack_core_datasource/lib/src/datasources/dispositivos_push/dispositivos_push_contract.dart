/// Registro de los móviles (token de Firebase Cloud Messaging) del usuario autenticado
///
/// Con un dispositivo registrado, cada fila nueva de `tnotificaciones` para ese
/// usuario se envía también como notificación push (Edge Function `enviar-push`).
abstract class DispositivosPushDataSource {
  /// Registra o actualiza el token de este móvil para el usuario autenticado.
  ///
  /// Si el token pertenecía a otro usuario (móvil compartido), pasa a este.
  Future<void> registrar({required String token, required String plataforma, String? appVersion});

  /// Da de baja el token (al cerrar sesión): este móvil deja de recibir push
  Future<void> eliminar(String token);
}
