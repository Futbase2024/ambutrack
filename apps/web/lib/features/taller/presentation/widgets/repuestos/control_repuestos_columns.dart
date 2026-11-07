import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/control_repuestos_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/taller_consulta_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';

/// Filtro de estado: repuestos aún no recibidos (solicitados + pedidos)
const String repuestoEstadoPendientes = 'pendientes';

/// Opciones del filtro de estado de repuesto
final Map<String, String> repuestoEstadoOptions = <String, String>{
  tallerFiltroTodos: 'Todos',
  repuestoEstadoPendientes: 'Pendientes de recibir',
  for (final EstadoRepuesto e in EstadoRepuesto.values) e.value: e.displayName,
};

/// Criterios de filtrado del control de repuestos
class ControlRepuestosFiltro {
  const ControlRepuestosFiltro({
    this.query = '',
    this.estado = tallerFiltroTodos,
    this.proveedor = tallerFiltroTodos,
    this.vehiculo = tallerFiltroTodos,
    this.rango,
  });

  final String query;
  final String estado;
  final String proveedor;
  final String vehiculo;

  /// Rango sobre la fecha de pedido (o de alta si no se pidió)
  final DateTimeRange? rango;

  bool get activo =>
      query.isNotEmpty || estado.isNotEmpty || proveedor.isNotEmpty || vehiculo.isNotEmpty || rango != null;

  ControlRepuestosFiltro copyWith({
    String? query,
    String? estado,
    String? proveedor,
    String? vehiculo,
    DateTimeRange? rango,
    bool clearRango = false,
  }) {
    return ControlRepuestosFiltro(
      query: query ?? this.query,
      estado: estado ?? this.estado,
      proveedor: proveedor ?? this.proveedor,
      vehiculo: vehiculo ?? this.vehiculo,
      rango: clearRango ? null : rango ?? this.rango,
    );
  }

  bool _estadoOk(EstadoRepuesto e) {
    if (estado.isEmpty) {
      return true;
    }
    if (estado == repuestoEstadoPendientes) {
      return e == EstadoRepuesto.solicitado || e == EstadoRepuesto.pedido;
    }
    return e.value == estado;
  }

  bool matches(RepuestoControlItem i) {
    final String q = query.trim().toLowerCase();
    final RepuestoOrdenEntity r = i.repuesto;
    final bool texto = q.isEmpty ||
        r.descripcion.toLowerCase().contains(q) ||
        (r.referencia?.toLowerCase().contains(q) ?? false) ||
        (i.numeroOrden?.toLowerCase().contains(q) ?? false) ||
        (i.vehiculoMatricula?.toLowerCase().contains(q) ?? false);
    return texto &&
        _estadoOk(r.estado) &&
        (proveedor.isEmpty || r.proveedorNombre == proveedor) &&
        (vehiculo.isEmpty || i.vehiculoMatricula == vehiculo) &&
        tallerEnRango(i.fechaReferencia, rango);
  }
}

TallerCellText _txt(String? v, {bool bold = false}) => TallerCellText(GestionFormatters.texto(v), bold: bold);

/// Columnas de la rejilla de control de repuestos
final List<GestionColumn<RepuestoControlItem>> controlRepuestosColumns = <GestionColumn<RepuestoControlItem>>[
  GestionColumn<RepuestoControlItem>(
    label: 'Descripción',
    flex: 4,
    sortValue: (RepuestoControlItem i) => i.repuesto.descripcion.toLowerCase(),
    cell: (RepuestoControlItem i) => _txt(i.repuesto.descripcion, bold: true),
  ),
  GestionColumn<RepuestoControlItem>(
    label: 'Referencia',
    flex: 2,
    sortValue: (RepuestoControlItem i) => (i.repuesto.referencia ?? '').toLowerCase(),
    cell: (RepuestoControlItem i) => _txt(i.repuesto.referencia),
  ),
  GestionColumn<RepuestoControlItem>(
    label: 'Nº orden',
    flex: 2,
    sortValue: (RepuestoControlItem i) => i.numeroOrden ?? '',
    cell: (RepuestoControlItem i) => _txt(i.numeroOrden),
  ),
  GestionColumn<RepuestoControlItem>(
    label: 'Vehículo',
    flex: 2,
    sortValue: (RepuestoControlItem i) => (i.vehiculoMatricula ?? '').toLowerCase(),
    cell: (RepuestoControlItem i) => _txt(i.vehiculoMatricula),
  ),
  GestionColumn<RepuestoControlItem>(
    label: 'Proveedor',
    flex: 3,
    sortValue: (RepuestoControlItem i) => (i.repuesto.proveedorNombre ?? '').toLowerCase(),
    cell: (RepuestoControlItem i) => _txt(i.repuesto.proveedorNombre),
  ),
  GestionColumn<RepuestoControlItem>(
    label: 'Cant.',
    width: 60,
    alignment: Alignment.centerRight,
    sortValue: (RepuestoControlItem i) => i.repuesto.cantidad,
    cell: (RepuestoControlItem i) => TallerCellText('${i.repuesto.cantidad}'),
  ),
  GestionColumn<RepuestoControlItem>(
    label: 'P. unitario',
    width: 100,
    alignment: Alignment.centerRight,
    sortValue: (RepuestoControlItem i) => i.repuesto.precioUnitario,
    cell: (RepuestoControlItem i) => TallerCellText(GestionFormatters.moneda(i.repuesto.precioUnitario)),
  ),
  GestionColumn<RepuestoControlItem>(
    label: 'Total',
    width: 110,
    alignment: Alignment.centerRight,
    sortValue: (RepuestoControlItem i) => i.repuesto.precioTotal,
    cell: (RepuestoControlItem i) => TallerCellText(GestionFormatters.moneda(i.repuesto.precioTotal), bold: true),
  ),
  GestionColumn<RepuestoControlItem>(
    label: 'Estado',
    flex: 2,
    sortValue: (RepuestoControlItem i) => i.repuesto.estado.index,
    cell: (RepuestoControlItem i) => GestionDotLabel(
      label: i.repuesto.estado.displayName,
      color: estadoRepuestoColor(i.repuesto.estado),
    ),
  ),
  GestionColumn<RepuestoControlItem>(
    label: 'Pedido',
    width: 100,
    sortValue: (RepuestoControlItem i) => i.fechaReferencia,
    cell: (RepuestoControlItem i) => TallerCellText(GestionFormatters.fecha(i.repuesto.fechaPedido)),
  ),
  GestionColumn<RepuestoControlItem>(
    label: 'Recibido',
    width: 100,
    sortValue: (RepuestoControlItem i) => i.repuesto.fechaRecibido ?? DateTime(0),
    cell: (RepuestoControlItem i) => TallerCellText(GestionFormatters.fecha(i.repuesto.fechaRecibido)),
  ),
];

/// Resumen de la barra de estado: registros, coste total y recuento por estado
List<String> resumenControlRepuestos(List<RepuestoControlItem> todos, List<RepuestoControlItem> visibles) {
  final double total = visibles.fold<double>(0, (double s, RepuestoControlItem i) => s + i.repuesto.precioTotal);
  return <String>[
    tallerRegistrosLabel(todos.length, visibles.length),
    'Coste total ${GestionFormatters.moneda(total)}',
    for (final EstadoRepuesto e in EstadoRepuesto.values)
      '${e.displayName} ${visibles.where((RepuestoControlItem i) => i.repuesto.estado == e).length}',
  ];
}

/// Imprime el listado de repuestos filtrado
Future<void> imprimirControlRepuestos(List<RepuestoControlItem> items, {String? subtitle}) {
  return GestionPrint.listado(
    title: 'Control de Repuestos',
    subtitle: subtitle,
    headers: const <String>[
      'Descripción', 'Referencia', 'Nº orden', 'Vehículo', 'Proveedor',
      'Cant.', 'P. unitario', 'Total', 'Estado', 'Pedido', 'Recibido',
    ],
    rows: items.map((RepuestoControlItem i) {
      final RepuestoOrdenEntity r = i.repuesto;
      return <String>[
        r.descripcion,
        GestionFormatters.texto(r.referencia),
        GestionFormatters.texto(i.numeroOrden),
        GestionFormatters.texto(i.vehiculoMatricula),
        GestionFormatters.texto(r.proveedorNombre),
        '${r.cantidad}',
        GestionFormatters.moneda(r.precioUnitario),
        GestionFormatters.moneda(r.precioTotal),
        r.estado.displayName,
        GestionFormatters.fecha(r.fechaPedido),
        GestionFormatters.fecha(r.fechaRecibido),
      ];
    }).toList(),
  );
}
