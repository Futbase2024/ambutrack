import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del MulticentroBloc
abstract class MulticentroState extends Equatable {
  const MulticentroState();

  @override
  List<Object?> get props => <Object?>[];
}

class MulticentroInitial extends MulticentroState {
  const MulticentroInitial();
}

class MulticentroLoading extends MulticentroState {
  const MulticentroLoading();
}

/// Empresas cargadas junto con los usuarios (para contar usuarios por empresa)
class MulticentroLoaded extends MulticentroState {
  const MulticentroLoaded({required this.empresas, required this.usuarios});

  final List<EmpresaTenantEntity> empresas;
  final List<UserEntity> usuarios;

  /// Usuarios asignados a la empresa [empresaId]
  List<UserEntity> usuariosDe(String empresaId) =>
      usuarios.where((UserEntity u) => u.empresaId == empresaId).toList();

  /// Usuarios sin empresa asignada
  int get usuariosSinEmpresa => usuarios.where((UserEntity u) => u.empresaId == null).length;

  @override
  List<Object?> get props => <Object?>[empresas, usuarios];
}

class MulticentroError extends MulticentroState {
  const MulticentroError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
