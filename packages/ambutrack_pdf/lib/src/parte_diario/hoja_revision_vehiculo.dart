import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'parte_diario_data.dart';
import 'pdf_componentes.dart';
import 'pdf_estilos.dart';

/// Anchos relativos: punto, sí, no, observaciones
const List<int> _flex = <int>[38, 7, 7, 48];

/// Hoja 2: "Revisión del vehículo" con el checklist del inicio de turno
class HojaRevisionVehiculo {
  const HojaRevisionVehiculo._();

  static pw.Page pagina({required ParteDiarioData parte, required String generado}) {
    final double alto = parte.checklist.length > 24 ? 16 : 20;
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(PdfEstilos.margen),
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          PdfComponentes.cabecera(parte.empresa, const <String>['REVISIÓN VEHÍCULO', 'INICIO DE TURNO']),
          pw.SizedBox(height: 6),
          PdfComponentes.filaCampos(<(String, String)>[
            ('FECHA DE LA REVISIÓN', parte.fecha),
            ('VEHÍCULO', parte.matricula),
            ('REALIZADO POR', parte.tecnico),
          ]),
          PdfComponentes.filaCampos(<(String, String)>[
            ('KM', parte.kmEntrada),
            ('COMBUSTIBLE', parte.combustible),
            ('DECLARACIÓN DE APTITUD', parte.declaracionAptitud ? 'SÍ' : 'NO'),
          ]),
          pw.SizedBox(height: 10),
          _cabeceraTabla(),
          pw.SizedBox(height: 2),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: <pw.Widget>[
              pw.SizedBox(
                width: 90,
                child: PdfComponentes.pastilla('CONTROLES', color: PdfEstilos.azul, fontSize: 8),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(child: _tabla(parte.checklist, alto)),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Center(
            child: pw.Text('OTRAS INCIDENCIAS', style: PdfEstilos.etiqueta.copyWith(fontSize: 9)),
          ),
          pw.SizedBox(height: 3),
          _otrasIncidencias(parte.otrasIncidencias),
          pw.Spacer(),
          PdfComponentes.pie(generado, context),
        ],
      ),
    );
  }

  static pw.Widget _cabeceraTabla() {
    pw.Widget circulo(String t) => pw.Container(
          width: 16,
          height: 16,
          alignment: pw.Alignment.center,
          decoration: const pw.BoxDecoration(color: PdfEstilos.granate, shape: pw.BoxShape.circle),
          child: pw.Text(t, style: PdfEstilos.pastilla.copyWith(fontSize: 5.5)),
        );
    return pw.Row(
      children: <pw.Widget>[
        pw.SizedBox(width: 98),
        pw.Expanded(flex: _flex[0], child: pw.SizedBox()),
        pw.Expanded(flex: _flex[1], child: pw.Center(child: circulo('SÍ'))),
        pw.Expanded(flex: _flex[2], child: pw.Center(child: circulo('NO'))),
        pw.Expanded(flex: _flex[3], child: pw.Center(child: PdfComponentes.pastilla('OBSERVACIONES'))),
      ],
    );
  }

  static pw.Widget _tabla(List<ChecklistParte> items, double alto) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfEstilos.granate, width: PdfEstilos.borde),
        borderRadius: pw.BorderRadius.circular(PdfEstilos.radio),
      ),
      child: pw.Column(
        children: <pw.Widget>[
          for (int i = 0; i < items.length; i++) _fila(items[i], alto: alto, ultima: i == items.length - 1),
        ],
      ),
    );
  }

  static pw.Widget _fila(ChecklistParte item, {required double alto, required bool ultima}) {
    final List<(String, pw.Alignment)> celdas = <(String, pw.Alignment)>[
      (item.nombre, pw.Alignment.center),
      (item.correcto ? 'X' : '', pw.Alignment.center),
      (item.correcto ? '' : 'X', pw.Alignment.center),
      (item.observacion ?? '', pw.Alignment.centerLeft),
    ];
    return pw.Container(
      height: alto,
      decoration: ultima
          ? null
          : const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfEstilos.granate, width: 0.5)),
            ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          for (int c = 0; c < celdas.length; c++)
            pw.Expanded(
              flex: _flex[c],
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                alignment: celdas[c].$2,
                decoration: c == celdas.length - 1
                    ? null
                    : const pw.BoxDecoration(
                        border: pw.Border(right: pw.BorderSide(color: PdfEstilos.granate, width: 0.5)),
                      ),
                child: pw.Text(
                  celdas[c].$1,
                  style: c == 0 ? PdfEstilos.etiqueta.copyWith(color: PdfEstilos.azul, fontSize: 6.5) : PdfEstilos.celda,
                  textAlign: c == 0 ? pw.TextAlign.center : pw.TextAlign.left,
                  maxLines: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _otrasIncidencias(List<String> lineas) {
    return pw.Container(
      width: double.infinity,
      constraints: const pw.BoxConstraints(minHeight: 70),
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
    );
  }
}
