import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/resultado_generacion_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/services/estadisticas_generacion_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

TurnoEntity _turno(String idPersonal, TipoTurno tipo, int dia) {
  final DateTime inicio = DateTime(2026, 11, dia, 7);
  return TurnoEntity(
    id: '$idPersonal-$dia-${tipo.name}',
    idPersonal: idPersonal,
    nombrePersonal: '',
    tipoTurno: tipo,
    fechaInicio: inicio,
    fechaFin: inicio.add(const Duration(hours: 8)),
    horaInicio: '07:00',
    horaFin: '15:00',
  );
}

void main() {
  group('calcularCobertura', () {
    test('todos los huecos cubiertos → 100', () {
      expect(EstadisticasGeneracionCalculator.calcularCobertura(huecosCubiertos: 9, huecosNecesarios: 9), 100);
    });

    test('cobertura parcial', () {
      expect(EstadisticasGeneracionCalculator.calcularCobertura(huecosCubiertos: 6, huecosNecesarios: 9),
          closeTo(66.67, 0.01));
    });

    test('ningún hueco cubierto → 0', () {
      expect(EstadisticasGeneracionCalculator.calcularCobertura(huecosCubiertos: 0, huecosNecesarios: 9), 0);
    });

    test('sin huecos necesarios → 100', () {
      expect(EstadisticasGeneracionCalculator.calcularCobertura(huecosCubiertos: 0, huecosNecesarios: 0), 100);
    });

    test('nunca supera 100', () {
      expect(EstadisticasGeneracionCalculator.calcularCobertura(huecosCubiertos: 12, huecosNecesarios: 9), 100);
    });
  });

  group('calcular', () {
    test('estadísticas con cobertura real', () {
      final EstadisticasGeneracion e = EstadisticasGeneracionCalculator.calcular(
        turnosGenerados: <TurnoEntity>[
          _turno('p1', TipoTurno.manana, 1),
          _turno('p2', TipoTurno.tarde, 1),
          _turno('p1', TipoTurno.manana, 2),
        ],
        huecosNecesarios: 6,
      );
      expect(e.totalTurnosGenerados, 3);
      expect(e.totalPersonalAsignado, 2);
      expect(e.horasPromedioPorPersona, 12);
      expect(e.distribucionPorTipoTurno, <TipoTurno, int>{TipoTurno.manana: 2, TipoTurno.tarde: 1});
      expect(e.coberturaCompletada, 50);
    });

    test('sin turnos generados', () {
      final EstadisticasGeneracion e =
          EstadisticasGeneracionCalculator.calcular(turnosGenerados: <TurnoEntity>[], huecosNecesarios: 3);
      expect(e.coberturaCompletada, 0);
      expect(e.horasPromedioPorPersona, 0);
    });
  });
}
