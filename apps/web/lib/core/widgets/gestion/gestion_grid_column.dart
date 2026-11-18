import 'package:flutter/material.dart';

/// Definición de una columna de `GestionGrid`
class GestionColumn<T> {
  const GestionColumn({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.width,
    this.minWidth,
    this.sortValue,
    this.alignment = Alignment.centerLeft,
    this.exportValue,
    this.filterValue,
    this.editCell,
    this.onCellDoubleTap,
    this.headerIcon,
    this.headerIconOnly = false,
  });

  /// Ancho mínimo por defecto de una columna flexible
  static const double defaultMinWidth = 110;

  final String label;

  /// Contenido de la celda para un elemento
  final Widget Function(T item) cell;

  /// Ancho flexible (se ignora si se indica [width])
  final int flex;

  /// Ancho fijo en píxeles
  final double? width;

  /// Ancho mínimo de una columna flexible. Si la rejilla no cabe con los
  /// mínimos, se desplaza en horizontal en lugar de aplastar columnas.
  final double? minWidth;

  /// Ancho que necesita la columna como mínimo
  double get requiredWidth => width ?? minWidth ?? defaultMinWidth;

  /// Valor por el que se ordena. Si es null, la columna no es ordenable.
  final Comparable<Object> Function(T item)? sortValue;

  final Alignment alignment;

  /// Valor para PDF/Excel (`String`, número, fecha, `GestionCell`...).
  /// Si es null, la columna no se exporta.
  final Object? Function(T item)? exportValue;

  /// Texto por el que se filtra la columna (filtro estilo Excel en la
  /// cabecera). Si es null, la columna no tiene filtro.
  final String Function(T item)? filterValue;

  /// Celda editable que se muestra en "modo edición" (si es null, la
  /// columna se pinta igual que siempre)
  final Widget Function(T item)? editCell;

  /// Acción al hacer doble clic en esta celda (fuera del modo edición).
  /// Si existe, sustituye a la acción de doble clic de la fila.
  final void Function(T item)? onCellDoubleTap;

  /// Icono de la cabecera (se muestra delante del título)
  final IconData? headerIcon;

  /// Muestra solo el icono en la cabecera (columnas estrechas); el título
  /// completo aparece al pasar el ratón
  final bool headerIconOnly;

  bool get sortable => sortValue != null;

  bool get filterable => filterValue != null;

  bool get editable => editCell != null;
}

/// Estado de ordenación de la rejilla
class GestionSort {
  const GestionSort({this.columnIndex, this.ascending = true});

  final int? columnIndex;
  final bool ascending;

  /// Nuevo estado al pulsar la cabecera de [index]
  GestionSort toggle(int index) {
    if (columnIndex == index) {
      return GestionSort(columnIndex: index, ascending: !ascending);
    }
    return GestionSort(columnIndex: index);
  }

  /// Devuelve una copia ordenada de [rows] según las [columns]
  List<T> apply<T>(List<T> rows, List<GestionColumn<T>> columns) {
    final int? index = columnIndex;
    if (index == null || index >= columns.length) {
      return rows;
    }
    final Comparable<Object> Function(T)? key = columns[index].sortValue;
    if (key == null) {
      return rows;
    }
    final List<T> sorted = List<T>.of(rows)
      ..sort((T a, T b) {
        final int result = key(a).compareTo(key(b));
        return ascending ? result : -result;
      });
    return sorted;
  }
}
