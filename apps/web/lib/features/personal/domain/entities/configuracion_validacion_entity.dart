import 'package:equatable/equatable.dart';

/// Configuración de validaciones de turnos para un trabajador específico
///
/// Permite personalizar las reglas de validación según:
/// - Tipo de contrato (tiempo completo, parcial, guardia)
/// - Exenciones especiales
/// - Situaciones de emergencia
class ConfiguracionValidacionEntity extends Equatable {
  const ConfiguracionValidacionEntity({
    this.permitirDobleTurno = false,
    this.horasMinimasDescanso = 12,
    this.horasMaximasSemanales = 40,
    this.horasMaximasMensuales = 160,
    this.diasDescansoSemanalMinimo = 1,
    this.horasMaximasContinuas = 72,
    this.validacionesActivas = true,
    this.motivoExencion,
  });

  /// Configuración estándar (normativa española)
  factory ConfiguracionValidacionEntity.estandar() {
    return const ConfiguracionValidacionEntity(
      
    );
  }

  /// Configuración para guardias 24h
  factory ConfiguracionValidacionEntity.guardia24h() {
    return const ConfiguracionValidacionEntity(
      permitirDobleTurno: true,
      horasMinimasDescanso: 0, // Sin restricción entre guardias
      horasMaximasSemanales: null, // Sin límite semanal
      horasMaximasMensuales: null, // Sin límite mensual
      diasDescansoSemanalMinimo: 0, // Flexible según calendario guardias
      horasMaximasContinuas: null, // Guardias pueden ser >72h
    );
  }

  /// Configuración para media jornada
  factory ConfiguracionValidacionEntity.mediaJornada() {
    return const ConfiguracionValidacionEntity(
      horasMaximasSemanales: 20,
      horasMaximasMensuales: 80,
      horasMaximasContinuas: 48,
    );
  }

  /// Configuración sin validaciones (emergencias)
  factory ConfiguracionValidacionEntity.sinValidaciones({
    required String motivo,
  }) {
    return ConfiguracionValidacionEntity(
      permitirDobleTurno: true,
      horasMinimasDescanso: 0,
      horasMaximasSemanales: null,
      horasMaximasMensuales: null,
      diasDescansoSemanalMinimo: 0,
      horasMaximasContinuas: null,
      validacionesActivas: false,
      motivoExencion: motivo,
    );
  }

  /// Crea desde Map de JSON
  factory ConfiguracionValidacionEntity.fromJson(Map<String, dynamic> json) {
    return ConfiguracionValidacionEntity(
      permitirDobleTurno: json['permitirDobleTurno'] as bool? ?? false,
      horasMinimasDescanso: (json['horasMinimasDescanso'] as num?)?.toDouble() ?? 12,
      horasMaximasSemanales: (json['horasMaximasSemanales'] as num?)?.toDouble(),
      horasMaximasMensuales: (json['horasMaximasMensuales'] as num?)?.toDouble(),
      diasDescansoSemanalMinimo: json['diasDescansoSemanalMinimo'] as int? ?? 1,
      horasMaximasContinuas: (json['horasMaximasContinuas'] as num?)?.toDouble(),
      validacionesActivas: json['validacionesActivas'] as bool? ?? true,
      motivoExencion: json['motivoExencion'] as String?,
    );
  }

  /// Permite asignar múltiples turnos en el mismo día
  ///
  /// Casos de uso:
  /// - Personal de guardia 24h
  /// - Turnos partidos (mañana + tarde)
  /// - Emergencias médicas
  final bool permitirDobleTurno;

  /// Horas mínimas de descanso entre turnos consecutivos
  ///
  /// Valores típicos:
  /// - 12h: Normativa estándar
  /// - 8h: Contratos especiales
  /// - 0h: Sin restricción (guardias)
  final double horasMinimasDescanso;

  /// Horas máximas de trabajo por semana
  ///
  /// Valores típicos:
  /// - 40h: Jornada completa estándar
  /// - 20-30h: Media jornada
  /// - null: Sin límite (autónomos, guardias)
  final double? horasMaximasSemanales;

  /// Horas máximas de trabajo por mes
  ///
  /// Valores típicos:
  /// - 160h: Jornada completa (40h/semana × 4 semanas)
  /// - 80-120h: Media/parcial jornada
  /// - null: Sin límite
  final double? horasMaximasMensuales;

  /// Días de descanso mínimos por semana
  ///
  /// Valores típicos:
  /// - 1: Normativa estándar
  /// - 0: Situaciones excepcionales
  final int diasDescansoSemanalMinimo;

  /// Horas máximas de trabajo continuo sin descanso
  ///
  /// Valores típicos:
  /// - 72h: Máximo legal
  /// - 48h: Recomendado
  /// - null: Sin límite
  final double? horasMaximasContinuas;

  /// Si las validaciones están activas para este trabajador
  ///
  /// - true: Aplicar todas las validaciones configuradas
  /// - false: ANULAR TODAS las validaciones (emergencias)
  final bool validacionesActivas;

  /// Motivo de exención de validaciones (si validacionesActivas = false)
  ///
  /// Ejemplos:
  /// - "Emergencia sanitaria COVID-19"
  /// - "Contrato de guardia localizada 24h"
  /// - "Autorización especial dirección médica"
  final String? motivoExencion;

  @override
  List<Object?> get props => <Object?>[
        permitirDobleTurno,
        horasMinimasDescanso,
        horasMaximasSemanales,
        horasMaximasMensuales,
        diasDescansoSemanalMinimo,
        horasMaximasContinuas,
        validacionesActivas,
        motivoExencion,
      ];

  /// CopyWith para inmutabilidad
  ConfiguracionValidacionEntity copyWith({
    bool? permitirDobleTurno,
    double? horasMinimasDescanso,
    double? horasMaximasSemanales,
    double? horasMaximasMensuales,
    int? diasDescansoSemanalMinimo,
    double? horasMaximasContinuas,
    bool? validacionesActivas,
    String? motivoExencion,
  }) {
    return ConfiguracionValidacionEntity(
      permitirDobleTurno: permitirDobleTurno ?? this.permitirDobleTurno,
      horasMinimasDescanso: horasMinimasDescanso ?? this.horasMinimasDescanso,
      horasMaximasSemanales: horasMaximasSemanales ?? this.horasMaximasSemanales,
      horasMaximasMensuales: horasMaximasMensuales ?? this.horasMaximasMensuales,
      diasDescansoSemanalMinimo:
          diasDescansoSemanalMinimo ?? this.diasDescansoSemanalMinimo,
      horasMaximasContinuas: horasMaximasContinuas ?? this.horasMaximasContinuas,
      validacionesActivas: validacionesActivas ?? this.validacionesActivas,
      motivoExencion: motivoExencion ?? this.motivoExencion,
    );
  }

  /// Convierte a Map para JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'permitirDobleTurno': permitirDobleTurno,
      'horasMinimasDescanso': horasMinimasDescanso,
      'horasMaximasSemanales': horasMaximasSemanales,
      'horasMaximasMensuales': horasMaximasMensuales,
      'diasDescansoSemanalMinimo': diasDescansoSemanalMinimo,
      'horasMaximasContinuas': horasMaximasContinuas,
      'validacionesActivas': validacionesActivas,
      'motivoExencion': motivoExencion,
    };
  }
}
