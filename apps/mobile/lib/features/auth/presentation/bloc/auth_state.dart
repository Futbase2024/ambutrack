import 'package:equatable/equatable.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Estados del AuthBloc
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - Verificando sesión
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carga (durante login/logout)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado autenticado - Usuario logueado
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.user,
    this.personal,
  });

  final UserEntity user;
  final UserEntity? personal;

  @override
  List<Object?> get props => [user, personal];
}

/// Estado no autenticado - Sin sesión
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Estado de error
class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
