import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de provincias
abstract class ProvinciaState extends Equatable {
  const ProvinciaState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class ProvinciaInitial extends ProvinciaState {
  const ProvinciaInitial();
}

/// Estado de carga
class ProvinciaLoading extends ProvinciaState {
  const ProvinciaLoading();
}

/// Estado de provincias cargadas
class ProvinciaLoaded extends ProvinciaState {
  const ProvinciaLoaded(this.provincias);

  final List<ProvinciaEntity> provincias;

  @override
  List<Object?> get props => <Object?>[provincias];
}

/// Estado de creación
class ProvinciaCreating extends ProvinciaState {
  const ProvinciaCreating();
}

/// Estado de creación exitosa
class ProvinciaCreated extends ProvinciaState {
  const ProvinciaCreated(this.provincia);

  final ProvinciaEntity provincia;

  @override
  List<Object?> get props => <Object?>[provincia];
}

/// Estado de actualización
class ProvinciaUpdating extends ProvinciaState {
  const ProvinciaUpdating();
}

/// Estado de actualización exitosa
class ProvinciaUpdated extends ProvinciaState {
  const ProvinciaUpdated(this.provincia);

  final ProvinciaEntity provincia;

  @override
  List<Object?> get props => <Object?>[provincia];
}

/// Estado de eliminación
class ProvinciaDeleting extends ProvinciaState {
  const ProvinciaDeleting();
}

/// Estado de eliminación exitosa
class ProvinciaDeleted extends ProvinciaState {
  const ProvinciaDeleted();
}

/// Estado de error
class ProvinciaError extends ProvinciaState {
  const ProvinciaError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
