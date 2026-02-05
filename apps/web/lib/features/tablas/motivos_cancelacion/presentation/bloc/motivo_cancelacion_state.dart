import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de motivos de cancelación
abstract class MotivoCancelacionState extends Equatable {
  const MotivoCancelacionState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class MotivoCancelacionInitial extends MotivoCancelacionState {
  const MotivoCancelacionInitial();
}

/// Estado de carga
class MotivoCancelacionLoading extends MotivoCancelacionState {
  const MotivoCancelacionLoading();
}

/// Estado con datos cargados
class MotivoCancelacionLoaded extends MotivoCancelacionState {
  const MotivoCancelacionLoaded(this.motivos);

  final List<MotivoCancelacionEntity> motivos;

  @override
  List<Object?> get props => <Object?>[motivos];
}

/// Estado de error
class MotivoCancelacionError extends MotivoCancelacionState {
  const MotivoCancelacionError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
