import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:equatable/equatable.dart';

/// Estados del PermisosAccesoBloc
abstract class PermisosAccesoState extends Equatable {
  const PermisosAccesoState();

  @override
  List<Object?> get props => <Object?>[];
}

class PermisosAccesoInitial extends PermisosAccesoState {
  const PermisosAccesoInitial();
}

class PermisosAccesoLoading extends PermisosAccesoState {
  const PermisosAccesoLoading();
}

/// Usuarios cargados (la matriz de permisos se obtiene del código)
class PermisosAccesoLoaded extends PermisosAccesoState {
  const PermisosAccesoLoaded({required this.usuarios});

  final List<UserEntity> usuarios;

  /// Usuarios cuyo rol coincide con [role]
  List<UserEntity> usuariosConRol(UserRole role) => usuarios
      .where((UserEntity u) => (u.rol ?? '').toLowerCase() == role.value)
      .toList();

  /// Usuarios cuyo rol no corresponde a ningún [UserRole] conocido
  int get usuariosSinRolReconocido => usuarios.where((UserEntity u) {
        final String rol = (u.rol ?? '').toLowerCase();
        return !UserRole.values.any((UserRole r) => r.value == rol);
      }).length;

  @override
  List<Object?> get props => <Object?>[usuarios];
}

class PermisosAccesoError extends PermisosAccesoState {
  const PermisosAccesoError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
