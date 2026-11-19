import 'dart:math' as math;

import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:ambutrack_web/features/informes/domain/informe_models.dart';
import 'package:intl/intl.dart';

/// Utilidades de cálculo compartidas por los informes
class InformeCalculos {
  const InformeCalculos._();

  static final NumberFormat _entero = NumberFormat.decimalPattern('es_ES');
  static final NumberFormat _decimal = NumberFormat('#,##0.0', 'es_ES');
  static final DateFormat _mes = DateFormat('MMM yyyy', 'es_ES');
  static final DateFormat _hora = DateFormat('HH:mm');

  /// "1.234"
  static String entero(num valor) => _entero.format(valor.round());

  /// "12,5"
  static String decimal(num valor) => _decimal.format(valor);

  /// "85,3 %" (o "—" si el denominador es 0)
  static String porcentaje(num parte, num total) =>
      total == 0 ? '—' : '${_decimal.format(parte * 100 / total)} %';

  /// "oct 2026"
  static String mes(DateTime fecha) => _mes.format(fecha);

  /// "09:30" (o "—")
  static String hora(DateTime? valor) => valor == null ? '—' : _hora.format(valor);

  /// Fecha mínima para ordenar valores nulos
  static final DateTime fechaMinima = DateTime(1900);

  /// Media de una lista (0 si está vacía)
  static double media(Iterable<num> valores) {
    if (valores.isEmpty) {
      return 0;
    }
    return valores.fold<double>(0, (double a, num b) => a + b) / valores.length;
  }

  /// Suma de una lista
  static double suma<T>(Iterable<T> items, num? Function(T item) valor) =>
      items.fold<double>(0, (double a, T b) => a + (valor(b) ?? 0));

  /// Minutos entre dos instantes (null si falta alguno)
  static int? minutosEntre(DateTime? inicio, DateTime? fin) {
    if (inicio == null || fin == null) {
      return null;
    }
    return fin.toLocal().difference(inicio.toLocal()).inMinutes;
  }

  /// Combina la fecha programada con la hora programada (hora local)
  static DateTime? fechaHora(DateTime? fecha, DateTime? hora) {
    if (fecha == null || hora == null) {
      return null;
    }
    final DateTime f = fecha.toLocal();
    return DateTime(f.year, f.month, f.day, hora.hour, hora.minute);
  }

  /// Días (inclusive) en que el intervalo [inicio, fin] se solapa con el filtro
  static int diasSolapados(InformeFiltro filtro, DateTime inicio, DateTime? fin) {
    final DateTime i = _dia(inicio);
    final DateTime f = _dia(fin ?? DateTime.now());
    final DateTime desde = i.isAfter(filtro.desde) ? i : filtro.desde;
    final DateTime hasta = f.isBefore(filtro.hasta) ? f : filtro.hasta;
    if (hasta.isBefore(desde)) {
      return 0;
    }
    return hasta.difference(desde).inDays + 1;
  }

  /// Agrupa y cuenta elementos por etiqueta, ordenado de mayor a menor
  static List<InformeBarItem> contar<T>(
    Iterable<T> items,
    String Function(T item) etiqueta, {
    int maximo = 8,
  }) {
    final Map<String, double> mapa = <String, double>{};
    for (final T item in items) {
      final String clave = etiqueta(item);
      mapa[clave] = (mapa[clave] ?? 0) + 1;
    }
    return barras(mapa, entero, maximo: maximo);
  }

  /// Convierte un mapa etiqueta → valor en barras ordenadas de mayor a menor
  static List<InformeBarItem> barras(
    Map<String, double> mapa,
    String Function(double valor) formato, {
    int maximo = 8,
    bool ordenar = true,
  }) {
    final List<MapEntry<String, double>> entradas = mapa.entries.toList();
    if (ordenar) {
      entradas.sort((MapEntry<String, double> a, MapEntry<String, double> b) => b.value.compareTo(a.value));
    }
    return entradas
        .take(math.max(0, maximo))
        .map(
          (MapEntry<String, double> e) => InformeBarItem(label: e.key, valor: e.value, texto: formato(e.value)),
        )
        .toList();
  }

  static DateTime _dia(DateTime d) {
    final DateTime l = d.toLocal();
    return DateTime(l.year, l.month, l.day);
  }
}
