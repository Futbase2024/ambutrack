import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Jornada realmente trabajada en un turno, a partir de los fichajes
///
/// Se asocian al turno los fichajes entre 3h antes de su inicio y 6h
/// después de su fin (llegadas tempranas y horas extra). Los cambios de
/// vehículo generan pares salida/entrada intermedios: se suman los tramos.
class JornadaReal {
  const JornadaReal({
    required this.entrada,
    required this.trabajado,
    this.salida,
  });

  /// Primer fichaje de entrada del turno
  final DateTime entrada;

  /// Último fichaje de salida (null = jornada en curso)
  final DateTime? salida;

  /// Tiempo trabajado (suma de tramos entrada → salida)
  final Duration trabajado;

  static const Duration _antes = Duration(hours: 3);
  static const Duration _despues = Duration(hours: 6);

  /// Margen a partir del cual se marca la diferencia con lo planificado
  static const Duration margenDesvio = Duration(minutes: 30);

  bool get finalizada => salida != null;

  /// Calcula la jornada del [turno] o null si no fichó entrada
  static JornadaReal? calcular(TurnoEntity turno, List<RegistroHorarioEntity> fichajes) {
    final DateTime desde = turno.inicioReal.subtract(_antes);
    final DateTime hasta = turno.finReal.add(_despues);

    final List<RegistroHorarioEntity> delTurno = fichajes
        .where((RegistroHorarioEntity f) =>
            f.activo && !f.fechaHora.isBefore(desde) && !f.fechaHora.isAfter(hasta))
        .toList()
      ..sort((RegistroHorarioEntity a, RegistroHorarioEntity b) => a.fechaHora.compareTo(b.fechaHora));

    DateTime? primeraEntrada;
    DateTime? entradaAbierta;
    DateTime? ultimaSalida;
    Duration total = Duration.zero;

    for (final RegistroHorarioEntity f in delTurno) {
      final bool esEntrada = f.tipo.toLowerCase() == 'entrada';
      if (esEntrada) {
        primeraEntrada ??= f.fechaHora;
        entradaAbierta ??= f.fechaHora;
      } else if (entradaAbierta != null) {
        total += f.fechaHora.difference(entradaAbierta);
        ultimaSalida = f.fechaHora;
        entradaAbierta = null;
      }
    }

    if (primeraEntrada == null) {
      return null;
    }
    // Sigue dentro: cuenta hasta ahora
    if (entradaAbierta != null) {
      total += DateTime.now().difference(entradaAbierta);
      ultimaSalida = null;
    }
    return JornadaReal(entrada: primeraEntrada, salida: ultimaSalida, trabajado: total);
  }

  /// Diferencia con la duración planificada del turno (+ = más horas)
  Duration desvio(TurnoEntity turno) => trabajado - turno.finReal.difference(turno.inicioReal);

  /// Formato "8h 05m"
  static String formatear(Duration d) {
    final Duration abs = d.abs();
    final int h = abs.inHours;
    final int m = abs.inMinutes.remainder(60);
    return h > 0 ? '${h}h ${m.toString().padLeft(2, '0')}m' : '${m}m';
  }
}
