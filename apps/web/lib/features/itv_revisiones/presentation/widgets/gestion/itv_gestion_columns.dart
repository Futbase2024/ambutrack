import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Color del tipo de inspección
Color itvTipoColor(TipoItvRevision tipo) {
  switch (tipo) {
    case TipoItvRevision.itv:
      return AppColors.info;
    case TipoItvRevision.revisionTecnica:
      return AppColors.secondary;
    case TipoItvRevision.inspeccionAnual:
      return AppColors.warning;
    case TipoItvRevision.inspeccionEspecial:
      return AppColors.primary;
  }
}

/// Color del resultado de la inspección
Color itvResultadoColor(ResultadoItvRevision resultado) {
  switch (resultado) {
    case ResultadoItvRevision.favorable:
      return AppColors.success;
    case ResultadoItvRevision.desfavorable:
      return AppColors.warning;
    case ResultadoItvRevision.negativo:
      return AppColors.error;
    case ResultadoItvRevision.pendiente:
      return AppColors.inactive;
  }
}

/// Color del estado de la inspección
Color itvEstadoColor(EstadoItvRevision estado) {
  switch (estado) {
    case EstadoItvRevision.pendiente:
      return AppColors.info;
    case EstadoItvRevision.realizada:
      return AppColors.success;
    case EstadoItvRevision.vencida:
      return AppColors.error;
    case EstadoItvRevision.cancelada:
      return AppColors.inactive;
  }
}

/// Matrícula del vehículo de la inspección (o marcador de vacío)
String itvMatricula(ItvRevisionEntity i, Map<String, VehiculoEntity> vehiculos) =>
    vehiculos[i.vehiculoId]?.matricula ?? GestionFormatters.vacio;

/// Columnas de la rejilla de ITV/Revisiones
List<GestionColumn<ItvRevisionEntity>> itvGestionColumns(Map<String, VehiculoEntity> vehiculos) {
  return <GestionColumn<ItvRevisionEntity>>[
    GestionColumn<ItvRevisionEntity>(
      label: 'Vehículo',
      width: 110,
      sortValue: (ItvRevisionEntity i) => itvMatricula(i, vehiculos).toLowerCase(),
      cell: (ItvRevisionEntity i) => FlotaCellText(itvMatricula(i, vehiculos), bold: true),
    ),
    GestionColumn<ItvRevisionEntity>(
      label: 'Tipo',
      flex: 2,
      sortValue: (ItvRevisionEntity i) => i.tipo.index,
      cell: (ItvRevisionEntity i) =>
          GestionDotLabel(label: i.tipo.displayName, color: itvTipoColor(i.tipo)),
    ),
    GestionColumn<ItvRevisionEntity>(
      label: 'Fecha',
      width: 100,
      sortValue: (ItvRevisionEntity i) => i.fecha.millisecondsSinceEpoch,
      cell: (ItvRevisionEntity i) => FlotaCellText(GestionFormatters.fecha(i.fecha)),
    ),
    GestionColumn<ItvRevisionEntity>(
      label: 'Vencimiento',
      width: 110,
      sortValue: (ItvRevisionEntity i) => i.fechaVencimiento?.millisecondsSinceEpoch ?? 0,
      cell: (ItvRevisionEntity i) => FlotaCellText(GestionFormatters.fecha(i.fechaVencimiento)),
    ),
    GestionColumn<ItvRevisionEntity>(
      label: 'Resultado',
      width: 130,
      sortValue: (ItvRevisionEntity i) => i.resultado.index,
      cell: (ItvRevisionEntity i) => GestionDotLabel(
        label: i.resultado.displayName,
        color: itvResultadoColor(i.resultado),
      ),
    ),
    GestionColumn<ItvRevisionEntity>(
      label: 'Km',
      width: 100,
      alignment: Alignment.centerRight,
      sortValue: (ItvRevisionEntity i) => i.kmVehiculo,
      cell: (ItvRevisionEntity i) => FlotaCellText(flotaKm(i.kmVehiculo)),
    ),
    GestionColumn<ItvRevisionEntity>(
      label: 'Coste',
      width: 100,
      alignment: Alignment.centerRight,
      sortValue: (ItvRevisionEntity i) => i.costoTotal,
      cell: (ItvRevisionEntity i) => FlotaCellText(GestionFormatters.moneda(i.costoTotal)),
    ),
    GestionColumn<ItvRevisionEntity>(
      label: 'Taller',
      flex: 2,
      sortValue: (ItvRevisionEntity i) => (i.taller ?? '').toLowerCase(),
      cell: (ItvRevisionEntity i) => FlotaCellText(GestionFormatters.texto(i.taller)),
    ),
    GestionColumn<ItvRevisionEntity>(
      label: 'Estado',
      width: 110,
      sortValue: (ItvRevisionEntity i) => i.estado.index,
      cell: (ItvRevisionEntity i) =>
          GestionDotLabel(label: i.estado.displayName, color: itvEstadoColor(i.estado)),
    ),
  ];
}

/// Filtra por texto (matrícula, taller, nº documento, observaciones), tipo, resultado y estado
List<ItvRevisionEntity> filtrarItv(
  List<ItvRevisionEntity> items, {
  required Map<String, VehiculoEntity> vehiculos,
  required String query,
  required TipoItvRevision? tipo,
  required ResultadoItvRevision? resultado,
  required EstadoItvRevision? estado,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((ItvRevisionEntity i) {
    final bool matchesSearch = q.isEmpty ||
        i.vehiculoId.toLowerCase().contains(q) ||
        itvMatricula(i, vehiculos).toLowerCase().contains(q) ||
        (i.taller?.toLowerCase().contains(q) ?? false) ||
        (i.numeroDocumento?.toLowerCase().contains(q) ?? false) ||
        (i.observaciones?.toLowerCase().contains(q) ?? false);
    return matchesSearch &&
        (tipo == null || i.tipo == tipo) &&
        (resultado == null || i.resultado == resultado) &&
        (estado == null || i.estado == estado);
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenItv(List<ItvRevisionEntity> todos, int filtrados) {
  int count(ResultadoItvRevision r) =>
      todos.where((ItvRevisionEntity i) => i.resultado == r).length;
  final int vencidas =
      todos.where((ItvRevisionEntity i) => i.estado == EstadoItvRevision.vencida).length;
  return <String>[
    flotaResumenRegistros(todos.length, filtrados),
    'Favorables ${count(ResultadoItvRevision.favorable)}',
    'Desfavorables ${count(ResultadoItvRevision.desfavorable)}',
    'Negativos ${count(ResultadoItvRevision.negativo)}',
    'Pendientes ${count(ResultadoItvRevision.pendiente)}',
    'Vencidas $vencidas',
  ];
}

/// Imprime el listado de ITV/Revisiones (filtrado y ordenado)
Future<void> imprimirItv(List<ItvRevisionEntity> items, Map<String, VehiculoEntity> vehiculos) {
  return GestionPrint.listado(
    title: 'ITV y Revisiones',
    headers: const <String>[
      'Vehículo', 'Tipo', 'Fecha', 'Vencimiento', 'Resultado', 'Km', 'Coste', 'Taller', 'Estado',
    ],
    rows: items
        .map(
          (ItvRevisionEntity i) => <String>[
            itvMatricula(i, vehiculos),
            i.tipo.displayName,
            GestionFormatters.fecha(i.fecha),
            GestionFormatters.fecha(i.fechaVencimiento),
            i.resultado.displayName,
            flotaKm(i.kmVehiculo),
            GestionFormatters.moneda(i.costoTotal),
            GestionFormatters.texto(i.taller),
            i.estado.displayName,
          ],
        )
        .toList(),
  );
}
