import 'package:ambutrack_desktop/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

/// Estados de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carga
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado autenticado
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final UserEntity user;

  @override
  List<Object?> get props => <Object?>[user];
}

/// Estado no autenticado
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Estado de error
class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de contraseña restablecida
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent({required this.email});

  final String email;

  @override
  List<Object?> get props => <Object?>[email];
}