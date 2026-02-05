// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos para el StockBloc (sistema simplificado)
abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todo el stock
class StockLoadAllRequested extends StockEvent {
  const StockLoadAllRequested();
}

/// Solicita cargar stock por producto
class StockLoadByProductoRequested extends StockEvent {
  const StockLoadByProductoRequested(this.productoId);

  final String productoId;

  @override
  List<Object?> get props => <Object?>[productoId];
}

/// Solicita cargar stock por almacén
class StockLoadByAlmacenRequested extends StockEvent {
  const StockLoadByAlmacenRequested(this.almacenId);

  final String almacenId;

  @override
  List<Object?> get props => <Object?>[almacenId];
}

/// Solicita cargar stock por vehículo
class StockLoadByVehiculoRequested extends StockEvent {
  const StockLoadByVehiculoRequested(this.vehiculoId);

  final String vehiculoId;

  @override
  List<Object?> get props => <Object?>[vehiculoId];
}

/// Solicita cargar stock bajo
class StockLoadBajoRequested extends StockEvent {
  const StockLoadBajoRequested(this.almacenId);

  final String almacenId;

  @override
  List<Object?> get props => <Object?>[almacenId];
}

/// Solicita crear stock
class StockCreateRequested extends StockEvent {
  const StockCreateRequested(this.stock);

  final StockEntity stock;

  @override
  List<Object?> get props => <Object?>[stock];
}

/// Solicita actualizar stock
class StockUpdateRequested extends StockEvent {
  const StockUpdateRequested(this.stock);

  final StockEntity stock;

  @override
  List<Object?> get props => <Object?>[stock];
}

/// Solicita eliminar stock
class StockDeleteRequested extends StockEvent {
  const StockDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Solicita ajustar cantidad de stock
class StockAjustarCantidadRequested extends StockEvent {
  const StockAjustarCantidadRequested({
    required this.stockId,
    required this.cantidad,
    required this.motivo,
  });

  final String stockId;
  final double cantidad;
  final String motivo;

  @override
  List<Object?> get props => <Object?>[stockId, cantidad, motivo];
}

/// Solicita transferir stock a un vehículo
class StockTransferirAVehiculoRequested extends StockEvent {
  const StockTransferirAVehiculoRequested({
    required this.stockId,
    required this.vehiculoId,
    required this.cantidad,
    required this.motivo,
    this.lote,
    this.fechaCaducidad,
  });

  final String stockId;
  final String vehiculoId;
  final double cantidad;
  final String motivo;
  final String? lote;
  final DateTime? fechaCaducidad;

  @override
  List<Object?> get props => <Object?>[
        stockId,
        vehiculoId,
        cantidad,
        motivo,
        lote,
        fechaCaducidad,
      ];
}

/// Solicita transferir stock entre almacenes
class StockTransferirEntreAlmacenesRequested extends StockEvent {
  const StockTransferirEntreAlmacenesRequested({
    required this.stockOrigenId,
    required this.almacenDestinoId,
    required this.cantidad,
    required this.motivo,
  });

  final String stockOrigenId;
  final String almacenDestinoId;
  final double cantidad;
  final String motivo;

  @override
  List<Object?> get props => <Object?>[
        stockOrigenId,
        almacenDestinoId,
        cantidad,
        motivo,
      ];
}

/// Solicita suscribirse a cambios en todo el stock
class StockWatchAllRequested extends StockEvent {
  const StockWatchAllRequested();
}

/// Solicita suscribirse a cambios por almacén
class StockWatchByAlmacenRequested extends StockEvent {
  const StockWatchByAlmacenRequested(this.almacenId);

  final String almacenId;

  @override
  List<Object?> get props => <Object?>[almacenId];
}

/// Solicita suscribirse a cambios por vehículo
class StockWatchByVehiculoRequested extends StockEvent {
  const StockWatchByVehiculoRequested(this.vehiculoId);

  final String vehiculoId;

  @override
  List<Object?> get props => <Object?>[vehiculoId];
}

// === ALIAS PARA COMPATIBILIDAD CON CÓDIGO LEGACY ===

/// Alias para StockLoadAllRequested (compatibilidad legacy)
class StockLoadRequested extends StockLoadAllRequested {
  const StockLoadRequested();
}

/// Evento para cargar stock próximo a caducar
class StockProximoACaducarLoadRequested extends StockEvent {
  const StockProximoACaducarLoadRequested({this.diasAntes = 30});

  final int diasAntes;

  @override
  List<Object?> get props => <Object?>[diasAntes];
}

/// Solicita cargar stock filtrado por categoría de producto
class StockLoadByTipoProductoRequested extends StockEvent {
  const StockLoadByTipoProductoRequested({
    required this.almacenId,
    required this.categoria,
  });

  final String almacenId;
  final CategoriaProducto categoria;

  @override
  List<Object?> get props => <Object?>[almacenId, categoria];
}
