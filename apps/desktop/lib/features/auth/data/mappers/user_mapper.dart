import 'package:ambutrack_desktop/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mapper para convertir User de Supabase a UserEntity
class UserMapper {
  /// Convierte un User de Supabase a UserEntity (solo con auth.users)
  /// ⚠️ LEGACY: Usar fromSupabaseUserAndUsuario para datos completos
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

  /// Convierte User de Supabase + datos de tabla usuarios a UserEntity completo
  /// ✅ RECOMENDADO: Incluye empresa_id, rol, activo, dni desde tabla usuarios
  static UserEntity fromSupabaseUserAndUsuario(
    User authUser,
    Map<String, dynamic> usuarioData,
  ) {
    // Construir displayName desde nombre + apellidos
    final String? nombre = usuarioData['nombre'] as String?;
    final String? apellidos = usuarioData['apellidos'] as String?;
    final String? displayName = nombre != null && apellidos != null
        ? '$nombre $apellidos'.trim()
        : nombre ?? apellidos;

    // Extraer nombre de empresa del JOIN
    String? empresaNombre;
    final dynamic empresasData = usuarioData['empresas'];
    if (empresasData is Map<String, dynamic>) {
      empresaNombre = empresasData['nombre'] as String?;
    }

    return UserEntity(
      uid: authUser.id,
      email: authUser.email ?? usuarioData['email'] as String? ?? '',
      displayName: displayName,
      photoUrl: usuarioData['foto_url'] as String?,
      phoneNumber: usuarioData['telefono'] as String? ?? authUser.phone,
      emailVerified: authUser.emailConfirmedAt != null,
      createdAt: DateTime.parse(authUser.createdAt),
      lastLoginAt: authUser.lastSignInAt != null
          ? DateTime.parse(authUser.lastSignInAt!)
          : null,
      empresaId: usuarioData['empresa_id'] as String?,
      empresaNombre: empresaNombre,
      rol: usuarioData['rol'] as String?,
      activo: usuarioData['activo'] as bool? ?? true,
      dni: usuarioData['dni'] as String?,
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
