import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:intl/intl.dart';

/// Formateadores del parte diario (todo en texto listo para pintar)
class ParteFormato {
  const ParteFormato._();

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy');
  static final DateFormat _hora = DateFormat('HH:mm');
  static final RegExp _uuid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');

  /// Entidad por defecto cuando el paciente no tiene mutua/aseguradora
  static const String entidadPorDefecto = 'SAS';

  static String fecha(DateTime? d) => d == null ? '' : _fecha.format(d.toLocal());

  static String hora(DateTime? d) => d == null ? '' : _hora.format(d.toLocal());

  static String entero(num? n) => n == null ? '' : n.round().toString();

  /// Número con 2 decimales y coma (litros, importes). Vacío si es 0 o null.
  static String decimal(double? n) {
    if (n == null || n == 0) {
      return '';
    }
    return n.toStringAsFixed(2).replaceAll('.', ',');
  }

  static String mayusculas(String? s) => (s ?? '').trim().toUpperCase();

  /// Nombre completo del paciente en MAYÚSCULAS
  static String paciente(PacienteEntity? p) {
    if (p == null) {
      return '';
    }
    final String nombre = <String?>[p.nombre, p.primerApellido, p.segundoApellido]
        .where((String? s) => s != null && s.trim().isNotEmpty)
        .join(' ');
    return mayusculas(nombre);
  }

  /// Entidad pagadora del servicio: mutua del paciente o `SAS` por defecto
  static String entidad(PacienteEntity? p) {
    final String mutua = mayusculas(p?.mutuaAseguradora);
    return mutua.isEmpty ? entidadPorDefecto : mutua;
  }

  /// Domicilio del paciente (o el origen si el origen es su domicilio)
  static String domicilio(TrasladoEntity t) {
    final String dom = mayusculas(t.paciente?.domicilioDireccion);
    if (dom.isNotEmpty) {
      return dom;
    }
    if (t.tipoOrigen == 'domicilio_paciente') {
      return mayusculas(t.origen);
    }
    if (t.tipoDestino == 'domicilio_paciente') {
      return mayusculas(t.destino);
    }
    return '';
  }

  /// Punto de origen/destino legible: resuelve IDs de centros hospitalarios
  static String punto({
    required String? tipo,
    required String? valor,
    required Map<String, String> nombresCentros,
  }) {
    final String v = (valor ?? '').trim();
    if (tipo == 'domicilio_paciente') {
      return 'DOMICILIO';
    }
    if (v.isEmpty) {
      return '';
    }
    final String? centro = nombresCentros[v];
    if (centro != null) {
      return mayusculas(centro);
    }
    if (_uuid.hasMatch(v)) {
      return 'CENTRO HOSPITALARIO';
    }
    return mayusculas(v);
  }
}
