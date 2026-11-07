import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity;
// ignore: implementation_imports
import 'package:ambutrack_core_datasource/src/datasources/almacen/entities/movimiento_stock_entity.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/almacen_gestion_common.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm');

/// Fecha y hora del movimiento o marcador de vacío
String movimientoFechaHora(DateTime? value) =>
    value == null ? GestionFormatters.vacio : _fechaHora.format(value.toLocal());

/// Filtro por sentido del movimiento
enum MovimientoSentidoFiltro { todos, entradas, salidas, transferencias }

/// Opciones del filtro de sentido
const Map<MovimientoSentidoFiltro, String> movimientoSentidoOptions = <MovimientoSentidoFiltro, String>{
  MovimientoSentidoFiltro.todos: 'Todos',
  MovimientoSentidoFiltro.entradas: 'Entradas',
  MovimientoSentidoFiltro.salidas: 'Salidas',
  MovimientoSentidoFiltro.transferencias: 'Transferencias',
};

/// Color asociado a cada tipo de movimiento
Color movimientoTipoColor(TipoMovimientoStock tipo) {
  switch (tipo) {
    case TipoMovimientoStock.entradaCompra:
      return AppColors.success;
    case TipoMovimientoStock.transferenciaAVehiculo:
    case TipoMovimientoStock.transferenciaEntreVehiculos:
      return AppColors.info;
    case TipoMovimientoStock.transferenciaDeVehiculo:
      return AppColors.secondary;
    case TipoMovimientoStock.consumoServicio:
      return AppColors.warning;
    case TipoMovimientoStock.ajusteInventario:
      return AppColors.primary;
    case TipoMovimientoStock.bajaCaducidad:
    case TipoMovimientoStock.bajaDeterioro:
      return AppColors.error;
    case TipoMovimientoStock.devolucionProveedor:
      return AppColors.inactive;
  }
}

/// Cantidad con signo según el sentido del movimiento ("+5", "−3")
String movimientoCantidadConSigno(MovimientoStockEntity m) {
  final String cantidad = almacenCantidad(m.cantidad);
  if (m.tipo.esEntrada) {
    return '+$cantidad';
  }
  return m.tipo.esSalida ? '−$cantidad' : cantidad;
}

/// Color de la cantidad según el sentido del movimiento
Color movimientoCantidadColor(TipoMovimientoStock tipo) {
  if (tipo.esEntrada) {
    return AppColors.success;
  }
  return tipo.esSalida ? AppColors.error : AppColors.gray800;
}

/// Nombre del producto del movimiento (o marcador de vacío si no está cargado)
String movimientoProductoNombre(MovimientoStockEntity m, Map<String, ProductoEntity> productos) =>
    productos[m.idProducto]?.nombre ?? GestionFormatters.vacio;

String _stockAntesDespues(MovimientoStockEntity m) {
  if (m.cantidadAnterior == null && m.cantidadNueva == null) {
    return GestionFormatters.vacio;
  }
  final String antes = m.cantidadAnterior == null ? '?' : almacenCantidad(m.cantidadAnterior!);
  final String despues = m.cantidadNueva == null ? '?' : almacenCantidad(m.cantidadNueva!);
  return '$antes → $despues';
}

/// Lote o número de serie del movimiento
String movimientoTrazabilidad(MovimientoStockEntity m) =>
    GestionFormatters.texto(m.lote ?? m.numeroSerie);

/// Columnas de la rejilla de movimientos (requiere el catálogo de productos)
List<GestionColumn<MovimientoStockEntity>> movimientoGestionColumns(
  Map<String, ProductoEntity> productos,
) {
  return <GestionColumn<MovimientoStockEntity>>[
    GestionColumn<MovimientoStockEntity>(
      label: 'Fecha',
      width: 130,
      sortValue: (MovimientoStockEntity m) => m.createdAt ?? DateTime(1970),
      cell: (MovimientoStockEntity m) => AlmacenCellText(movimientoFechaHora(m.createdAt)),
    ),
    GestionColumn<MovimientoStockEntity>(
      label: 'Tipo',
      flex: 3,
      sortValue: (MovimientoStockEntity m) => m.tipo.label,
      cell: (MovimientoStockEntity m) => GestionDotLabel(
        label: m.tipo.label,
        color: movimientoTipoColor(m.tipo),
      ),
    ),
    GestionColumn<MovimientoStockEntity>(
      label: 'Producto',
      flex: 4,
      sortValue: (MovimientoStockEntity m) => movimientoProductoNombre(m, productos).toLowerCase(),
      cell: (MovimientoStockEntity m) => AlmacenCellText(movimientoProductoNombre(m, productos), bold: true),
    ),
    GestionColumn<MovimientoStockEntity>(
      label: 'Cantidad',
      width: 90,
      alignment: Alignment.centerRight,
      sortValue: (MovimientoStockEntity m) => m.cantidad,
      cell: (MovimientoStockEntity m) => AlmacenCellText(
        movimientoCantidadConSigno(m),
        bold: true,
        color: movimientoCantidadColor(m.tipo),
      ),
    ),
    GestionColumn<MovimientoStockEntity>(
      label: 'Stock',
      width: 110,
      cell: (MovimientoStockEntity m) => AlmacenCellText(_stockAntesDespues(m)),
    ),
    GestionColumn<MovimientoStockEntity>(
      label: 'Lote / Nº serie',
      flex: 2,
      sortValue: (MovimientoStockEntity m) => (m.lote ?? m.numeroSerie ?? '').toLowerCase(),
      cell: (MovimientoStockEntity m) => AlmacenCellText(movimientoTrazabilidad(m)),
    ),
    GestionColumn<MovimientoStockEntity>(
      label: 'Referencia',
      flex: 2,
      sortValue: (MovimientoStockEntity m) => (m.referencia ?? '').toLowerCase(),
      cell: (MovimientoStockEntity m) => AlmacenCellText(GestionFormatters.texto(m.referencia)),
    ),
    GestionColumn<MovimientoStockEntity>(
      label: 'Motivo',
      flex: 3,
      cell: (MovimientoStockEntity m) => AlmacenCellText(GestionFormatters.texto(m.motivo)),
    ),
  ];
}

/// Filtra movimientos por texto (producto, lote, nº serie, referencia, motivo), tipo y sentido
List<MovimientoStockEntity> filtrarMovimientos(
  List<MovimientoStockEntity> movimientos,
  Map<String, ProductoEntity> productos, {
  required String query,
  required TipoMovimientoStock? tipo,
  required MovimientoSentidoFiltro sentido,
}) {
  final String q = query.trim().toLowerCase();
  bool contiene(String? value) => value?.toLowerCase().contains(q) ?? false;
  return movimientos.where((MovimientoStockEntity m) {
    final ProductoEntity? p = productos[m.idProducto];
    final bool matchesSearch = q.isEmpty ||
        contiene(p?.nombre) ||
        contiene(p?.codigo) ||
        contiene(m.lote) ||
        contiene(m.numeroSerie) ||
        contiene(m.referencia) ||
        contiene(m.motivo);
    final bool matchesTipo = tipo == null || m.tipo == tipo;
    final bool matchesSentido = switch (sentido) {
      MovimientoSentidoFiltro.todos => true,
      MovimientoSentidoFiltro.entradas => m.tipo.esEntrada,
      MovimientoSentidoFiltro.salidas => m.tipo.esSalida,
      MovimientoSentidoFiltro.transferencias => m.tipo.esTransferencia,
    };
    return matchesSearch && matchesTipo && matchesSentido;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenMovimientos(List<MovimientoStockEntity> todos, int filtrados, int limite) {
  int contar(bool Function(TipoMovimientoStock) test) =>
      todos.where((MovimientoStockEntity m) => test(m.tipo)).length;
  return <String>[
    almacenRegistrosLabel(todos.length, filtrados),
    '${contar((TipoMovimientoStock t) => t.esEntrada)} entradas',
    '${contar((TipoMovimientoStock t) => t.esSalida)} salidas',
    '${contar((TipoMovimientoStock t) => t.esTransferencia)} transferencias',
    if (todos.length >= limite) 'Mostrando los últimos $limite',
  ];
}

/// Imprime el listado de movimientos (filtrado y ordenado)
Future<void> imprimirMovimientos(
  List<MovimientoStockEntity> movimientos,
  Map<String, ProductoEntity> productos,
) {
  return GestionPrint.listado(
    title: 'Movimientos de Stock',
    headers: const <String>[
      'Fecha', 'Tipo', 'Producto', 'Cantidad', 'Stock', 'Lote / Nº serie', 'Referencia', 'Motivo',
    ],
    rows: movimientos
        .map(
          (MovimientoStockEntity m) => <String>[
            movimientoFechaHora(m.createdAt),
            m.tipo.label,
            movimientoProductoNombre(m, productos),
            movimientoCantidadConSigno(m),
            _stockAntesDespues(m),
            movimientoTrazabilidad(m),
            GestionFormatters.texto(m.referencia),
            GestionFormatters.texto(m.motivo),
          ],
        )
        .toList(),
  );
}
