// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del MovimientoStockBloc
abstract class MovimientoStockState extends Equatable {
  const MovimientoStockState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class MovimientoStockInitial extends MovimientoStockState {
  const MovimientoStockInitial();
}

/// Estado de carga
class MovimientoStockLoading extends MovimientoStockState {
  const MovimientoStockLoading();
}

/// Estado de datos cargados
class MovimientoStockLoaded extends MovimientoStockState {
  const MovimientoStockLoaded(this.movimientos);

  final List<MovimientoStockEntity> movimientos;

  @override
  List<Object?> get props => <Object?>[movimientos];
}

/// Estado de error
class MovimientoStockError extends MovimientoStockState {
  const MovimientoStockError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de operación en progreso
class MovimientoStockOperationInProgress extends MovimientoStockState {
  const MovimientoStockOperationInProgress();
}

/// Estado de operación completada exitosamente
class MovimientoStockOperationSuccess extends MovimientoStockState {
  const MovimientoStockOperationSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
