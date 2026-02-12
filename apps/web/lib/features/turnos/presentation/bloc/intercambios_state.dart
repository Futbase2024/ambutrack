import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de intercambios
abstract class IntercambiosState extends Equatable {
  const IntercambiosState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class IntercambiosInitial extends IntercambiosState {
  const IntercambiosInitial();
}

/// Estado de carga
class IntercambiosLoading extends IntercambiosState {
  const IntercambiosLoading();
}

/// Estado con datos cargados
class IntercambiosLoaded extends IntercambiosState {
  const IntercambiosLoaded(this.solicitudes);

  final List<SolicitudIntercambioEntity> solicitudes;

  @override
  List<Object?> get props => <Object?>[solicitudes];
}

/// Estado de procesamiento (aprobar/rechazar/cancelar)
class IntercambiosProcessing extends IntercambiosState {
  const IntercambiosProcessing();
}

/// Estado de éxito en operación
class IntercambiosSuccess extends IntercambiosState {
  const IntercambiosSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de error
class IntercambiosError extends IntercambiosState {
  const IntercambiosError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
