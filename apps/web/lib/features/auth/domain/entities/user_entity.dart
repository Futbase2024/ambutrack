import 'package:equatable/equatable.dart';

/// Entidad de usuario del dominio
class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.emailVerified,
    required this.createdAt,
    this.lastLoginAt,
    this.empresaId,
    this.empresaNombre,
    this.rol,
    this.activo,
    this.dni,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  /// ID de la empresa a la que pertenece el usuario
  final String? empresaId;

  /// Nombre de la empresa a la que pertenece el usuario
  final String? empresaNombre;

  /// Rol del usuario (admin, coordinador, conductor, sanitario, usuario)
  final String? rol;

  /// Indica si el usuario está activo
  final bool? activo;

  /// DNI del usuario (para login alternativo)
  final String? dni;

  @override
  List<Object?> get props => <Object?>[
        uid,
        email,
        displayName,
        photoUrl,
        phoneNumber,
        emailVerified,
        createdAt,
        lastLoginAt,
        empresaId,
        empresaNombre,
        rol,
        activo,
        dni,
      ];
}