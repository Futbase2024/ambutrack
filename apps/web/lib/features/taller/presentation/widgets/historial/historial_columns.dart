import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/taller_consulta_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';

/// Filtro de estado: finalizadas + cerradas
const String historialEstadoTerminadas = 'terminadas';

/// Filtro de estado: cualquier estado del historial (incluye anuladas)
const String historialEstadoTodas = 'todas';

/// Opciones del filtro de estado del historial
final Map<String, String> historialEstadoOptions = <String, String>{
  historialEstadoTerminadas: 'Terminadas',
  EstadoOrdenReparacion.finalizada.value: EstadoOrdenReparacion.finalizada.displayName,
  EstadoOrdenReparacion.cerrada.value: EstadoOrdenReparacion.cerrada.displayName,
  EstadoOrdenReparacion.anulada.value: 'Anuladas',
  historialEstadoTodas: 'Todas (incl. anuladas)',
};

/// Fecha de salida del taller (finalización o, si no, cierre)
DateTime? historialFechaSalida(OrdenReparacionEntity o) => o.fechaFinalizacion ?? o.fechaCierre;

/// Días que el vehículo estuvo en taller (null si no hay fecha de salida)
int? historialDiasTaller(OrdenReparacionEntity o) {
  final DateTime? salida = historialFechaSalida(o);
  if (salida == null) {
    return null;
  }
  final int dias = salida.toLocal().difference(o.fechaEntrada.toLocal()).inDays;
  return dias < 0 ? 0 : dias;
}

String _numero(OrdenReparacionEntity o) => o.numeroOrden.isEmpty ? GestionFormatters.vacio : o.numeroOrden;

String _dias(OrdenReparacionEntity o) {
  final int? d = historialDiasTaller(o);
  return d == null ? GestionFormatters.vacio : '$d d';
}

/// Criterios de filtrado del historial
class HistorialFiltro {
  const HistorialFiltro({
    this.query = '',
    this.estado = historialEstadoTerminadas,
    this.vehiculo = tallerFiltroTodos,
    this.taller = tallerFiltroTodos,
    this.origen,
    this.rango,
  });

  final String query;
  final String estado;
  final String vehiculo;
  final String taller;
  final OrigenOrdenReparacion? origen;

  /// Rango sobre la fecha de salida (o de entrada si no hay salida)
  final DateTimeRange? rango;

  bool get activo =>
      query.isNotEmpty ||
      estado != historialEstadoTerminadas ||
      vehiculo.isNotEmpty ||
      taller.isNotEmpty ||
      origen != null ||
      rango != null;

  bool _estadoOk(EstadoOrdenReparacion e) {
    if (estado == historialEstadoTodas) {
      return true;
    }
    if (estado == historialEstadoTerminadas) {
      return e == EstadoOrdenReparacion.finalizada || e == EstadoOrdenReparacion.cerrada;
    }
    return e.value == estado;
  }

  bool matches(OrdenReparacionEntity o) {
    final String q = query.trim().toLowerCase();
    final bool texto = q.isEmpty ||
        o.numeroOrden.toLowerCase().contains(q) ||
        (o.vehiculoMatricula?.toLowerCase().contains(q) ?? false) ||
        (o.tallerNombre?.toLowerCase().contains(q) ?? false) ||
        (o.diagnostico?.toLowerCase().contains(q) ?? false);
    return texto &&
        _estadoOk(o.estado) &&
        (vehiculo.isEmpty || o.vehiculoMatricula == vehiculo) &&
        (taller.isEmpty || o.tallerNombre == taller) &&
        (origen == null || o.origen == origen) &&
        tallerEnRango(historialFechaSalida(o) ?? o.fechaEntrada, rango);
  }
}

/// Columnas de la rejilla del historial
final List<GestionColumn<OrdenReparacionEntity>> historialColumns = <GestionColumn<OrdenReparacionEntity>>[
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
    label: 'Estado',
    flex: 2,
    sortValue: (OrdenReparacionEntity o) => o.estado.index,
    cell: (OrdenReparacionEntity o) =>
        GestionDotLabel(label: o.estado.displayName, color: estadoOrdenColor(o.estado)),
  ),
  GestionColumn<OrdenReparacionEntity>(
    label: 'Entrada',
    width: 100,
    sortValue: (OrdenReparacionEntity o) => o.fechaEntrada,
    cell: (OrdenReparacionEntity o) => TallerCellText(GestionFormatters.fecha(o.fechaEntrada)),
  ),
  GestionColumn<OrdenReparacionEntity>(
    label: 'Salida',
    width: 100,
    sortValue: (OrdenReparacionEntity o) => historialFechaSalida(o) ?? DateTime(0),
    cell: (OrdenReparacionEntity o) => TallerCellText(GestionFormatters.fecha(historialFechaSalida(o))),
  ),
  GestionColumn<OrdenReparacionEntity>(
    label: 'Días',
    width: 70,
    alignment: Alignment.centerRight,
    sortValue: (OrdenReparacionEntity o) => historialDiasTaller(o) ?? -1,
    cell: (OrdenReparacionEntity o) => TallerCellText(_dias(o)),
  ),
  GestionColumn<OrdenReparacionEntity>(
    label: 'Coste total',
    width: 120,
    alignment: Alignment.centerRight,
    sortValue: (OrdenReparacionEntity o) => o.costoTotal,
    cell: (OrdenReparacionEntity o) => TallerCellText(GestionFormatters.moneda(o.costoTotal), bold: true),
  ),
];

/// Resumen de la barra de estado: nº órdenes, coste total, coste medio y días medios
List<String> resumenHistorial(List<OrdenReparacionEntity> todas, List<OrdenReparacionEntity> visibles) {
  final List<OrdenReparacionEntity> validas =
      visibles.where((OrdenReparacionEntity o) => o.estado != EstadoOrdenReparacion.anulada).toList();
  final double total = validas.fold<double>(0, (double s, OrdenReparacionEntity o) => s + o.costoTotal);
  final List<int> dias = validas.map(historialDiasTaller).whereType<int>().toList();
  final String medioDias = dias.isEmpty
      ? GestionFormatters.vacio
      : (dias.reduce((int a, int b) => a + b) / dias.length).toStringAsFixed(1).replaceAll('.', ',');
  return <String>[
    tallerRegistrosLabel(todas.length, visibles.length).replaceAll('registros', 'órdenes'),
    'Coste total ${GestionFormatters.moneda(total)}',
    'Coste medio ${GestionFormatters.moneda(validas.isEmpty ? 0 : total / validas.length)}',
    'Días medios en taller $medioDias',
  ];
}

/// Imprime el historial filtrado
Future<void> imprimirHistorial(List<OrdenReparacionEntity> ordenes, {String? subtitle}) {
  return GestionPrint.listado(
    title: 'Historial de Reparaciones',
    subtitle: subtitle,
    headers: const <String>[
      'Nº orden', 'Vehículo', 'Taller', 'Origen', 'Estado', 'Entrada', 'Salida', 'Días', 'Coste total',
    ],
    rows: ordenes
        .map(
          (OrdenReparacionEntity o) => <String>[
            _numero(o),
            GestionFormatters.texto(o.vehiculoMatricula),
            GestionFormatters.texto(o.tallerNombre),
            o.origen.displayName,
            o.estado.displayName,
            GestionFormatters.fecha(o.fechaEntrada),
            GestionFormatters.fecha(historialFechaSalida(o)),
            _dias(o),
            GestionFormatters.moneda(o.costoTotal),
          ],
        )
        .toList(),
  );
}
