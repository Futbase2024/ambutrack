import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Interfaz del repositorio de autenticación
///
/// Define las operaciones de autenticación en la capa de dominio.
abstract class AuthRepository {
  /// Login con email y contraseña
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Cierra la sesión del usuario actual
  Future<void> signOut();

  /// Obtiene el usuario actualmente autenticado
  Future<UserEntity?> getCurrentUser();

  /// Stream que emite eventos cuando cambia el estado de autenticación
  Stream<UserEntity?> get authStateChanges;

  /// Busca el email de un usuario por su DNI
  Future<String?> getEmailByDni(String dni);

  /// true si la clave actual es provisional (alta o restablecimiento) y hay que cambiarla
  Future<bool> debeCambiarClave();

  /// Cambia la clave del usuario autenticado y quita la marca de provisional
  Future<void> cambiarMiClave(String nuevaClave);
}
