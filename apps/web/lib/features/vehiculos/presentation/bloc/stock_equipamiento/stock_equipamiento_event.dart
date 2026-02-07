import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Stock de Equipamiento de Vehículos
abstract class StockEquipamientoEvent extends Equatable {
  const StockEquipamientoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar el stock de todos los vehículos
class StockEquipamientoLoadRequested extends StockEquipamientoEvent {
  const StockEquipamientoLoadRequested();
}

/// Evento para refrescar los datos
class StockEquipamientoRefreshRequested extends StockEquipamientoEvent {
  const StockEquipamientoRefreshRequested();
}

/// Evento cuando se actualiza el stock de un vehículo específico
class StockEquipamientoVehiculoUpdated extends StockEquipamientoEvent {
  const StockEquipamientoVehiculoUpdated({required this.vehiculoId});

  /// ID del vehículo cuyo stock se actualizó
  final String vehiculoId;

  @override
  List<Object?> get props => <Object?>[vehiculoId];
}
