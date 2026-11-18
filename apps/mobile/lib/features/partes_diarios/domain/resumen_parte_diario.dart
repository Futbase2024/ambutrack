import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados de traslado que cuentan como "no realizado" en el parte
const Set<EstadoTraslado> _estadosNoRealizados = <EstadoTraslado>{
  EstadoTraslado.noRealizado,
  EstadoTraslado.cancelado,
  EstadoTraslado.suspendido,
  EstadoTraslado.anulado,
};

/// Resumen de la jornada de un trabajador: tiempo fichado, servicios y km.
class ResumenParteDiario extends Equatable {
  const ResumenParteDiario({
    required this.tiempoTrabajado,
    required this.realizados,
    required this.noRealizados,
    required this.pendientes,
    required this.kmTotales,
    required this.jornadaAbierta,
  });

  /// Calcula el resumen a partir de los fichajes y traslados del día.
  ///
  /// El tiempo se obtiene emparejando cada entrada con la siguiente salida.
  /// Si la última entrada no tiene salida, cuenta hasta [ahora] (jornada en
  /// curso) siempre que [ahora] sea posterior a la entrada.
  factory ResumenParteDiario.calcular({
    required List<RegistroHorarioEntity> fichajes,
    required List<TrasladoEntity> traslados,
    required DateTime ahora,
  }) {
    final List<RegistroHorarioEntity> ordenados = List<RegistroHorarioEntity>.of(fichajes)
      ..sort((RegistroHorarioEntity a, RegistroHorarioEntity b) => a.fechaHora.compareTo(b.fechaHora));

    Duration total = Duration.zero;
    DateTime? entrada;
    for (final RegistroHorarioEntity f in ordenados) {
      final String tipo = f.tipo.toLowerCase();
      if (tipo == 'entrada') {
        entrada ??= f.fechaHora;
      } else if (tipo == 'salida' && entrada != null) {
        total += f.fechaHora.difference(entrada);
        entrada = null;
      }
    }
    final bool abierta = entrada != null;
    if (entrada != null && ahora.isAfter(entrada)) {
      total += ahora.difference(entrada);
    }

    int realizados = 0;
    int noRealizados = 0;
    int pendientes = 0;
    double km = 0;
    for (final TrasladoEntity t in traslados) {
      final EstadoTraslado? estado = EstadoTraslado.fromValue(t.estado);
      if (estado == EstadoTraslado.finalizado) {
        realizados++;
      } else if (_estadosNoRealizados.contains(estado)) {
        noRealizados++;
      } else {
        pendientes++;
      }
      km += kmDeTraslado(t);
    }

    return ResumenParteDiario(
      tiempoTrabajado: total,
      realizados: realizados,
      noRealizados: noRealizados,
      pendientes: pendientes,
      kmTotales: km,
      jornadaAbierta: abierta,
    );
  }

  final Duration tiempoTrabajado;
  final int realizados;
  final int noRealizados;
  final int pendientes;
  final double kmTotales;

  /// Hay una entrada sin salida (jornada en curso o sin cerrar)
  final bool jornadaAbierta;

  int get totalServicios => realizados + noRealizados + pendientes;

  @override
  List<Object?> get props =>
      <Object?>[tiempoTrabajado, realizados, noRealizados, pendientes, kmTotales, jornadaAbierta];
}

/// Km recorridos en un traslado: `kmTotales` o, en su defecto, fin - inicio.
double kmDeTraslado(TrasladoEntity t) {
  final double? totales = t.kmTotales;
  if (totales != null && totales > 0) {
    return totales;
  }
  final double? inicio = t.kmInicio;
  final double? fin = t.kmFin;
  if (inicio != null && fin != null && fin > inicio) {
    return fin - inicio;
  }
  return 0;
}

/// "7 h 05 min"
String formatDuracion(Duration d) {
  final int horas = d.inHours;
  final int minutos = d.inMinutes.remainder(60);
  return '$horas h ${minutos.toString().padLeft(2, '0')} min';
}
