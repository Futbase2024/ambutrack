import 'package:ambutrack_web/core/services/auth_service.dart';
import 'package:ambutrack_web/features/auth/data/mappers/user_mapper.dart';
import 'package:ambutrack_web/features/auth/domain/entities/user_entity.dart';
import 'package:ambutrack_web/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementación del repositorio de autenticación
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authService);

  final AuthService _authService;
  SupabaseClient get _supabase => Supabase.instance.client;

  UserEntity? _cachedUser;

  @override
  UserEntity? get currentUser {
    // Si ya tenemos un usuario cacheado, devolverlo
    if (_cachedUser != null) {
      return _cachedUser;
    }

    // Si no, intentar obtener desde auth
    final User? user = _authService.currentUser;
    if (user == null) {
      return null;
    }

    // Sincronizar los datos desde la tabla usuarios (sin await porque es getter)
    // Esto se ejecutará en background y actualizará el cache
    _syncUserData(user.id);

    // Mientras tanto, devolver datos básicos de auth.users
    return UserMapper.fromSupabaseUser(user);
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((User? user) async {
      if (user == null) {
        _cachedUser = null;
        return null;
      }

      // Consultar tabla usuarios para datos completos
      final Map<String, dynamic>? usuarioData = await _fetchUsuarioData(user.id);

      if (usuarioData != null) {
        return _cachedUser = UserMapper.fromSupabaseUserAndUsuario(user, usuarioData);
      } else {
        return _cachedUser = UserMapper.fromSupabaseUser(user);
      }
    });
  }

  /// Sincroniza los datos del usuario en background y actualiza el cache
  Future<void> _syncUserData(String userId) async {
    try {
      final User? authUser = _authService.currentUser;
      if (authUser == null) {
        return;
      }

      final Map<String, dynamic>? usuarioData = await _fetchUsuarioData(userId);

      if (usuarioData != null) {
        _cachedUser = UserMapper.fromSupabaseUserAndUsuario(authUser, usuarioData);
        debugPrint('✅ AuthRepository: Datos de usuario sincronizados desde tabla usuarios');
      }
    } catch (e) {
      debugPrint('❌ AuthRepository: Error al sincronizar datos de usuario: $e');
    }
  }

  @override
  bool get isAuthenticated => _authService.isAuthenticated;

  @override
  Future<UserEntity?> refreshCurrentUser() async {
    final User? authUser = _authService.currentUser;
    if (authUser == null) {
      _cachedUser = null;
      return null;
    }

    final Map<String, dynamic>? usuarioData = await _fetchUsuarioData(authUser.id);

    if (usuarioData != null) {
      _cachedUser = UserMapper.fromSupabaseUserAndUsuario(authUser, usuarioData);
      debugPrint('✅ AuthRepository: Usuario actualizado desde tabla usuarios');
      return _cachedUser;
    } else {
      _cachedUser = UserMapper.fromSupabaseUser(authUser);
      debugPrint('⚠️ AuthRepository: Usuario no encontrado en tabla usuarios, usando solo auth.users');
      return _cachedUser;
    }
  }

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
      final User authUser = result.data!.user!;

      // ✅ Consultar tabla usuarios para obtener datos completos
      final Map<String, dynamic>? usuarioData = await _fetchUsuarioData(authUser.id);

      if (usuarioData != null) {
        return UserMapper.fromSupabaseUserAndUsuario(authUser, usuarioData);
      } else {
        // Fallback: usar solo datos de auth.users
        debugPrint('⚠️ AuthRepository: Usuario no encontrado en tabla usuarios, usando solo auth.users');
        return UserMapper.fromSupabaseUser(authUser);
      }
    } else {
      throw result.error ?? Exception('Error desconocido al iniciar sesión');
    }
  }

  @override
  Future<UserEntity> signInWithDniAndPassword({
    required String dni,
    required String password,
  }) async {
    final AuthResult<AuthResponse> result = await _authService.signInWithDniAndPassword(
      dni: dni,
      password: password,
    );

    if (result.isSuccess && result.data != null && result.data!.user != null) {
      final User authUser = result.data!.user!;

      // ✅ Consultar tabla usuarios para obtener datos completos
      final Map<String, dynamic>? usuarioData = await _fetchUsuarioData(authUser.id);

      if (usuarioData != null) {
        return UserMapper.fromSupabaseUserAndUsuario(authUser, usuarioData);
      } else {
        // Fallback: usar solo datos de auth.users
        debugPrint('⚠️ AuthRepository: Usuario no encontrado en tabla usuarios, usando solo auth.users');
        return UserMapper.fromSupabaseUser(authUser);
      }
    } else {
      throw result.error ?? Exception('Error desconocido al iniciar sesión con DNI');
    }
  }

  /// Obtiene datos del usuario desde la tabla usuarios
  Future<Map<String, dynamic>?> _fetchUsuarioData(String userId) async {
    try {
      // Query 1: Obtener datos del usuario
      final Map<String, dynamic> response = await _supabase
          .from('usuarios')
          .select('id, email, nombre, apellidos, telefono, rol, activo, foto_url, empresa_id, dni')
          .eq('id', userId)
          .single();

      // Query 2: Obtener nombre de la empresa si existe empresa_id
      final String? empresaId = response['empresa_id'] as String?;
      if (empresaId != null) {
        try {
          final Map<String, dynamic> empresaData = await _supabase
              .from('empresas')
              .select('nombre')
              .eq('id', empresaId)
              .single();

          // Agregar el nombre de la empresa al response en el formato esperado
          response['empresas'] = empresaData;
        } catch (e) {
          debugPrint('⚠️ AuthRepository: No se pudo obtener nombre de empresa: $e');
          // Continuar sin el nombre de la empresa
        }
      }

      return response;
    } catch (e) {
      debugPrint('❌ AuthRepository: Error al obtener datos de usuario: $e');
      return null;
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
