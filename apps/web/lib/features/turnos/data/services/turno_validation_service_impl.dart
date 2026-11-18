import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/entities/configuracion_validacion_entity.dart';
import 'package:ambutrack_web/features/turnos/data/services/indisponibilidad_personal_loader.dart';
import 'package:ambutrack_web/features/turnos/data/services/turno_validaciones_periodo_mixin.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/validation_result_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/services/turno_ausencias_checker.dart';
import 'package:ambutrack_web/features/turnos/domain/services/turno_validation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del servicio de validación de turnos
@LazySingleton(as: TurnoValidationService)
class TurnoValidationServiceImpl with TurnoValidacionesPeriodo implements TurnoValidationService {
  /// No se inyecta por constructor para no requerir regenerar DI
  final IndisponibilidadPersonalLoader _indisponibilidadLoader = IndisponibilidadPersonalLoader();

  @override
  Future<ValidationResult> validateTurno({
    required TurnoEntity turnoNuevo,
    required String idPersonal,
    required List<TurnoEntity> turnosExistentes,
    ConfiguracionValidacionEntity? configuracion,
  }) async {
    debugPrint('🔍 Validando turno para personal: $idPersonal');

    // Usar configuración proporcionada o estándar por defecto
    final ConfiguracionValidacionEntity config =
        configuracion ?? ConfiguracionValidacionEntity.estandar();

    // Si las validaciones están desactivadas, retornar éxito inmediatamente
    if (!config.validacionesActivas) {
      debugPrint(
        '⚠️ Validaciones desactivadas para este personal. Motivo: ${config.motivoExencion}',
      );
      // Retornar validación vacía cuando las validaciones están desactivadas
      return ValidationResult.empty();
    }

    final List<ValidationResult> resultados = <ValidationResult>[
      // 1. Validar doble turno
      validateDobleTurno(
        turnoNuevo: turnoNuevo,
        turnosExistentes: turnosExistentes,
        permitirDobleTurno: config.permitirDobleTurno,
      ),
      // 2. Validar descanso entre turnos
      validateDescansoEntreTurnos(
        turnoNuevo: turnoNuevo,
        turnosExistentes: turnosExistentes,
        horasMinimasDescanso: config.horasMinimasDescanso,
      ),
    ];

    // 3. Validar horas semanales (si tiene límite)
    if (config.horasMaximasSemanales != null) {
      resultados.add(
        validateHorasSemanales(
          turnoNuevo: turnoNuevo,
          turnosExistentes: turnosExistentes,
          horasMaximasSemanales: config.horasMaximasSemanales,
        ),
      );
    }

    // 4. Validar horas mensuales (si tiene límite)
    if (config.horasMaximasMensuales != null) {
      resultados.add(
        validateHorasMensuales(
          turnoNuevo: turnoNuevo,
          turnosExistentes: turnosExistentes,
          horasMaximasMensuales: config.horasMaximasMensuales,
        ),
      );
    }

    // 5. Validar descanso semanal
    resultados.add(
      validateDescansoSemanal(
        turnoNuevo: turnoNuevo,
        turnosExistentes: turnosExistentes,
        diasDescansoSemanal: config.diasDescansoSemanalMinimo,
      ),
    );

    // 6. Validar exceso de horas sin descanso (si tiene límite)
    if (config.horasMaximasContinuas != null) {
      resultados.add(
        validateExcesoHorasSinDescanso(
          turnoNuevo: turnoNuevo,
          turnosExistentes: turnosExistentes,
          horasMaximasSinDescanso: config.horasMaximasContinuas,
        ),
      );
    }

    // 7. Validar cruce con ausencias
    resultados.add(
      await validateCruceConAusencias(
        turnoNuevo: turnoNuevo,
        idPersonal: idPersonal,
      ),
    );

    final ValidationResult resultado = ValidationResult.combine(resultados);

    if (resultado.hasErrors) {
      debugPrint('❌ Validación fallida: ${resultado.errors.length} errores');
    } else if (resultado.hasWarnings) {
      debugPrint('⚠️ Validación con advertencias: ${resultado.warnings.length}');
    } else {
      debugPrint('✅ Validación exitosa');
    }

    return resultado;
  }

  @override
  ValidationResult validateDobleTurno({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentes,
    bool permitirDobleTurno = false,
  }) {
    // Si está permitido el doble turno, no validar solapamientos
    if (permitirDobleTurno) {
      return ValidationResult.empty();
    }

    // Buscar turnos que se solapen con el nuevo turno
    for (final TurnoEntity turnoExistente in turnosExistentes) {
      if (_turnosSeSolapan(turnoNuevo, turnoExistente)) {
        return ValidationResult.error(
          ValidationIssue(
            ruleType: ValidationRuleType.dobleTurno,
            severity: ValidationSeverity.error,
            message: 'El turno se solapa con otro turno existente',
            details:
                'El turno propuesto (${turnoNuevo.horaInicio}-${turnoNuevo.horaFin}) se solapa con el turno existente "${turnoExistente.tipoTurno.nombre}" (${turnoExistente.horaInicio}-${turnoExistente.horaFin})',
            suggestedAction: 'Ajusta los horarios para que no se solapen o activa "Permitir Doble Turno" en la configuración del trabajador',
          ),
        );
      }
    }

    return ValidationResult.empty();
  }

  /// Verifica si dos turnos se solapan en tiempo
  bool _turnosSeSolapan(TurnoEntity turno1, TurnoEntity turno2) {
    // Convertir fechas y horas a DateTime para comparación precisa
    final DateTime inicio1 = _combinarFechaHora(turno1.fechaInicio, turno1.horaInicio);
    final DateTime fin1 = _combinarFechaHora(turno1.fechaFin, turno1.horaFin);
    final DateTime inicio2 = _combinarFechaHora(turno2.fechaInicio, turno2.horaInicio);
    final DateTime fin2 = _combinarFechaHora(turno2.fechaFin, turno2.horaFin);

    // Dos turnos se solapan si:
    // - El inicio de uno está entre el inicio y fin del otro, O
    // - El fin de uno está entre el inicio y fin del otro, O
    // - Uno contiene completamente al otro
    return inicio1.isBefore(fin2) && fin1.isAfter(inicio2);
  }

  /// Combina una fecha con una hora en formato HH:mm
  DateTime _combinarFechaHora(DateTime fecha, String hora) {
    final List<String> partes = hora.split(':');
    if (partes.length != 2) {
      return fecha; // Si formato inválido, retornar solo la fecha
    }

    final int horas = int.tryParse(partes[0]) ?? 0;
    final int minutos = int.tryParse(partes[1]) ?? 0;

    return DateTime(fecha.year, fecha.month, fecha.day, horas, minutos);
  }

  @override
  ValidationResult validateExcesoHorasSinDescanso({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentes,
    double? horasMaximasSinDescanso,
  }) {
    // Si no hay límite (null = sin límite), no validar
    if (horasMaximasSinDescanso == null) {
      return ValidationResult.empty();
    }

    // Calcular horas trabajadas en los últimos 3 días
    final DateTime tresDiasAtras =
        turnoNuevo.fechaInicio.subtract(const Duration(days: 3));

    final List<TurnoEntity> turnosRecientes = turnosExistentes
        .where(
          (TurnoEntity t) => t.fechaInicio.isAfter(tresDiasAtras),
        )
        .toList();

    final double horasTrabajadas = calcularHorasTrabajadas(
      turnos: <TurnoEntity>[...turnosRecientes, turnoNuevo],
      fechaInicio: tresDiasAtras,
      fechaFin: turnoNuevo.fechaFin,
    );

    if (horasTrabajadas > horasMaximasSinDescanso) {
      return ValidationResult.error(
        ValidationIssue(
          ruleType: ValidationRuleType.excesoHorasSinDescanso,
          severity: ValidationSeverity.warning,
          message:
              'El trabajador acumula ${horasTrabajadas.toStringAsFixed(1)}h en los últimos 3 días',
          details:
              'Se recomienda un descanso después de $horasMaximasSinDescanso horas trabajadas',
          suggestedAction: 'Asigna un día de descanso antes de este turno',
        ),
      );
    }

    return ValidationResult.empty();
  }

  @override
  ValidationResult validateDescansoEntreTurnos({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentes,
    required double horasMinimasDescanso,
  }) {
    for (final TurnoEntity turnoExistente in turnosExistentes) {
      // Combinar fecha+hora para comparación precisa
      final DateTime finTurnoExistente = _combinarFechaHora(
        turnoExistente.fechaFin,
        turnoExistente.horaFin,
      );
      final DateTime inicioTurnoNuevo = _combinarFechaHora(
        turnoNuevo.fechaInicio,
        turnoNuevo.horaInicio,
      );

      // Calcular tiempo entre fin de un turno e inicio del siguiente
      // Si el nuevo turno empieza ANTES de que termine el existente, se solapan (ya validado)
      // Si el nuevo turno empieza DESPUÉS, calcular diferencia
      if (inicioTurnoNuevo.isAfter(finTurnoExistente)) {
        final Duration diferencia = inicioTurnoNuevo.difference(finTurnoExistente);

        if (diferencia.inMinutes < (horasMinimasDescanso * 60)) {
          return ValidationResult.error(
            ValidationIssue(
              ruleType: ValidationRuleType.descansoInsuficiente,
              severity: ValidationSeverity.error,
              message:
                  'Descanso insuficiente entre turnos (${(diferencia.inMinutes / 60).toStringAsFixed(1)}h)',
              details:
                  'Se requiere un mínimo de $horasMinimasDescanso horas de descanso entre turnos',
              suggestedAction:
                  'Ajusta la fecha/hora del turno para garantizar el descanso',
            ),
          );
        }
      } else if (inicioTurnoNuevo.isBefore(finTurnoExistente)) {
        // Verificar también el caso inverso: si el turno existente empieza después del nuevo
        final DateTime finTurnoNuevo = _combinarFechaHora(
          turnoNuevo.fechaFin,
          turnoNuevo.horaFin,
        );
        final DateTime inicioTurnoExistente = _combinarFechaHora(
          turnoExistente.fechaInicio,
          turnoExistente.horaInicio,
        );

        if (inicioTurnoExistente.isAfter(finTurnoNuevo)) {
          final Duration diferencia = inicioTurnoExistente.difference(finTurnoNuevo);

          if (diferencia.inMinutes < (horasMinimasDescanso * 60)) {
            return ValidationResult.error(
              ValidationIssue(
                ruleType: ValidationRuleType.descansoInsuficiente,
                severity: ValidationSeverity.error,
                message:
                    'Descanso insuficiente entre turnos (${(diferencia.inMinutes / 60).toStringAsFixed(1)}h)',
                details:
                    'Se requiere un mínimo de $horasMinimasDescanso horas de descanso entre turnos',
                suggestedAction:
                    'Ajusta la fecha/hora del turno para garantizar el descanso',
              ),
            );
          }
        }
      }
    }

    return ValidationResult.empty();
  }

  @override
  Future<ValidationResult> validateCruceConAusencias({
    required TurnoEntity turnoNuevo,
    required String idPersonal,
  }) async {
    try {
      final List<PeriodoIndisponibilidad> periodos = await _indisponibilidadLoader.cargarDePersonal(idPersonal);
      return TurnoAusenciasChecker.validar(turno: turnoNuevo, idPersonal: idPersonal, periodos: periodos);
    } catch (e) {
      debugPrint('⚠️ No se pudieron comprobar ausencias/vacaciones: $e');
      return ValidationResult.error(
        const ValidationIssue(
          ruleType: ValidationRuleType.cruceConAusencia,
          severity: ValidationSeverity.warning,
          message: 'No se pudieron comprobar las ausencias y vacaciones del trabajador',
          suggestedAction: 'Verifica manualmente que no tenga ausencias o vacaciones aprobadas ese día',
        ),
      );
    }
  }

  @override
  double calcularHorasTrabajadas({
    required List<TurnoEntity> turnos,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) {
    double totalHoras = 0;

    for (final TurnoEntity turno in turnos) {
      // Solo contar turnos dentro del rango
      if (turno.fechaInicio.isAfter(fechaInicio) &&
          turno.fechaInicio.isBefore(fechaFin)) {
        final Duration duracion = turno.fechaFin.difference(turno.fechaInicio);
        totalHoras += duracion.inMinutes / 60;
      }
    }

    return totalHoras;
  }
}
