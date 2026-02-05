import 'package:equatable/equatable.dart';
import 'package:ambutrack_core/ambutrack_core.dart';

/// Estados del RegistroHorarioBloc
sealed class RegistroHorarioState extends Equatable {
  const RegistroHorarioState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - Cargando datos
class RegistroHorarioInitial extends RegistroHorarioState {
  const RegistroHorarioInitial();
}

/// Estado con datos cargados
class RegistroHorarioLoaded extends RegistroHorarioState {
  const RegistroHorarioLoaded({
    this.ultimoRegistro,
    required this.historial,
    required this.estadoActual,
  });

  final RegistroHorarioEntity? ultimoRegistro;
  final List<RegistroHorarioEntity> historial;
  final EstadoFichaje estadoActual;

  @override
  List<Object?> get props => [ultimoRegistro, historial, estadoActual];
}

/// Estado procesando fichaje
class RegistroHorarioFichando extends RegistroHorarioState {
  const RegistroHorarioFichando();
}

/// Estado de fichaje exitoso (temporal)
class RegistroHorarioSuccess extends RegistroHorarioState {
  const RegistroHorarioSuccess(this.mensaje);

  final String mensaje;

  @override
  List<Object?> get props => [mensaje];
}

/// Estado de error
class RegistroHorarioError extends RegistroHorarioState {
  const RegistroHorarioError(this.mensaje);

  final String mensaje;

  @override
  List<Object?> get props => [mensaje];
}

/// Enum para el estado actual del personal (dentro/fuera)
enum EstadoFichaje {
  fuera, // No ha fichado entrada o ya fichó salida
  dentro, // Ha fichado entrada y no ha fichado salida
}
