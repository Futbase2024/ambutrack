import 'entities/auth_user_entity.dart';

/// Contrato abstracto para el datasource de autenticación
///
/// Define las operaciones de autenticación sin acoplamientos a implementaciones.
abstract class AuthDataSource {
  /// Login con email y contraseña
  ///
  /// Retorna el usuario autenticado o lanza una excepción.
  Future<AuthUserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Cierra la sesión del usuario actual
  Future<void> signOut();

  /// Obtiene el usuario actualmente autenticado
  ///
  /// Retorna null si no hay sesión activa.
  Future<AuthUserEntity?> getCurrentUser();

  /// Stream que emite eventos cuando cambia el estado de autenticación
  ///
  /// Emite el usuario cuando se autentica o null cuando cierra sesión.
  Stream<AuthUserEntity?> get authStateChanges;

  /// Busca el email de un usuario por su DNI
  ///
  /// Retorna el email si encuentra el usuario, null si no existe.
  Future<String?> getEmailByDni(String dni);
}
