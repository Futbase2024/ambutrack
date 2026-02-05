import 'package:flutter/material.dart';

import 'dia_semana.dart';

/// Configuración de un día específico para el servicio
/// Puede representar un día de la semana, un día del mes, o una fecha específica
class ConfiguracionDia {

  const ConfiguracionDia({
    this.diaSemana,
    this.diaMes,
    this.fecha,
    required this.ida,
    this.horaIda,
    required this.tiempoEspera,
    required this.vuelta,
  });

  /// Deserializa desde JSON
  factory ConfiguracionDia.fromJson(Map<String, dynamic> json) {
    // Parse horaIda si existe
    TimeOfDay? horaIda;
    if (json['hora_ida'] != null) {
      final List<String> parts = (json['hora_ida'] as String).split(':');
      horaIda = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return ConfiguracionDia(
      // ✅ Usar DiaSemana.fromValor() en lugar de DiaSemana.values[]
      // porque 'dia_semana' en JSON usa .valor (1=lunes, 2=martes, etc.)
      diaSemana: json['dia_semana'] != null
          ? DiaSemana.fromValor(json['dia_semana'] as int)
          : null,
      diaMes: json['dia_mes'] as int?,
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : null,
      ida: json['ida'] as bool,
      horaIda: horaIda,
      tiempoEspera: json['tiempo_espera'] as int,
      vuelta: json['vuelta'] as bool,
    );
  }

  /// Crea una configuración de día de la semana
  factory ConfiguracionDia.semanal({
    required DiaSemana diaSemana,
    required bool ida,
    TimeOfDay? horaIda,
    required int tiempoEspera,
    required bool vuelta,
  }) {
    return ConfiguracionDia(
      diaSemana: diaSemana,
      ida: ida,
      horaIda: horaIda,
      tiempoEspera: tiempoEspera,
      vuelta: vuelta,
    );
  }

  /// Crea una configuración de día del mes
  factory ConfiguracionDia.mensual({
    required int diaMes,
    required bool ida,
    TimeOfDay? horaIda,
    required int tiempoEspera,
    required bool vuelta,
  }) {
    return ConfiguracionDia(
      diaMes: diaMes,
      ida: ida,
      horaIda: horaIda,
      tiempoEspera: tiempoEspera,
      vuelta: vuelta,
    );
  }

  /// Crea una configuración de fecha específica
  factory ConfiguracionDia.fechaEspecifica({
    required DateTime fecha,
    required bool ida,
    TimeOfDay? horaIda,
    required int tiempoEspera,
    required bool vuelta,
  }) {
    return ConfiguracionDia(
      fecha: fecha,
      ida: ida,
      horaIda: horaIda,
      tiempoEspera: tiempoEspera,
      vuelta: vuelta,
    );
  }
  /// Día de la semana (para semanal/dias_alternos)
  final DiaSemana? diaSemana;

  /// Día del mes (para mensual: 1-31, o 0=último día del mes)
  final int? diaMes;

  /// Fecha específica (para fechas_especificas)
  final DateTime? fecha;

  /// Si tiene traslado de ida
  final bool ida;

  /// Hora del traslado de ida
  final TimeOfDay? horaIda;

  /// Tiempo de espera en minutos (del motivo de traslado)
  final int tiempoEspera;

  /// Si tiene traslado de vuelta
  final bool vuelta;

  /// Auto-calcula la hora de vuelta basándose en la hora de ida + tiempo de espera
  TimeOfDay? get horaVueltaCalculada {
    if (!vuelta || horaIda == null) {
      return null;
    }

    final int totalMinutos = horaIda!.hour * 60 + horaIda!.minute + tiempoEspera;
    return TimeOfDay(
      hour: (totalMinutos ~/ 60) % 24,
      minute: totalMinutos % 60,
    );
  }

  /// Obtener el label del día (Lunes, Día 15, Lun 06/01/25, etc.)
  String get label {
    if (diaSemana != null) {
      return diaSemana!.nombre;
    } else if (diaMes != null) {
      return diaMes == 0 ? 'Último día' : 'Día $diaMes';
    } else if (fecha != null) {
      final DiaSemana dia = DiaSemana.fromDateTime(fecha!);
      return '${dia.abreviatura} ${fecha!.day.toString().padLeft(2, '0')}/${fecha!.month.toString().padLeft(2, '0')}/${fecha!.year.toString().substring(2)}';
    }
    return '';
  }

  /// Crea una copia con los valores modificados
  ConfiguracionDia copyWith({
    bool? ida,
    TimeOfDay? horaIda,
    bool? vuelta,
  }) {
    return ConfiguracionDia(
      diaSemana: diaSemana,
      diaMes: diaMes,
      fecha: fecha,
      ida: ida ?? this.ida,
      horaIda: horaIda ?? this.horaIda,
      tiempoEspera: tiempoEspera,
      vuelta: vuelta ?? this.vuelta,
    );
  }

  /// Serializa a JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      // ✅ Usar .valor en lugar de .index para coincidir con PostgreSQL DOW
      // DiaSemana.lunes.valor = 1 (que coincide con PostgreSQL Monday = 1)
      // DiaSemana.martes.valor = 2 (Tuesday = 2), etc.
      if (diaSemana != null) 'dia_semana': diaSemana!.valor,
      if (diaMes != null) 'dia_mes': diaMes,
      if (fecha != null) 'fecha': fecha!.toIso8601String(),
      'ida': ida,
      if (horaIda != null) 'hora_ida': '${horaIda!.hour.toString().padLeft(2, '0')}:${horaIda!.minute.toString().padLeft(2, '0')}',
      'tiempo_espera': tiempoEspera,
      'vuelta': vuelta,
    };
  }
}
