import 'package:equatable/equatable.dart';

/// Nivel de severidad de una validación
enum ValidationSeverity {
  /// Error crítico - bloquea la operación
  error,

  /// Advertencia - permite continuar pero recomienda revisar
  warning,

  /// Información - sugerencia o dato relevante
  info,
}

/// Extensión para obtener texto y color de severidad
extension ValidationSeverityExtension on ValidationSeverity {
  String get displayText {
    switch (this) {
      case ValidationSeverity.error:
        return 'Error';
      case ValidationSeverity.warning:
        return 'Advertencia';
      case ValidationSeverity.info:
        return 'Información';
    }
  }

  String get icon {
    switch (this) {
      case ValidationSeverity.error:
        return '🔴';
      case ValidationSeverity.warning:
        return '⚠️';
      case ValidationSeverity.info:
        return 'ℹ️';
    }
  }
}

/// Tipo de regla de validación
enum ValidationRuleType {
  dobleTurno,
  excesoHorasSinDescanso,
  descansoInsuficiente,
  excesoHorasSemanales,
  excesoHorasMensuales,
  cruceConAusencia,
  violacionConvenio,
  faltaDescansoSemanal,
  turnoFueraHorario,
}

/// Extensión para obtener descripción de regla
extension ValidationRuleTypeExtension on ValidationRuleType {
  String get description {
    switch (this) {
      case ValidationRuleType.dobleTurno:
        return 'Doble Turno en el Mismo Día';
      case ValidationRuleType.excesoHorasSinDescanso:
        return 'Exceso de Horas Sin Descanso';
      case ValidationRuleType.descansoInsuficiente:
        return 'Descanso Insuficiente Entre Turnos';
      case ValidationRuleType.excesoHorasSemanales:
        return 'Exceso de Horas Semanales';
      case ValidationRuleType.excesoHorasMensuales:
        return 'Exceso de Horas Mensuales';
      case ValidationRuleType.cruceConAusencia:
        return 'Conflicto con Ausencia Registrada';
      case ValidationRuleType.violacionConvenio:
        return 'Violación del Convenio Laboral';
      case ValidationRuleType.faltaDescansoSemanal:
        return 'Falta Descanso Semanal';
      case ValidationRuleType.turnoFueraHorario:
        return 'Turno Fuera de Horario Permitido';
    }
  }
}

/// Resultado individual de una validación
class ValidationIssue extends Equatable {
  const ValidationIssue({
    required this.ruleType,
    required this.severity,
    required this.message,
    this.details,
    this.suggestedAction,
  });

  /// Tipo de regla que generó este issue
  final ValidationRuleType ruleType;

  /// Nivel de severidad
  final ValidationSeverity severity;

  /// Mensaje descriptivo del problema
  final String message;

  /// Detalles adicionales (opcional)
  final String? details;

  /// Acción sugerida para resolver (opcional)
  final String? suggestedAction;

  /// Si es un error crítico
  bool get isCritical => severity == ValidationSeverity.error;

  /// Si es una advertencia
  bool get isWarning => severity == ValidationSeverity.warning;

  /// Si es informativo
  bool get isInfo => severity == ValidationSeverity.info;

  @override
  List<Object?> get props => <Object?>[
        ruleType,
        severity,
        message,
        details,
        suggestedAction,
      ];

  @override
  bool get stringify => true;
}

/// Resultado completo de una validación de turno
class ValidationResult extends Equatable {
  const ValidationResult({
    required this.issues,
  });

  /// Resultado vacío (sin problemas)
  factory ValidationResult.empty() {
    return const ValidationResult(issues: <ValidationIssue>[]);
  }

  /// Resultado con un solo error
  factory ValidationResult.error(ValidationIssue issue) {
    return ValidationResult(issues: <ValidationIssue>[issue]);
  }

  /// Combina múltiples resultados
  factory ValidationResult.combine(List<ValidationResult> results) {
    final List<ValidationIssue> allIssues = <ValidationIssue>[];
    for (final ValidationResult result in results) {
      allIssues.addAll(result.issues);
    }
    return ValidationResult(issues: allIssues);
  }

  /// Lista de problemas encontrados
  final List<ValidationIssue> issues;

  /// Si la validación fue exitosa (sin errores críticos)
  bool get isValid => !hasErrors;

  /// Si tiene errores críticos
  bool get hasErrors =>
      issues.any((ValidationIssue issue) => issue.isCritical);

  /// Si tiene advertencias
  bool get hasWarnings =>
      issues.any((ValidationIssue issue) => issue.isWarning);

  /// Si tiene información
  bool get hasInfo => issues.any((ValidationIssue issue) => issue.isInfo);

  /// Obtiene solo los errores
  List<ValidationIssue> get errors => issues
      .where((ValidationIssue issue) => issue.isCritical)
      .toList();

  /// Obtiene solo las advertencias
  List<ValidationIssue> get warnings => issues
      .where((ValidationIssue issue) => issue.isWarning)
      .toList();

  /// Obtiene solo la información
  List<ValidationIssue> get infos =>
      issues.where((ValidationIssue issue) => issue.isInfo).toList();

  @override
  List<Object?> get props => <Object?>[issues];

  @override
  bool get stringify => true;
}
