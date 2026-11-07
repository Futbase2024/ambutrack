import 'package:ambutrack_web/core/widgets/gestion/gestion_formatters.dart';
import 'package:equatable/equatable.dart';

/// Periodos predefinidos de los informes
enum InformePeriodo {
  esteMes('Este mes'),
  mesAnterior('Mes anterior'),
  trimestre('Trimestre actual'),
  anio('Año actual'),
  personalizado('Personalizado');

  const InformePeriodo(this.label);

  final String label;
}

/// Filtro común de los informes: periodo + rango de fechas + filtros extra
/// propios de cada informe (vehículo, categoría, base...).
class InformeFiltro extends Equatable {
  const InformeFiltro({
    required this.periodo,
    required this.desde,
    required this.hasta,
    this.extras = const <String, String>{},
  });

  /// Filtro inicial: mes en curso
  factory InformeFiltro.inicial() {
    final DateTime hoy = DateTime.now();
    return InformeFiltro(
      periodo: InformePeriodo.esteMes,
      desde: DateTime(hoy.year, hoy.month),
      hasta: DateTime(hoy.year, hoy.month + 1, 0),
    );
  }

  final InformePeriodo periodo;

  /// Primer día del rango (00:00)
  final DateTime desde;

  /// Último día del rango (incluido)
  final DateTime hasta;

  /// Filtros adicionales (clave → valor). Sin clave = "Todos".
  final Map<String, String> extras;

  /// Número de días naturales del rango
  int get dias => hasta.difference(desde).inDays + 1;

  /// Límite superior exclusivo (día siguiente a [hasta])
  DateTime get finExclusivo => DateTime(hasta.year, hasta.month, hasta.day + 1);

  /// Texto "01/10/2026 – 31/10/2026"
  String get etiqueta =>
      '${GestionFormatters.fecha(desde)} – ${GestionFormatters.fecha(hasta)}';

  String? extra(String clave) => extras[clave];

  /// Indica si [fecha] cae dentro del rango
  bool contiene(DateTime? fecha) {
    if (fecha == null) {
      return false;
    }
    final DateTime f = fecha.toLocal();
    return !f.isBefore(desde) && f.isBefore(finExclusivo);
  }

  /// Indica si otro filtro tiene el mismo rango de fechas
  bool mismoRango(InformeFiltro otro) => desde == otro.desde && hasta == otro.hasta;

  /// Nuevo filtro con un periodo predefinido
  InformeFiltro conPeriodo(InformePeriodo nuevo) {
    final DateTime hoy = DateTime.now();
    final int trimestre = ((hoy.month - 1) ~/ 3) * 3 + 1;
    switch (nuevo) {
      case InformePeriodo.esteMes:
        return _copia(nuevo, DateTime(hoy.year, hoy.month), DateTime(hoy.year, hoy.month + 1, 0));
      case InformePeriodo.mesAnterior:
        return _copia(nuevo, DateTime(hoy.year, hoy.month - 1), DateTime(hoy.year, hoy.month, 0));
      case InformePeriodo.trimestre:
        return _copia(nuevo, DateTime(hoy.year, trimestre), DateTime(hoy.year, trimestre + 3, 0));
      case InformePeriodo.anio:
        return _copia(nuevo, DateTime(hoy.year), DateTime(hoy.year, 12, 31));
      case InformePeriodo.personalizado:
        return _copia(nuevo, desde, hasta);
    }
  }

  /// Nuevo filtro con un rango personalizado
  InformeFiltro conRango(DateTime nuevoDesde, DateTime nuevoHasta) => _copia(
        InformePeriodo.personalizado,
        DateTime(nuevoDesde.year, nuevoDesde.month, nuevoDesde.day),
        DateTime(nuevoHasta.year, nuevoHasta.month, nuevoHasta.day),
      );

  /// Nuevo filtro con un filtro extra (null = quitar filtro)
  InformeFiltro conExtra(String clave, String? valor) {
    final Map<String, String> nuevos = Map<String, String>.of(extras);
    if (valor == null) {
      nuevos.remove(clave);
    } else {
      nuevos[clave] = valor;
    }
    return InformeFiltro(periodo: periodo, desde: desde, hasta: hasta, extras: nuevos);
  }

  InformeFiltro _copia(InformePeriodo p, DateTime d, DateTime h) =>
      InformeFiltro(periodo: p, desde: d, hasta: h, extras: extras);

  @override
  List<Object?> get props => <Object?>[periodo, desde, hasta, extras];
}
