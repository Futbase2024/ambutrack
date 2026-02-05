import '../../../../core/datasources/auth/entities/auth_user_entity.dart';

/// Interfaz del repositorio de autenticación
///
/// Define las operaciones de autenticación en la capa de dominio.
abstract class AuthRepository {
  /// Login con email y contraseña
  Future<AuthUserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Cierra la sesión del usuario actual
  Future<void> signOut();

  /// Obtiene el usuario actualmente autenticado
  Future<AuthUserEntity?> getCurrentUser();

  /// Stream que emite eventos cuando cambia el estado de autenticación
  Stream<AuthUserEntity?> get authStateChanges;

  /// Busca el email de un usuario por su DNI
  Future<String?> getEmailByDni(String dni);
}
