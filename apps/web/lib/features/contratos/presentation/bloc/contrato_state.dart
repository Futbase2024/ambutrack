import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de contratos
abstract class ContratoState extends Equatable {
  const ContratoState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class ContratoInitial extends ContratoState {
  const ContratoInitial();
}

/// Estado de carga
class ContratoLoading extends ContratoState {
  const ContratoLoading();
}

/// Estado de éxito con lista de contratos
class ContratoLoaded extends ContratoState {

  const ContratoLoaded(this.contratos);
  final List<ContratoEntity> contratos;

  @override
  List<Object?> get props => <Object?>[contratos];
}

/// Estado de error
class ContratoError extends ContratoState {

  const ContratoError(this.message);
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de operación exitosa (crear, actualizar, eliminar)
class ContratoOperationSuccess extends ContratoState {

  const ContratoOperationSuccess(this.message, this.contratos);
  final String message;
  final List<ContratoEntity> contratos;

  @override
  List<Object?> get props => <Object?>[message, contratos];
}
