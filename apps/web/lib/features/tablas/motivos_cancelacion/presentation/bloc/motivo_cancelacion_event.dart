import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de motivos de cancelación
abstract class MotivoCancelacionEvent extends Equatable {
  const MotivoCancelacionEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todos los motivos
class MotivoCancelacionLoadRequested extends MotivoCancelacionEvent {
  const MotivoCancelacionLoadRequested();
}

/// Evento para crear un nuevo motivo
class MotivoCancelacionCreateRequested extends MotivoCancelacionEvent {
  const MotivoCancelacionCreateRequested(this.motivo);

  final MotivoCancelacionEntity motivo;

  @override
  List<Object?> get props => <Object?>[motivo];
}

/// Evento para actualizar un motivo existente
class MotivoCancelacionUpdateRequested extends MotivoCancelacionEvent {
  const MotivoCancelacionUpdateRequested(this.motivo);

  final MotivoCancelacionEntity motivo;

  @override
  List<Object?> get props => <Object?>[motivo];
}

/// Evento para eliminar un motivo
class MotivoCancelacionDeleteRequested extends MotivoCancelacionEvent {
  const MotivoCancelacionDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
