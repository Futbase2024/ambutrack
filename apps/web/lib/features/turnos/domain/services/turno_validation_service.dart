import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/personal/domain/entities/configuracion_validacion_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/validation_result_entity.dart';

/// Servicio de validación de turnos
abstract class TurnoValidationService {
  /// Valida un turno antes de crearlo o actualizarlo
  ///
  /// Parámetros:
  /// - [turnoNuevo]: El turno que se quiere crear/actualizar
  /// - [idPersonal]: ID del personal al que se asigna
  /// - [turnosExistentes]: Lista de turnos ya asignados a ese personal
  /// - [configuracion]: Configuración de validaciones del personal (opcional)
  ///   Si no se proporciona, usa configuración estándar
  ///
  /// Retorna [ValidationResult] con errores, advertencias e información
  Future<ValidationResult> validateTurno({
    required TurnoEntity turnoNuevo,
    required String idPersonal,
    required List<TurnoEntity> turnosExistentes,
    ConfiguracionValidacionEntity? configuracion,
  });

  /// Valida si hay solapamiento de turnos
  ///
  /// Detecta si el turno nuevo se solapa en horario con algún turno existente.
  /// Permite múltiples turnos en el mismo día si NO se solapan.
  ///
  /// Si [permitirDobleTurno] es true, no valida solapamientos.
  ValidationResult validateDobleTurno({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentes,
    bool permitirDobleTurno = false,
  });

  /// Valida exceso de horas sin descanso
  ///
  /// Si [horasMaximasSinDescanso] es null, no hay límite
  ValidationResult validateExcesoHorasSinDescanso({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentes,
    double? horasMaximasSinDescanso,
  });

  /// Valida descanso mínimo entre turnos
  ValidationResult validateDescansoEntreTurnos({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentes,
    required double horasMinimasDescanso,
  });

  /// Valida exceso de horas semanales
  ///
  /// Si [horasMaximasSemanales] es null, no hay límite
  ValidationResult validateHorasSemanales({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentes,
    double? horasMaximasSemanales,
  });

  /// Valida exceso de horas mensuales
  ///
  /// Si [horasMaximasMensuales] es null, no hay límite
  ValidationResult validateHorasMensuales({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentes,
    double? horasMaximasMensuales,
  });

  /// Valida descanso semanal obligatorio
  ValidationResult validateDescansoSemanal({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentes,
    required int diasDescansoSemanal,
  });

  /// Valida cruce con ausencias registradas
  ///
  // TODO(dev): Integrar con módulo de ausencias cuando esté disponible
  Future<ValidationResult> validateCruceConAusencias({
    required TurnoEntity turnoNuevo,
    required String idPersonal,
  });

  /// Calcula horas trabajadas en un rango de fechas
  double calcularHorasTrabajadas({
    required List<TurnoEntity> turnos,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });
}
