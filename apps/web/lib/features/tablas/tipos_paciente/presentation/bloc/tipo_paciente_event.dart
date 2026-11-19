import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de tipos de paciente
abstract class TipoPacienteEvent extends Equatable {
  const TipoPacienteEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todos los tipos de paciente
class TipoPacienteLoadRequested extends TipoPacienteEvent {
  const TipoPacienteLoadRequested();
}

/// Evento para crear un nuevo tipo de paciente
class TipoPacienteCreateRequested extends TipoPacienteEvent {
  const TipoPacienteCreateRequested(this.tipoPaciente);

  final TipoPacienteEntity tipoPaciente;

  @override
  List<Object?> get props => <Object?>[tipoPaciente];
}

/// Evento para actualizar un tipo de paciente
class TipoPacienteUpdateRequested extends TipoPacienteEvent {
  const TipoPacienteUpdateRequested(this.tipoPaciente);

  final TipoPacienteEntity tipoPaciente;

  @override
  List<Object?> get props => <Object?>[tipoPaciente];
}

/// Evento para eliminar un tipo de paciente
class TipoPacienteDeleteRequested extends TipoPacienteEvent {
  const TipoPacienteDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
