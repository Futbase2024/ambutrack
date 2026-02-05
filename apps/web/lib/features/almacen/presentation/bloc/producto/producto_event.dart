// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos para el ProductoBloc
abstract class ProductoEvent extends Equatable {
  const ProductoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todos los productos
class ProductoLoadAllRequested extends ProductoEvent {
  const ProductoLoadAllRequested();
}

/// Solicita cargar productos por categoría
class ProductoLoadByCategoriaRequested extends ProductoEvent {
  const ProductoLoadByCategoriaRequested(this.categoria);

  final CategoriaProducto categoria;

  @override
  List<Object?> get props => <Object?>[categoria];
}

/// Solicita buscar productos
class ProductoSearchRequested extends ProductoEvent {
  const ProductoSearchRequested(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

/// Solicita crear un producto
class ProductoCreateRequested extends ProductoEvent {
  const ProductoCreateRequested(this.producto);

  final ProductoEntity producto;

  @override
  List<Object?> get props => <Object?>[producto];
}

/// Solicita actualizar un producto
class ProductoUpdateRequested extends ProductoEvent {
  const ProductoUpdateRequested(this.producto);

  final ProductoEntity producto;

  @override
  List<Object?> get props => <Object?>[producto];
}

/// Solicita eliminar un producto
class ProductoDeleteRequested extends ProductoEvent {
  const ProductoDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Solicita suscribirse a cambios en tiempo real
class ProductoWatchAllRequested extends ProductoEvent {
  const ProductoWatchAllRequested();
}

/// Solicita suscribirse a cambios por categoría
class ProductoWatchByCategoriaRequested extends ProductoEvent {
  const ProductoWatchByCategoriaRequested(this.categoria);

  final CategoriaProducto categoria;

  @override
  List<Object?> get props => <Object?>[categoria];
}
