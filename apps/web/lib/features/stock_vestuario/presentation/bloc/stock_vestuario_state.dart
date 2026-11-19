import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Stock Vestuario
abstract class StockVestuarioState extends Equatable {
  const StockVestuarioState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class StockVestuarioInitial extends StockVestuarioState {
  const StockVestuarioInitial();
}

/// Estado de carga
class StockVestuarioLoading extends StockVestuarioState {
  const StockVestuarioLoading();
}

/// Estado de éxito con datos cargados
class StockVestuarioLoaded extends StockVestuarioState {
  const StockVestuarioLoaded(this.items);

  final List<StockVestuarioEntity> items;

  @override
  List<Object?> get props => <Object?>[items];
}

/// Estado de error
class StockVestuarioError extends StockVestuarioState {
  const StockVestuarioError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
