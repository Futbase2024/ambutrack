import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del MantenimientoBloc
abstract class MantenimientoState extends Equatable {
  const MantenimientoState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class MantenimientoInitial extends MantenimientoState {
  const MantenimientoInitial();
}

/// Estado de carga
class MantenimientoLoading extends MantenimientoState {
  const MantenimientoLoading();
}

/// Estado con datos cargados
class MantenimientoLoaded extends MantenimientoState {
  const MantenimientoLoaded({required this.mantenimientos});

  final List<MantenimientoEntity> mantenimientos;

  @override
  List<Object?> get props => <Object?>[mantenimientos];
}

/// Estado de error
class MantenimientoError extends MantenimientoState {
  const MantenimientoError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de operación exitosa (crear/actualizar/eliminar)
class MantenimientoOperationSuccess extends MantenimientoState {
  const MantenimientoOperationSuccess({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
