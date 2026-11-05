import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Generador de PDFs para incidencias
class PdfIncidenciaGenerator {
  PdfIncidenciaGenerator._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Genera un PDF individual para una incidencia
  static Future<void> printSingle(IncidenciaEntity item) async {
    final pw.Document doc = pw.Document()
      ..addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.portrait,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              // Header
              _buildHeader('Incidencia #${item.id.substring(0, 8)}'),
              pw.SizedBox(height: 20),

              // Título
              pw.Text(item.titulo, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),

              // Info table
              _buildInfoTable(item),
              pw.SizedBox(height: 16),

              // Descripción
              if (item.descripcion != null && item.descripcion!.isNotEmpty) ...<pw.Widget>[
                pw.Text('Descripción', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text(item.descripcion!, style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 16),
              ],

              // Resolución
              if (item.resolucion != null && item.resolucion!.isNotEmpty) ...<pw.Widget>[
                pw.Text('Resolución', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text(item.resolucion!, style: const pw.TextStyle(fontSize: 11)),
              ],

              // Footer
              pw.Spacer(),
              pw.Divider(),
              pw.Text(
                'Generado el ${_dateFormat.format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
      );

    await _displayPdf(await doc.save());
  }

  /// Genera un PDF con el listado de todas las incidencias
  static Future<void> printAll(List<IncidenciaEntity> items) async {
    final pw.Document doc = pw.Document()
      ..addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.landscape,
          margin: const pw.EdgeInsets.all(30),
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              _buildHeader('Listado de Incidencias (${items.length})'),
              pw.SizedBox(height: 12),

              // Tabla
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: <pw.TableRow>[
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue900),
                    children: _tableHeaders
                        .map(
                          (String h) => pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              h,
                              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  // Data rows
                  ...items.map(
                    (IncidenciaEntity item) => pw.TableRow(
                      children: <pw.Widget>[
                        _tableCell(item.titulo),
                        _tableCell(item.categoria.displayName),
                        _tableCell(item.prioridad.displayName),
                        _tableCell(item.estado.displayName),
                        _tableCell(_dateFormat.format(item.fechaIncidencia)),
                        _tableCell(item.responsableNombre ?? '—'),
                      ],
                    ),
                  ),
                ],
              ),

              // Footer
              pw.Spacer(),
              pw.Divider(),
              pw.Text(
                'Generado el ${_dateFormat.format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
      );

    await _displayPdf(await doc.save());
  }

  // === Helpers privados ===

  static final List<String> _tableHeaders = <String>[
    'Título',
    'Categoría',
    'Prioridad',
    'Estado',
    'Fecha',
    'Responsable',
  ];

  static pw.Widget _tableCell(String text, {int maxLines = 1}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9), maxLines: maxLines),
    );
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        pw.Text(
          'AmbuTrack',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
        ),
        pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildInfoTable(IncidenciaEntity item) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: <pw.TableRow>[
        _infoRow('Categoría', item.categoria.displayName),
        _infoRow('Prioridad', item.prioridad.displayName),
        _infoRow('Estado', item.estado.displayName),
        _infoRow('Fecha', _dateFormat.format(item.fechaIncidencia)),
        _infoRow('Responsable', item.responsableNombre ?? 'Sin asignar'),
        if (item.vehiculoMatricula != null) _infoRow('Vehículo', item.vehiculoMatricula!),
        if (item.fechaResolucion != null) _infoRow('Fecha Resolución', _dateFormat.format(item.fechaResolucion!)),
        _infoRow('Reportado por', item.reportadoPorNombre ?? '—'),
      ],
    );
  }

  static pw.TableRow _infoRow(String label, String value) {
    return pw.TableRow(
      children: <pw.Widget>[
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          color: PdfColors.grey100,
          child: pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  static Future<void> _displayPdf(Uint8List bytes) async {
    // En web, abrir en nueva pestaña
    if (globalContext.has('Blob')) {
      final _JsBlob blob = _JsBlob(<JSAny>[bytes.toJS].toJS, _JsBlobOptions(type: 'application/pdf'));
      final String url = _createObjectUrl(blob);
      _windowOpen(url, '_blank');
    } else {
      // Fallback para plataformas nativas
      await Printing.layoutPdf(onLayout: (_) => bytes);
    }
  }
}

/// Constructor JS `Blob`
@JS('Blob')
extension type _JsBlob._(JSObject _) implements JSObject {
  external factory _JsBlob(JSArray<JSAny> parts, _JsBlobOptions options);
}

/// Opciones del constructor `Blob`
extension type _JsBlobOptions._(JSObject _) implements JSObject {
  external factory _JsBlobOptions({String type});
}

@JS('URL.createObjectURL')
external String _createObjectUrl(_JsBlob blob);

@JS('window.open')
external JSObject? _windowOpen(String url, String target);
