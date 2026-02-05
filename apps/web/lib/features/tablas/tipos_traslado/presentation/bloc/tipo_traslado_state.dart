import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de tipos de traslado
abstract class TipoTrasladoState extends Equatable {
  const TipoTrasladoState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class TipoTrasladoInitial extends TipoTrasladoState {
  const TipoTrasladoInitial();
}

/// Estado de carga
class TipoTrasladoLoading extends TipoTrasladoState {
  const TipoTrasladoLoading();
}

/// Estado de éxito con datos cargados
class TipoTrasladoLoaded extends TipoTrasladoState {
  const TipoTrasladoLoaded(this.tipos);

  final List<TipoTrasladoEntity> tipos;

  @override
  List<Object?> get props => <Object?>[tipos];
}

/// Estado de error
class TipoTrasladoError extends TipoTrasladoState {
  const TipoTrasladoError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
