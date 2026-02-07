import 'package:equatable/equatable.dart';

/// Eventos del VehiculoAsignadoBloc
sealed class VehiculoAsignadoEvent extends Equatable {
  const VehiculoAsignadoEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar el vehículo asignado al usuario actual
class LoadVehiculoAsignado extends VehiculoAsignadoEvent {
  const LoadVehiculoAsignado();
}

/// Evento para refrescar el vehículo asignado
class RefreshVehiculoAsignado extends VehiculoAsignadoEvent {
  const RefreshVehiculoAsignado();
}
