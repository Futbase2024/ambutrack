import 'package:ambutrack_web/core/services/auth_service.dart';
import 'package:ambutrack_web/features/auth/data/mappers/user_mapper.dart';
import 'package:ambutrack_web/features/auth/domain/entities/user_entity.dart';
import 'package:ambutrack_web/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementación del repositorio de autenticación
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authService);

  final AuthService _authService;

  @override
  UserEntity? get currentUser {
    final User? user = _authService.currentUser;
    return user != null ? UserMapper.fromSupabaseUser(user) : null;
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authService.authStateChanges.map(
      (User? user) => user != null ? UserMapper.fromSupabaseUser(user) : null,
    );
  }

  @override
  bool get isAuthenticated => _authService.isAuthenticated;

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final AuthResult<AuthResponse> result = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.isSuccess && result.data != null && result.data!.user != null) {
      return UserMapper.fromSupabaseUser(result.data!.user!);
    } else {
      throw result.error ?? Exception('Error desconocido al iniciar sesión');
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final AuthResult<AuthResponse> result = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.isSuccess && result.data != null && result.data!.user != null) {
      return UserMapper.fromSupabaseUser(result.data!.user!);
    } else {
      throw result.error ?? Exception('Error desconocido al registrar usuario');
    }
  }

  @override
  Future<void> signOut() async {
    final AuthResult<void> result = await _authService.signOut();

    if (result.isFailure) {
      throw result.error ?? Exception('Error desconocido al cerrar sesión');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    final AuthResult<void> result = await _authService.resetPassword(email: email);

    if (result.isFailure) {
      throw result.error ?? Exception('Error desconocido al restablecer contraseña');
    }
  }
}
