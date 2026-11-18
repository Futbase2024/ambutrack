import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/resultado_generacion_entity.dart';

/// Cálculos puros de estadísticas de la generación automática de turnos.
class EstadisticasGeneracionCalculator {
  const EstadisticasGeneracionCalculator._();

  /// Porcentaje (0-100) de huecos cubiertos sobre los necesarios.
  ///
  /// Sin huecos necesarios no hay nada que cubrir → 100 %.
  static double calcularCobertura({
    required int huecosCubiertos,
    required int huecosNecesarios,
  }) {
    if (huecosNecesarios <= 0) {
      return 100;
    }
    final int cubiertos = huecosCubiertos.clamp(0, huecosNecesarios);
    return cubiertos * 100 / huecosNecesarios;
  }

  /// Estadísticas completas a partir de los turnos generados.
  static EstadisticasGeneracion calcular({
    required List<TurnoEntity> turnosGenerados,
    required int huecosNecesarios,
  }) {
    final Map<String, int> turnosPorPersonal = <String, int>{};
    final Map<TipoTurno, int> distribucionPorTipo = <TipoTurno, int>{};
    double totalHoras = 0;

    for (final TurnoEntity turno in turnosGenerados) {
      turnosPorPersonal[turno.idPersonal] = (turnosPorPersonal[turno.idPersonal] ?? 0) + 1;
      distribucionPorTipo[turno.tipoTurno] = (distribucionPorTipo[turno.tipoTurno] ?? 0) + 1;
      totalHoras += turno.fechaFin.difference(turno.fechaInicio).inHours.toDouble();
    }

    final int personalConTurnos = turnosPorPersonal.length;

    return EstadisticasGeneracion(
      totalTurnosGenerados: turnosGenerados.length,
      totalPersonalAsignado: personalConTurnos,
      horasPromedioPorPersona: personalConTurnos > 0 ? totalHoras / personalConTurnos : 0,
      distribucionPorTipoTurno: distribucionPorTipo,
      coberturaCompletada: calcularCobertura(
        huecosCubiertos: turnosGenerados.length,
        huecosNecesarios: huecosNecesarios,
      ),
    );
  }
}
