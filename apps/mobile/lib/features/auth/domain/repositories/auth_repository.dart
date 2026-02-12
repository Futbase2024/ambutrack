
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
}
