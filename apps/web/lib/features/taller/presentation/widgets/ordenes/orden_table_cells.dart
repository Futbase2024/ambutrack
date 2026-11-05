import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';

/// Columnas de la tabla de Órdenes de Reparación
const List<DataGridColumn> ordenTableColumns = <DataGridColumn>[
  DataGridColumn(label: 'Nº ORDEN', flexWidth: 2),
  DataGridColumn(label: 'VEHÍCULO', flexWidth: 2),
  DataGridColumn(label: 'TALLER', flexWidth: 3),
  DataGridColumn(label: 'ORIGEN', flexWidth: 2),
  DataGridColumn(label: 'PRIORIDAD', flexWidth: 2),
  DataGridColumn(label: 'ESTADO', flexWidth: 2),
  DataGridColumn(label: 'ENTRADA', flexWidth: 2),
  DataGridColumn(label: 'COSTE TOTAL', flexWidth: 2),
];

/// Valor del filtro para mostrar solo órdenes activas
const String filtroOrdenesActivas = 'activas';

/// Valor del filtro sin restricción
const String filtroOrdenesTodas = 'todos';

/// Construye las celdas de una fila de orden
List<DataGridCell> buildOrdenCells(OrdenReparacionEntity o) {
  return <DataGridCell>[
    DataGridCell(
      child: Text(
        o.numeroOrden.isEmpty ? '-' : o.numeroOrden,
        style: AppTextStyles.tableCell.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    DataGridCell(child: Text(o.vehiculoMatricula ?? '-', style: AppTextStyles.tableCell)),
    DataGridCell(
      child: Text(o.tallerNombre ?? '-', style: AppTextStyles.tableCell, overflow: TextOverflow.ellipsis),
    ),
    DataGridCell(child: Text(o.origen.displayName, style: AppTextStyles.tableCell)),
    DataGridCell(
      child: OrdenColorBadge(label: o.prioridad.displayName, color: prioridadOrdenColor(o.prioridad)),
    ),
    DataGridCell(
      child: OrdenColorBadge(label: o.estado.displayName, color: estadoOrdenColor(o.estado)),
    ),
    DataGridCell(child: Text(formatFecha(o.fechaEntrada), style: AppTextStyles.tableCell)),
    DataGridCell(
      child: Text(formatEuros(o.costoTotal), style: AppTextStyles.tableCell.copyWith(fontWeight: FontWeight.w600)),
    ),
  ];
}

/// Filtra órdenes por búsqueda (nº orden, matrícula, taller) y estado
List<OrdenReparacionEntity> filterOrdenes(
  List<OrdenReparacionEntity> ordenes, {
  required String query,
  required String estado,
}) {
  final String q = query.trim().toLowerCase();
  return ordenes.where((OrdenReparacionEntity o) {
    final bool matchesSearch =
        q.isEmpty ||
        o.numeroOrden.toLowerCase().contains(q) ||
        (o.vehiculoMatricula?.toLowerCase().contains(q) ?? false) ||
        (o.tallerNombre?.toLowerCase().contains(q) ?? false);
    final bool matchesEstado =
        estado == filtroOrdenesTodas || (estado == filtroOrdenesActivas ? o.estado.isActiva : o.estado.value == estado);
    return matchesSearch && matchesEstado;
  }).toList();
}
