import '../users/entities/users_entity.dart';

/// Gestión de cuentas de acceso (auth.users + usuarios)
///
/// Todas las escrituras pasan por la Edge Function `admin-users`, que usa la
/// service_role y valida en servidor quién puede hacer qué:
/// - admin → cualquier usuario y rol
/// - jefe_personal → usuarios con rol operativo de su empresa (no elimina)
abstract class CuentasUsuarioDataSource {
  /// Crea la cuenta con una clave provisional y devuelve su ID.
  ///
  /// El usuario tendrá que cambiar la clave en su primer acceso.
  Future<String> crear(UserEntity usuario, String claveProvisional);

  /// Actualiza datos, rol, empresa y estado de un usuario
  Future<void> actualizar(UserEntity usuario);

  /// Pone una clave provisional nueva (el usuario la cambiará al entrar)
  Future<void> restablecerClave(String usuarioId, String claveProvisional);

  /// Activa o desactiva el acceso (desactivado = no puede iniciar sesión)
  Future<void> cambiarEstado(String usuarioId, {required bool activo});

  /// Elimina la cuenta (solo admin)
  Future<void> eliminar(String usuarioId);

  /// El usuario autenticado cambia su propia clave (quita la marca de provisional)
  Future<void> cambiarMiClave(String nuevaClave);

  /// true si el usuario autenticado tiene una clave provisional pendiente de cambiar
  Future<bool> debeCambiarClave();
}

/// Error devuelto por la gestión de cuentas, con un mensaje apto para el usuario
class CuentaUsuarioException implements Exception {
  const CuentaUsuarioException(this.message);

  final String message;

  @override
  String toString() => message;
}
