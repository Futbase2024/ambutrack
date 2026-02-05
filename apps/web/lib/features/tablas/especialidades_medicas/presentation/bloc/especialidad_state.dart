import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de especialidades médicas
abstract class EspecialidadState extends Equatable {
  const EspecialidadState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class EspecialidadInitial extends EspecialidadState {
  const EspecialidadInitial();
}

/// Estado de carga
class EspecialidadLoading extends EspecialidadState {
  const EspecialidadLoading();
}

/// Estado de especialidades cargadas
class EspecialidadLoaded extends EspecialidadState {

  const EspecialidadLoaded(this.especialidades);
  final List<EspecialidadEntity> especialidades;

  @override
  List<Object?> get props => <Object?>[especialidades];
}

/// Estado de creación
class EspecialidadCreating extends EspecialidadState {
  const EspecialidadCreating();
}

/// Estado de actualización
class EspecialidadUpdating extends EspecialidadState {
  const EspecialidadUpdating();
}

/// Estado de eliminación
class EspecialidadDeleting extends EspecialidadState {
  const EspecialidadDeleting();
}

/// Estado de error
class EspecialidadError extends EspecialidadState {

  const EspecialidadError(this.message);
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
