import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de vehículos
abstract class VehiculosEvent extends Equatable {
  const VehiculosEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todos los vehículos
class VehiculosLoadRequested extends VehiculosEvent {
  const VehiculosLoadRequested();
}

/// Solicita refrescar los vehículos
class VehiculosRefreshRequested extends VehiculosEvent {
  const VehiculosRefreshRequested();
}

/// Solicita suscribirse a actualizaciones en tiempo real
class VehiculosSubscribeRequested extends VehiculosEvent {
  const VehiculosSubscribeRequested();
}

/// Los vehículos se actualizaron (desde el stream de tiempo real)
class VehiculosUpdated extends VehiculosEvent {
  const VehiculosUpdated(this.vehiculos);

  final List<VehiculoEntity> vehiculos;

  @override
  List<Object?> get props => <Object?>[vehiculos];
}

/// Solicita crear un nuevo vehículo (versión con Map)
class VehiculosCreateRequested extends VehiculosEvent {
  const VehiculosCreateRequested(this.vehiculoData);

  final Map<String, dynamic> vehiculoData;

  @override
  List<Object?> get props => <Object?>[vehiculoData];
}

/// Solicita crear un nuevo vehículo (versión con Entity)
class VehiculoCreateRequested extends VehiculosEvent {
  const VehiculoCreateRequested({required this.vehiculo});

  final VehiculoEntity vehiculo;

  @override
  List<Object?> get props => <Object?>[vehiculo];
}

/// Solicita actualizar un vehículo existente
class VehiculoUpdateRequested extends VehiculosEvent {
  const VehiculoUpdateRequested({required this.vehiculo});

  final VehiculoEntity vehiculo;

  @override
  List<Object?> get props => <Object?>[vehiculo];
}

/// Solicita eliminar un vehículo
class VehiculoDeleteRequested extends VehiculosEvent {
  const VehiculoDeleteRequested({required this.vehiculoId});

  final String vehiculoId;

  @override
  List<Object?> get props => <Object?>[vehiculoId];
}
