import 'package:ambutrack_web/core/widgets/gestion/gestion_grid_column.dart';

/// Texto con el que se muestran los valores vacíos en el filtro de columna
const String kGestionFiltroVacio = '(Vacío)';

/// Filtros por columna estilo Excel: para cada columna (por índice) se guarda
/// el conjunto de valores aceptados. Una fila pasa si cumple todas las columnas
/// filtradas (Y entre columnas, O entre los valores de una misma columna).
class GestionColumnFilters {
  const GestionColumnFilters([this.values = const <int, Set<String>>{}]);

  /// Índice de columna → valores aceptados
  final Map<int, Set<String>> values;

  bool get isEmpty => values.isEmpty;

  bool isActive(int column) => values.containsKey(column);

  /// Valores aceptados en [column] (null = sin filtro)
  Set<String>? of(int column) => values[column];

  /// Copia con el filtro de [column] cambiado. `null` quita el filtro.
  GestionColumnFilters withColumn(int column, Set<String>? accepted) {
    final Map<int, Set<String>> next = Map<int, Set<String>>.of(values);
    if (accepted == null) {
      next.remove(column);
    } else {
      next[column] = accepted;
    }
    return GestionColumnFilters(next);
  }

  /// Valor de filtro normalizado de una fila en una columna
  static String valueOf<T>(GestionColumn<T> column, T item) {
    final String raw = column.filterValue!(item).trim();
    return raw.isEmpty ? kGestionFiltroVacio : raw;
  }

  /// Filas que cumplen todos los filtros (salvo el de la columna [except])
  List<T> apply<T>(List<T> rows, List<GestionColumn<T>> columns, {int? except}) {
    final Iterable<MapEntry<int, Set<String>>> activos = values.entries.where(
      (MapEntry<int, Set<String>> e) =>
          e.key != except && e.key < columns.length && columns[e.key].filterable,
    );
    if (activos.isEmpty) {
      return rows;
    }
    return rows
        .where(
          (T item) => activos.every(
            (MapEntry<int, Set<String>> e) => e.value.contains(valueOf(columns[e.key], item)),
          ),
        )
        .toList();
  }

  /// Valores distintos de [column] en [rows], ordenados (vacío al final)
  static List<String> distinct<T>(List<T> rows, GestionColumn<T> column) {
    final Set<String> unicos = <String>{for (final T item in rows) valueOf(column, item)};
    return unicos.toList()
      ..sort((String a, String b) {
        if (a == kGestionFiltroVacio) {
          return 1;
        }
        if (b == kGestionFiltroVacio) {
          return -1;
        }
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
  }

  /// Descripción legible, p. ej. "Estado: Baja, Mantenimiento · Tipo: Colectiva"
  List<String> describe<T>(List<GestionColumn<T>> columns) {
    return <String>[
      for (final MapEntry<int, Set<String>> e in values.entries)
        if (e.key < columns.length) '${columns[e.key].label}: ${e.value.join(', ')}',
    ];
  }
}
