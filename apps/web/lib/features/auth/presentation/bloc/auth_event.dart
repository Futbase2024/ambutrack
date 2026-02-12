import 'package:equatable/equatable.dart';

/// Eventos de autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para verificar el estado de autenticación
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Evento para iniciar sesión
class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => <Object?>[email, password];
}

/// Evento para iniciar sesión con DNI
class AuthDniLoginRequested extends AuthEvent {
  const AuthDniLoginRequested({
    required this.dni,
    required this.password,
  });

  final String dni;
  final String password;

  @override
  List<Object?> get props => <Object?>[dni, password];
}

/// Evento para cerrar sesión
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Evento para registrar nuevo usuario
class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => <Object?>[email, password];
}

/// Evento para restablecer contraseña
class AuthResetPasswordRequested extends AuthEvent {
  const AuthResetPasswordRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => <Object?>[email];
}