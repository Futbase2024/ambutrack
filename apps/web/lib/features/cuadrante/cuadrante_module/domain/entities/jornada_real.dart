import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Tramo trabajado entre una entrada y su salida (salida null = en curso)
class TramoJornada {
  const TramoJornada({required this.entrada, this.salida});

  final DateTime entrada;
  final DateTime? salida;

  Duration get duracion => (salida ?? DateTime.now()).difference(entrada);
}

/// Jornada realmente trabajada en un turno, a partir de los fichajes
///
/// Se asocian al turno los fichajes entre 3h antes de su inicio y 6h
/// después de su fin (llegadas tempranas y horas extra). Los cambios de
/// vehículo generan pares salida/entrada intermedios: se suman los tramos.
class JornadaReal {
  const JornadaReal({
    required this.entrada,
    required this.trabajado,
    required this.tramos,
    this.salida,
  });

  /// Tramos entrada → salida (más de uno si hubo pausas o cambios)
  final List<TramoJornada> tramos;

  /// Entrada del tramo actual (en curso) o del último tramo
  DateTime get entradaActual => tramos.last.entrada;

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

    final List<TramoJornada> tramos = <TramoJornada>[];
    DateTime? entradaAbierta;
    for (final RegistroHorarioEntity f in delTurno) {
      if (f.tipo.toLowerCase() == 'entrada') {
        entradaAbierta ??= f.fechaHora;
      } else if (entradaAbierta != null) {
        tramos.add(TramoJornada(entrada: entradaAbierta, salida: f.fechaHora));
        entradaAbierta = null;
      }
    }
    // Sigue dentro: tramo en curso
    if (entradaAbierta != null) {
      tramos.add(TramoJornada(entrada: entradaAbierta));
    }
    if (tramos.isEmpty) {
      return null;
    }

    final Duration total =
        tramos.fold(Duration.zero, (Duration acc, TramoJornada t) => acc + t.duracion);
    return JornadaReal(
      entrada: tramos.first.entrada,
      salida: tramos.last.salida,
      trabajado: total,
      tramos: tramos,
    );
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
