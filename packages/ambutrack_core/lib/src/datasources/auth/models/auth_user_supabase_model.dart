import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/auth_user_entity.dart';

/// Modelo DTO para serialización desde Supabase Auth
///
/// Se encarga de convertir los datos de Supabase User a AuthUserEntity.
class AuthUserSupabaseModel {
  const AuthUserSupabaseModel({
    required this.id,
    required this.email,
    this.nombreCompleto,
    this.avatarUrl,
    this.rol,
    this.empresaId,
  });

  final String id;
  final String email;
  final String? nombreCompleto;
  final String? avatarUrl;
  final String? rol;
  final String? empresaId;

  /// Crea un modelo desde Supabase User y metadata adicional
  factory AuthUserSupabaseModel.fromSupabaseUser(
    User user, {
    Map<String, dynamic>? metadata,
  }) {
    return AuthUserSupabaseModel(
      id: user.id,
      email: user.email ?? '',
      nombreCompleto: metadata?['nombre_completo'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      rol: metadata?['rol'] as String?,
      empresaId: metadata?['empresa_id'] as String?,
    );
  }

  /// Convierte el modelo a Entity de dominio
  AuthUserEntity toEntity() {
    return AuthUserEntity(
      id: id,
      email: email,
      nombreCompleto: nombreCompleto,
      avatarUrl: avatarUrl,
      rol: rol,
      empresaId: empresaId,
    );
  }
}
