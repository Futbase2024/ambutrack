import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Pacientes
abstract class PacientesState extends Equatable {
  const PacientesState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class PacientesInitial extends PacientesState {
  const PacientesInitial();
}

/// Estado de carga
class PacientesLoading extends PacientesState {
  const PacientesLoading();
}

/// Estado de éxito con datos cargados
class PacientesLoaded extends PacientesState {
  const PacientesLoaded(this.pacientes);

  final List<PacienteEntity> pacientes;

  @override
  List<Object?> get props => <Object?>[pacientes];
}

/// Estado de error
class PacientesError extends PacientesState {
  const PacientesError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
