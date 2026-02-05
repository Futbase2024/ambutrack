import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de tipos de traslado
abstract class TipoTrasladoEvent extends Equatable {
  const TipoTrasladoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todos los tipos de traslado
class TipoTrasladoLoadRequested extends TipoTrasladoEvent {
  const TipoTrasladoLoadRequested();
}

/// Solicita crear un nuevo tipo de traslado
class TipoTrasladoCreateRequested extends TipoTrasladoEvent {
  const TipoTrasladoCreateRequested(this.tipo);

  final TipoTrasladoEntity tipo;

  @override
  List<Object?> get props => <Object?>[tipo];
}

/// Solicita actualizar un tipo de traslado existente
class TipoTrasladoUpdateRequested extends TipoTrasladoEvent {
  const TipoTrasladoUpdateRequested(this.tipo);

  final TipoTrasladoEntity tipo;

  @override
  List<Object?> get props => <Object?>[tipo];
}

/// Solicita eliminar un tipo de traslado
class TipoTrasladoDeleteRequested extends TipoTrasladoEvent {
  const TipoTrasladoDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
