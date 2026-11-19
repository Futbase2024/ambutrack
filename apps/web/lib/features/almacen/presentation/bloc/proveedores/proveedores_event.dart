import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource, StockDataSourceFactory;
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Proveedores
abstract class ProveedoresEvent extends Equatable {
  const ProveedoresEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todos los proveedores
class ProveedoresLoadRequested extends ProveedoresEvent {
  const ProveedoresLoadRequested();
}

/// Evento para crear un nuevo proveedor
class ProveedorCreateRequested extends ProveedoresEvent {
  const ProveedorCreateRequested(this.proveedor);

  final ProveedorEntity proveedor;

  @override
  List<Object?> get props => <Object?>[proveedor];
}

/// Evento para actualizar un proveedor existente
class ProveedorUpdateRequested extends ProveedoresEvent {
  const ProveedorUpdateRequested(this.proveedor);

  final ProveedorEntity proveedor;

  @override
  List<Object?> get props => <Object?>[proveedor];
}

/// Evento para eliminar (desactivar) un proveedor
class ProveedorDeleteRequested extends ProveedoresEvent {
  const ProveedorDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Evento para buscar proveedores por texto
class ProveedoresSearchRequested extends ProveedoresEvent {
  const ProveedoresSearchRequested(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

/// Evento para limpiar la búsqueda y recargar todos
class ProveedoresSearchCleared extends ProveedoresEvent {
  const ProveedoresSearchCleared();
}
