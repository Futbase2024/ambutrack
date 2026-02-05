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
      ];
}