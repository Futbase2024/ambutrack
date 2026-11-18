import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Genera e imprime la etiqueta QR del vehículo para pegar en el salpicadero.
///
/// El contenido del QR es el `id` (uuid) del vehículo: la app móvil lo lee al
/// iniciar turno y busca el vehículo por id, matrícula o nº interno.
Future<void> imprimirQrVehiculo(VehiculoEntity vehiculo) async {
  debugPrint('🖨️ QR vehículo: generando etiqueta de ${vehiculo.matricula} (${vehiculo.id})');
  final pw.Document doc = pw.Document()
    ..addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) => pw.Center(child: _etiqueta(vehiculo)),
      ),
    );
  await Printing.layoutPdf(
    name: 'QR_${vehiculo.matricula.replaceAll(' ', '_')}',
    onLayout: (PdfPageFormat format) async => doc.save(),
  );
}

final PdfColor _primary = PdfColor.fromInt(AppColors.primary.toARGB32());
final PdfColor _gray = PdfColor.fromInt(AppColors.gray600.toARGB32());
final PdfColor _border = PdfColor.fromInt(AppColors.gray300.toARGB32());

/// Etiqueta recortable: QR grande + matrícula + nº interno
pw.Widget _etiqueta(VehiculoEntity v) {
  final String? interno = v.numeroInterno?.trim();
  return pw.Container(
    width: 380,
    padding: const pw.EdgeInsets.all(24),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _border),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
    ),
    child: pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: <pw.Widget>[
        pw.Text(
          'EmerTrack · Inicio de turno',
          style: pw.TextStyle(fontSize: 11, color: _primary, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: v.id,
          width: 300,
          height: 300,
        ),
        pw.SizedBox(height: 18),
        pw.Text(
          v.matricula.toUpperCase(),
          style: pw.TextStyle(fontSize: 34, fontWeight: pw.FontWeight.bold, letterSpacing: 2),
        ),
        if (interno != null && interno.isNotEmpty) ...<pw.Widget>[
          pw.SizedBox(height: 4),
          pw.Text('Nº interno: $interno', style: const pw.TextStyle(fontSize: 18)),
        ],
        pw.SizedBox(height: 12),
        pw.Text(
          'Escanea este código con la app al iniciar el turno',
          style: pw.TextStyle(fontSize: 10, color: _gray),
        ),
      ],
    ),
  );
}
