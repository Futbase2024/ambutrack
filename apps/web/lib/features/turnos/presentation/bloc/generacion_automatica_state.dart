import 'package:ambutrack_web/features/turnos/domain/entities/resultado_generacion_entity.dart';
import 'package:equatable/equatable.dart';

abstract class GeneracionAutomaticaState extends Equatable {
  const GeneracionAutomaticaState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class GeneracionAutomaticaInitial extends GeneracionAutomaticaState {
  const GeneracionAutomaticaInitial();
}

/// Generando cuadrante
class GeneracionAutomaticaGenerando extends GeneracionAutomaticaState {
  const GeneracionAutomaticaGenerando();
}

/// Generación completada (pendiente de confirmación)
class GeneracionAutomaticaCompletada extends GeneracionAutomaticaState {
  const GeneracionAutomaticaCompletada(this.resultado);

  final ResultadoGeneracionEntity resultado;

  @override
  List<Object?> get props => <Object?>[resultado];
}

/// Guardando turnos confirmados
class GeneracionAutomaticaGuardando extends GeneracionAutomaticaState {
  const GeneracionAutomaticaGuardando();
}

/// Turnos guardados exitosamente
class GeneracionAutomaticaGuardada extends GeneracionAutomaticaState {
  const GeneracionAutomaticaGuardada(this.totalTurnosGuardados);

  final int totalTurnosGuardados;

  @override
  List<Object?> get props => <Object?>[totalTurnosGuardados];
}

/// Error durante generación o guardado
class GeneracionAutomaticaError extends GeneracionAutomaticaState {
  const GeneracionAutomaticaError(this.mensaje);

  final String mensaje;

  @override
  List<Object?> get props => <Object?>[mensaje];
}
