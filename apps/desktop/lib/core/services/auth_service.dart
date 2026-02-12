import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Resultado de operaciones de autenticación
class AuthResult<T> {
  const AuthResult.success(this.data) : error = null;
  const AuthResult.failure(this.error) : data = null;

  final T? data;
  final Exception? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

/// Excepción de autenticación de Supabase
class SupabaseAuthException implements Exception {
  const SupabaseAuthException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'SupabaseAuthException: [$code] $message';
}

/// Servicio de autenticación usando Supabase Auth
/// Compatible con iautomat_auth_manager
@lazySingleton
class AuthService {
  AuthService() : _supabaseAuth = Supabase.instance.client.auth;

  final GoTrueClient _supabaseAuth;

  /// Usuario actual autenticado
  User? get currentUser => _supabaseAuth.currentUser;

  /// Stream de cambios de estado de autenticación
  Stream<User?> get authStateChanges {
    return _supabaseAuth.onAuthStateChange.map(
      (AuthState state) => state.session?.user,
    );
  }

  /// Indica si hay un usuario autenticado
  bool get isAuthenticated => _supabaseAuth.currentUser != null;

  /// Sesión actual
  Session? get currentSession => _supabaseAuth.currentSession;

  /// Iniciar sesión con email y contraseña
  Future<AuthResult<AuthResponse>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔑 AuthService: Intentando signIn con Supabase para $email');
      final AuthResponse response = await _supabaseAuth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ AuthService: SignIn exitoso - User: ${response.user?.email}');
      return AuthResult<AuthResponse>.success(response);
    } on AuthException catch (e) {
      debugPrint('❌ AuthService: AuthException - [${e.statusCode}] ${e.message}');
      return AuthResult<AuthResponse>.failure(
        SupabaseAuthException(e.statusCode ?? 'unknown', e.message),
      );
    } catch (e) {
      debugPrint('❌ AuthService: Exception genérica - $e');
      return AuthResult<AuthResponse>.failure(Exception(e.toString()));
    }
  }

  /// Iniciar sesión con DNI y contraseña
  /// Busca el email asociado al DNI y luego hace login con email/password
  Future<AuthResult<AuthResponse>> signInWithDniAndPassword({
    required String dni,
    required String password,
  }) async {
    try {
      debugPrint('🔑 AuthService: Intentando signIn con DNI $dni');

      // 1. Llamar a función SQL para obtener email desde DNI
      final String email = await Supabase.instance.client
          .rpc<String>('get_email_by_dni', params: <String, dynamic>{'dni_input': dni});

      if (email.isEmpty) {
        debugPrint('❌ AuthService: No se encontró usuario con DNI $dni');
        return const AuthResult<AuthResponse>.failure(
          SupabaseAuthException(
            'dni_not_found',
            'No existe un usuario con este DNI o está inactivo',
          ),
        );
      }

      debugPrint('✅ AuthService: DNI $dni → Email: $email');

      // 2. Hacer login normal con email + password
      return await signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      debugPrint('❌ AuthService: AuthException en DNI login - [${e.statusCode}] ${e.message}');
      return AuthResult<AuthResponse>.failure(
        SupabaseAuthException(e.statusCode ?? 'unknown', e.message),
      );
    } catch (e) {
      debugPrint('❌ AuthService: Exception genérica en DNI login - $e');
      return AuthResult<AuthResponse>.failure(Exception(e.toString()));
    }
  }

  /// Registrar nuevo usuario con email y contraseña
  Future<AuthResult<AuthResponse>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('📝 AuthService: Intentando signUp con Supabase para $email');
      final AuthResponse response = await _supabaseAuth.signUp(
        email: email,
        password: password,
      );
      debugPrint('✅ AuthService: SignUp exitoso - User: ${response.user?.email}');
      return AuthResult<AuthResponse>.success(response);
    } on AuthException catch (e) {
      debugPrint('❌ AuthService: AuthException en signUp - [${e.statusCode}] ${e.message}');
      return AuthResult<AuthResponse>.failure(
        SupabaseAuthException(e.statusCode ?? 'unknown', e.message),
      );
    } catch (e) {
      debugPrint('❌ AuthService: Exception genérica en signUp - $e');
      return AuthResult<AuthResponse>.failure(Exception(e.toString()));
    }
  }

  /// Cerrar sesión
  Future<AuthResult<void>> signOut() async {
    try {
      debugPrint('🚪 AuthService: Cerrando sesión...');
      // Usar scope 'global' para limpiar todas las sesiones y tokens
      await _supabaseAuth.signOut(scope: SignOutScope.global);
      debugPrint('✅ AuthService: Sesión cerrada correctamente');
      return const AuthResult<void>.success(null);
    } on AuthException catch (e) {
      debugPrint('❌ AuthService: Error al cerrar sesión - [${e.statusCode}] ${e.message}');
      return AuthResult<void>.failure(
        SupabaseAuthException(e.statusCode ?? 'unknown', e.message),
      );
    } catch (e) {
      debugPrint('❌ AuthService: Exception genérica al cerrar sesión - $e');
      return AuthResult<void>.failure(Exception(e.toString()));
    }
  }

  /// Restablecer contraseña
  Future<AuthResult<void>> resetPassword({required String email}) async {
    try {
      await _supabaseAuth.resetPasswordForEmail(email);
      return const AuthResult<void>.success(null);
    } on AuthException catch (e) {
      return AuthResult<void>.failure(
        SupabaseAuthException(e.statusCode ?? 'unknown', e.message),
      );
    } catch (e) {
      return AuthResult<void>.failure(Exception(e.toString()));
    }
  }

  /// Refrescar sesión del usuario actual
  Future<void> refreshSession() async {
    await _supabaseAuth.refreshSession();
  }

  /// Obtener token de acceso del usuario actual
  Future<String?> getAccessToken() async {
    return currentSession?.accessToken;
  }

  /// Actualizar contraseña del usuario
  Future<AuthResult<UserResponse>> updatePassword({
    required String newPassword,
  }) async {
    try {
      final UserResponse response = await _supabaseAuth.updateUser(
        UserAttributes(password: newPassword),
      );
      return AuthResult<UserResponse>.success(response);
    } on AuthException catch (e) {
      return AuthResult<UserResponse>.failure(
        SupabaseAuthException(e.statusCode ?? 'unknown', e.message),
      );
    } catch (e) {
      return AuthResult<UserResponse>.failure(Exception(e.toString()));
    }
  }

  /// Actualizar perfil del usuario
  Future<AuthResult<UserResponse>> updateProfile({
    String? email,
    Map<String, dynamic>? data,
  }) async {
    try {
      final UserResponse response = await _supabaseAuth.updateUser(
        UserAttributes(
          email: email,
          data: data,
        ),
      );
      return AuthResult<UserResponse>.success(response);
    } on AuthException catch (e) {
      return AuthResult<UserResponse>.failure(
        SupabaseAuthException(e.statusCode ?? 'unknown', e.message),
      );
    } catch (e) {
      return AuthResult<UserResponse>.failure(Exception(e.toString()));
    }
  }
}
