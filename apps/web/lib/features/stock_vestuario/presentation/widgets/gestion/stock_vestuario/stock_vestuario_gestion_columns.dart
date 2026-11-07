import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Nivel de existencias de un artículo
enum NivelStock {
  normal('Normal'),
  bajo('Stock bajo'),
  sinStock('Sin stock');

  const NivelStock(this.label);

  final String label;

  static NivelStock of(StockVestuarioEntity s) {
    if (s.sinStock) {
      return NivelStock.sinStock;
    }
    if (s.tieneStockBajo) {
      return NivelStock.bajo;
    }
    return NivelStock.normal;
  }

  Color get color {
    switch (this) {
      case NivelStock.normal:
        return AppColors.success;
      case NivelStock.bajo:
        return AppColors.warning;
      case NivelStock.sinStock:
        return AppColors.error;
    }
  }
}

/// Filtro por estado del artículo
enum StockEstadoFiltro { todos, activos, inactivos }

/// Indicador activo/inactivo
class StockEstadoDot extends StatelessWidget {
  const StockEstadoDot({required this.activo, super.key});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: activo ? 'Activo' : 'Inactivo',
      color: activo ? AppColors.success : AppColors.inactive,
    );
  }
}

/// Cantidad disponible con punto de color según el nivel de stock
class StockDisponibleDot extends StatelessWidget {
  const StockDisponibleDot({required this.item, super.key});

  final StockVestuarioEntity item;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: '${item.cantidadDisponible}',
      color: NivelStock.of(item).color,
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class StockCellText extends StatelessWidget {
  const StockCellText(this.value, {this.bold = false, super.key});

  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == GestionFormatters.vacio;
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: empty ? AppColors.gray300 : null,
      ),
    );
  }
}

/// Columnas de la rejilla de stock de vestuario
final List<GestionColumn<StockVestuarioEntity>> stockVestuarioColumns =
    <GestionColumn<StockVestuarioEntity>>[
  GestionColumn<StockVestuarioEntity>(
    label: 'Prenda',
    flex: 3,
    sortValue: (StockVestuarioEntity s) => s.prenda.toLowerCase(),
    cell: (StockVestuarioEntity s) => StockCellText(s.prenda, bold: true),
  ),
  GestionColumn<StockVestuarioEntity>(
    label: 'Talla',
    width: 80,
    sortValue: (StockVestuarioEntity s) => s.talla.toLowerCase(),
    cell: (StockVestuarioEntity s) => StockCellText(GestionFormatters.texto(s.talla)),
  ),
  GestionColumn<StockVestuarioEntity>(
    label: 'Marca',
    flex: 2,
    sortValue: (StockVestuarioEntity s) => (s.marca ?? '').toLowerCase(),
    cell: (StockVestuarioEntity s) => StockCellText(GestionFormatters.texto(s.marca)),
  ),
  GestionColumn<StockVestuarioEntity>(
    label: 'Color',
    flex: 2,
    sortValue: (StockVestuarioEntity s) => (s.color ?? '').toLowerCase(),
    cell: (StockVestuarioEntity s) => StockCellText(GestionFormatters.texto(s.color)),
  ),
  GestionColumn<StockVestuarioEntity>(
    label: 'Total',
    width: 80,
    alignment: Alignment.centerRight,
    sortValue: (StockVestuarioEntity s) => s.cantidadTotal,
    cell: (StockVestuarioEntity s) => StockCellText('${s.cantidadTotal}', bold: true),
  ),
  GestionColumn<StockVestuarioEntity>(
    label: 'Asignada',
    width: 90,
    alignment: Alignment.centerRight,
    sortValue: (StockVestuarioEntity s) => s.cantidadAsignada,
    cell: (StockVestuarioEntity s) => StockCellText('${s.cantidadAsignada}'),
  ),
  GestionColumn<StockVestuarioEntity>(
    label: 'Disponible',
    width: 100,
    sortValue: (StockVestuarioEntity s) => s.cantidadDisponible,
    cell: (StockVestuarioEntity s) => StockDisponibleDot(item: s),
  ),
  GestionColumn<StockVestuarioEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (StockVestuarioEntity s) => s.activo ? 0 : 1,
    cell: (StockVestuarioEntity s) => StockEstadoDot(activo: s.activo),
  ),
];

/// Filtra por texto (prenda, talla, marca, color, proveedor), nivel y estado
List<StockVestuarioEntity> filtrarStockVestuario(
  List<StockVestuarioEntity> items, {
  required String query,
  required NivelStock? nivel,
  required StockEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((StockVestuarioEntity s) {
    final bool matchesSearch = q.isEmpty ||
        s.prenda.toLowerCase().contains(q) ||
        s.talla.toLowerCase().contains(q) ||
        (s.marca?.toLowerCase().contains(q) ?? false) ||
        (s.color?.toLowerCase().contains(q) ?? false) ||
        (s.proveedor?.toLowerCase().contains(q) ?? false);
    final bool matchesNivel = nivel == null || NivelStock.of(s) == nivel;
    final bool matchesEstado = estado == StockEstadoFiltro.todos ||
        (estado == StockEstadoFiltro.activos ? s.activo : !s.activo);
    return matchesSearch && matchesNivel && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenStockVestuario(List<StockVestuarioEntity> todos, int filtrados) {
  int count(NivelStock n) => todos.where((StockVestuarioEntity s) => NivelStock.of(s) == n).length;
  final int unidades =
      todos.fold<int>(0, (int sum, StockVestuarioEntity s) => sum + s.cantidadDisponible);
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} artículos'
    else
      '$filtrados de ${todos.length} artículos',
    '$unidades uds. disponibles',
    'Normal ${count(NivelStock.normal)}',
    'Stock bajo ${count(NivelStock.bajo)}',
    'Sin stock ${count(NivelStock.sinStock)}',
    '${todos.where((StockVestuarioEntity s) => s.activo).length} activos',
  ];
}

/// Imprime el listado de stock (filtrado y ordenado)
Future<void> imprimirStockVestuario(List<StockVestuarioEntity> items) {
  return GestionPrint.listado(
    title: 'Stock de Vestuario',
    headers: const <String>[
      'Prenda', 'Talla', 'Marca', 'Color', 'Total', 'Asignada', 'Disponible', 'Mínimo',
      'Proveedor', 'Ubicación', 'Estado',
    ],
    rows: items
        .map(
          (StockVestuarioEntity s) => <String>[
            s.prenda,
            s.talla,
            GestionFormatters.texto(s.marca),
            GestionFormatters.texto(s.color),
            '${s.cantidadTotal}',
            '${s.cantidadAsignada}',
            '${s.cantidadDisponible}',
            GestionFormatters.texto(s.stockMinimo?.toString()),
            GestionFormatters.texto(s.proveedor),
            GestionFormatters.texto(s.ubicacionAlmacen),
            if (s.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
