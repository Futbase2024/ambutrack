import 'package:flutter/foundation.dart';

/// Utilidades para cálculo automático de horarios de servicios
class TimeCalculator {
  /// Tiempo estimado de ruta en minutos (configurable, default 30 min)
  static const int tiempoRutaDefaultMinutos = 30;

  /// Calcula los horarios completos basándose en la hora de cita y el motivo de traslado
  ///
  /// [horaCita] - Hora de la cita en formato "HH:mm"
  /// [tiempoEsperaMinutos] - Minutos de espera en destino (del motivo de traslado)
  /// [tieneVuelta] - Si el servicio incluye viaje de retorno
  /// [tiempoRutaMinutos] - Tiempo de ruta (opcional, default 30 min)
  ///
  /// Retorna un mapa con las 3 horas calculadas
  static Map<String, String?> calcularHorarios({
    required String horaCita,
    required int tiempoEsperaMinutos,
    required bool tieneVuelta,
    int tiempoRutaMinutos = tiempoRutaDefaultMinutos,
  }) {
    try {
      // Parsear hora de cita
      final DateTime? cita = _parseTime(horaCita);
      if (cita == null) {
        debugPrint('❌ TimeCalculator: Hora de cita inválida: $horaCita');
        return <String, String?>{
          'hora_recogida': horaCita,
          'hora_cita': horaCita,
          'hora_vuelta': null,
        };
      }

      // Calcular hora de recogida (cita - tiempo de ruta)
      final DateTime recogida = _restarMinutos(cita, tiempoRutaMinutos);

      // Calcular hora de vuelta (solo si tiene vuelta)
      final DateTime? vuelta =
          tieneVuelta ? _sumarMinutos(cita, tiempoEsperaMinutos) : null;

      final Map<String, String?> result = <String, String?>{
        'hora_recogida': _formatTime(recogida),
        'hora_cita': horaCita,
        'hora_vuelta': vuelta != null ? _formatTime(vuelta) : null,
      };

      debugPrint('📊 TimeCalculator: Horarios calculados:');
      debugPrint('   Recogida: ${result['hora_recogida']}');
      debugPrint('   Cita: ${result['hora_cita']}');
      debugPrint('   Vuelta: ${result['hora_vuelta'] ?? "—"}');

      return result;
    } catch (e) {
      debugPrint('❌ TimeCalculator: Error calculando horarios: $e');
      return <String, String?>{
        'hora_recogida': horaCita,
        'hora_cita': horaCita,
        'hora_vuelta': null,
      };
    }
  }

  /// Calcula solo la hora de recogida
  static String calcularHoraRecogida(
    String horaCita, {
    int tiempoRutaMinutos = tiempoRutaDefaultMinutos,
  }) {
    final DateTime? cita = _parseTime(horaCita);
    if (cita == null) {
      return horaCita;
    }

    final DateTime recogida = _restarMinutos(cita, tiempoRutaMinutos);
    return _formatTime(recogida);
  }

  /// Calcula solo la hora de vuelta
  static String? calcularHoraVuelta(
    String horaCita,
    int tiempoEsperaMinutos,
    // ignore: avoid_positional_boolean_parameters
    bool tieneVuelta,
  ) {
    if (!tieneVuelta) {
      return null;
    }

    final DateTime? cita = _parseTime(horaCita);
    if (cita == null) {
      return null;
    }

    final DateTime vuelta = _sumarMinutos(cita, tiempoEsperaMinutos);
    return _formatTime(vuelta);
  }

  /// Valida que una hora esté en formato HH:mm correcto
  static bool esHoraValida(String hora) {
    final RegExp regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(hora);
  }

  /// Valida que la hora esté en el rango permitido (06:00 - 22:00)
  static bool esHoraEnRangoPermitido(
    String hora, {
    String horaMin = '06:00',
    String horaMax = '22:00',
  }) {
    final DateTime? time = _parseTime(hora);
    final DateTime? min = _parseTime(horaMin);
    final DateTime? max = _parseTime(horaMax);

    if (time == null || min == null || max == null) {
      return false;
    }

    final int minutos = time.hour * 60 + time.minute;
    final int minutosMin = min.hour * 60 + min.minute;
    final int minutosMax = max.hour * 60 + max.minute;

    return minutos >= minutosMin && minutos <= minutosMax;
  }

  /// Convierte una hora en formato "HH:mm" a DateTime
  static DateTime? _parseTime(String hora) {
    try {
      final List<String> parts = hora.split(':');
      if (parts.length != 2) {
        return null;
      }

      final int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }

      final DateTime now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  /// Suma minutos a una hora
  static DateTime _sumarMinutos(DateTime time, int minutos) {
    return time.add(Duration(minutes: minutos));
  }

  /// Resta minutos a una hora
  static DateTime _restarMinutos(DateTime time, int minutos) {
    return time.subtract(Duration(minutes: minutos));
  }

  /// Formatea DateTime a string "HH:mm"
  static String _formatTime(DateTime time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Compara dos horas en formato HH:mm
  /// Retorna: -1 si h1 < h2, 0 si h1 == h2, 1 si h1 > h2
  static int compararHoras(String h1, String h2) {
    final DateTime? time1 = _parseTime(h1);
    final DateTime? time2 = _parseTime(h2);

    if (time1 == null || time2 == null) {
      return 0;
    }

    return time1.compareTo(time2);
  }

  /// Convierte minutos totales a formato "Xh Ymin"
  /// Ejemplo: 280 → "4h 40min"
  static String minutosATexto(int minutos) {
    final int horas = minutos ~/ 60;
    final int mins = minutos % 60;

    if (horas == 0) {
      return '${mins}min';
    } else if (mins == 0) {
      return '${horas}h';
    } else {
      return '${horas}h ${mins}min';
    }
  }
}
