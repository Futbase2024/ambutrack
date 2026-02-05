import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de Stock Vestuario
abstract class StockVestuarioEvent extends Equatable {
  const StockVestuarioEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todos los items de stock
class StockVestuarioLoadRequested extends StockVestuarioEvent {
  const StockVestuarioLoadRequested();
}

/// Solicita crear un nuevo item de stock
class StockVestuarioCreateRequested extends StockVestuarioEvent {
  const StockVestuarioCreateRequested(this.item);

  final StockVestuarioEntity item;

  @override
  List<Object?> get props => <Object?>[item];
}

/// Solicita actualizar un item de stock
class StockVestuarioUpdateRequested extends StockVestuarioEvent {
  const StockVestuarioUpdateRequested(this.item);

  final StockVestuarioEntity item;

  @override
  List<Object?> get props => <Object?>[item];
}

/// Solicita eliminar un item de stock
class StockVestuarioDeleteRequested extends StockVestuarioEvent {
  const StockVestuarioDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Solicita cargar items con stock bajo
class StockVestuarioLoadStockBajoRequested extends StockVestuarioEvent {
  const StockVestuarioLoadStockBajoRequested();
}

/// Solicita cargar items disponibles
class StockVestuarioLoadDisponiblesRequested extends StockVestuarioEvent {
  const StockVestuarioLoadDisponiblesRequested();
}

/// Solicita incrementar cantidad asignada
class StockVestuarioIncrementarAsignadaRequested extends StockVestuarioEvent {
  const StockVestuarioIncrementarAsignadaRequested(this.id, this.cantidad);

  final String id;
  final int cantidad;

  @override
  List<Object?> get props => <Object?>[id, cantidad];
}

/// Solicita decrementar cantidad asignada
class StockVestuarioDecrementarAsignadaRequested extends StockVestuarioEvent {
  const StockVestuarioDecrementarAsignadaRequested(this.id, this.cantidad);

  final String id;
  final int cantidad;

  @override
  List<Object?> get props => <Object?>[id, cantidad];
}
