import 'package:flutter/foundation.dart';

/// Utilidades para generar fechas según tipo de recurrencia
class RecurrenceUtils {
  /// Genera lista de fechas para recurrencia DIARIA
  ///
  /// [fechaInicio] - Fecha de inicio
  /// [fechaFin] - Fecha de fin (puede ser null para indefinido)
  /// [maxDias] - Máximo de días a generar (default 365 para indefinido)
  ///
  /// Retorna lista de fechas ordenadas
  static List<DateTime> generarFechasDiarias({
    required DateTime fechaInicio,
    DateTime? fechaFin,
    int maxDias = 365,
  }) {
    final List<DateTime> fechas = <DateTime>[];
    DateTime current = _normalizarFecha(fechaInicio);
    final DateTime? end = fechaFin != null ? _normalizarFecha(fechaFin) : null;

    int count = 0;
    while (count < maxDias) {
      // Si hay fecha fin y la hemos superado, terminar
      if (end != null && current.isAfter(end)) {
        break;
      }

      fechas.add(current);
      current = current.add(const Duration(days: 1));
      count++;
    }

    debugPrint('📅 RecurrenceUtils: Generadas ${fechas.length} fechas diarias');
    return fechas;
  }

  /// Genera lista de fechas para recurrencia SEMANAL
  ///
  /// [fechaInicio] - Fecha de inicio
  /// [fechaFin] - Fecha de fin (puede ser null)
  /// [diasSemana] - Lista de días de la semana (0=Domingo, 1=Lunes...6=Sábado)
  /// [maxSemanas] - Máximo de semanas a generar (default 52 para indefinido)
  static List<DateTime> generarFechasSemanales({
    required DateTime fechaInicio,
    DateTime? fechaFin,
    required List<int> diasSemana,
    int maxSemanas = 52,
  }) {
    if (diasSemana.isEmpty) {
      return <DateTime>[];
    }

    final List<DateTime> fechas = <DateTime>[];
    DateTime current = _normalizarFecha(fechaInicio);
    final DateTime? end = fechaFin != null ? _normalizarFecha(fechaFin) : null;

    int semanasContadas = 0;
    while (semanasContadas < maxSemanas) {
      // Generar fechas para la semana actual
      for (final int dia in diasSemana) {
        final DateTime fecha = _obtenerFechaEnSemana(current, dia);

        // Solo agregar si está en el rango
        if (fecha.isAfter(current.subtract(const Duration(days: 1)))) {
          if (end == null || !fecha.isAfter(end)) {
            fechas.add(fecha);
          }
        }
      }

      // Si hay fecha fin y la hemos superado, terminar
      if (end != null && current.isAfter(end)) {
        break;
      }

      // Avanzar a la siguiente semana
      current = current.add(const Duration(days: 7));
      semanasContadas++;
    }

    // Ordenar fechas
    fechas.sort((DateTime a, DateTime b) => a.compareTo(b));

    debugPrint(
        '📅 RecurrenceUtils: Generadas ${fechas.length} fechas semanales');
    return fechas;
  }

  /// Genera lista de fechas para recurrencia DÍAS ALTERNOS
  ///
  /// [fechaInicio] - Fecha de inicio
  /// [fechaFin] - Fecha de fin (puede ser null)
  /// [intervaloDias] - Cada cuántos días se repite (ej: 2 = cada 2 días)
  /// [maxDias] - Máximo de días a generar
  static List<DateTime> generarFechasDiasAlternos({
    required DateTime fechaInicio,
    DateTime? fechaFin,
    required int intervaloDias,
    int maxDias = 365,
  }) {
    if (intervaloDias < 2) {
      return <DateTime>[];
    }

    final List<DateTime> fechas = <DateTime>[];
    DateTime current = _normalizarFecha(fechaInicio);
    final DateTime? end = fechaFin != null ? _normalizarFecha(fechaFin) : null;

    int count = 0;
    while (count < maxDias) {
      if (end != null && current.isAfter(end)) {
        break;
      }

      fechas.add(current);
      current = current.add(Duration(days: intervaloDias));
      count++;
    }

    debugPrint(
        '📅 RecurrenceUtils: Generadas ${fechas.length} fechas cada $intervaloDias días');
    return fechas;
  }

  /// Genera lista de fechas para recurrencia MENSUAL
  ///
  /// [fechaInicio] - Fecha de inicio
  /// [fechaFin] - Fecha de fin (puede ser null)
  /// [diasMes] - Lista de días del mes (1-31)
  /// [maxMeses] - Máximo de meses a generar (default 12)
  static List<DateTime> generarFechasMensuales({
    required DateTime fechaInicio,
    DateTime? fechaFin,
    required List<int> diasMes,
    int maxMeses = 12,
  }) {
    if (diasMes.isEmpty) {
      return <DateTime>[];
    }

    final List<DateTime> fechas = <DateTime>[];
    DateTime current = _normalizarFecha(fechaInicio);
    final DateTime? end = fechaFin != null ? _normalizarFecha(fechaFin) : null;

    int mesesContados = 0;
    while (mesesContados < maxMeses) {
      // Generar fechas para el mes actual
      for (final int dia in diasMes) {
        try {
          // Intentar crear la fecha para ese día del mes
          final DateTime fecha = DateTime(current.year, current.month, dia);

          // Solo agregar si está en el rango
          if (fecha.isAfter(current.subtract(const Duration(days: 1)))) {
            if (end == null || !fecha.isAfter(end)) {
              fechas.add(fecha);
            }
          }
        } catch (e) {
          // El día no existe en este mes (ej: 31 de febrero)
          debugPrint(
              '⚠️ Día $dia no existe en ${current.month}/${current.year}');
        }
      }

      // Si hay fecha fin y la hemos superado, terminar
      if (end != null && current.isAfter(end)) {
        break;
      }

      // Avanzar al siguiente mes
      current = DateTime(current.year, current.month + 1);
      mesesContados++;
    }

    // Ordenar fechas
    fechas.sort((DateTime a, DateTime b) => a.compareTo(b));

    debugPrint(
        '📅 RecurrenceUtils: Generadas ${fechas.length} fechas mensuales');
    return fechas;
  }

  /// Obtiene el día de la semana de una fecha (0=Domingo, 1=Lunes...6=Sábado)
  static int obtenerDiaSemana(DateTime fecha) {
    return fecha.weekday % 7; // DateTime usa 1=Lunes, convertimos a 0=Domingo
  }

  /// Obtiene el nombre del día de la semana en español
  static String obtenerNombreDiaSemana(int diaSemana) {
    const List<String> nombres = <String>[
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
    ];
    return nombres[diaSemana];
  }

  /// Obtiene el nombre corto del día de la semana
  static String obtenerNombreDiaSemanaCorto(int diaSemana) {
    const List<String> nombres = <String>['D', 'L', 'M', 'X', 'J', 'V', 'S'];
    return nombres[diaSemana];
  }

  /// Normaliza una fecha a medianoche (00:00:00)
  static DateTime _normalizarFecha(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  /// Obtiene la fecha de un día específico de la semana en una semana dada
  /// [semana] - Cualquier fecha de la semana
  /// [diaSemana] - Día objetivo (0=Domingo...6=Sábado)
  static DateTime _obtenerFechaEnSemana(DateTime semana, int diaSemana) {
    final int diaActual = obtenerDiaSemana(semana);
    final int diferencia = diaSemana - diaActual;

    return semana.add(Duration(days: diferencia));
  }

  /// Verifica si una fecha cae en fin de semana
  static bool esFindeSemana(DateTime fecha) {
    final int dia = obtenerDiaSemana(fecha);
    return dia == 0 || dia == 6; // Domingo o Sábado
  }

  /// Filtra fechas excluyendo fines de semana
  static List<DateTime> excluirFinesDeSemana(List<DateTime> fechas) {
    return fechas.where((DateTime fecha) => !esFindeSemana(fecha)).toList();
  }

  /// Cuenta cuántos días hay entre dos fechas
  static int contarDiasEntre(DateTime inicio, DateTime fin) {
    final DateTime inicioNorm = _normalizarFecha(inicio);
    final DateTime finNorm = _normalizarFecha(fin);

    return finNorm.difference(inicioNorm).inDays + 1;
  }
}
