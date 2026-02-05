import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de tipos de vehículo
abstract class TipoVehiculoEvent extends Equatable {
  const TipoVehiculoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todos los tipos de vehículo
class TipoVehiculoLoadAllRequested extends TipoVehiculoEvent {
  const TipoVehiculoLoadAllRequested();
}

/// Evento para crear un tipo de vehículo
class TipoVehiculoCreateRequested extends TipoVehiculoEvent {
  const TipoVehiculoCreateRequested(this.tipoVehiculo);

  final TipoVehiculoEntity tipoVehiculo;

  @override
  List<Object?> get props => <Object?>[tipoVehiculo];
}

/// Evento para actualizar un tipo de vehículo
class TipoVehiculoUpdateRequested extends TipoVehiculoEvent {
  const TipoVehiculoUpdateRequested(this.tipoVehiculo);

  final TipoVehiculoEntity tipoVehiculo;

  @override
  List<Object?> get props => <Object?>[tipoVehiculo];
}

/// Evento para eliminar un tipo de vehículo
class TipoVehiculoDeleteRequested extends TipoVehiculoEvent {
  const TipoVehiculoDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
