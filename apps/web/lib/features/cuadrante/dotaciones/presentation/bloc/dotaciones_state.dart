import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Dotaciones
abstract class DotacionesState extends Equatable {
  const DotacionesState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class DotacionesInitial extends DotacionesState {
  const DotacionesInitial();
}

/// Estado de carga
class DotacionesLoading extends DotacionesState {
  const DotacionesLoading();
}

/// Estado de datos cargados
class DotacionesLoaded extends DotacionesState {
  const DotacionesLoaded(this.dotaciones);

  final List<DotacionEntity> dotaciones;

  @override
  List<Object?> get props => <Object?>[dotaciones];
}

/// Estado de error
class DotacionesError extends DotacionesState {
  const DotacionesError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de operación exitosa (crear, actualizar, eliminar)
class DotacionOperationSuccess extends DotacionesState {
  const DotacionOperationSuccess(this.message, this.dotaciones);

  final String message;
  final List<DotacionEntity> dotaciones;

  @override
  List<Object?> get props => <Object?>[message, dotaciones];
}
