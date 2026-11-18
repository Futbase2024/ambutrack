import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Medidas fijas de la tabla semanal del cuadrante
abstract final class CuadranteTablaMedidas {
  /// Ancho de la columna de personal
  static const double anchoPersonal = 220;

  /// Ancho de la columna de resumen semanal
  static const double anchoSemana = 112;

  /// Altura fija de cada fila de personal
  static const double altoFila = 68;

  /// Jornada ordinaria de referencia (no hay horas de contrato en BD)
  static const Duration referenciaSemana = Duration(hours: 40);
}

/// Los 7 días de la semana que empieza en [lunes]
List<DateTime> diasDeSemana(DateTime lunes) {
  return List<DateTime>.generate(7, (int i) => lunes.add(Duration(days: i)));
}

/// Compara dos fechas ignorando la hora
bool mismaFecha(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Indica si [dia] es hoy
bool esHoy(DateTime dia) => mismaFecha(dia, DateTime.now());

/// Convierte "HH:mm" a minutos desde medianoche
int horaAMinutos(String hora) {
  final List<String> partes = hora.split(':');
  final int horas = int.tryParse(partes.first) ?? 0;
  final int minutos = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
  return horas * 60 + minutos;
}

/// "07:00" → "07", "07:30" → "07:30" (formato compacto para la tarjeta)
String horaCorta(String hora) => hora.endsWith(':00') ? hora.substring(0, hora.length - 3) : hora;

/// Formato de horas: "8h", "37h 30m", "45m"
String formatearHoras(Duration d) {
  final int h = d.inHours;
  final int m = d.inMinutes.remainder(60);
  if (h == 0) {
    return '${m}m';
  }
  return m == 0 ? '${h}h' : '${h}h ${m.toString().padLeft(2, '0')}m';
}

/// Indica si el turno termina en un día distinto al que empieza
bool cruzaMedianoche(TurnoEntity turno) => !mismaFecha(turno.fechaInicio, turno.fechaFin);

/// Horario visible del turno en [dia]: los turnos que cruzan medianoche
/// se parten (primer día hasta 00:00, segundo desde 00:00)
({String inicio, String fin}) horarioEnDia(TurnoEntity turno, DateTime dia) {
  if (!cruzaMedianoche(turno)) {
    return (inicio: turno.horaInicio, fin: turno.horaFin);
  }
  return mismaFecha(dia, turno.fechaInicio)
      ? (inicio: turno.horaInicio, fin: '00:00')
      : (inicio: '00:00', fin: turno.horaFin);
}

/// Matrícula del vehículo asignado o null si no hay / no se encuentra
String? matriculaDe(String? idVehiculo, List<VehiculoEntity> vehiculos) {
  if (idVehiculo == null || idVehiculo.isEmpty) {
    return null;
  }
  for (final VehiculoEntity v in vehiculos) {
    if (v.id == idVehiculo) {
      return v.matricula;
    }
  }
  return null;
}

/// Duración del turno que cae dentro de la semana [lunes, lunes + 7d)
Duration duracionEnSemana(TurnoEntity turno, DateTime lunes) {
  final DateTime desde = DateTime(lunes.year, lunes.month, lunes.day);
  final DateTime hasta = desde.add(const Duration(days: 7));
  final DateTime inicio = turno.inicioReal.isBefore(desde) ? desde : turno.inicioReal;
  final DateTime fin = turno.finReal.isAfter(hasta) ? hasta : turno.finReal;
  return fin.isAfter(inicio) ? fin.difference(inicio) : Duration.zero;
}

/// Aspecto visual (color, icono y etiqueta) de un turno según su tipo y duración
class TurnoVisual {
  const TurnoVisual({required this.color, required this.icono, required this.etiqueta});

  /// Detecta los tipos especiales (24h, 12h día, 12h noche) antes que el tipo base
  factory TurnoVisual.de(TurnoEntity turno) {
    final bool cruza = cruzaMedianoche(turno);
    if (cruza && turno.horaInicio == turno.horaFin) {
      return const TurnoVisual(color: AppColors.turnoMorado, icono: Icons.emergency_outlined, etiqueta: '24 Horas');
    }
    if (_esDe12Horas(turno, cruza: cruza)) {
      return cruza
          ? const TurnoVisual(color: AppColors.turnoAzul, icono: Icons.dark_mode_outlined, etiqueta: '12h Noche')
          : const TurnoVisual(color: AppColors.turnoTurquesa, icono: Icons.light_mode_outlined, etiqueta: '12h Día');
    }
    switch (turno.tipoTurno) {
      case TipoTurno.manana:
        return TurnoVisual(color: AppColors.success, icono: Icons.wb_sunny_outlined, etiqueta: turno.tipoTurno.nombre);
      case TipoTurno.tarde:
        return TurnoVisual(color: AppColors.turnoNaranja, icono: Icons.wb_twilight, etiqueta: turno.tipoTurno.nombre);
      case TipoTurno.noche:
        return TurnoVisual(color: AppColors.turnoAzul, icono: Icons.nightlight_outlined, etiqueta: turno.tipoTurno.nombre);
      case TipoTurno.personalizado:
        return TurnoVisual(color: AppColors.turnoGris, icono: Icons.tune, etiqueta: turno.tipoTurno.nombre);
    }
  }

  final Color color;
  final IconData icono;
  final String etiqueta;

  /// Entre 11,5 y 12,5 horas de duración
  static bool _esDe12Horas(TurnoEntity turno, {required bool cruza}) {
    int fin = horaAMinutos(turno.horaFin);
    if (cruza) {
      fin += 24 * 60;
    }
    final int duracion = fin - horaAMinutos(turno.horaInicio);
    return duracion >= 690 && duracion <= 750;
  }
}
