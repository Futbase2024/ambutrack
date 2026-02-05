import 'package:equatable/equatable.dart';

/// Entity de dominio pura para el usuario autenticado
///
/// Representa la información del usuario sin acoplamientos a Supabase.
class AuthUserEntity extends Equatable {
  const AuthUserEntity({
    required this.id,
    required this.email,
    this.nombreCompleto,
    this.avatarUrl,
    this.rol,
    this.empresaId,
  });

  /// ID único del usuario (UUID de Supabase Auth)
  final String id;

  /// Email del usuario
  final String email;

  /// Nombre completo del usuario
  final String? nombreCompleto;

  /// URL del avatar
  final String? avatarUrl;

  /// Rol del usuario (ej: conductor, tecnico, admin)
  final String? rol;

  /// ID de la empresa a la que pertenece
  final String? empresaId;

  @override
  List<Object?> get props => [
        id,
        email,
        nombreCompleto,
        avatarUrl,
        rol,
        empresaId,
      ];

  /// Copia la entidad con nuevos valores opcionales
  AuthUserEntity copyWith({
    String? id,
    String? email,
    String? nombreCompleto,
    String? avatarUrl,
    String? rol,
    String? empresaId,
  }) {
    return AuthUserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rol: rol ?? this.rol,
      empresaId: empresaId ?? this.empresaId,
    );
  }

  @override
  String toString() {
    return 'AuthUserEntity(id: $id, email: $email, nombreCompleto: $nombreCompleto, rol: $rol)';
  }
}
