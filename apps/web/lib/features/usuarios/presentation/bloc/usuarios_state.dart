import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de usuarios
abstract class UsuariosState extends Equatable {
  const UsuariosState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class UsuariosInitial extends UsuariosState {
  const UsuariosInitial();
}

/// Cargando lista de usuarios
class UsuariosLoading extends UsuariosState {
  const UsuariosLoading();
}

/// Usuarios cargados correctamente
class UsuariosLoaded extends UsuariosState {
  const UsuariosLoaded(this.usuarios);

  final List<UserEntity> usuarios;

  @override
  List<Object?> get props => <Object?>[usuarios];
}

/// Creando usuario
class UsuariosCreating extends UsuariosState {
  const UsuariosCreating();
}

/// Usuario creado exitosamente
class UsuariosCreated extends UsuariosState {
  const UsuariosCreated(this.usuario);

  final UserEntity usuario;

  @override
  List<Object?> get props => <Object?>[usuario];
}

/// Actualizando usuario
class UsuariosUpdating extends UsuariosState {
  const UsuariosUpdating();
}

/// Usuario actualizado exitosamente
class UsuariosUpdated extends UsuariosState {
  const UsuariosUpdated(this.usuario);

  final UserEntity usuario;

  @override
  List<Object?> get props => <Object?>[usuario];
}

/// Eliminando usuario
class UsuariosDeleting extends UsuariosState {
  const UsuariosDeleting();
}

/// Usuario eliminado exitosamente
class UsuariosDeleted extends UsuariosState {
  const UsuariosDeleted();
}

/// Reseteando contraseña
class UsuariosResettingPassword extends UsuariosState {
  const UsuariosResettingPassword();
}

/// Contraseña reseteada exitosamente
class UsuariosPasswordReset extends UsuariosState {
  const UsuariosPasswordReset();
}

/// Error en alguna operación
class UsuariosError extends UsuariosState {
  const UsuariosError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
