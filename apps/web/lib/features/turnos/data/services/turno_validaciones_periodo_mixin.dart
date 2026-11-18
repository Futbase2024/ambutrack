import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/validation_result_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/services/turno_validation_service.dart';

/// Validaciones por periodo (horas semanales/mensuales y descanso semanal),
/// separadas de `TurnoValidationServiceImpl` para mantener el tamaño del archivo.
mixin TurnoValidacionesPeriodo implements TurnoValidationService {
  @override
  ValidationResult validateHorasSemanales({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentes,
    double? horasMaximasSemanales,
  }) {
    // Si no hay límite (null = sin límite), no validar
    if (horasMaximasSemanales == null) {
      return ValidationResult.empty();
    }

    // Calcular inicio de la semana (lunes)
    final DateTime inicioSemana = turnoNuevo.fechaInicio.subtract(
      Duration(days: turnoNuevo.fechaInicio.weekday - 1),
    );
    final DateTime finSemana = inicioSemana.add(const Duration(days: 7));

    // Filtrar turnos de esta semana
    final List<TurnoEntity> turnosSemana = turnosExistentes
        .where(
          (TurnoEntity t) =>
              t.fechaInicio.isAfter(inicioSemana) &&
              t.fechaInicio.isBefore(finSemana),
        )
        .toList();

    final double horasTrabajadas = calcularHorasTrabajadas(
      turnos: <TurnoEntity>[...turnosSemana, turnoNuevo],
      fechaInicio: inicioSemana,
      fechaFin: finSemana,
    );

    if (horasTrabajadas > horasMaximasSemanales) {
      return ValidationResult.error(
        ValidationIssue(
          ruleType: ValidationRuleType.excesoHorasSemanales,
          severity: ValidationSeverity.warning,
          message:
              'Exceso de horas semanales (${horasTrabajadas.toStringAsFixed(1)}h / $horasMaximasSemanales h)',
          details: 'El convenio establece un máximo de $horasMaximasSemanales horas semanales',
          suggestedAction: 'Reduce la carga horaria o distribuye en otra semana',
        ),
      );
    }

    return ValidationResult.empty();
  }

  @override
  ValidationResult validateHorasMensuales({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentes,
    double? horasMaximasMensuales,
  }) {
    // Si no hay límite (null = sin límite), no validar
    if (horasMaximasMensuales == null) {
      return ValidationResult.empty();
    }

    // Primer y último día del mes
    final DateTime inicioMes = DateTime(
      turnoNuevo.fechaInicio.year,
      turnoNuevo.fechaInicio.month,
    );
    final DateTime finMes = DateTime(
      turnoNuevo.fechaInicio.year,
      turnoNuevo.fechaInicio.month + 1,
    );

    // Filtrar turnos de este mes
    final List<TurnoEntity> turnosMes = turnosExistentes
        .where(
          (TurnoEntity t) =>
              t.fechaInicio.isAfter(inicioMes) &&
              t.fechaInicio.isBefore(finMes),
        )
        .toList();

    final double horasTrabajadas = calcularHorasTrabajadas(
      turnos: <TurnoEntity>[...turnosMes, turnoNuevo],
      fechaInicio: inicioMes,
      fechaFin: finMes,
    );

    if (horasTrabajadas > horasMaximasMensuales) {
      return ValidationResult.error(
        ValidationIssue(
          ruleType: ValidationRuleType.excesoHorasMensuales,
          severity: ValidationSeverity.warning,
          message:
              'Exceso de horas mensuales (${horasTrabajadas.toStringAsFixed(1)}h / $horasMaximasMensuales h)',
          details: 'El convenio establece un máximo de $horasMaximasMensuales horas mensuales',
          suggestedAction: 'Reduce la carga horaria o distribuye en otro mes',
        ),
      );
    }

    return ValidationResult.empty();
  }

  @override
  ValidationResult validateDescansoSemanal({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentes,
    required int diasDescansoSemanal,
  }) {
    // Calcular inicio de la semana
    final DateTime inicioSemana = turnoNuevo.fechaInicio.subtract(
      Duration(days: turnoNuevo.fechaInicio.weekday - 1),
    );
    final DateTime finSemana = inicioSemana.add(const Duration(days: 7));

    // Filtrar turnos de esta semana
    final List<TurnoEntity> turnosSemana = turnosExistentes
        .where(
          (TurnoEntity t) =>
              t.fechaInicio.isAfter(inicioSemana) &&
              t.fechaInicio.isBefore(finSemana),
        )
        .toList();

    // Contar días únicos con turno
    final Set<int> diasConTurno = <int>{
      ...turnosSemana.map((TurnoEntity t) => t.fechaInicio.day),
      turnoNuevo.fechaInicio.day,
    };

    final int diasTrabajados = diasConTurno.length;
    final int diasLibres = 7 - diasTrabajados;

    if (diasLibres < diasDescansoSemanal) {
      return ValidationResult.error(
        ValidationIssue(
          ruleType: ValidationRuleType.faltaDescansoSemanal,
          severity: ValidationSeverity.warning,
          message: 'Falta descanso semanal obligatorio',
          details:
              'Trabaja $diasTrabajados días esta semana, quedan solo $diasLibres días libres (mínimo: $diasDescansoSemanal)',
          suggestedAction: 'Asegura al menos $diasDescansoSemanal día(s) de descanso por semana',
        ),
      );
    }

    return ValidationResult.empty();
  }
}
