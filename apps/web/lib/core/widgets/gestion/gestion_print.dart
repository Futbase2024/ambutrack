import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_formatters.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Impresión / exportación a PDF de listados de las pantallas de gestión
class GestionPrint {
  const GestionPrint._();

  /// Abre el diálogo de impresión con un listado en A4 apaisado.
  ///
  /// Desde el diálogo del navegador también se puede "Guardar como PDF".
  static Future<void> listado({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
    String? subtitle,
  }) async {
    debugPrint('🖨️ GestionPrint: imprimiendo "$title" (${rows.length} filas)');
    final pw.Document doc = pw.Document();
    final String fecha = GestionFormatters.fecha(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (pw.Context ctx) => _header(title, subtitle, fecha),
        footer: (pw.Context ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _gray),
          ),
        ),
        build: (pw.Context ctx) => <pw.Widget>[
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(color: _border, width: 0.5),
              bottom: pw.BorderSide(color: _border, width: 0.5),
            ),
            headerStyle: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: _headerBg),
            cellStyle: const pw.TextStyle(fontSize: 8.5),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Total: ${rows.length} registros',
            style: const pw.TextStyle(fontSize: 8.5, color: _gray),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      name: '${title.replaceAll(' ', '_')}_$fecha',
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  static final PdfColor _primary = PdfColor.fromInt(AppColors.primary.toARGB32());
  static const PdfColor _gray = PdfColor.fromInt(0xFF6B7280);
  static const PdfColor _border = PdfColor.fromInt(0xFFD1D5DB);
  static const PdfColor _headerBg = PdfColor.fromInt(0xFFF0F2F5);

  static pw.Widget _header(String title, String? subtitle, String fecha) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _primary, width: 1.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: <pw.Widget>[
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(
                'AmbuTrack',
                style: pw.TextStyle(fontSize: 9, color: _primary, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              if (subtitle != null)
                pw.Text(subtitle, style: const pw.TextStyle(fontSize: 9, color: _gray)),
            ],
          ),
          pw.Text('Fecha: $fecha', style: const pw.TextStyle(fontSize: 9, color: _gray)),
        ],
      ),
    );
  }
}
