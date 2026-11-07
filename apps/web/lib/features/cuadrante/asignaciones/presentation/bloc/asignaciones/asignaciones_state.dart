import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Asignaciones
abstract class AsignacionesState extends Equatable {
  const AsignacionesState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class AsignacionesInitial extends AsignacionesState {
  const AsignacionesInitial();
}

/// Estado de carga
class AsignacionesLoading extends AsignacionesState {
  const AsignacionesLoading();
}

/// Estado con datos cargados
class AsignacionesLoaded extends AsignacionesState {
  const AsignacionesLoaded(this.asignaciones);

  final List<AsignacionVehiculoTurnoEntity> asignaciones;

  @override
  List<Object?> get props => <Object?>[asignaciones];
}

/// Estado de error
class AsignacionesError extends AsignacionesState {
  const AsignacionesError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
