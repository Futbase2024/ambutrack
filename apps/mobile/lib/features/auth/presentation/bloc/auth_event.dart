import 'package:equatable/equatable.dart';

import 'package:ambutrack_core/ambutrack_core.dart';

/// Eventos del AuthBloc
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para iniciar sesión con email y contraseña
class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Evento para iniciar sesión con DNI
class AuthSignInWithDniRequested extends AuthEvent {
  const AuthSignInWithDniRequested({
    required this.dni,
    required this.password,
  });

  final String dni;
  final String password;

  @override
  List<Object?> get props => [dni, password];
}

/// Evento para cerrar sesión
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Evento emitido cuando cambia el estado de autenticación
class AuthStateChanged extends AuthEvent {
  const AuthStateChanged(this.user);

  final AuthUserEntity? user;

  @override
  List<Object?> get props => [user];
}

/// Evento para verificar sesión al iniciar la app
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
