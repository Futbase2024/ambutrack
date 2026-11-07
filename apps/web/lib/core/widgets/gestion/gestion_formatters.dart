import 'package:intl/intl.dart';

/// Formateadores comunes para las vistas tipo programa de gestión
class GestionFormatters {
  const GestionFormatters._();

  /// Texto que se muestra cuando un campo está vacío
  static const String vacio = '—';

  static final NumberFormat _moneda =
      NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);
  static final DateFormat _fecha = DateFormat('dd/MM/yyyy');

  /// Devuelve [value] o el marcador de vacío si es null/blanco
  static String texto(String? value) {
    if (value == null || value.trim().isEmpty) {
      return vacio;
    }
    return value.trim();
  }

  /// Formatea un teléfono español de 9 dígitos como "956 11 07 00"
  static String telefono(String? value) {
    if (value == null || value.trim().isEmpty) {
      return vacio;
    }
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 9) {
      return value.trim();
    }
    return '${digits.substring(0, 3)} ${digits.substring(3, 5)} '
        '${digits.substring(5, 7)} ${digits.substring(7)}';
  }

  /// Formatea un importe como "3.240,00 €"
  static String moneda(double value) => _moneda.format(value);

  /// Formatea una fecha como "28/10/2026"
  static String fecha(DateTime? value) =>
      value == null ? vacio : _fecha.format(value.toLocal());
}
