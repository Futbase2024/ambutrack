import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del VehiculoAsignadoBloc
sealed class VehiculoAsignadoState extends Equatable {
  const VehiculoAsignadoState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class VehiculoAsignadoInitial extends VehiculoAsignadoState {
  const VehiculoAsignadoInitial();
}

/// Estado de carga
class VehiculoAsignadoLoading extends VehiculoAsignadoState {
  const VehiculoAsignadoLoading();
}

/// Estado de éxito con vehículo cargado
class VehiculoAsignadoLoaded extends VehiculoAsignadoState {
  const VehiculoAsignadoLoaded({
    required this.vehiculo,
    required this.turno,
  });

  final VehiculoEntity vehiculo;
  final TurnoEntity turno;

  @override
  List<Object?> get props => [vehiculo, turno];
}

/// Estado cuando no hay vehículo asignado
class VehiculoAsignadoEmpty extends VehiculoAsignadoState {
  const VehiculoAsignadoEmpty();
}

/// Estado de error
class VehiculoAsignadoError extends VehiculoAsignadoState {
  const VehiculoAsignadoError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
