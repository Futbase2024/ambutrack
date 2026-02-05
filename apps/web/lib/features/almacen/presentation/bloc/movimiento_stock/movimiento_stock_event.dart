// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos para el MovimientoStockBloc
abstract class MovimientoStockEvent extends Equatable {
  const MovimientoStockEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todos los movimientos
class MovimientoStockLoadAllRequested extends MovimientoStockEvent {
  const MovimientoStockLoadAllRequested({this.limit = 100});

  final int limit;

  @override
  List<Object?> get props => <Object?>[limit];
}

/// Solicita cargar movimientos por producto
class MovimientoStockLoadByProductoRequested extends MovimientoStockEvent {
  const MovimientoStockLoadByProductoRequested(this.productoId);

  final String productoId;

  @override
  List<Object?> get props => <Object?>[productoId];
}

/// Solicita cargar movimientos por almacén
class MovimientoStockLoadByAlmacenRequested extends MovimientoStockEvent {
  const MovimientoStockLoadByAlmacenRequested(this.almacenId);

  final String almacenId;

  @override
  List<Object?> get props => <Object?>[almacenId];
}

/// Solicita cargar movimientos por tipo
class MovimientoStockLoadByTipoRequested extends MovimientoStockEvent {
  const MovimientoStockLoadByTipoRequested(this.tipo);

  final TipoMovimientoStock tipo;

  @override
  List<Object?> get props => <Object?>[tipo];
}

/// Solicita cargar movimientos por rango de fechas
class MovimientoStockLoadByFechasRequested extends MovimientoStockEvent {
  const MovimientoStockLoadByFechasRequested({
    required this.fechaInicio,
    required this.fechaFin,
  });

  final DateTime fechaInicio;
  final DateTime fechaFin;

  @override
  List<Object?> get props => <Object?>[fechaInicio, fechaFin];
}

/// Solicita crear un movimiento
class MovimientoStockCreateRequested extends MovimientoStockEvent {
  const MovimientoStockCreateRequested(this.movimiento);

  final MovimientoStockEntity movimiento;

  @override
  List<Object?> get props => <Object?>[movimiento];
}

/// Solicita eliminar un movimiento
class MovimientoStockDeleteRequested extends MovimientoStockEvent {
  const MovimientoStockDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Solicita suscribirse a todos los movimientos en tiempo real
class MovimientoStockWatchAllRequested extends MovimientoStockEvent {
  const MovimientoStockWatchAllRequested();
}

/// Solicita suscribirse a movimientos por almacén
class MovimientoStockWatchByAlmacenRequested extends MovimientoStockEvent {
  const MovimientoStockWatchByAlmacenRequested(this.almacenId);

  final String almacenId;

  @override
  List<Object?> get props => <Object?>[almacenId];
}
