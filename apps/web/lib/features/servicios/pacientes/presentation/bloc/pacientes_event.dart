import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Pacientes
abstract class PacientesEvent extends Equatable {
  const PacientesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento: Cargar todos los pacientes
class PacientesLoadRequested extends PacientesEvent {
  const PacientesLoadRequested();
}

/// Evento: Buscar pacientes por query
class PacientesSearchRequested extends PacientesEvent {
  const PacientesSearchRequested(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

/// Evento: Crear un nuevo paciente
class PacientesCreateRequested extends PacientesEvent {
  const PacientesCreateRequested(this.paciente);

  final PacienteEntity paciente;

  @override
  List<Object?> get props => <Object?>[paciente];
}

/// Evento: Actualizar un paciente existente
class PacientesUpdateRequested extends PacientesEvent {
  const PacientesUpdateRequested(this.paciente);

  final PacienteEntity paciente;

  @override
  List<Object?> get props => <Object?>[paciente];
}

/// Evento: Eliminar un paciente
class PacientesDeleteRequested extends PacientesEvent {
  const PacientesDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
