import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/export/gestion_report.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Renderiza uno o varios [GestionReport] como PDF con estilo corporativo.
///
/// Cada informe empieza en página nueva y repite su cabecera en cada página.
class GestionReportPdf {
  const GestionReportPdf._();

  /// Abre la vista previa del navegador para imprimir o guardar como PDF
  static Future<void> imprimir(List<GestionReport> reports, {required String fileName}) async {
    final Uint8List bytes = await generar(reports);
    await Printing.layoutPdf(name: fileName, onLayout: (PdfPageFormat _) async => bytes);
  }

  /// Descarga directamente el archivo PDF
  static Future<void> descargar(List<GestionReport> reports, {required String fileName}) async {
    final Uint8List bytes = await generar(reports);
    await Printing.sharePdf(bytes: bytes, filename: '$fileName.pdf');
  }

  /// Genera los bytes del PDF
  static Future<Uint8List> generar(List<GestionReport> reports) async {
    debugPrint('📄 GestionReportPdf: generando ${reports.length} informe(s)');
    final pw.ThemeData theme = await _theme();
    final String generado = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final pw.Document doc = pw.Document(title: reports.first.title, author: 'AmbuTrack', theme: theme);
    for (final GestionReport r in reports) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: r.landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 24),
          header: (pw.Context _) => _PdfParts.header(r),
          footer: (pw.Context ctx) => _PdfParts.footer(ctx, generado),
          build: (pw.Context _) => <pw.Widget>[
            if (r.summary.isNotEmpty) _PdfParts.summary(r.summary),
            for (final GestionReportSection s in r.sections) ..._PdfParts.section(s, landscape: r.landscape),
          ],
        ),
      );
    }
    return doc.save();
  }

  static pw.ThemeData? _cachedTheme;

  /// Roboto (soporta €, acentos, ñ). Si no se puede descargar, Helvetica.
  static Future<pw.ThemeData> _theme() async {
    final pw.ThemeData? cached = _cachedTheme;
    if (cached != null) {
      return cached;
    }
    try {
      final pw.ThemeData theme = pw.ThemeData.withFont(
        base: await PdfGoogleFonts.robotoRegular(),
        bold: await PdfGoogleFonts.robotoBold(),
        italic: await PdfGoogleFonts.robotoItalic(),
      );
      return _cachedTheme = theme;
    } catch (e) {
      debugPrint('⚠️ GestionReportPdf: no se pudo cargar Roboto, uso Helvetica ($e)');
      return pw.ThemeData.base();
    }
  }
}

PdfColor _pdf(Color c) => PdfColor.fromInt(c.toARGB32());

/// Piezas visuales del PDF
class _PdfParts {
  const _PdfParts._();

  static final PdfColor primary = _pdf(AppColors.primary);
  static final PdfColor primarySurface = _pdf(AppColors.primarySurface);
  static final PdfColor gray50 = _pdf(AppColors.gray50);
  static final PdfColor gray200 = _pdf(AppColors.gray200);
  static final PdfColor gray400 = _pdf(AppColors.gray400);
  static final PdfColor gray500 = _pdf(AppColors.gray500);
  static final PdfColor gray800 = _pdf(AppColors.gray800);
  static final PdfColor error = _pdf(AppColors.error);
  static const PdfColor white = PdfColors.white;

  static pw.Widget header(GestionReport r) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: primary, width: 2)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: <pw.Widget>[
          pw.Container(
            width: 30,
            height: 30,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(color: primary, borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Text(
              'A',
              style: pw.TextStyle(color: white, fontSize: 17, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  'AMBUTRACK · GESTIÓN DE FLOTA',
                  style: pw.TextStyle(fontSize: 7.5, color: primary, fontWeight: pw.FontWeight.bold, letterSpacing: 1),
                ),
                pw.Text(
                  r.title,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: gray800),
                ),
                if (r.subtitle != null) pw.Text(r.subtitle!, style: pw.TextStyle(fontSize: 9, color: gray500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget footer(pw.Context ctx, String generado) {
    final pw.TextStyle style = pw.TextStyle(fontSize: 7.5, color: gray500);
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 5),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: gray200, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Text('Documento generado por AmbuTrack el $generado', style: style),
          pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}', style: style),
        ],
      ),
    );
  }

  static pw.Widget summary(List<GestionReportField> items) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Row(
        children: <pw.Widget>[
          for (final GestionReportField f in items)
            pw.Expanded(
              child: pw.Container(
                margin: const pw.EdgeInsets.only(right: 6),
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: pw.BoxDecoration(color: primarySurface, borderRadius: pw.BorderRadius.circular(5)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(f.label.toUpperCase(), style: pw.TextStyle(fontSize: 6.5, color: gray500)),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      GestionReportFormat.text(f.value),
                      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: primary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static List<pw.Widget> section(GestionReportSection s, {required bool landscape}) {
    return <pw.Widget>[
      sectionTitle(s.title),
      ...switch (s) {
        final GestionReportFields f => <pw.Widget>[fields(f, columns: landscape ? 3 : 2)],
        final GestionReportTable t => table(t),
      },
      pw.SizedBox(height: 12),
    ];
  }

  static pw.Widget sectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.only(left: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: primary, width: 3)),
      ),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: primary, letterSpacing: 0.5),
      ),
    );
  }

  static pw.Widget fields(GestionReportFields s, {required int columns}) {
    final List<pw.TableRow> rows = <pw.TableRow>[];
    for (int i = 0; i < s.fields.length; i += columns) {
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: gray200, width: 0.5)),
          ),
          children: <pw.Widget>[
            for (int c = i; c < i + columns; c++) c < s.fields.length ? fieldCell(s.fields[c]) : pw.SizedBox(),
          ],
        ),
      );
    }
    return pw.Table(
      columnWidths: <int, pw.TableColumnWidth>{for (int c = 0; c < columns; c++) c: const pw.FlexColumnWidth()},
      children: rows,
    );
  }

  static pw.Widget fieldCell(GestionReportField f) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.SizedBox(
            width: 82,
            child: pw.Text(f.label, style: pw.TextStyle(fontSize: 8, color: gray500)),
          ),
          pw.Expanded(
            child: pw.Text(
              GestionReportFormat.text(f.value),
              style: pw.TextStyle(
                fontSize: 8.5,
                color: f.highlight ? error : gray800,
                fontWeight: f.highlight ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tabla suelta en el documento para que MultiPage la parta entre páginas
  /// (la cabecera se repite en cada página)
  static List<pw.Widget> table(GestionReportTable t) {
    if (t.rows.isEmpty) {
      return <pw.Widget>[
        pw.Text(
          t.emptyMessage,
          style: pw.TextStyle(fontSize: 8.5, color: gray500, fontStyle: pw.FontStyle.italic),
        ),
      ];
    }
    return <pw.Widget>[
      pw.TableHelper.fromTextArray(
        headers: t.columns.map((GestionReportColumn c) => c.label).toList(),
        data: t.rows,
        cellBuilder: (int index, Object? data, int _) => cell(data),
        cellAlignments: <int, pw.Alignment>{
          for (int i = 0; i < t.columns.length; i++) i: _alignment(t.columns[i].align),
        },
        columnWidths: <int, pw.TableColumnWidth>{
          for (int i = 0; i < t.columns.length; i++) i: pw.FlexColumnWidth(t.columns[i].flex),
        },
        headerStyle: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: white),
        headerDecoration: pw.BoxDecoration(color: primary),
        cellStyle: pw.TextStyle(fontSize: 7.5, color: gray800),
        oddRowDecoration: pw.BoxDecoration(color: gray50),
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3.5),
        cellAlignment: pw.Alignment.centerLeft,
        headerAlignment: pw.Alignment.centerLeft,
        border: pw.TableBorder(bottom: pw.BorderSide(color: gray200, width: 0.5)),
      ),
      if (t.footer != null)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Text(t.footer!, style: pw.TextStyle(fontSize: 8, color: gray500)),
        ),
    ];
  }

  static pw.Alignment _alignment(GestionReportAlign a) => switch (a) {
        GestionReportAlign.left => pw.Alignment.centerLeft,
        GestionReportAlign.center => pw.Alignment.center,
        GestionReportAlign.right => pw.Alignment.centerRight,
      };

  /// Icono check_circle (mismo que la rejilla) como vector: no depende de la fuente
  static final String _checkSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
      '<path fill="#${(AppColors.success.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}" '
      'd="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 '
      '1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>';

  /// Celda de tabla: ✓ / — , punto de estado, o texto con color
  static pw.Widget cell(Object? data) {
    final pw.TextStyle base = pw.TextStyle(fontSize: 7.5, color: gray800);
    if (data is! GestionCell) {
      return pw.Text(GestionReportFormat.text(data), style: base);
    }
    switch (data.kind) {
      case GestionCellKind.check:
        return data.checked
            ? pw.SvgImage(svg: _checkSvg, width: 10, height: 10)
            : pw.Text(GestionReportFormat.text(null), style: base.copyWith(color: gray400));
      case GestionCellKind.dot:
        return pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          children: <pw.Widget>[
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(color: _pdf(data.color!), shape: pw.BoxShape.circle),
            ),
            pw.SizedBox(width: 4),
            pw.Text(GestionReportFormat.text(data.value), style: base),
          ],
        );
      case GestionCellKind.text:
        final Color? color = data.color;
        return pw.Text(
          GestionReportFormat.text(data.value),
          style: base.copyWith(
            color: color == null ? null : _pdf(color),
            fontWeight: data.bold ? pw.FontWeight.bold : null,
          ),
        );
    }
  }
}
