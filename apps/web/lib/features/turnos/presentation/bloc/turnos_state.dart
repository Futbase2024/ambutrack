import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/validation_result_entity.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Turnos
abstract class TurnosState extends Equatable {
  const TurnosState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class TurnosInitial extends TurnosState {
  const TurnosInitial();
}

/// Estado de carga
class TurnosLoading extends TurnosState {
  const TurnosLoading();
}

/// Estado de turnos cargados exitosamente
class TurnosLoaded extends TurnosState {
  const TurnosLoaded(this.turnos);

  final List<TurnoEntity> turnos;

  @override
  List<Object?> get props => <Object?>[turnos];
}

/// Estado de error
class TurnosError extends TurnosState {
  const TurnosError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de conflicto detectado
class TurnosConflictDetected extends TurnosState {
  const TurnosConflictDetected({
    required this.hasConflict,
    this.conflictingTurnos,
  });

  final bool hasConflict;
  final List<TurnoEntity>? conflictingTurnos;

  @override
  List<Object?> get props => <Object?>[hasConflict, conflictingTurnos];
}

/// Estado de operación exitosa (crear/actualizar/eliminar)
class TurnosOperationSuccess extends TurnosState {
  const TurnosOperationSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado cuando se crea un turno exitosamente
class TurnoCreated extends TurnosState {
  const TurnoCreated(this.turno);

  final TurnoEntity turno;

  @override
  List<Object?> get props => <Object?>[turno];
}

/// Estado cuando se actualiza un turno exitosamente
class TurnoUpdated extends TurnosState {
  const TurnoUpdated(this.turno);

  final TurnoEntity turno;

  @override
  List<Object?> get props => <Object?>[turno];
}

/// Estado cuando se elimina un turno exitosamente
class TurnoDeleted extends TurnosState {
  const TurnoDeleted(this.turnoId);

  final String turnoId;

  @override
  List<Object?> get props => <Object?>[turnoId];
}

/// Estado cuando la validación falla con errores críticos
class TurnosValidationFailed extends TurnosState {
  const TurnosValidationFailed(this.validationResult);

  final ValidationResult validationResult;

  @override
  List<Object?> get props => <Object?>[validationResult];
}

/// Estado cuando hay advertencias de validación (no críticas)
class TurnosValidationWarnings extends TurnosState {
  const TurnosValidationWarnings(this.validationResult);

  final ValidationResult validationResult;

  @override
  List<Object?> get props => <Object?>[validationResult];
}
