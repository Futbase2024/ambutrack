import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de localidades
abstract class LocalidadState extends Equatable {
  const LocalidadState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class LocalidadInitial extends LocalidadState {
  const LocalidadInitial();
}

/// Estado de carga
class LocalidadLoading extends LocalidadState {
  const LocalidadLoading();
}

/// Estado de localidades cargadas
class LocalidadLoaded extends LocalidadState {
  const LocalidadLoaded(this.localidades);

  final List<LocalidadEntity> localidades;

  @override
  List<Object?> get props => <Object?>[localidades];
}

/// Estado de creación
class LocalidadCreating extends LocalidadState {
  const LocalidadCreating();
}

/// Estado de creación exitosa
class LocalidadCreated extends LocalidadState {
  const LocalidadCreated(this.localidad);

  final LocalidadEntity localidad;

  @override
  List<Object?> get props => <Object?>[localidad];
}

/// Estado de actualización
class LocalidadUpdating extends LocalidadState {
  const LocalidadUpdating();
}

/// Estado de actualización exitosa
class LocalidadUpdated extends LocalidadState {
  const LocalidadUpdated(this.localidad);

  final LocalidadEntity localidad;

  @override
  List<Object?> get props => <Object?>[localidad];
}

/// Estado de eliminación
class LocalidadDeleting extends LocalidadState {
  const LocalidadDeleting();
}

/// Estado de eliminación exitosa
class LocalidadDeleted extends LocalidadState {
  const LocalidadDeleted();
}

/// Estado de error
class LocalidadError extends LocalidadState {
  const LocalidadError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
