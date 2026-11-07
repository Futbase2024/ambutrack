import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form_style.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_grid_column.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GestionFormParse.decimal', () {
    test('formato español con miles y decimales', () {
      expect(GestionFormParse.decimal('1.234,56'), 1234.56);
      expect(GestionFormParse.decimal('1234,5'), 1234.5);
    });

    test('formato con punto decimal', () {
      expect(GestionFormParse.decimal('1234.56'), 1234.56);
    });

    test('vacío devuelve null', () {
      expect(GestionFormParse.decimal('  '), isNull);
    });
  });

  group('GestionFormParse.entero', () {
    test('ignora separadores de miles', () {
      expect(GestionFormParse.entero('12.500'), 12500);
    });

    test('vacío devuelve null', () {
      expect(GestionFormParse.entero(''), isNull);
    });
  });

  test('formatEntero y formatDecimal usan formato español', () {
    expect(GestionFormParse.formatEntero(12500), '12.500');
    expect(GestionFormParse.formatDecimal(1234.5), '1.234,50');
    expect(GestionFormParse.formatDecimal(null), '');
  });

  group('GestionColumn.requiredWidth', () {
    Widget celda(Object _) => const SizedBox.shrink();

    test('columna fija usa su ancho', () {
      expect(GestionColumn<Object>(label: 'A', cell: celda, width: 90).requiredWidth, 90);
    });

    test('columna flexible usa su mínimo o el mínimo por defecto', () {
      expect(GestionColumn<Object>(label: 'A', cell: celda, minWidth: 180).requiredWidth, 180);
      expect(GestionColumn<Object>(label: 'A', cell: celda).requiredWidth, GestionColumn.defaultMinWidth);
    });
  });
}
