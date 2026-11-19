import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'parte_diario_data.dart';
import 'pdf_estilos.dart';

/// Piezas comunes de las hojas del parte (cabecera, campos, pastillas, cajas)
class PdfComponentes {
  const PdfComponentes._();

  /// Cabecera: logo + datos de la empresa a la izquierda, título a la derecha
  static pw.Widget cabecera(EmpresaParte empresa, List<String> titulo) {
    final List<String> datos = <String>[
      if ((empresa.razonSocial ?? '').isNotEmpty) empresa.razonSocial! else empresa.nombre,
      if ((empresa.direccion ?? '').isNotEmpty) empresa.direccion!,
      if ((empresa.telefono ?? '').isNotEmpty) 'Tlf: ${empresa.telefono}',
      if ((empresa.cif ?? '').isNotEmpty) 'C.I.F.: ${empresa.cif}',
    ];
    return pw.Column(
      children: <pw.Widget>[
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Expanded(
              flex: 4,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  if (empresa.logo != null)
                    pw.Image(empresa.logo!, height: 44, fit: pw.BoxFit.contain)
                  else
                    pw.Text(empresa.nombre.toUpperCase(), style: PdfEstilos.titulo.copyWith(color: PdfEstilos.granate)),
                  pw.SizedBox(height: 4),
                  for (final String d in datos) pw.Text(d, style: PdfEstilos.empresa),
                ],
              ),
            ),
            pw.Expanded(
              flex: 5,
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8),
                child: pw.Column(
                  children: <pw.Widget>[
                    for (final String t in titulo)
                      pw.Text(t, style: PdfEstilos.titulo, textAlign: pw.TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        lineaPulso(),
      ],
    );
  }

  /// Línea fina azul con un pequeño pulso de electrocardiograma al final
  static pw.Widget lineaPulso() {
    return pw.SizedBox(
      height: 12,
      child: pw.CustomPaint(
        size: const PdfPoint(double.infinity, 12),
        painter: (PdfGraphics g, PdfPoint size) {
          final double y = size.y / 2;
          final double x = size.x - 30;
          g
            ..setStrokeColor(PdfEstilos.azulClaro)
            ..setLineWidth(0.7)
            ..moveTo(0, y)
            ..lineTo(x, y)
            ..lineTo(x + 4, y + 5)
            ..lineTo(x + 8, y - 6)
            ..lineTo(x + 12, y)
            ..lineTo(size.x, y)
            ..strokePath();
        },
      ),
    );
  }

  /// Campo "ETIQUETA: valor" con el valor subrayado (como en el papel)
  static pw.Widget campo(String etiqueta, String valor) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: <pw.Widget>[
        pw.Text('$etiqueta:', style: PdfEstilos.etiqueta),
        pw.SizedBox(width: 4),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 1, left: 2),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfEstilos.granate, width: 0.6)),
            ),
            child: pw.Text(valor, style: PdfEstilos.valor, maxLines: 1),
          ),
        ),
      ],
    );
  }

  /// Fila de campos repartidos a partes iguales
  static pw.Widget filaCampos(List<(String, String)> campos) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: <pw.Widget>[
          for (int i = 0; i < campos.length; i++) ...<pw.Widget>[
            if (i > 0) pw.SizedBox(width: 10),
            pw.Expanded(child: campo(campos[i].$1, campos[i].$2)),
          ],
        ],
      ),
    );
  }

  /// Pastilla redondeada con texto blanco (cabeceras de columna y categorías)
  static pw.Widget pastilla(
    String texto, {
    PdfColor color = PdfEstilos.granate,
    double fontSize = 7,
    double paddingHorizontal = 8,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 2.5),
      decoration: pw.BoxDecoration(color: color, borderRadius: pw.BorderRadius.circular(8)),
      child: pw.Text(
        texto,
        style: PdfEstilos.pastilla.copyWith(fontSize: fontSize),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Caja de texto libre con borde granate redondeado y pastilla de título
  static pw.Widget cajaTexto({
    required String titulo,
    required List<String> lineas,
    double alturaMinima = 60,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pastilla(titulo),
        pw.SizedBox(height: 2),
        pw.Container(
          width: double.infinity,
          constraints: pw.BoxConstraints(minHeight: alturaMinima),
          padding: const pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfEstilos.granate, width: PdfEstilos.borde),
            borderRadius: pw.BorderRadius.circular(PdfEstilos.radio),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              for (final String l in lineas)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text('• $l', style: PdfEstilos.celda),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Casilla de verificación (marcada con X)
  static pw.Widget casilla({required bool marcada, double lado = 9}) {
    return pw.Container(
      width: lado,
      height: lado,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfEstilos.granate, width: 0.8)),
      child: marcada
          ? pw.Text('X', style: PdfEstilos.etiqueta.copyWith(fontSize: lado - 2, color: PdfEstilos.texto))
          : pw.SizedBox(),
    );
  }

  /// Pie con fecha de generación y número de página
  static pw.Widget pie(String generado, pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        pw.Text('Generado por EmerTrack · $generado', style: PdfEstilos.pie),
        pw.Text('Página ${context.pageNumber} de ${context.pagesCount}', style: PdfEstilos.pie),
      ],
    );
  }
}
