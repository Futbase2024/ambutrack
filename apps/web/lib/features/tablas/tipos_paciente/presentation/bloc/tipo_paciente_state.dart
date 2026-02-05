import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de tipos de paciente
abstract class TipoPacienteState extends Equatable {
  const TipoPacienteState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class TipoPacienteInitial extends TipoPacienteState {
  const TipoPacienteInitial();
}

/// Estado de carga
class TipoPacienteLoading extends TipoPacienteState {
  const TipoPacienteLoading();
}

/// Estado cuando los datos están cargados
class TipoPacienteLoaded extends TipoPacienteState {
  const TipoPacienteLoaded(this.tiposPaciente);

  final List<TipoPacienteEntity> tiposPaciente;

  @override
  List<Object?> get props => <Object?>[tiposPaciente];
}

/// Estado de error
class TipoPacienteError extends TipoPacienteState {
  const TipoPacienteError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
