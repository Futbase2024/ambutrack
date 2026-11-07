import 'package:ambutrack_web/features/auth/domain/entities/user_entity.dart';

/// Repositorio abstracto de autenticación
abstract class AuthRepository {
  /// Usuario actual autenticado
  UserEntity? get currentUser;

  /// Stream de cambios de estado de autenticación
  Stream<UserEntity?> get authStateChanges;

  /// Indica si hay un usuario autenticado
  bool get isAuthenticated;

  /// Refresca los datos del usuario actual desde la base de datos
  Future<UserEntity?> refreshCurrentUser();

  /// Iniciar sesión con email y contraseña
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Iniciar sesión con DNI y contraseña
  Future<UserEntity> signInWithDniAndPassword({
    required String dni,
    required String password,
  });

  /// Registrar nuevo usuario con email y contraseña
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Cerrar sesión
  Future<void> signOut();

  /// Restablecer contraseña
  Future<void> resetPassword({required String email});
}