import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'parte_diario_data.dart';
import 'pdf_componentes.dart';
import 'pdf_estilos.dart';

/// Filas de servicios por hoja (como el parte en papel)
const int filasPorHoja = 17;

/// Anchos relativos de las columnas: paciente, domicilio, origen, destino, recog., final, entidad
const List<int> _flex = <int>[21, 19, 15, 15, 8, 8, 11];
const double _altoFila = 22;

/// Hoja 1: "Registro prestaciones de servicios".
///
/// [servicios] son las filas de esta hoja (máx. [filasPorHoja]); la caja de
/// incidencias y los P-10 solo se pintan en la última hoja ([ultima]).
class HojaServicios {
  const HojaServicios._();

  static pw.Page pagina({
    required ParteDiarioData parte,
    required List<ServicioParte> servicios,
    required bool ultima,
    required String generado,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(PdfEstilos.margen),
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          PdfComponentes.cabecera(parte.empresa, const <String>['REGISTRO', 'PRESTACIONES DE SERVICIOS']),
          pw.SizedBox(height: 6),
          _datosTurno(parte),
          pw.SizedBox(height: 4),
          _revisado(parte.revisadoControles),
          pw.SizedBox(height: 8),
          _cabeceraTabla(),
          pw.SizedBox(height: 2),
          _tabla(servicios),
          pw.SizedBox(height: 10),
          if (ultima) ...<pw.Widget>[
            PdfComponentes.cajaTexto(titulo: 'INCIDENCIAS SERVICIOS / VEHÍCULO', lineas: parte.incidencias),
            pw.SizedBox(height: 8),
            pw.SizedBox(width: 260, child: PdfComponentes.campo('NÚMEROS DE P-10 ENTREGADOS', parte.numerosP10)),
          ],
          pw.Spacer(),
          PdfComponentes.pie(generado, context),
        ],
      ),
    );
  }

  static pw.Widget _datosTurno(ParteDiarioData p) {
    final String tecnico = p.rol.isEmpty ? p.tecnico : '${p.tecnico} (${p.rol})';
    return pw.Column(
      children: <pw.Widget>[
        PdfComponentes.filaCampos(<(String, String)>[
          ('TÉCNICO', tecnico),
          ('MATRÍCULA', p.matricula),
          ('FECHA', p.fecha),
          ('COMPAÑERO', p.companero),
        ]),
        PdfComponentes.filaCampos(<(String, String)>[
          ('HORA DE ENTRADA', p.horaEntrada),
          ('HORA DE SALIDA', p.horaSalida),
          ('KM ENTRADA', p.kmEntrada),
          ('KM SALIDA', p.kmSalida),
        ]),
        PdfComponentes.filaCampos(<(String, String)>[
          ('KM RECORRIDOS', p.kmRecorridos),
          ('GASÓLEO LITROS', p.gasoleoLitros),
          ('IMPORTE', p.importe),
          ('E. SERVICIOS', p.numServicios),
        ]),
      ],
    );
  }

  static pw.Widget _revisado(bool revisado) {
    return pw.Row(
      children: <pw.Widget>[
        PdfComponentes.casilla(marcada: revisado),
        pw.SizedBox(width: 5),
        pw.Text('REVISADO CONTROLES DE MANTENIMIENTO Y SEGURIDAD', style: PdfEstilos.etiqueta.copyWith(color: PdfEstilos.azul)),
      ],
    );
  }

  static pw.Widget _cabeceraTabla() {
    // Las columnas de hora son estrechas: menos relleno para que "RECOG." no se parta
    pw.Widget col(int flex, String texto, {double padding = 8}) => pw.Expanded(
          flex: flex,
          child: pw.Center(child: PdfComponentes.pastilla(texto, paddingHorizontal: padding)),
        );
    return pw.Row(
      children: <pw.Widget>[
        col(_flex[0], 'NOMBRE PACIENTE'),
        col(_flex[1], 'DOMICILIO'),
        col(_flex[2] + _flex[3], 'TRAYECTO (ORIGEN / DESTINO)'),
        col(_flex[4], 'RECOG.\nHORA', padding: 4),
        col(_flex[5], 'FINAL\nHORA', padding: 4),
        col(_flex[6], 'ENTIDAD'),
      ],
    );
  }

  static pw.Widget _tabla(List<ServicioParte> servicios) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfEstilos.granate, width: PdfEstilos.borde),
        borderRadius: pw.BorderRadius.circular(PdfEstilos.radio),
      ),
      child: pw.Column(
        children: <pw.Widget>[
          for (int i = 0; i < filasPorHoja; i++)
            _fila(i < servicios.length ? servicios[i] : null, ultima: i == filasPorHoja - 1),
        ],
      ),
    );
  }

  static pw.Widget _fila(ServicioParte? s, {required bool ultima}) {
    final List<String> celdas = s == null
        ? const <String>['', '', '', '', '', '', '']
        : <String>[s.paciente, s.domicilio, s.origen, s.destino, s.horaRecogida, s.horaFinal, s.entidad];
    return pw.Container(
      height: _altoFila,
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
                padding: const pw.EdgeInsets.symmetric(horizontal: 3),
                alignment: c >= 4 ? pw.Alignment.center : pw.Alignment.centerLeft,
                decoration: c == celdas.length - 1
                    ? null
                    : const pw.BoxDecoration(
                        border: pw.Border(right: pw.BorderSide(color: PdfEstilos.granate, width: 0.5)),
                      ),
                child: pw.Text(celdas[c], style: PdfEstilos.celda, maxLines: 2),
              ),
            ),
        ],
      ),
    );
  }
}
