import '../users/entities/users_entity.dart';

/// Contrato para el datasource de autenticación
///
/// Define los métodos básicos para gestionar la autenticación de usuarios
abstract class AuthDataSource {
  /// Inicia sesión con email y contraseña
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Inicia sesión con email y contraseña (alias de signInWithEmail)
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Obtiene el email asociado a un DNI
  Future<String?> getEmailByDni(String dni);

  /// Cierra la sesión actual
  Future<void> signOut();

  /// Obtiene el usuario actualmente autenticado
  Future<UserEntity?> getCurrentUser();

  /// Stream del usuario autenticado (notifica cambios)
  Stream<UserEntity?> get authStateChanges;

  /// Verifica si hay un usuario autenticado
  Future<bool> isAuthenticated();

  /// Registra un nuevo usuario
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Restablece la contraseña enviando email
  Future<void> resetPassword({required String email});

  /// Actualiza el perfil del usuario
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Cambia la contraseña del usuario
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
