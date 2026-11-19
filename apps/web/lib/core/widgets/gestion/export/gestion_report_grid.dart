import 'package:ambutrack_web/core/widgets/gestion/export/gestion_report.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_grid_column.dart';
import 'package:flutter/material.dart';

/// Convierte las columnas de una `GestionGrid` en una tabla de informe, para que
/// el PDF/Excel sea idéntico a la rejilla (mismas columnas, orden y estilos).
///
/// Solo se exportan las columnas con `exportValue`.
GestionReportTable gestionReportTableFromGrid<T>({
  required String title,
  required List<GestionColumn<T>> columns,
  required List<T> rows,
  bool rowNumbers = true,
  String? sheetName,
  String emptyMessage = 'Sin registros',
}) {
  final List<GestionColumn<T>> exportables =
      columns.where((GestionColumn<T> c) => c.exportValue != null).toList();
  return GestionReportTable(
    title: title,
    sheetName: sheetName,
    emptyMessage: emptyMessage,
    columns: <GestionReportColumn>[
      if (rowNumbers) const GestionReportColumn('#', flex: 0.35, excelWidth: 6, align: GestionReportAlign.right),
      for (final GestionColumn<T> c in exportables)
        GestionReportColumn(c.label, flex: _flex(c), align: _align(c.alignment)),
    ],
    rows: <List<Object?>>[
      for (int i = 0; i < rows.length; i++)
        <Object?>[
          if (rowNumbers) i + 1,
          for (final GestionColumn<T> c in exportables) c.exportValue!(rows[i]),
        ],
    ],
  );
}

/// Texto "Orden: Columna (ascendente)" para la cabecera del informe
String? gestionSortDescription<T>(GestionSort sort, List<GestionColumn<T>> columns) {
  final int? i = sort.columnIndex;
  if (i == null || i >= columns.length || !columns[i].sortable) {
    return null;
  }
  return 'Orden: ${columns[i].label} (${sort.ascending ? 'ascendente' : 'descendente'})';
}

/// Ancho relativo en el PDF: proporcional al de la rejilla (px fijos o flex)
double _flex<T>(GestionColumn<T> c) {
  final double? w = c.width;
  return w != null ? w / 100 : c.flex.toDouble();
}

GestionReportAlign _align(Alignment a) {
  if (a.x > 0) {
    return GestionReportAlign.right;
  }
  return a.x == 0 ? GestionReportAlign.center : GestionReportAlign.left;
}
