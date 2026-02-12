// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource, StockDataSourceFactory;
import 'package:equatable/equatable.dart';

/// Estados del MantenimientoElectromedicinaBloc
abstract class MantenimientoElectromedicinaState extends Equatable {
  const MantenimientoElectromedicinaState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class MantenimientoElectromedicinaInitial extends MantenimientoElectromedicinaState {
  const MantenimientoElectromedicinaInitial();
}

/// Estado de carga
class MantenimientoElectromedicinaLoading extends MantenimientoElectromedicinaState {
  const MantenimientoElectromedicinaLoading();
}

/// Estado de datos cargados
class MantenimientoElectromedicinaLoaded extends MantenimientoElectromedicinaState {
  const MantenimientoElectromedicinaLoaded(this.mantenimientos);

  final List<MantenimientoElectromedicinaEntity> mantenimientos;

  @override
  List<Object?> get props => <Object?>[mantenimientos];
}

/// Estado de error
class MantenimientoElectromedicinaError extends MantenimientoElectromedicinaState {
  const MantenimientoElectromedicinaError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de operación en progreso
class MantenimientoElectromedicinaOperationInProgress extends MantenimientoElectromedicinaState {
  const MantenimientoElectromedicinaOperationInProgress();
}

/// Estado de operación completada exitosamente
class MantenimientoElectromedicinaOperationSuccess extends MantenimientoElectromedicinaState {
  const MantenimientoElectromedicinaOperationSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
