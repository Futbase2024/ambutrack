import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Listado completo de consumos (ya filtrado por el BLoC), sus filtros y estadísticas
class ConsumoSnapshot {
  const ConsumoSnapshot({
    required this.registros,
    required this.vehiculos,
    required this.estadisticas,
    this.filtroVehiculoId,
    this.filtroFechaInicio,
    this.filtroFechaFin,
  });

  final List<ConsumoCombustibleEntity> registros;
  final List<VehiculoEntity> vehiculos;
  final Map<String, double> estadisticas;
  final String? filtroVehiculoId;
  final DateTime? filtroFechaInicio;
  final DateTime? filtroFechaFin;

  bool get hasBlocFilters =>
      filtroVehiculoId != null || filtroFechaInicio != null || filtroFechaFin != null;

  Map<String, VehiculoEntity> get vehiculosPorId =>
      <String, VehiculoEntity>{for (final VehiculoEntity v in vehiculos) v.id: v};
}

/// Texto del tipo de combustible
String combustibleLabel(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'gasolina95':
      return 'Gasolina 95';
    case 'gasolina98':
      return 'Gasolina 98';
    case 'diesel':
      return 'Diesel';
    case 'electrico':
      return 'Eléctrico';
    case 'hibrido':
      return 'Híbrido';
    default:
      return tipo;
  }
}

/// Color del tipo de combustible
Color combustibleColor(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'gasolina95':
      return AppColors.info;
    case 'gasolina98':
      return AppColors.primary;
    case 'diesel':
      return AppColors.warning;
    case 'electrico':
      return AppColors.success;
    case 'hibrido':
      return AppColors.secondary;
    default:
      return AppColors.gray500;
  }
}

/// Color del consumo L/100km (verde < 8, naranja < 10, rojo resto)
Color consumoColor(double consumo) {
  if (consumo < 8.0) {
    return AppColors.success;
  }
  if (consumo < 10.0) {
    return AppColors.warning;
  }
  return AppColors.error;
}

/// Matrícula del vehículo del registro
String consumoMatricula(ConsumoCombustibleEntity c, Map<String, VehiculoEntity> vehiculos) =>
    vehiculos[c.vehiculoId]?.matricula ?? GestionFormatters.vacio;

/// Columnas de la rejilla de consumos
List<GestionColumn<ConsumoCombustibleEntity>> consumoGestionColumns(Map<String, VehiculoEntity> vehiculos) {
  return <GestionColumn<ConsumoCombustibleEntity>>[
    GestionColumn<ConsumoCombustibleEntity>(
      label: 'Fecha',
      width: 100,
      sortValue: (ConsumoCombustibleEntity c) => c.fecha.millisecondsSinceEpoch,
      cell: (ConsumoCombustibleEntity c) => FlotaCellText(GestionFormatters.fecha(c.fecha)),
    ),
    GestionColumn<ConsumoCombustibleEntity>(
      label: 'Vehículo',
      width: 110,
      sortValue: (ConsumoCombustibleEntity c) => consumoMatricula(c, vehiculos).toLowerCase(),
      cell: (ConsumoCombustibleEntity c) => FlotaCellText(consumoMatricula(c, vehiculos), bold: true),
    ),
    GestionColumn<ConsumoCombustibleEntity>(
      label: 'Km vehículo',
      width: 110,
      alignment: Alignment.centerRight,
      sortValue: (ConsumoCombustibleEntity c) => c.kmVehiculo,
      cell: (ConsumoCombustibleEntity c) => FlotaCellText(flotaKm(c.kmVehiculo)),
    ),
    GestionColumn<ConsumoCombustibleEntity>(
      label: 'Combustible',
      width: 120,
      sortValue: (ConsumoCombustibleEntity c) => combustibleLabel(c.tipoCombustible),
      cell: (ConsumoCombustibleEntity c) => GestionDotLabel(
        label: combustibleLabel(c.tipoCombustible),
        color: combustibleColor(c.tipoCombustible),
      ),
    ),
    GestionColumn<ConsumoCombustibleEntity>(
      label: 'Litros',
      width: 84,
      alignment: Alignment.centerRight,
      sortValue: (ConsumoCombustibleEntity c) => c.litros,
      cell: (ConsumoCombustibleEntity c) => FlotaCellText(flotaDecimal(c.litros, sufijo: ' L')),
    ),
    GestionColumn<ConsumoCombustibleEntity>(
      label: 'Coste',
      width: 100,
      alignment: Alignment.centerRight,
      sortValue: (ConsumoCombustibleEntity c) => c.costoTotal,
      cell: (ConsumoCombustibleEntity c) => FlotaCellText(GestionFormatters.moneda(c.costoTotal)),
    ),
    GestionColumn<ConsumoCombustibleEntity>(
      label: 'L/100km',
      width: 84,
      alignment: Alignment.centerRight,
      sortValue: (ConsumoCombustibleEntity c) => c.consumoL100km ?? -1,
      cell: (ConsumoCombustibleEntity c) => FlotaCellText(
        flotaDecimal(c.consumoL100km),
        bold: c.consumoL100km != null,
        color: c.consumoL100km == null ? null : consumoColor(c.consumoL100km!),
      ),
    ),
    GestionColumn<ConsumoCombustibleEntity>(
      label: 'Estación',
      flex: 2,
      sortValue: (ConsumoCombustibleEntity c) => (c.estacion ?? '').toLowerCase(),
      cell: (ConsumoCombustibleEntity c) => FlotaCellText(GestionFormatters.texto(c.estacion)),
    ),
    GestionColumn<ConsumoCombustibleEntity>(
      label: 'Conductor',
      flex: 2,
      sortValue: (ConsumoCombustibleEntity c) => (c.conductorNombre ?? '').toLowerCase(),
      cell: (ConsumoCombustibleEntity c) => FlotaCellText(GestionFormatters.texto(c.conductorNombre)),
    ),
  ];
}

/// Búsqueda por texto sobre el listado completo (matrícula, estación, conductor, ticket)
List<ConsumoCombustibleEntity> buscarConsumos(
  List<ConsumoCombustibleEntity> items,
  Map<String, VehiculoEntity> vehiculos,
  String query,
) {
  final String q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return items;
  }
  return items.where((ConsumoCombustibleEntity c) {
    return consumoMatricula(c, vehiculos).toLowerCase().contains(q) ||
        (c.estacion?.toLowerCase().contains(q) ?? false) ||
        (c.conductorNombre?.toLowerCase().contains(q) ?? false) ||
        (c.numeroTicket?.toLowerCase().contains(q) ?? false);
  }).toList();
}

/// Resumen para la barra de estado: registros del listado + estadísticas del filtro
List<String> resumenConsumos(ConsumoSnapshot data, int visibles) {
  final Map<String, double> e = data.estadisticas;
  return <String>[
    flotaResumenRegistros(data.registros.length, visibles),
    'Consumo medio ${flotaDecimal(e['consumo_promedio'] ?? 0, sufijo: ' L/100km')}',
    'Recorrido ${flotaKm(e['km_recorridos'] ?? 0)}',
    'Litros ${flotaEntero(e['litros_totales'] ?? 0)}',
    'Coste ${GestionFormatters.moneda(e['costo_total'] ?? 0)}',
  ];
}

/// Imprime todos los consumos visibles (filtrados y ordenados, sin paginar)
Future<void> imprimirConsumos(List<ConsumoCombustibleEntity> items, Map<String, VehiculoEntity> vehiculos) {
  return GestionPrint.listado(
    title: 'Consumo y Kilometraje',
    headers: const <String>[
      'Fecha', 'Vehículo', 'Km', 'Combustible', 'Litros', 'Coste', 'L/100km', 'Estación', 'Conductor',
    ],
    rows: items
        .map(
          (ConsumoCombustibleEntity c) => <String>[
            GestionFormatters.fecha(c.fecha),
            consumoMatricula(c, vehiculos),
            flotaKm(c.kmVehiculo),
            combustibleLabel(c.tipoCombustible),
            flotaDecimal(c.litros, sufijo: ' L'),
            GestionFormatters.moneda(c.costoTotal),
            flotaDecimal(c.consumoL100km),
            GestionFormatters.texto(c.estacion),
            GestionFormatters.texto(c.conductorNombre),
          ],
        )
        .toList(),
  );
}
