import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';

/// Valor del filtro de estado sin restricción
const String ordenFiltroTodas = 'todos';

/// Valor del filtro de estado para órdenes activas (vehículo en taller)
const String ordenFiltroActivas = 'activas';

/// Opciones del filtro de estado (incluye "Activas")
final Map<String, String> ordenEstadoFiltroOptions = <String, String>{
  ordenFiltroTodas: 'Todos',
  ordenFiltroActivas: 'Activas',
  for (final EstadoOrdenReparacion e in EstadoOrdenReparacion.values) e.value: e.displayName,
};

String _numero(OrdenReparacionEntity o) =>
    o.numeroOrden.isEmpty ? GestionFormatters.vacio : o.numeroOrden;

/// Columnas de la rejilla de órdenes de reparación
final List<GestionColumn<OrdenReparacionEntity>> ordenGestionColumns =
    <GestionColumn<OrdenReparacionEntity>>[
  GestionColumn<OrdenReparacionEntity>(
    label: 'Nº orden',
    flex: 2,
    sortValue: (OrdenReparacionEntity o) => o.numeroOrden,
    cell: (OrdenReparacionEntity o) => TallerCellText(_numero(o), bold: true),
  ),
  GestionColumn<OrdenReparacionEntity>(
    label: 'Vehículo',
    flex: 2,
    sortValue: (OrdenReparacionEntity o) => (o.vehiculoMatricula ?? '').toLowerCase(),
    cell: (OrdenReparacionEntity o) => TallerCellText(GestionFormatters.texto(o.vehiculoMatricula)),
  ),
  GestionColumn<OrdenReparacionEntity>(
    label: 'Taller',
    flex: 3,
    sortValue: (OrdenReparacionEntity o) => (o.tallerNombre ?? '').toLowerCase(),
    cell: (OrdenReparacionEntity o) => TallerCellText(GestionFormatters.texto(o.tallerNombre)),
  ),
  GestionColumn<OrdenReparacionEntity>(
    label: 'Origen',
    flex: 2,
    sortValue: (OrdenReparacionEntity o) => o.origen.displayName,
    cell: (OrdenReparacionEntity o) => TallerCellText(o.origen.displayName),
  ),
  GestionColumn<OrdenReparacionEntity>(
    label: 'Prioridad',
    flex: 2,
    sortValue: (OrdenReparacionEntity o) => o.prioridad.index,
    cell: (OrdenReparacionEntity o) => GestionDotLabel(
      label: o.prioridad.displayName,
      color: prioridadOrdenColor(o.prioridad),
    ),
  ),
  GestionColumn<OrdenReparacionEntity>(
    label: 'Estado',
    flex: 2,
    sortValue: (OrdenReparacionEntity o) => o.estado.index,
    cell: (OrdenReparacionEntity o) => GestionDotLabel(
      label: o.estado.displayName,
      color: estadoOrdenColor(o.estado),
    ),
  ),
  GestionColumn<OrdenReparacionEntity>(
    label: 'Entrada',
    width: 100,
    sortValue: (OrdenReparacionEntity o) => o.fechaEntrada,
    cell: (OrdenReparacionEntity o) => TallerCellText(GestionFormatters.fecha(o.fechaEntrada)),
  ),
  GestionColumn<OrdenReparacionEntity>(
    label: 'Coste total',
    width: 120,
    alignment: Alignment.centerRight,
    sortValue: (OrdenReparacionEntity o) => o.costoTotal,
    cell: (OrdenReparacionEntity o) => TallerCellText(GestionFormatters.moneda(o.costoTotal), bold: true),
  ),
];

/// Filtra órdenes por texto (nº orden, matrícula, taller), estado y prioridad
List<OrdenReparacionEntity> filtrarOrdenes(
  List<OrdenReparacionEntity> ordenes, {
  required String query,
  required String estado,
  required PrioridadOrdenReparacion? prioridad,
}) {
  final String q = query.trim().toLowerCase();
  return ordenes.where((OrdenReparacionEntity o) {
    final bool matchesSearch = q.isEmpty ||
        o.numeroOrden.toLowerCase().contains(q) ||
        (o.vehiculoMatricula?.toLowerCase().contains(q) ?? false) ||
        (o.tallerNombre?.toLowerCase().contains(q) ?? false);
    final bool matchesEstado = estado == ordenFiltroTodas ||
        (estado == ordenFiltroActivas ? o.estado.isActiva : o.estado.value == estado);
    final bool matchesPrioridad = prioridad == null || o.prioridad == prioridad;
    return matchesSearch && matchesEstado && matchesPrioridad;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenOrdenes(List<OrdenReparacionEntity> todas, List<OrdenReparacionEntity> visibles) {
  int contar(bool Function(OrdenReparacionEntity) test) => todas.where(test).length;
  final int activas = contar((OrdenReparacionEntity o) => o.estado.isActiva);
  final int esperando =
      contar((OrdenReparacionEntity o) => o.estado == EstadoOrdenReparacion.esperandoRepuestos);
  final int terminadas = contar(
    (OrdenReparacionEntity o) =>
        o.estado == EstadoOrdenReparacion.finalizada || o.estado == EstadoOrdenReparacion.cerrada,
  );
  final double importe = visibles.fold<double>(
    0,
    (double sum, OrdenReparacionEntity o) => sum + o.costoTotal,
  );
  return <String>[
    if (visibles.length == todas.length)
      '${todas.length} registros'
    else
      '${visibles.length} de ${todas.length} registros',
    '$activas activas',
    '$esperando esperando repuestos',
    '$terminadas terminadas',
    'Importe ${GestionFormatters.moneda(importe)}',
  ];
}

/// Imprime el listado de órdenes (filtrado y ordenado)
Future<void> imprimirOrdenes(List<OrdenReparacionEntity> ordenes) {
  return GestionPrint.listado(
    title: 'Órdenes de Reparación',
    headers: const <String>[
      'Nº orden', 'Vehículo', 'Taller', 'Origen', 'Prioridad', 'Estado', 'Entrada', 'Coste total',
    ],
    rows: ordenes
        .map(
          (OrdenReparacionEntity o) => <String>[
            _numero(o),
            GestionFormatters.texto(o.vehiculoMatricula),
            GestionFormatters.texto(o.tallerNombre),
            o.origen.displayName,
            o.prioridad.displayName,
            o.estado.displayName,
            GestionFormatters.fecha(o.fechaEntrada),
            GestionFormatters.moneda(o.costoTotal),
          ],
        )
        .toList(),
  );
}
