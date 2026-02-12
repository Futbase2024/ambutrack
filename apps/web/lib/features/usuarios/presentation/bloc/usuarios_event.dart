import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de usuarios
abstract class UsuariosEvent extends Equatable {
  const UsuariosEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar todos los usuarios
class UsuariosLoadAllRequested extends UsuariosEvent {
  const UsuariosLoadAllRequested();
}

/// Crear nuevo usuario
class UsuariosCreateRequested extends UsuariosEvent {
  const UsuariosCreateRequested(this.usuario, this.password);

  final UserEntity usuario;
  final String password;

  @override
  List<Object?> get props => <Object?>[usuario, password];
}

/// Actualizar usuario existente
class UsuariosUpdateRequested extends UsuariosEvent {
  const UsuariosUpdateRequested(this.usuario);

  final UserEntity usuario;

  @override
  List<Object?> get props => <Object?>[usuario];
}

/// Eliminar usuario
class UsuariosDeleteRequested extends UsuariosEvent {
  const UsuariosDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Resetear contraseña de usuario
class UsuariosResetPasswordRequested extends UsuariosEvent {
  const UsuariosResetPasswordRequested(this.userId, this.newPassword);

  final String userId;
  final String newPassword;

  @override
  List<Object?> get props => <Object?>[userId, newPassword];
}

/// Cambiar estado activo/inactivo de usuario
class UsuariosCambiarEstadoRequested extends UsuariosEvent {
  const UsuariosCambiarEstadoRequested(this.id, {required this.activo});

  final String id;
  final bool activo;

  @override
  List<Object?> get props => <Object?>[id, activo];
}
