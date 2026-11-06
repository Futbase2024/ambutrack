import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Color del tipo de mantenimiento
Color mantTipoColor(TipoMantenimiento tipo) {
  switch (tipo) {
    case TipoMantenimiento.basico:
      return AppColors.info;
    case TipoMantenimiento.completo:
      return AppColors.secondary;
    case TipoMantenimiento.especial:
      return AppColors.primary;
    case TipoMantenimiento.urgente:
      return AppColors.error;
  }
}

/// Color del estado del mantenimiento
Color mantEstadoColor(EstadoMantenimiento estado) {
  switch (estado) {
    case EstadoMantenimiento.programado:
      return AppColors.info;
    case EstadoMantenimiento.enProceso:
      return AppColors.warning;
    case EstadoMantenimiento.completado:
      return AppColors.success;
    case EstadoMantenimiento.cancelado:
      return AppColors.inactive;
  }
}

/// Matrícula del vehículo del mantenimiento (o marcador de vacío)
String mantMatricula(MantenimientoEntity m, Map<String, VehiculoEntity> vehiculos) =>
    vehiculos[m.vehiculoId]?.matricula ?? GestionFormatters.vacio;

/// Fecha de referencia: la programada si existe, si no la de registro
DateTime mantFechaRef(MantenimientoEntity m) => m.fechaProgramada ?? m.fecha;

/// Programado con fecha ya pasada
bool mantVencido(MantenimientoEntity m) {
  final DateTime hoy = DateUtils.dateOnly(DateTime.now());
  return m.estado == EstadoMantenimiento.programado && mantFechaRef(m).isBefore(hoy);
}

/// Etiqueta de estado (marca como vencido el programado con fecha pasada)
String mantEstadoLabel(MantenimientoEntity m) => mantVencido(m) ? 'Vencido' : m.estado.displayName;

/// Color de estado (rojo si está vencido)
Color mantEstadoColorDe(MantenimientoEntity m) => mantVencido(m) ? AppColors.error : mantEstadoColor(m.estado);

/// Columnas de la rejilla de mantenimientos
List<GestionColumn<MantenimientoEntity>> mantGestionColumns(Map<String, VehiculoEntity> vehiculos) {
  return <GestionColumn<MantenimientoEntity>>[
    GestionColumn<MantenimientoEntity>(
      label: 'Vehículo',
      width: 110,
      sortValue: (MantenimientoEntity m) => mantMatricula(m, vehiculos).toLowerCase(),
      cell: (MantenimientoEntity m) => FlotaCellText(mantMatricula(m, vehiculos), bold: true),
    ),
    GestionColumn<MantenimientoEntity>(
      label: 'Fecha',
      width: 100,
      sortValue: (MantenimientoEntity m) => mantFechaRef(m).millisecondsSinceEpoch,
      cell: (MantenimientoEntity m) => FlotaCellText(GestionFormatters.fecha(mantFechaRef(m))),
    ),
    GestionColumn<MantenimientoEntity>(
      label: 'Tipo',
      width: 120,
      sortValue: (MantenimientoEntity m) => m.tipoMantenimiento.index,
      cell: (MantenimientoEntity m) => GestionDotLabel(
        label: m.tipoMantenimiento.displayName,
        color: mantTipoColor(m.tipoMantenimiento),
      ),
    ),
    GestionColumn<MantenimientoEntity>(
      label: 'Descripción',
      flex: 3,
      sortValue: (MantenimientoEntity m) => m.descripcion.toLowerCase(),
      cell: (MantenimientoEntity m) => FlotaCellText(GestionFormatters.texto(m.descripcion)),
    ),
    GestionColumn<MantenimientoEntity>(
      label: 'Km',
      width: 100,
      alignment: Alignment.centerRight,
      sortValue: (MantenimientoEntity m) => m.kmVehiculo,
      cell: (MantenimientoEntity m) => FlotaCellText(flotaKm(m.kmVehiculo)),
    ),
    GestionColumn<MantenimientoEntity>(
      label: 'Coste',
      width: 100,
      alignment: Alignment.centerRight,
      sortValue: (MantenimientoEntity m) => m.costoTotal,
      cell: (MantenimientoEntity m) => FlotaCellText(GestionFormatters.moneda(m.costoTotal)),
    ),
    GestionColumn<MantenimientoEntity>(
      label: 'Taller',
      flex: 2,
      sortValue: (MantenimientoEntity m) => (m.taller ?? '').toLowerCase(),
      cell: (MantenimientoEntity m) => FlotaCellText(GestionFormatters.texto(m.taller)),
    ),
    GestionColumn<MantenimientoEntity>(
      label: 'Estado',
      width: 120,
      sortValue: (MantenimientoEntity m) => m.estado.index,
      cell: (MantenimientoEntity m) => GestionDotLabel(label: mantEstadoLabel(m), color: mantEstadoColorDe(m)),
    ),
  ];
}

/// Filtra por texto (matrícula, descripción, taller, nº orden, mecánico), tipo y estado
List<MantenimientoEntity> filtrarMantenimientos(
  List<MantenimientoEntity> items, {
  required Map<String, VehiculoEntity> vehiculos,
  required String query,
  required TipoMantenimiento? tipo,
  required EstadoMantenimiento? estado,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((MantenimientoEntity m) {
    final bool matchesSearch = q.isEmpty ||
        mantMatricula(m, vehiculos).toLowerCase().contains(q) ||
        m.descripcion.toLowerCase().contains(q) ||
        (m.taller?.toLowerCase().contains(q) ?? false) ||
        (m.numeroOrden?.toLowerCase().contains(q) ?? false) ||
        (m.mecanicoResponsable?.toLowerCase().contains(q) ?? false);
    return matchesSearch &&
        (tipo == null || m.tipoMantenimiento == tipo) &&
        (estado == null || m.estado == estado);
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenMantenimientos(List<MantenimientoEntity> todos, int filtrados) {
  int count(EstadoMantenimiento e) => todos.where((MantenimientoEntity m) => m.estado == e).length;
  return <String>[
    flotaResumenRegistros(todos.length, filtrados),
    'Programados ${count(EstadoMantenimiento.programado)}',
    'En proceso ${count(EstadoMantenimiento.enProceso)}',
    'Completados ${count(EstadoMantenimiento.completado)}',
    'Vencidos ${todos.where(mantVencido).length}',
  ];
}

/// Imprime el listado de mantenimientos (filtrado y ordenado)
Future<void> imprimirMantenimientos(
  List<MantenimientoEntity> items,
  Map<String, VehiculoEntity> vehiculos,
) {
  return GestionPrint.listado(
    title: 'Mantenimiento Preventivo',
    headers: const <String>['Vehículo', 'Fecha', 'Tipo', 'Descripción', 'Km', 'Coste', 'Taller', 'Estado'],
    rows: items
        .map(
          (MantenimientoEntity m) => <String>[
            mantMatricula(m, vehiculos),
            GestionFormatters.fecha(mantFechaRef(m)),
            m.tipoMantenimiento.displayName,
            GestionFormatters.texto(m.descripcion),
            flotaKm(m.kmVehiculo),
            GestionFormatters.moneda(m.costoTotal),
            GestionFormatters.texto(m.taller),
            mantEstadoLabel(m),
          ],
        )
        .toList(),
  );
}
