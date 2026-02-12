import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del MantenimientoBloc
abstract class MantenimientoEvent extends Equatable {
  const MantenimientoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todos los mantenimientos
class MantenimientoLoadRequested extends MantenimientoEvent {
  const MantenimientoLoadRequested();
}

/// Evento para cargar mantenimientos por vehículo
class MantenimientoLoadByVehiculoRequested extends MantenimientoEvent {
  const MantenimientoLoadByVehiculoRequested({required this.vehiculoId});

  final String vehiculoId;

  @override
  List<Object?> get props => <Object?>[vehiculoId];
}

/// Evento para crear un nuevo mantenimiento
class MantenimientoCreateRequested extends MantenimientoEvent {
  const MantenimientoCreateRequested({required this.mantenimiento});

  final MantenimientoEntity mantenimiento;

  @override
  List<Object?> get props => <Object?>[mantenimiento];
}

/// Evento para actualizar un mantenimiento
class MantenimientoUpdateRequested extends MantenimientoEvent {
  const MantenimientoUpdateRequested({required this.mantenimiento});

  final MantenimientoEntity mantenimiento;

  @override
  List<Object?> get props => <Object?>[mantenimiento];
}

/// Evento para eliminar un mantenimiento
class MantenimientoDeleteRequested extends MantenimientoEvent {
  const MantenimientoDeleteRequested({required this.id});

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Evento para cargar mantenimientos próximos
class MantenimientoLoadProximosRequested extends MantenimientoEvent {
  const MantenimientoLoadProximosRequested({this.dias = 30});

  final int dias;

  @override
  List<Object?> get props => <Object?>[dias];
}

/// Evento para cargar mantenimientos vencidos
class MantenimientoLoadVencidosRequested extends MantenimientoEvent {
  const MantenimientoLoadVencidosRequested();
}
