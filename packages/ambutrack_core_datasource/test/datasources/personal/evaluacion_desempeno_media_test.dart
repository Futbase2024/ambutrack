import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

EvaluacionDesempenoEntity _eval(int a, int b, int c, int d, {double? media}) => EvaluacionDesempenoEntity(
      id: 'ev-1',
      personalId: 'per-1',
      fecha: DateTime(2026, 11, 18),
      puntualidad: a,
      tratoPaciente: b,
      trabajoEquipo: c,
      cumplimientoProtocolos: d,
      puntuacionMedia: media,
    );

void main() {
  group('EvaluacionDesempenoEntity.calcularMedia', () {
    test('lista vacía → 0', () {
      expect(EvaluacionDesempenoEntity.calcularMedia(<int>[]), 0);
    });

    test('todas iguales → ese valor', () {
      expect(EvaluacionDesempenoEntity.calcularMedia(<int>[5, 5, 5, 5]), 5);
    });

    test('media exacta con decimales', () {
      expect(EvaluacionDesempenoEntity.calcularMedia(<int>[4, 3, 5, 3]), 3.75);
    });

    test('redondea a 2 decimales', () {
      expect(EvaluacionDesempenoEntity.calcularMedia(<int>[1, 2, 2]), 1.67);
    });
  });

  group('EvaluacionDesempenoEntity', () {
    test('puntuacionMedia calculada en cliente si la BD no la devuelve', () {
      expect(_eval(4, 4, 5, 2).puntuacionMedia, 3.75);
    });

    test('puntuacionMedia prioriza el valor de la BD', () {
      expect(_eval(4, 4, 5, 2, media: 3.75).puntuacionMedia, 3.75);
      expect(_eval(1, 1, 1, 1, media: 2).puntuacionMedia, 2);
    });

    test('puntuaciones expone los cuatro criterios', () {
      final Map<CriterioEvaluacion, int> p = _eval(1, 2, 3, 4).puntuaciones;
      expect(p[CriterioEvaluacion.puntualidad], 1);
      expect(p[CriterioEvaluacion.tratoPaciente], 2);
      expect(p[CriterioEvaluacion.trabajoEquipo], 3);
      expect(p[CriterioEvaluacion.cumplimientoProtocolos], 4);
    });

    test('puntuacionValida acepta solo 1..5', () {
      expect(EvaluacionDesempenoEntity.puntuacionValida(0), isFalse);
      expect(EvaluacionDesempenoEntity.puntuacionValida(1), isTrue);
      expect(EvaluacionDesempenoEntity.puntuacionValida(5), isTrue);
      expect(EvaluacionDesempenoEntity.puntuacionValida(6), isFalse);
    });
  });
}
