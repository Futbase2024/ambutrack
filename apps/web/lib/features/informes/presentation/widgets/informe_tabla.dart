import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_grid.dart';
import 'package:ambutrack_web/features/informes/domain/informe_models.dart';
import 'package:flutter/material.dart';

/// Definición de una columna de informe: sirve tanto para la rejilla como
/// para la impresión en PDF.
class InformeColumna<T> {
  const InformeColumna({
    required this.label,
    required this.texto,
    this.orden,
    this.flex = 1,
    this.width,
    this.numerica = false,
    this.negrita = false,
  });

  final String label;

  /// Texto de la celda (también se usa en el PDF)
  final String Function(T item) texto;

  /// Valor de ordenación (null = no ordenable)
  final Comparable<Object> Function(T item)? orden;
  final int flex;
  final double? width;

  /// Alinea a la derecha
  final bool numerica;
  final bool negrita;

  GestionColumn<T> toGestionColumn() {
    return GestionColumn<T>(
      label: label,
      flex: flex,
      width: width,
      sortValue: orden,
      alignment: numerica ? Alignment.centerRight : Alignment.centerLeft,
      cell: (T item) => _InformeCelda(texto: texto(item), negrita: negrita),
    );
  }
}

/// Construye los datos de impresión a partir de columnas y filas
InformeImpresion informeImpresion<T>(List<InformeColumna<T>> columnas, List<T> filas) {
  return InformeImpresion(
    headers: columnas.map((InformeColumna<T> c) => c.label).toList(),
    rows: filas
        .map((T f) => columnas.map((InformeColumna<T> c) => c.texto(f)).toList())
        .toList(),
  );
}

/// Rejilla de desglose de un informe (ordenable y con selección de fila)
class InformeTabla<T> extends StatefulWidget {
  const InformeTabla({
    required this.columnas,
    required this.filas,
    required this.rowId,
    this.emptyMessage = 'No hay datos en el periodo seleccionado',
    super.key,
  });

  final List<InformeColumna<T>> columnas;
  final List<T> filas;
  final String Function(T item) rowId;
  final String emptyMessage;

  @override
  State<InformeTabla<T>> createState() => _InformeTablaState<T>();
}

class _InformeTablaState<T> extends State<InformeTabla<T>> {
  GestionSort _sort = const GestionSort();
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final List<GestionColumn<T>> columns =
        widget.columnas.map((InformeColumna<T> c) => c.toGestionColumn()).toList();
    return GestionGrid<T>(
      columns: columns,
      rows: _sort.apply(widget.filas, columns),
      rowId: widget.rowId,
      selectedId: _selectedId,
      sort: _sort,
      emptyMessage: widget.emptyMessage,
      onSort: (GestionSort s) => setState(() => _sort = s),
      onSelect: (T item) => setState(() => _selectedId = widget.rowId(item)),
    );
  }
}

class _InformeCelda extends StatelessWidget {
  const _InformeCelda({required this.texto, required this.negrita});

  final String texto;
  final bool negrita;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: negrita ? FontWeight.w600 : FontWeight.w400,
        color: AppColors.gray900,
      ),
    );
  }
}
