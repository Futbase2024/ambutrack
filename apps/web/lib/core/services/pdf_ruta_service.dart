import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/trafico_diario/presentation/models/traslado_con_ruta_info.dart';

/// Servicio para generar PDFs de rutas de técnicos
@lazySingleton
class PdfRutaService {
  /// Genera un PDF de la hoja de ruta
  Future<void> generarPdfRuta({
    required String tecnicoNombre,
    required String? vehiculoMatricula,
    required DateTime fecha,
    required List<TrasladoConRutaInfo> traslados,
    required RutaResumen resumen,
  }) async {
    final pw.Document pdf = pw.Document();

    // ignore: cascade_invocations
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return <pw.Widget>[
            _buildHeader(tecnicoNombre, vehiculoMatricula, fecha),
            pw.SizedBox(height: 20),
            _buildResumen(resumen),
            pw.SizedBox(height: 20),
            _buildAlertaFactibilidad(resumen),
            pw.SizedBox(height: 20),
            _buildListaTraslados(traslados),
            pw.SizedBox(height: 20),
            _buildPiePagina(),
          ];
        },
      ),
    );

    // Imprimir o guardar PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Ruta_${tecnicoNombre.replaceAll(' ', '_')}_${_formatFecha(fecha)}.pdf',
    );

    debugPrint('✅ PDF generado exitosamente');
  }

  /// Header del PDF
  pw.Widget _buildHeader(String tecnicoNombre, String? vehiculoMatricula, DateTime fecha) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            'HOJA DE RUTA - TÉCNICO',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: <pw.Widget>[
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(
                    'Técnico: $tecnicoNombre',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  if (vehiculoMatricula != null)
                    pw.Text(
                      'Vehículo: $vehiculoMatricula',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                ],
              ),
              pw.Text(
                'Fecha: ${_formatFecha(fecha)}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Resumen de la ruta
  pw.Widget _buildResumen(RutaResumen resumen) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            'RESUMEN DE RUTA',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: <pw.Widget>[
              pw.Expanded(
                child: _buildMetricaPdf(
                  label: 'Total Traslados',
                  valor: '${resumen.totalTraslados}',
                ),
              ),
              pw.Expanded(
                child: _buildMetricaPdf(
                  label: 'Distancia Total',
                  valor: '${resumen.distanciaTotalKm.toStringAsFixed(1)} km',
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            children: <pw.Widget>[
              pw.Expanded(
                child: _buildMetricaPdf(
                  label: 'Tiempo Estimado',
                  valor: resumen.tiempoTotalFormateado,
                ),
              ),
              pw.Expanded(
                child: _buildMetricaPdf(
                  label: 'Velocidad Promedio',
                  valor: '${resumen.velocidadPromedioKmh.toStringAsFixed(0)} km/h',
                ),
              ),
            ],
          ),
          if (resumen.horaInicio != null && resumen.horaFin != null) ...<pw.Widget>[
            pw.SizedBox(height: 6),
            pw.Row(
              children: <pw.Widget>[
                pw.Expanded(
                  child: _buildMetricaPdf(
                    label: 'Inicio Estimado',
                    valor: _formatHora(resumen.horaInicio!),
                  ),
                ),
                pw.Expanded(
                  child: _buildMetricaPdf(
                    label: 'Fin Estimado',
                    valor: _formatHora(resumen.horaFin!),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildMetricaPdf({required String label, required String valor}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          valor,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Alerta de factibilidad
  pw.Widget _buildAlertaFactibilidad(RutaResumen resumen) {
    if (resumen.esFactible) {
      return pw.SizedBox.shrink();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.orange300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
            children: <pw.Widget>[
              pw.Text(
                '⚠️ ',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'ALERTA DE FACTIBILIDAD',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange900,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '${resumen.trasladosConRetraso.length} traslado${resumen.trasladosConRetraso.length > 1 ? 's' : ''} con retraso estimado:',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 4),
          ...resumen.trasladosConRetraso.map((TrasladoConRetrasoInfo retraso) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(left: 12, top: 2),
              child: pw.Text(
                '• Traslado ${retraso.orden}: +${retraso.minutosRetraso} minutos de retraso',
                style: const pw.TextStyle(fontSize: 9),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Lista de traslados
  pw.Widget _buildListaTraslados(List<TrasladoConRutaInfo> traslados) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          'TRASLADOS EN ORDEN (${traslados.length})',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: <pw.TableRow>[
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              children: <pw.Widget>[
                _buildTableHeader('#'),
                _buildTableHeader('Origen → Destino'),
                _buildTableHeader('Hora'),
                _buildTableHeader('Distancia'),
                _buildTableHeader('Tiempo'),
              ],
            ),
            // Filas
            ...traslados.map((TrasladoConRutaInfo traslado) {
              return pw.TableRow(
                children: <pw.Widget>[
                  _buildTableCell('${traslado.orden}'),
                  _buildTableCell(
                    '${traslado.origen.nombre}\n→ ${traslado.destino.nombre}',
                  ),
                  _buildTableCell(
                    traslado.horaEstimadaLlegada != null
                        ? _formatHora(traslado.horaEstimadaLlegada!)
                        : '-',
                  ),
                  _buildTableCell(
                    traslado.distanciaTotalTrasladoKm != null
                        ? '${traslado.distanciaTotalTrasladoKm!.toStringAsFixed(1)} km'
                        : '-',
                  ),
                  _buildTableCell(
                    traslado.tiempoTotalTrasladoMinutos != null
                        ? '${traslado.tiempoTotalTrasladoMinutos} min'
                        : '-',
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Pie de página
  pw.Widget _buildPiePagina() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Column(
        children: <pw.Widget>[
          pw.Text(
            'Generado con AmbuTrack',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Fecha de generación: ${_formatFechaHora(DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _formatHora(DateTime hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }

  String _formatFechaHora(DateTime fechaHora) {
    return '${_formatFecha(fechaHora)} ${_formatHora(fechaHora)}';
  }
}
