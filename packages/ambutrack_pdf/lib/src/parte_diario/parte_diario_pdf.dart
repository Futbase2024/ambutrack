import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'hoja_revision_vehiculo.dart';
import 'hoja_servicios.dart';
import 'parte_diario_data.dart';

/// Genera, imprime y comparte partes diarios en PDF (web y móvil).
///
/// Cada parte ocupa: hoja(s) de servicios (17 filas por hoja) + hoja de
/// revisión del vehículo (si hubo checklist de inicio de turno).
class ParteDiarioPdf {
  const ParteDiarioPdf._();

  static pw.ThemeData? _tema;
  static final Map<String, pw.ImageProvider> _logos = <String, pw.ImageProvider>{};

  /// Abre el diálogo del sistema para imprimir o guardar como PDF
  static Future<void> imprimir(List<ParteDiarioData> partes, {required String nombreArchivo}) async {
    final Uint8List bytes = await generar(partes);
    await Printing.layoutPdf(name: nombreArchivo, onLayout: (PdfPageFormat _) async => bytes);
  }

  /// Comparte (móvil) o descarga (web) el archivo PDF
  static Future<void> compartir(List<ParteDiarioData> partes, {required String nombreArchivo}) async {
    final Uint8List bytes = await generar(partes);
    await Printing.sharePdf(bytes: bytes, filename: '$nombreArchivo.pdf');
  }

  /// Genera los bytes del PDF con todos los [partes] (uno detrás de otro)
  static Future<Uint8List> generar(List<ParteDiarioData> partes) async {
    debugPrint('📄 ParteDiarioPdf: generando ${partes.length} parte(s)');
    final String generado = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final pw.Document doc = pw.Document(
      title: 'Parte diario',
      author: 'EmerTrack',
      theme: await _cargarTema(),
    );
    for (final ParteDiarioData parte in partes) {
      final List<List<ServicioParte>> hojas = _trocear(parte.servicios);
      for (int i = 0; i < hojas.length; i++) {
        doc.addPage(HojaServicios.pagina(
          parte: parte,
          servicios: hojas[i],
          ultima: i == hojas.length - 1,
          generado: generado,
        ));
      }
      if (parte.tieneRevision) {
        doc.addPage(HojaRevisionVehiculo.pagina(parte: parte, generado: generado));
      }
    }
    return doc.save();
  }

  /// Datos de cabecera a partir de la empresa (carga el logo si es una URL)
  static Future<EmpresaParte> empresaDesde(EmpresaTenantEntity? empresa) async {
    if (empresa == null) {
      return const EmpresaParte(nombre: '');
    }
    return EmpresaParte(
      nombre: empresa.nombre,
      razonSocial: empresa.razonSocial,
      direccion: empresa.direccion,
      telefono: empresa.telefono,
      cif: empresa.cif,
      logo: await cargarLogo(empresa.logoUrl),
    );
  }

  /// Descarga el logo para el PDF; null si no hay URL o falla la descarga
  static Future<pw.ImageProvider?> cargarLogo(String? url) async {
    if (url == null || !url.startsWith('http')) {
      return null;
    }
    final pw.ImageProvider? cache = _logos[url];
    if (cache != null) {
      return cache;
    }
    try {
      return _logos[url] = await networkImage(url);
    } catch (e) {
      debugPrint('⚠️ ParteDiarioPdf: no se pudo cargar el logo ($e)');
      return null;
    }
  }

  /// Nombre de archivo sugerido: `parte_diario_<persona>_<dd-MM-yyyy>`
  static String nombreArchivo({required String persona, required DateTime dia}) {
    final String limpio = persona.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9áéíóúñü]+'), '_');
    return 'parte_diario_${limpio}_${DateFormat('dd-MM-yyyy').format(dia)}';
  }

  static List<List<ServicioParte>> _trocear(List<ServicioParte> servicios) {
    if (servicios.isEmpty) {
      return <List<ServicioParte>>[const <ServicioParte>[]];
    }
    return <List<ServicioParte>>[
      for (int i = 0; i < servicios.length; i += filasPorHoja)
        servicios.sublist(i, (i + filasPorHoja).clamp(0, servicios.length)),
    ];
  }

  /// Roboto (acentos, €, ñ); si no hay red, Helvetica por defecto
  static Future<pw.ThemeData> _cargarTema() async {
    final pw.ThemeData? cache = _tema;
    if (cache != null) {
      return cache;
    }
    try {
      final pw.ThemeData tema = pw.ThemeData.withFont(
        base: await PdfGoogleFonts.robotoRegular(),
        bold: await PdfGoogleFonts.robotoBold(),
      );
      _tema = tema;
      return tema;
    } catch (e) {
      debugPrint('⚠️ ParteDiarioPdf: sin fuente Roboto, se usa la de por defecto ($e)');
      return pw.ThemeData();
    }
  }
}
