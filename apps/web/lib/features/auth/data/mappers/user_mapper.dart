import 'package:ambutrack_web/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mapper para convertir User de Supabase a UserEntity
class UserMapper {
  /// Convierte un User de Supabase a UserEntity
  static UserEntity fromSupabaseUser(User user) {
    final Map<String, dynamic> metadata = user.userMetadata ?? <String, dynamic>{};
    final Map<String, dynamic> appMetadata = user.appMetadata;

    // Buscar empresa_id en app_metadata (preferido) o user_metadata
    final String? empresaId = appMetadata['empresa_id'] as String? ??
        metadata['empresa_id'] as String?;

    return UserEntity(
      uid: user.id,
      email: user.email ?? '',
      displayName: metadata['display_name'] as String? ??
          metadata['full_name'] as String? ??
          metadata['name'] as String?,
      photoUrl: metadata['avatar_url'] as String? ?? metadata['photo_url'] as String?,
      phoneNumber: user.phone,
      emailVerified: user.emailConfirmedAt != null,
      createdAt: DateTime.parse(user.createdAt),
      lastLoginAt: user.lastSignInAt != null ? DateTime.parse(user.lastSignInAt!) : null,
      empresaId: empresaId,
    );
  }

  /// Convierte un UserEntity a Map para Supabase
  static Map<String, dynamic> toSupabaseUserMetadata(UserEntity entity) {
    return <String, dynamic>{
      'display_name': entity.displayName,
      'avatar_url': entity.photoUrl,
      if (entity.empresaId != null) 'empresa_id': entity.empresaId,
    };
  }
}
