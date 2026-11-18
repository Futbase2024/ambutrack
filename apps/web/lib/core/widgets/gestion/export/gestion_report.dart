/// Modelo neutro de informe para exportar a PDF y Excel.
///
/// Una pantalla construye un [GestionReport] una sola vez y lo pasa a
/// `GestionReportPdf` o `GestionReportExcel`, que lo renderizan cada uno
/// a su formato. Así PDF y Excel siempre contienen los mismos datos.
///
/// Valores de celda admitidos: `String`, `int`, `double`, `bool`, `DateTime`,
/// [GestionMoney], [GestionCell] y `null` (se muestra como vacío).
library;

import 'dart:ui' show Color;

import 'package:ambutrack_web/core/widgets/gestion/gestion_formatters.dart';
import 'package:intl/intl.dart';

/// Importe en euros (se formatea como moneda en PDF y Excel)
class GestionMoney {
  const GestionMoney(this.value);

  final double value;
}

/// Cómo se pinta una [GestionCell]
enum GestionCellKind {
  /// Texto/valor normal (con color y negrita opcionales)
  text,

  /// Booleano: ✓ verde si es true, — gris si es false (como en la rejilla)
  check,

  /// Punto de color + texto (indicador de estado)
  dot,
}

/// Celda con estilo, para que el informe se vea igual que la rejilla
class GestionCell {
  const GestionCell(this.value, {this.color, this.bold = false}) : kind = GestionCellKind.text;

  const GestionCell.check({required bool checked})
      : value = checked,
        kind = GestionCellKind.check,
        color = null,
        bold = false;

  const GestionCell.dot(String this.value, {required Color this.color})
      : kind = GestionCellKind.dot,
        bold = false;

  final Object? value;
  final GestionCellKind kind;

  /// Color del texto (o del punto en [GestionCellKind.dot])
  final Color? color;
  final bool bold;

  bool get checked => value == true;
}

/// Alineación horizontal de una columna
enum GestionReportAlign { left, center, right }

/// Sección de un informe
sealed class GestionReportSection {
  const GestionReportSection({required this.title});

  final String title;
}

/// Sección de pares etiqueta → valor (ficha de un registro)
class GestionReportFields extends GestionReportSection {
  const GestionReportFields({required super.title, required this.fields});

  final List<GestionReportField> fields;
}

/// Un par etiqueta → valor de [GestionReportFields]
class GestionReportField {
  const GestionReportField(this.label, this.value, {this.highlight = false});

  final String label;
  final Object? value;

  /// Resalta el valor (p.ej. un vencimiento ya pasado)
  final bool highlight;
}

/// Columna de [GestionReportTable]
class GestionReportColumn {
  const GestionReportColumn(this.label, {this.flex = 1, this.excelWidth, this.align = GestionReportAlign.left});

  final String label;
  final GestionReportAlign align;

  /// Ancho relativo en el PDF
  final double flex;

  /// Ancho en caracteres en Excel (si es null se calcula)
  final double? excelWidth;
}

/// Sección en forma de tabla
class GestionReportTable extends GestionReportSection {
  const GestionReportTable({
    required super.title,
    required this.columns,
    required this.rows,
    this.emptyMessage = 'Sin registros',
    this.footer,
    this.sheetName,
  });

  final List<GestionReportColumn> columns;
  final List<List<Object?>> rows;
  final String emptyMessage;

  /// Línea de resumen bajo la tabla (p.ej. "Importe total: 1.200,00 €")
  final String? footer;

  /// Nombre de la hoja en Excel (por defecto, el título)
  final String? sheetName;
}

/// Informe completo: cabecera + secciones
class GestionReport {
  const GestionReport({
    required this.title,
    required this.sections,
    this.subtitle,
    this.landscape = false,
    this.summary = const <GestionReportField>[],
  });

  final String title;
  final String? subtitle;

  /// Indicadores destacados bajo la cabecera (p.ej. totales por estado)
  final List<GestionReportField> summary;
  final List<GestionReportSection> sections;

  /// Orientación horizontal en el PDF
  final bool landscape;

  /// Copia con otra orientación del PDF
  GestionReport withOrientation({required bool landscape}) => GestionReport(
        title: title,
        subtitle: subtitle,
        summary: summary,
        sections: sections,
        landscape: landscape,
      );
}

/// Conversión de valores de celda a texto (común a PDF y Excel)
class GestionReportFormat {
  const GestionReportFormat._();

  static final NumberFormat _entero = NumberFormat.decimalPattern('es_ES');
  static final NumberFormat _decimal = NumberFormat('#,##0.##', 'es_ES');

  static String text(Object? value) {
    return switch (value) {
      null => GestionFormatters.vacio,
      final String s => GestionFormatters.texto(s),
      final bool b => b ? 'Sí' : 'No',
      final int i => _entero.format(i),
      final double d => _decimal.format(d),
      final DateTime f => GestionFormatters.fecha(f),
      final GestionMoney m => GestionFormatters.moneda(m.value),
      GestionCell(kind: GestionCellKind.check, checked: final bool c) => c ? '✓' : GestionFormatters.vacio,
      final GestionCell c => text(c.value),
      _ => value.toString(),
    };
  }
}
