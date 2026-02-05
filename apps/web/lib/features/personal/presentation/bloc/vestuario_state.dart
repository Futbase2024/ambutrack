import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Vestuario
abstract class VestuarioState extends Equatable {
  const VestuarioState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class VestuarioInitial extends VestuarioState {
  const VestuarioInitial();
}

/// Estado de carga
class VestuarioLoading extends VestuarioState {
  const VestuarioLoading();
}

/// Estado con datos cargados
class VestuarioLoaded extends VestuarioState {
  const VestuarioLoaded(this.items);

  final List<VestuarioEntity> items;

  @override
  List<Object?> get props => <Object?>[items];
}

/// Estado de error
class VestuarioError extends VestuarioState {
  const VestuarioError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
