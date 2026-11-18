import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/documentacion/documentacion_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/evaluaciones/evaluacion_gestion_columns.dart';
import 'package:flutter_test/flutter_test.dart';

DocumentoPersonalEntity _doc(String id, TipoDocumentoPersonal tipo, DateTime? caducidad) => DocumentoPersonalEntity(
      id: id,
      personalId: 'per-$id',
      tipo: tipo,
      fechaCaducidad: caducidad,
      personalNombre: 'TRABAJADOR $id',
    );

void main() {
  group('Documentación del personal', () {
    final DateTime hoy = DateTime.now();
    final List<DocumentoPersonalEntity> docs = <DocumentoPersonalEntity>[
      _doc('1', TipoDocumentoPersonal.dni, hoy.add(const Duration(days: 400))),
      _doc('2', TipoDocumentoPersonal.carnetConducir, hoy.add(const Duration(days: 10))),
      _doc('3', TipoDocumentoPersonal.carnetConducir, hoy.subtract(const Duration(days: 5))),
      _doc('4', TipoDocumentoPersonal.titulacion, null),
    ];

    test('filtra por estado de caducidad', () {
      final List<DocumentoPersonalEntity> r = filtrarDocumentos(
        docs,
        query: '',
        tipo: null,
        estado: EstadoDocumentoPersonal.caducado,
      );
      expect(r.map((DocumentoPersonalEntity d) => d.id), <String>['3']);
    });

    test('filtra por tipo y texto', () {
      expect(
        filtrarDocumentos(docs, query: '', tipo: TipoDocumentoPersonal.carnetConducir, estado: null).length,
        2,
      );
      expect(filtrarDocumentos(docs, query: 'trabajador 4', tipo: null, estado: null).single.id, '4');
    });

    test('resumen cuenta vigentes, próximos y caducados', () {
      expect(
        resumenDocumentos(docs, 4),
        <String>['4 registros', '1 vigentes', '1 próximos a caducar', '1 caducados'],
      );
    });
  });

  group('Evaluaciones de desempeño', () {
    test('banda de valoración según la media', () {
      expect(ValoracionEvaluacion.de(4.5), ValoracionEvaluacion.alta);
      expect(ValoracionEvaluacion.de(4), ValoracionEvaluacion.alta);
      expect(ValoracionEvaluacion.de(3.75), ValoracionEvaluacion.media);
      expect(ValoracionEvaluacion.de(2.99), ValoracionEvaluacion.baja);
    });

    test('media con coma decimal', () {
      expect(evaluacionMediaTexto(3.75), '3,75');
      expect(evaluacionMediaTexto(4), '4,00');
    });
  });
}
