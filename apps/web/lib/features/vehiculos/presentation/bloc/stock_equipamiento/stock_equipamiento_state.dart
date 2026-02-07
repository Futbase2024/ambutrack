import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Stock de Equipamiento de Vehículos
abstract class StockEquipamientoState extends Equatable {
  const StockEquipamientoState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class StockEquipamientoInitial extends StockEquipamientoState {
  const StockEquipamientoInitial();
}

/// Estado de carga
class StockEquipamientoLoading extends StockEquipamientoState {
  const StockEquipamientoLoading();
}

/// Estado con datos cargados
class StockEquipamientoLoaded extends StockEquipamientoState {
  const StockEquipamientoLoaded({
    required this.vehiculos,
    this.isRefreshing = false,
  });

  /// Lista de vehículos con su resumen de stock
  final List<VehiculoStockResumenEntity> vehiculos;

  /// Indica si se está refrescando en segundo plano
  final bool isRefreshing;

  /// Total de vehículos
  int get totalVehiculos => vehiculos.length;

  /// Vehículos con estado OK
  int get vehiculosOk =>
      vehiculos.where((VehiculoStockResumenEntity v) => v.estadoGeneral == EstadoStockGeneral.ok).length;

  /// Vehículos que requieren atención
  int get vehiculosAtencion =>
      vehiculos.where((VehiculoStockResumenEntity v) => v.estadoGeneral == EstadoStockGeneral.atencion).length;

  /// Vehículos en estado crítico
  int get vehiculosCritico =>
      vehiculos.where((VehiculoStockResumenEntity v) => v.estadoGeneral == EstadoStockGeneral.critico).length;

  @override
  List<Object?> get props => <Object?>[vehiculos, isRefreshing];

  /// Crea una copia con valores actualizados
  StockEquipamientoLoaded copyWith({
    List<VehiculoStockResumenEntity>? vehiculos,
    bool? isRefreshing,
  }) {
    return StockEquipamientoLoaded(
      vehiculos: vehiculos ?? this.vehiculos,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Estado de error
class StockEquipamientoError extends StockEquipamientoState {
  const StockEquipamientoError({
    required this.message,
    this.previousVehiculos,
  });

  /// Mensaje de error
  final String message;

  /// Vehículos cargados previamente (si los había)
  final List<VehiculoStockResumenEntity>? previousVehiculos;

  @override
  List<Object?> get props => <Object?>[message, previousVehiculos];
}
