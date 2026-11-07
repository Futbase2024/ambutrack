import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/auth_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/perfil_repository.dart';

/// Implementación del repositorio de perfil usando Supabase Auth
@LazySingleton(as: PerfilRepository)
class PerfilRepositoryImpl implements PerfilRepository {
  PerfilRepositoryImpl(this._authService, this._authRepository);

  final AuthService _authService;
  final AuthRepository _authRepository;

  @override
  UserEntity? getCurrentUser() {
    debugPrint('📦 PerfilRepository: Obteniendo usuario actual');
    return _authRepository.currentUser;
  }

  @override
  Future<UserEntity?> refreshCurrentUser() async {
    debugPrint('🔄 PerfilRepository: Refrescando datos del usuario actual');
    return _authRepository.refreshCurrentUser();
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    debugPrint('📝 PerfilRepository: Actualizando perfil...');
    debugPrint('  - displayName: $displayName');
    debugPrint('  - phoneNumber: $phoneNumber');
    debugPrint('  - photoUrl: $photoUrl');

    try {
      // Construir el map de datos solo con valores no nulos
      final Map<String, dynamic> data = <String, dynamic>{};

      if (displayName != null) {
        data['display_name'] = displayName;
      }
      if (phoneNumber != null) {
        data['phone_number'] = phoneNumber;
      }
      if (photoUrl != null) {
        data['photo_url'] = photoUrl;
      }

      // Llamar a AuthService para actualizar en Supabase
      final AuthResult<UserResponse> result = await _authService.updateProfile(data: data);

      if (result.isFailure) {
        debugPrint('❌ PerfilRepository: Error al actualizar perfil');
        throw Exception(result.error?.toString() ?? 'Error desconocido al actualizar perfil');
      }

      debugPrint('✅ PerfilRepository: Perfil actualizado correctamente');
    } catch (e) {
      debugPrint('❌ PerfilRepository: Exception al actualizar perfil - $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    debugPrint('🔒 PerfilRepository: Cambiando contraseña...');

    try {
      // Validación de longitud mínima
      if (newPassword.length < 6) {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      }

      // Llamar a AuthService para actualizar en Supabase
      final AuthResult<UserResponse> result = await _authService.updatePassword(newPassword: newPassword);

      if (result.isFailure) {
        debugPrint('❌ PerfilRepository: Error al cambiar contraseña');
        throw Exception(result.error?.toString() ?? 'Error desconocido al cambiar contraseña');
      }

      debugPrint('✅ PerfilRepository: Contraseña cambiada correctamente');
    } catch (e) {
      debugPrint('❌ PerfilRepository: Exception al cambiar contraseña - $e');
      rethrow;
    }
  }
}
