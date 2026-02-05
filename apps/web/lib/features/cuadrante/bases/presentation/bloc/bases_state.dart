import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Bases
abstract class BasesState extends Equatable {
  const BasesState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class BasesInitial extends BasesState {
  const BasesInitial();
}

/// Estado de carga
class BasesLoading extends BasesState {
  const BasesLoading();
}

/// Estado de datos cargados
class BasesLoaded extends BasesState {
  const BasesLoaded(this.bases);

  final List<BaseCentroEntity> bases;

  @override
  List<Object?> get props => <Object?>[bases];
}

/// Estado de error
class BasesError extends BasesState {
  const BasesError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de operación exitosa (crear, actualizar, eliminar)
class BaseOperationSuccess extends BasesState {
  const BaseOperationSuccess(this.message, this.bases);

  final String message;
  final List<BaseCentroEntity> bases;

  @override
  List<Object?> get props => <Object?>[message, bases];
}

/// Estado de verificación de código
class BaseCodigoVerified extends BasesState {
  // ignore: avoid_positional_boolean_parameters
  const BaseCodigoVerified(this.codigo, this.isAvailable);

  final String codigo;
  final bool isAvailable;

  @override
  List<Object?> get props => <Object?>[codigo, isAvailable];
}

/// Estado de base encontrada por código
class BaseFoundByCodigo extends BasesState {
  const BaseFoundByCodigo(this.base);

  final BaseCentroEntity? base;

  @override
  List<Object?> get props => <Object?>[base];
}
