import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de tipos de vehículo
abstract class TipoVehiculoState extends Equatable {
  const TipoVehiculoState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class TipoVehiculoInitial extends TipoVehiculoState {
  const TipoVehiculoInitial();
}

/// Estado de carga
class TipoVehiculoLoading extends TipoVehiculoState {
  const TipoVehiculoLoading();
}

/// Estado de tipos de vehículo cargados
class TipoVehiculoLoaded extends TipoVehiculoState {
  const TipoVehiculoLoaded(this.tiposVehiculo);

  final List<TipoVehiculoEntity> tiposVehiculo;

  @override
  List<Object?> get props => <Object?>[tiposVehiculo];
}

/// Estado de creación
class TipoVehiculoCreating extends TipoVehiculoState {
  const TipoVehiculoCreating();
}

/// Estado de creación exitosa
class TipoVehiculoCreated extends TipoVehiculoState {
  const TipoVehiculoCreated(this.tipoVehiculo);

  final TipoVehiculoEntity tipoVehiculo;

  @override
  List<Object?> get props => <Object?>[tipoVehiculo];
}

/// Estado de actualización
class TipoVehiculoUpdating extends TipoVehiculoState {
  const TipoVehiculoUpdating();
}

/// Estado de actualización exitosa
class TipoVehiculoUpdated extends TipoVehiculoState {
  const TipoVehiculoUpdated(this.tipoVehiculo);

  final TipoVehiculoEntity tipoVehiculo;

  @override
  List<Object?> get props => <Object?>[tipoVehiculo];
}

/// Estado de eliminación
class TipoVehiculoDeleting extends TipoVehiculoState {
  const TipoVehiculoDeleting();
}

/// Estado de eliminación exitosa
class TipoVehiculoDeleted extends TipoVehiculoState {
  const TipoVehiculoDeleted();
}

/// Estado de error
class TipoVehiculoError extends TipoVehiculoState {
  const TipoVehiculoError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
