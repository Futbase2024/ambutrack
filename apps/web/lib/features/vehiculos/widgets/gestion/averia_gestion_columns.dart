import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Listado completo de incidencias (ya filtrado por el BLoC) y sus filtros
class AveriasSnapshot {
  const AveriasSnapshot({
    required this.incidencias,
    this.filtroEstado,
    this.filtroPrioridad,
    this.filtroTipo,
  });

  final List<IncidenciaVehiculoEntity> incidencias;
  final EstadoIncidencia? filtroEstado;
  final PrioridadIncidencia? filtroPrioridad;
  final TipoIncidencia? filtroTipo;

  bool get hasBlocFilters => filtroEstado != null || filtroPrioridad != null || filtroTipo != null;
}

/// Color del estado de la incidencia
Color averiaEstadoColor(EstadoIncidencia estado) {
  switch (estado) {
    case EstadoIncidencia.reportada:
      return AppColors.info;
    case EstadoIncidencia.enRevision:
      return AppColors.warning;
    case EstadoIncidencia.enReparacion:
      return AppColors.primary;
    case EstadoIncidencia.resuelta:
      return AppColors.success;
    case EstadoIncidencia.cerrada:
      return AppColors.inactive;
  }
}

/// Color de la prioridad de la incidencia
Color averiaPrioridadColor(PrioridadIncidencia prioridad) {
  switch (prioridad) {
    case PrioridadIncidencia.baja:
      return AppColors.lowPriority;
    case PrioridadIncidencia.media:
      return AppColors.info;
    case PrioridadIncidencia.alta:
      return AppColors.warning;
    case PrioridadIncidencia.critica:
      return AppColors.error;
  }
}

/// Color neutro para el tipo de incidencia
const Color averiaTipoColor = AppColors.averia;

/// Matrícula del vehículo (o el inicio del identificador si no está cargado)
String averiaVehiculo(IncidenciaVehiculoEntity i, Map<String, VehiculoEntity> vehiculos) {
  final VehiculoEntity? v = vehiculos[i.vehiculoId];
  if (v != null) {
    return v.matricula;
  }
  return i.vehiculoId.length > 8 ? '#${i.vehiculoId.substring(0, 8)}…' : '#${i.vehiculoId}';
}

/// Columnas de la rejilla de averías
List<GestionColumn<IncidenciaVehiculoEntity>> averiaGestionColumns(
  Map<String, VehiculoEntity> vehiculos,
) {
  return <GestionColumn<IncidenciaVehiculoEntity>>[
    GestionColumn<IncidenciaVehiculoEntity>(
      label: 'Fecha',
      width: 100,
      sortValue: (IncidenciaVehiculoEntity i) => i.fechaReporte.millisecondsSinceEpoch,
      cell: (IncidenciaVehiculoEntity i) => FlotaCellText(GestionFormatters.fecha(i.fechaReporte)),
    ),
    GestionColumn<IncidenciaVehiculoEntity>(
      label: 'Vehículo',
      width: 110,
      sortValue: (IncidenciaVehiculoEntity i) => averiaVehiculo(i, vehiculos).toLowerCase(),
      cell: (IncidenciaVehiculoEntity i) => FlotaCellText(averiaVehiculo(i, vehiculos), bold: true),
    ),
    GestionColumn<IncidenciaVehiculoEntity>(
      label: 'Título',
      flex: 4,
      sortValue: (IncidenciaVehiculoEntity i) => i.titulo.toLowerCase(),
      cell: (IncidenciaVehiculoEntity i) => FlotaCellText(GestionFormatters.texto(i.titulo)),
    ),
    GestionColumn<IncidenciaVehiculoEntity>(
      label: 'Tipo',
      width: 130,
      sortValue: (IncidenciaVehiculoEntity i) => i.tipo.nombre,
      cell: (IncidenciaVehiculoEntity i) => GestionDotLabel(label: i.tipo.nombre, color: averiaTipoColor),
    ),
    GestionColumn<IncidenciaVehiculoEntity>(
      label: 'Prioridad',
      width: 100,
      sortValue: (IncidenciaVehiculoEntity i) => i.prioridad.index,
      cell: (IncidenciaVehiculoEntity i) => GestionDotLabel(
        label: i.prioridad.nombre,
        color: averiaPrioridadColor(i.prioridad),
      ),
    ),
    GestionColumn<IncidenciaVehiculoEntity>(
      label: 'Estado',
      width: 130,
      sortValue: (IncidenciaVehiculoEntity i) => i.estado.index,
      cell: (IncidenciaVehiculoEntity i) =>
          GestionDotLabel(label: i.estado.nombre, color: averiaEstadoColor(i.estado)),
    ),
    GestionColumn<IncidenciaVehiculoEntity>(
      label: 'Reportado por',
      flex: 2,
      sortValue: (IncidenciaVehiculoEntity i) => i.reportadoPorNombre.toLowerCase(),
      cell: (IncidenciaVehiculoEntity i) => FlotaCellText(GestionFormatters.texto(i.reportadoPorNombre)),
    ),
    GestionColumn<IncidenciaVehiculoEntity>(
      label: 'Coste',
      width: 100,
      alignment: Alignment.centerRight,
      sortValue: (IncidenciaVehiculoEntity i) => i.costoReparacion ?? -1,
      cell: (IncidenciaVehiculoEntity i) => FlotaCellText(flotaMoneda(i.costoReparacion)),
    ),
  ];
}

/// Búsqueda por texto sobre el listado completo (título, descripción, vehículo, reportado por)
List<IncidenciaVehiculoEntity> buscarAverias(
  List<IncidenciaVehiculoEntity> items,
  Map<String, VehiculoEntity> vehiculos,
  String query,
) {
  final String q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return items;
  }
  return items.where((IncidenciaVehiculoEntity i) {
    return i.titulo.toLowerCase().contains(q) ||
        i.descripcion.toLowerCase().contains(q) ||
        i.reportadoPorNombre.toLowerCase().contains(q) ||
        averiaVehiculo(i, vehiculos).toLowerCase().contains(q);
  }).toList();
}

/// Resumen para la barra de estado (sobre el listado completo filtrado)
List<String> resumenAverias(AveriasSnapshot data, int visibles) {
  int count(List<EstadoIncidencia> estados) => data.incidencias
      .where((IncidenciaVehiculoEntity i) => estados.contains(i.estado))
      .length;
  return <String>[
    flotaResumenRegistros(data.incidencias.length, visibles),
    'Pendientes ${count(<EstadoIncidencia>[EstadoIncidencia.reportada, EstadoIncidencia.enRevision])}',
    'En reparación ${count(<EstadoIncidencia>[EstadoIncidencia.enReparacion])}',
    'Resueltas ${count(<EstadoIncidencia>[EstadoIncidencia.resuelta, EstadoIncidencia.cerrada])}',
  ];
}

/// Imprime todas las averías visibles (filtradas y ordenadas, sin paginar)
Future<void> imprimirAverias(
  List<IncidenciaVehiculoEntity> items,
  Map<String, VehiculoEntity> vehiculos,
) {
  return GestionPrint.listado(
    title: 'Historial de Averías',
    headers: const <String>[
      'Fecha', 'Vehículo', 'Título', 'Tipo', 'Prioridad', 'Estado', 'Reportado por', 'Coste',
    ],
    rows: items
        .map(
          (IncidenciaVehiculoEntity i) => <String>[
            GestionFormatters.fecha(i.fechaReporte),
            averiaVehiculo(i, vehiculos),
            i.titulo,
            i.tipo.nombre,
            i.prioridad.nombre,
            i.estado.nombre,
            GestionFormatters.texto(i.reportadoPorNombre),
            flotaMoneda(i.costoReparacion),
          ],
        )
        .toList(),
  );
}
