import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/almacen_gestion_common.dart';
import 'package:flutter/material.dart';

/// Situación de una línea de stock (de más a menos grave)
enum StockSituacion {
  caducado('Caducado', AppColors.error),
  proximoCaducar('Próx. caducidad', AppColors.warning),
  bajo('Stock bajo', AppColors.warning),
  ok('OK', AppColors.success);

  const StockSituacion(this.label, this.color);

  final String label;
  final Color color;

  static StockSituacion de(StockEntity s) {
    if (s.caducado) {
      return StockSituacion.caducado;
    }
    if (s.proximoACaducar) {
      return StockSituacion.proximoCaducar;
    }
    if (s.bajoCantidadMinima) {
      return StockSituacion.bajo;
    }
    return StockSituacion.ok;
  }
}

/// Nombre del producto de la línea de stock
String stockProducto(StockEntity s, Map<String, ProductoEntity> productos) =>
    productos[s.idProducto]?.nombre ?? 'Producto no encontrado';

/// Categoría del producto (o marcador de vacío)
String stockCategoria(StockEntity s, Map<String, ProductoEntity> productos) =>
    productos[s.idProducto]?.categoria?.label ?? GestionFormatters.vacio;

/// Cantidad con su unidad de medida
String stockCantidad(StockEntity s, Map<String, ProductoEntity> productos) {
  final String unidad = productos[s.idProducto]?.unidadMedida ?? '';
  return '${almacenCantidad(s.cantidadActual)} $unidad'.trim();
}

/// Mínimo / máximo
String stockMinMax(StockEntity s) =>
    '${almacenCantidad(s.cantidadMinima)} / ${s.cantidadMaxima == null ? '—' : almacenCantidad(s.cantidadMaxima!)}';

/// Columnas de la rejilla de stock del almacén
List<GestionColumn<StockEntity>> stockGestionColumns(Map<String, ProductoEntity> productos) {
  return <GestionColumn<StockEntity>>[
    GestionColumn<StockEntity>(
      label: 'Producto',
      flex: 3,
      minWidth: 180,
      sortValue: (StockEntity s) => stockProducto(s, productos).toLowerCase(),
      cell: (StockEntity s) => AlmacenCellText(stockProducto(s, productos), bold: true),
    ),
    GestionColumn<StockEntity>(
      label: 'Categoría',
      width: 150,
      sortValue: (StockEntity s) => stockCategoria(s, productos),
      cell: (StockEntity s) => AlmacenCellText(stockCategoria(s, productos)),
    ),
    GestionColumn<StockEntity>(
      label: 'Cantidad',
      width: 110,
      alignment: Alignment.centerRight,
      sortValue: (StockEntity s) => s.cantidadActual,
      cell: (StockEntity s) => AlmacenCellText(stockCantidad(s, productos)),
    ),
    GestionColumn<StockEntity>(
      label: 'Mín / Máx',
      width: 100,
      sortValue: (StockEntity s) => s.cantidadMinima,
      cell: (StockEntity s) => AlmacenCellText(stockMinMax(s)),
    ),
    GestionColumn<StockEntity>(
      label: 'Ubicación',
      flex: 2,
      sortValue: (StockEntity s) => (s.ubicacionFisica ?? '').toLowerCase(),
      cell: (StockEntity s) => AlmacenCellText(GestionFormatters.texto(s.ubicacionFisica)),
    ),
    GestionColumn<StockEntity>(
      label: 'Lote / Nº serie',
      width: 130,
      sortValue: (StockEntity s) => (s.lote ?? s.numeroSerie ?? '').toLowerCase(),
      cell: (StockEntity s) => AlmacenCellText(GestionFormatters.texto(s.lote ?? s.numeroSerie)),
    ),
    GestionColumn<StockEntity>(
      label: 'Caducidad',
      width: 100,
      sortValue: (StockEntity s) => s.fechaCaducidad?.millisecondsSinceEpoch ?? 0,
      cell: (StockEntity s) => AlmacenCellText(GestionFormatters.fecha(s.fechaCaducidad)),
    ),
    GestionColumn<StockEntity>(
      label: 'Estado',
      width: 140,
      sortValue: (StockEntity s) => StockSituacion.de(s).index,
      cell: (StockEntity s) {
        final StockSituacion e = StockSituacion.de(s);
        return GestionDotLabel(label: e.label, color: e.color);
      },
    ),
  ];
}

/// Filtra por texto (producto, nombre comercial, código, ubicación, lote, nº serie),
/// categoría y situación
List<StockEntity> filtrarStock(
  List<StockEntity> items, {
  required Map<String, ProductoEntity> productos,
  required String query,
  required CategoriaProducto? categoria,
  required StockSituacion? situacion,
}) {
  final String q = query.trim().toLowerCase();
  bool contiene(String? v) => v?.toLowerCase().contains(q) ?? false;
  return items.where((StockEntity s) {
    final ProductoEntity? p = productos[s.idProducto];
    final bool matchesSearch = q.isEmpty ||
        contiene(p?.nombre) ||
        contiene(p?.nombreComercial) ||
        contiene(p?.codigo) ||
        contiene(s.ubicacionFisica) ||
        contiene(s.lote) ||
        contiene(s.numeroSerie);
    return matchesSearch &&
        (categoria == null || p?.categoria == categoria) &&
        (situacion == null || StockSituacion.de(s) == situacion);
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenStock(List<StockEntity> todos, int filtrados) {
  int count(StockSituacion e) => todos.where((StockEntity s) => StockSituacion.de(s) == e).length;
  return <String>[
    almacenRegistrosLabel(todos.length, filtrados),
    'Stock bajo ${count(StockSituacion.bajo)}',
    'Próx. caducidad ${count(StockSituacion.proximoCaducar)}',
    'Caducados ${count(StockSituacion.caducado)}',
    'Reservados ${todos.where((StockEntity s) => s.cantidadReservada > 0).length}',
  ];
}

/// Imprime el listado de stock (filtrado y ordenado)
Future<void> imprimirStock(List<StockEntity> items, Map<String, ProductoEntity> productos) {
  return GestionPrint.listado(
    title: 'Almacén General — Stock',
    headers: const <String>[
      'Producto', 'Categoría', 'Cantidad', 'Mín / Máx', 'Ubicación', 'Lote / Nº serie', 'Caducidad', 'Estado',
    ],
    rows: items
        .map(
          (StockEntity s) => <String>[
            stockProducto(s, productos),
            stockCategoria(s, productos),
            stockCantidad(s, productos),
            stockMinMax(s),
            GestionFormatters.texto(s.ubicacionFisica),
            GestionFormatters.texto(s.lote ?? s.numeroSerie),
            GestionFormatters.fecha(s.fechaCaducidad),
            StockSituacion.de(s).label,
          ],
        )
        .toList(),
  );
}
