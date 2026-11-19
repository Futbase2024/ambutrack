import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Paleta y medidas de los partes impresos (réplica del parte en papel).
///
/// Son colores de impresión (`PdfColor`), no de la UI: `AppColors` vive en cada
/// app y no se puede usar desde el motor PDF.
class PdfEstilos {
  const PdfEstilos._();

  /// Granate de bordes, etiquetas y pastillas
  static const PdfColor granate = PdfColor.fromInt(0xFFA3203A);

  /// Azul de títulos y pastillas de categoría
  static const PdfColor azul = PdfColor.fromInt(0xFF1E7FC2);

  static const PdfColor azulClaro = PdfColor.fromInt(0xFF8EC3E6);
  static const PdfColor texto = PdfColor.fromInt(0xFF1F2937);
  static const PdfColor gris = PdfColor.fromInt(0xFF6B7280);
  static const PdfColor blanco = PdfColors.white;

  static const double radio = 8;
  static const double borde = 0.8;
  static const double margen = 24;

  static const pw.TextStyle titulo = pw.TextStyle(
    color: azul,
    fontSize: 17,
    fontWeight: pw.FontWeight.bold,
  );

  static const pw.TextStyle etiqueta = pw.TextStyle(
    color: granate,
    fontSize: 7.5,
    fontWeight: pw.FontWeight.bold,
  );

  static const pw.TextStyle valor = pw.TextStyle(color: texto, fontSize: 8.5);

  static const pw.TextStyle celda = pw.TextStyle(color: texto, fontSize: 7);

  static const pw.TextStyle pastilla = pw.TextStyle(
    color: blanco,
    fontSize: 7,
    fontWeight: pw.FontWeight.bold,
  );

  static const pw.TextStyle empresa = pw.TextStyle(color: texto, fontSize: 7.5);

  static const pw.TextStyle pie = pw.TextStyle(color: gris, fontSize: 6.5);
}
