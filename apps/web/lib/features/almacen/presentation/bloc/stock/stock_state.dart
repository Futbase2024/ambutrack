// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource, StockDataSourceFactory;
import 'package:ambutrack_core_datasource/src/datasources/almacen/entities/stock_entity.dart';
import 'package:equatable/equatable.dart';

/// Estados del StockBloc (sistema simplificado)
abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class StockInitial extends StockState {
  const StockInitial();
}

/// Estado de carga
class StockLoading extends StockState {
  const StockLoading();
}

/// Estado de datos cargados
class StockLoaded extends StockState {
  const StockLoaded(this.stocks, {this.isLoading = false});

  final List<StockEntity> stocks;
  final bool isLoading;

  /// Alias para compatibilidad con código legacy
  List<StockEntity> get stock => stocks;

  @override
  List<Object?> get props => <Object?>[stocks, isLoading];
}

/// Estado de error
class StockError extends StockState {
  const StockError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de operación en progreso (crear/actualizar/eliminar)
class StockOperationInProgress extends StockState {
  const StockOperationInProgress();
}

/// Estado de operación completada exitosamente
class StockOperationSuccess extends StockState {
  const StockOperationSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
