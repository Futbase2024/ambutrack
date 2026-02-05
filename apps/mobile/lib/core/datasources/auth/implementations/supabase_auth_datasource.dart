import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth_datasource_contract.dart';
import '../entities/auth_user_entity.dart';
import '../models/auth_user_supabase_model.dart';

/// Implementación del datasource de autenticación usando Supabase
class SupabaseAuthDataSource implements AuthDataSource {
  SupabaseAuthDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<AuthUserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 [Auth] Intentando login con email: $email');

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        debugPrint('❌ [Auth] Login falló: Usuario nulo en respuesta');
        throw Exception('Error al autenticar: usuario no encontrado');
      }

      debugPrint('✅ [Auth] Login exitoso: ${response.user!.email}');

      // Convertir User de Supabase a Entity
      final model = AuthUserSupabaseModel.fromSupabaseUser(
        response.user!,
        metadata: response.user!.userMetadata,
      );

      return model.toEntity();
    } on AuthException catch (e) {
      debugPrint('❌ [Auth] AuthException: ${e.message}');
      throw Exception('Error de autenticación: ${e.message}');
    } catch (e) {
      debugPrint('❌ [Auth] Error inesperado: $e');
      throw Exception('Error inesperado al autenticar: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      debugPrint('🚪 [Auth] Cerrando sesión...');
      await _client.auth.signOut();
      debugPrint('✅ [Auth] Sesión cerrada exitosamente');
    } catch (e) {
      debugPrint('❌ [Auth] Error al cerrar sesión: $e');
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<AuthUserEntity?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;

      if (user == null) {
        debugPrint('ℹ️ [Auth] No hay usuario autenticado');
        return null;
      }

      debugPrint('✅ [Auth] Usuario actual: ${user.email}');

      final model = AuthUserSupabaseModel.fromSupabaseUser(
        user,
        metadata: user.userMetadata,
      );

      return model.toEntity();
    } catch (e) {
      debugPrint('❌ [Auth] Error al obtener usuario actual: $e');
      return null;
    }
  }

  @override
  Stream<AuthUserEntity?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;

      if (user == null) {
        debugPrint('🔄 [Auth] Estado cambiado: Sin sesión');
        return null;
      }

      debugPrint('🔄 [Auth] Estado cambiado: ${user.email}');

      final model = AuthUserSupabaseModel.fromSupabaseUser(
        user,
        metadata: user.userMetadata,
      );

      return model.toEntity();
    });
  }

  @override
  Future<String?> getEmailByDni(String dni) async {
    try {
      final dniUpper = dni.trim().toUpperCase();
      debugPrint('🔍 [Auth] Buscando email por DNI: $dniUpper');

      final response = await _client
          .from('usuarios')
          .select('email, dni')
          .ilike('dni', dniUpper)
          .maybeSingle();

      if (response == null) {
        debugPrint('❌ [Auth] No se encontró usuario con DNI: $dniUpper');
        return null;
      }

      debugPrint('🔍 [Auth] Registro encontrado: $response');

      final email = response['email'] as String?;

      if (email == null || email.isEmpty) {
        debugPrint('❌ [Auth] El usuario no tiene email configurado');
        return null;
      }

      debugPrint('✅ [Auth] Email encontrado: $email');
      return email;
    } catch (e) {
      debugPrint('❌ [Auth] Error al buscar email por DNI: $e');
      return null;
    }
  }
}
