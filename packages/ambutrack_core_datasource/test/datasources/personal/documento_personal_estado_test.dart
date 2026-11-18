import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

DocumentoPersonalEntity _doc({DateTime? caducidad, String? nombre}) => DocumentoPersonalEntity(
      id: 'doc-1',
      personalId: 'per-1',
      tipo: TipoDocumentoPersonal.carnetConducir,
      nombre: nombre,
      fechaCaducidad: caducidad,
    );

void main() {
  final DateTime hoy = DateTime(2026, 11, 18, 17, 45);

  group('EstadoDocumentoPersonal.calcular', () {
    test('sin fecha de caducidad → sinCaducidad', () {
      expect(EstadoDocumentoPersonal.calcular(null, hoy), EstadoDocumentoPersonal.sinCaducidad);
    });

    test('caducado ayer → caducado', () {
      expect(
        EstadoDocumentoPersonal.calcular(DateTime(2026, 11, 17), hoy),
        EstadoDocumentoPersonal.caducado,
      );
    });

    test('caduca hoy (con hora anterior) → próximo a caducar, no caducado', () {
      expect(
        EstadoDocumentoPersonal.calcular(DateTime(2026, 11, 18), hoy),
        EstadoDocumentoPersonal.proximoACaducar,
      );
    });

    test('caduca justo dentro de 30 días → próximo a caducar', () {
      expect(
        EstadoDocumentoPersonal.calcular(DateTime(2026, 12, 18), hoy),
        EstadoDocumentoPersonal.proximoACaducar,
      );
    });

    test('caduca dentro de 31 días → vigente', () {
      expect(
        EstadoDocumentoPersonal.calcular(DateTime(2026, 12, 19), hoy),
        EstadoDocumentoPersonal.vigente,
      );
    });

    test('caduca dentro de años → vigente', () {
      expect(
        EstadoDocumentoPersonal.calcular(DateTime(2030), hoy),
        EstadoDocumentoPersonal.vigente,
      );
    });
  });

  group('DocumentoPersonalEntity', () {
    test('estado() usa la fecha de referencia', () {
      expect(_doc(caducidad: DateTime(2026, 1, 1)).estado(hoy), EstadoDocumentoPersonal.caducado);
    });

    test('diasHastaCaducidad positivo, cero y negativo', () {
      expect(_doc(caducidad: DateTime(2026, 11, 28)).diasHastaCaducidad(hoy), 10);
      expect(_doc(caducidad: DateTime(2026, 11, 18)).diasHastaCaducidad(hoy), 0);
      expect(_doc(caducidad: DateTime(2026, 11, 15)).diasHastaCaducidad(hoy), -3);
      expect(_doc().diasHastaCaducidad(hoy), isNull);
    });

    test('descripcion usa el nombre o, si falta, la etiqueta del tipo', () {
      expect(_doc(nombre: 'Carnet C1').descripcion, 'Carnet C1');
      expect(_doc(nombre: '  ').descripcion, TipoDocumentoPersonal.carnetConducir.label);
    });

    test('TipoDocumentoPersonal.fromString con valor desconocido → otro', () {
      expect(TipoDocumentoPersonal.fromString('dni'), TipoDocumentoPersonal.dni);
      expect(TipoDocumentoPersonal.fromString('xyz'), TipoDocumentoPersonal.otro);
      expect(TipoDocumentoPersonal.fromString(null), TipoDocumentoPersonal.otro);
    });
  });
}
