import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/validation_result_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/services/turno_ausencias_checker.dart';
import 'package:flutter_test/flutter_test.dart';

TurnoEntity _turno({
  required DateTime inicio,
  DateTime? fin,
  String horaInicio = '07:00',
  String horaFin = '15:00',
  String idPersonal = 'p1',
}) {
  return TurnoEntity(
    id: 't1',
    idPersonal: idPersonal,
    nombrePersonal: 'ANA LÓPEZ',
    tipoTurno: TipoTurno.manana,
    fechaInicio: inicio,
    fechaFin: fin ?? inicio,
    horaInicio: horaInicio,
    horaFin: horaFin,
  );
}

AusenciaEntity _ausencia({
  EstadoAusencia estado = EstadoAusencia.aprobada,
  bool activo = true,
  String idPersonal = 'p1',
}) {
  return AusenciaEntity(
    id: 'a1',
    idPersonal: idPersonal,
    idTipoAusencia: 'tipo-baja',
    fechaInicio: DateTime(2026, 11, 10),
    fechaFin: DateTime(2026, 11, 12),
    estado: estado,
    activo: activo,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

VacacionesEntity _vacaciones({String estado = 'aprobada', bool activo = true}) {
  return VacacionesEntity(
    id: 'v1',
    idPersonal: 'p1',
    fechaInicio: DateTime(2026, 12),
    fechaFin: DateTime(2026, 12, 5),
    diasSolicitados: 5,
    estado: estado,
    activo: activo,
  );
}

void main() {
  group('desdeAusencias / desdeVacaciones', () {
    test('solo incluye ausencias aprobadas y activas, con nombre del tipo', () {
      final List<PeriodoIndisponibilidad> periodos = TurnoAusenciasChecker.desdeAusencias(
        <AusenciaEntity>[
          _ausencia(),
          _ausencia(estado: EstadoAusencia.pendiente),
          _ausencia(estado: EstadoAusencia.rechazada),
          _ausencia(activo: false),
        ],
        nombresTipo: <String, String>{'tipo-baja': 'Baja médica'},
      );
      expect(periodos, hasLength(1));
      expect(periodos.first.motivo, 'baja médica');
      expect(periodos.first.esVacaciones, isFalse);
    });

    test('ausencia sin tipo conocido usa "ausencia" como motivo', () {
      final List<PeriodoIndisponibilidad> periodos =
          TurnoAusenciasChecker.desdeAusencias(<AusenciaEntity>[_ausencia()]);
      expect(periodos.single.motivo, 'ausencia');
    });

    test('solo incluye vacaciones aprobadas (sin distinguir mayúsculas) y activas', () {
      final List<PeriodoIndisponibilidad> periodos = TurnoAusenciasChecker.desdeVacaciones(
        <VacacionesEntity>[
          _vacaciones(),
          _vacaciones(estado: 'Aprobada'),
          _vacaciones(estado: 'pendiente'),
          _vacaciones(activo: false),
        ],
      );
      expect(periodos, hasLength(2));
      expect(periodos.every((PeriodoIndisponibilidad p) => p.esVacaciones), isTrue);
    });
  });

  group('diasDelTurno', () {
    test('turno diurno ocupa un día', () {
      final List<DateTime> dias = TurnoAusenciasChecker.diasDelTurno(
        _turno(inicio: DateTime(2026, 11, 10, 7), fin: DateTime(2026, 11, 10, 15)),
      );
      expect(dias, <DateTime>[DateTime(2026, 11, 10)]);
    });

    test('turno nocturno solo cuenta el día de inicio', () {
      final List<DateTime> dias = TurnoAusenciasChecker.diasDelTurno(
        _turno(
          inicio: DateTime(2026, 11, 9, 23),
          fin: DateTime(2026, 11, 10, 7),
          horaInicio: '23:00',
          horaFin: '07:00',
        ),
      );
      expect(dias, <DateTime>[DateTime(2026, 11, 9)]);
    });

    test('turno de varios días incluye todos sus días', () {
      final List<DateTime> dias = TurnoAusenciasChecker.diasDelTurno(
        _turno(inicio: DateTime(2026, 11, 9, 8), fin: DateTime(2026, 11, 11, 20), horaInicio: '08:00', horaFin: '20:00'),
      );
      expect(dias, hasLength(3));
    });
  });

  group('validar', () {
    final List<PeriodoIndisponibilidad> periodos = <PeriodoIndisponibilidad>[
      ...TurnoAusenciasChecker.desdeAusencias(
        <AusenciaEntity>[_ausencia()],
        nombresTipo: <String, String>{'tipo-baja': 'Baja médica'},
      ),
      ...TurnoAusenciasChecker.desdeVacaciones(<VacacionesEntity>[_vacaciones()]),
    ];

    test('turno dentro de una ausencia aprobada → error crítico con mensaje claro', () {
      final ValidationResult r = TurnoAusenciasChecker.validar(
        turno: _turno(inicio: DateTime(2026, 11, 11, 7)),
        idPersonal: 'p1',
        periodos: periodos,
      );
      expect(r.hasErrors, isTrue);
      expect(r.errors.single.ruleType, ValidationRuleType.cruceConAusencia);
      expect(r.errors.single.message, 'ANA LÓPEZ tiene baja médica aprobada del 10/11/2026 al 12/11/2026');
    });

    test('límites inclusivos: primer y último día de la ausencia', () {
      for (final DateTime dia in <DateTime>[DateTime(2026, 11, 10, 7), DateTime(2026, 11, 12, 7)]) {
        final ValidationResult r =
            TurnoAusenciasChecker.validar(turno: _turno(inicio: dia), idPersonal: 'p1', periodos: periodos);
        expect(r.hasErrors, isTrue, reason: '$dia');
      }
    });

    test('turno en vacaciones aprobadas → error con mensaje de vacaciones', () {
      final ValidationResult r = TurnoAusenciasChecker.validar(
        turno: _turno(inicio: DateTime(2026, 12, 3, 7)),
        idPersonal: 'p1',
        periodos: periodos,
      );
      expect(r.errors.single.message, 'ANA LÓPEZ tiene vacaciones aprobadas del 01/12/2026 al 05/12/2026');
    });

    test('turno fuera de cualquier periodo → sin errores', () {
      final ValidationResult r = TurnoAusenciasChecker.validar(
        turno: _turno(inicio: DateTime(2026, 11, 13, 7)),
        idPersonal: 'p1',
        periodos: periodos,
      );
      expect(r.issues, isEmpty);
    });

    test('noche anterior a la ausencia no entra en conflicto', () {
      final ValidationResult r = TurnoAusenciasChecker.validar(
        turno: _turno(
          inicio: DateTime(2026, 11, 9, 23),
          fin: DateTime(2026, 11, 10, 7),
          horaInicio: '23:00',
          horaFin: '07:00',
        ),
        idPersonal: 'p1',
        periodos: periodos,
      );
      expect(r.issues, isEmpty);
    });

    test('la ausencia de otra persona no afecta', () {
      final ValidationResult r = TurnoAusenciasChecker.validar(
        turno: _turno(inicio: DateTime(2026, 11, 11, 7), idPersonal: 'p2'),
        idPersonal: 'p2',
        periodos: periodos,
      );
      expect(r.issues, isEmpty);
    });
  });
}
