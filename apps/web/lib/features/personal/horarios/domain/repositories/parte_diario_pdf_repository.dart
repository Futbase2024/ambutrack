import 'package:ambutrack_pdf/ambutrack_pdf.dart';

/// Datos necesarios para imprimir partes diarios en PDF.
///
/// El contrato lo define `ParteDiarioFuentes` (paquete `ambutrack_pdf`) para
/// que web y móvil compartan la misma orquestación.
abstract class ParteDiarioPdfRepository implements ParteDiarioFuentes {}
