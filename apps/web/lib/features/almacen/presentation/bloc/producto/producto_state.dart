// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del ProductoBloc
abstract class ProductoState extends Equatable {
  const ProductoState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class ProductoInitial extends ProductoState {
  const ProductoInitial();
}

/// Estado de carga
class ProductoLoading extends ProductoState {
  const ProductoLoading();
}

/// Estado de datos cargados
class ProductoLoaded extends ProductoState {
  const ProductoLoaded(this.productos);

  final List<ProductoEntity> productos;

  @override
  List<Object?> get props => <Object?>[productos];
}

/// Estado de error
class ProductoError extends ProductoState {
  const ProductoError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de operación en progreso (crear/actualizar/eliminar)
class ProductoOperationInProgress extends ProductoState {
  const ProductoOperationInProgress();
}

/// Estado de operación completada exitosamente
class ProductoOperationSuccess extends ProductoState {
  const ProductoOperationSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
