import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Estado combinado de un item de stock (la caducidad tiene prioridad)
String stockItemEstadoLabel(StockVehiculoEntity item) {
  switch (item.estadoCaducidad) {
    case 'caducado':
      return 'Caducado';
    case 'critico':
      return 'Caduca pronto';
    case 'proximo':
      return 'Próximo a caducar';
  }
  switch (item.estadoStock) {
    case 'sin_stock':
      return 'Sin stock';
    case 'bajo':
      return 'Stock bajo';
  }
  return 'OK';
}

/// Color del estado combinado de un item de stock
Color stockItemEstadoColor(StockVehiculoEntity item) {
  if (item.estadoCaducidad == 'caducado' || item.estadoStock == 'sin_stock') {
    return AppColors.error;
  }
  if (item.estadoCaducidad == 'critico' ||
      item.estadoCaducidad == 'proximo' ||
      item.estadoStock == 'bajo') {
    return AppColors.warning;
  }
  return AppColors.success;
}

/// Estados disponibles en el filtro
const List<String> stockItemEstados = <String>[
  'OK',
  'Stock bajo',
  'Sin stock',
  'Próximo a caducar',
  'Caduca pronto',
  'Caducado',
];

/// Indicador de estado del item de stock
class StockItemEstadoDot extends StatelessWidget {
  const StockItemEstadoDot({required this.item, super.key});

  final StockVehiculoEntity item;

  @override
  Widget build(BuildContext context) =>
      GestionDotLabel(label: stockItemEstadoLabel(item), color: stockItemEstadoColor(item));
}

Color? _cantidadColor(StockVehiculoEntity s) => s.estadoStock == 'sin_stock'
    ? AppColors.error
    : s.estadoStock == 'bajo'
        ? AppColors.warning
        : null;

/// Columnas de la rejilla de stock del vehículo
final List<GestionColumn<StockVehiculoEntity>> vehiculoStockColumns = <GestionColumn<StockVehiculoEntity>>[
  GestionColumn<StockVehiculoEntity>(
    label: 'Producto',
    flex: 3,
    sortValue: (StockVehiculoEntity s) => (s.productoNombre ?? '').toLowerCase(),
    cell: (StockVehiculoEntity s) => FlotaCellText(GestionFormatters.texto(s.productoNombre), bold: true),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Nombre comercial',
    flex: 2,
    sortValue: (StockVehiculoEntity s) => (s.nombreComercial ?? '').toLowerCase(),
    cell: (StockVehiculoEntity s) => FlotaCellText(GestionFormatters.texto(s.nombreComercial)),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Categoría',
    flex: 2,
    sortValue: (StockVehiculoEntity s) => (s.categoriaNombre ?? '').toLowerCase(),
    cell: (StockVehiculoEntity s) => FlotaCellText(GestionFormatters.texto(s.categoriaNombre)),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Cantidad',
    width: 84,
    alignment: Alignment.centerRight,
    sortValue: (StockVehiculoEntity s) => s.cantidadActual,
    cell: (StockVehiculoEntity s) =>
        FlotaCellText('${s.cantidadActual}', bold: true, color: _cantidadColor(s)),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Mínimo',
    width: 76,
    alignment: Alignment.centerRight,
    sortValue: (StockVehiculoEntity s) => s.cantidadMinima ?? -1,
    cell: (StockVehiculoEntity s) => FlotaCellText(s.cantidadMinima?.toString() ?? GestionFormatters.vacio),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Lote',
    width: 110,
    sortValue: (StockVehiculoEntity s) => (s.lote ?? '').toLowerCase(),
    cell: (StockVehiculoEntity s) => FlotaCellText(GestionFormatters.texto(s.lote)),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Caducidad',
    width: 100,
    sortValue: (StockVehiculoEntity s) => s.fechaCaducidad?.millisecondsSinceEpoch ?? 0,
    cell: (StockVehiculoEntity s) => FlotaCellText(GestionFormatters.fecha(s.fechaCaducidad)),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Ubicación',
    flex: 2,
    sortValue: (StockVehiculoEntity s) => (s.ubicacion ?? '').toLowerCase(),
    cell: (StockVehiculoEntity s) => FlotaCellText(GestionFormatters.texto(s.ubicacion)),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Estado',
    width: 140,
    sortValue: stockItemEstadoLabel,
    cell: (StockVehiculoEntity s) => StockItemEstadoDot(item: s),
  ),
];

/// Filtra por texto (producto, nombre comercial, lote, ubicación), categoría y estado
List<StockVehiculoEntity> filtrarStockVehiculo(
  List<StockVehiculoEntity> items, {
  required String query,
  required String? categoria,
  required String? estado,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((StockVehiculoEntity s) {
    final bool matchesSearch = q.isEmpty ||
        (s.productoNombre?.toLowerCase().contains(q) ?? false) ||
        (s.nombreComercial?.toLowerCase().contains(q) ?? false) ||
        (s.lote?.toLowerCase().contains(q) ?? false) ||
        (s.ubicacion?.toLowerCase().contains(q) ?? false);
    return matchesSearch &&
        (categoria == null || s.categoriaNombre == categoria) &&
        (estado == null || stockItemEstadoLabel(s) == estado);
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenStockVehiculo(List<StockVehiculoEntity> todos, int filtrados) {
  int count(Color color) =>
      todos.where((StockVehiculoEntity s) => stockItemEstadoColor(s) == color).length;
  return <String>[
    flotaResumenRegistros(todos.length, filtrados),
    'OK ${count(AppColors.success)}',
    'Atención ${count(AppColors.warning)}',
    'Críticos ${count(AppColors.error)}',
  ];
}

/// Imprime el stock del vehículo (filtrado y ordenado)
Future<void> imprimirStockVehiculo(List<StockVehiculoEntity> items, String titulo) {
  return GestionPrint.listado(
    title: titulo,
    headers: const <String>[
      'Producto', 'Nombre comercial', 'Categoría', 'Cantidad', 'Mínimo', 'Lote', 'Caducidad', 'Ubicación',
      'Estado',
    ],
    rows: items
        .map(
          (StockVehiculoEntity s) => <String>[
            GestionFormatters.texto(s.productoNombre),
            GestionFormatters.texto(s.nombreComercial),
            GestionFormatters.texto(s.categoriaNombre),
            '${s.cantidadActual}',
            s.cantidadMinima?.toString() ?? GestionFormatters.vacio,
            GestionFormatters.texto(s.lote),
            GestionFormatters.fecha(s.fechaCaducidad),
            GestionFormatters.texto(s.ubicacion),
            stockItemEstadoLabel(s),
          ],
        )
        .toList(),
  );
}
