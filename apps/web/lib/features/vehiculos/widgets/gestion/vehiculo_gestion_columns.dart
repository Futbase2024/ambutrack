import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/lang/app_strings.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Tipos de vehículo disponibles en el filtro (valor → texto)
const Map<String?, String> vehiculoTiposFiltro = <String?, String>{
  null: 'Todos',
  'CONVENCIONAL': 'Convencional',
  'COLECTIVA': 'Colectiva',
  'UVI MÓVIL': 'UVI Móvil',
};

/// Color neutro para el indicador de tipo de vehículo
const Color vehiculoTipoColor = AppColors.info;

/// Texto del estado del vehículo
String vehiculoEstadoLabel(VehiculoEstado estado) {
  switch (estado) {
    case VehiculoEstado.activo:
      return AppStrings.vehiculosEstadoDisponible;
    case VehiculoEstado.mantenimiento:
      return AppStrings.vehiculosEstadoMantenimiento;
    case VehiculoEstado.reparacion:
      return AppStrings.vehiculosEstadoReparacion;
    case VehiculoEstado.baja:
      return AppStrings.vehiculosEstadoBaja;
  }
}

/// Color del estado del vehículo
Color vehiculoEstadoColor(VehiculoEstado estado) {
  switch (estado) {
    case VehiculoEstado.activo:
      return AppColors.success;
    case VehiculoEstado.mantenimiento:
      return AppColors.warning;
    case VehiculoEstado.reparacion:
      return AppColors.error;
    case VehiculoEstado.baja:
      return AppColors.inactive;
  }
}

/// Indicador de estado del vehículo
class VehiculoEstadoDot extends StatelessWidget {
  const VehiculoEstadoDot({required this.estado, super.key});

  final VehiculoEstado estado;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(label: vehiculoEstadoLabel(estado), color: vehiculoEstadoColor(estado));
  }
}

/// Fecha que se pinta en rojo si ya ha vencido y en naranja si vence en 30 días
class VehiculoFechaVencimiento extends StatelessWidget {
  const VehiculoFechaVencimiento({required this.fecha, super.key});

  final DateTime? fecha;

  @override
  Widget build(BuildContext context) {
    final DateTime? f = fecha;
    if (f == null) {
      return const FlotaCellText(GestionFormatters.vacio);
    }
    final int dias = f.difference(DateTime.now()).inDays;
    final Color? color = f.isBefore(DateTime.now())
        ? AppColors.error
        : dias <= 30
            ? AppColors.warning
            : null;
    return FlotaCellText(GestionFormatters.fecha(f), color: color, bold: color != null);
  }
}

/// Columnas de la rejilla de vehículos
final List<GestionColumn<VehiculoEntity>> vehiculoGestionColumns = <GestionColumn<VehiculoEntity>>[
  GestionColumn<VehiculoEntity>(
    label: 'Matrícula',
    width: 110,
    sortValue: (VehiculoEntity v) => v.matricula.toLowerCase(),
    cell: (VehiculoEntity v) => FlotaCellText(v.matricula, bold: true),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Marca',
    flex: 2,
    sortValue: (VehiculoEntity v) => v.marca.toLowerCase(),
    cell: (VehiculoEntity v) => FlotaCellText(GestionFormatters.texto(v.marca)),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Modelo',
    flex: 2,
    sortValue: (VehiculoEntity v) => v.modelo.toLowerCase(),
    cell: (VehiculoEntity v) => FlotaCellText(GestionFormatters.texto(v.modelo)),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Año',
    width: 64,
    sortValue: (VehiculoEntity v) => v.anioFabricacion,
    cell: (VehiculoEntity v) => FlotaCellText('${v.anioFabricacion}'),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Tipo',
    flex: 2,
    sortValue: (VehiculoEntity v) => v.tipoVehiculo.toLowerCase(),
    cell: (VehiculoEntity v) => FlotaCellText(GestionFormatters.texto(v.tipoVehiculo)),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Estado',
    width: 130,
    sortValue: (VehiculoEntity v) => v.estado.index,
    cell: (VehiculoEntity v) => VehiculoEstadoDot(estado: v.estado),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Km',
    width: 100,
    alignment: Alignment.centerRight,
    sortValue: (VehiculoEntity v) => v.kmActual ?? -1,
    cell: (VehiculoEntity v) => FlotaCellText(flotaKm(v.kmActual)),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Ubicación',
    flex: 2,
    sortValue: (VehiculoEntity v) => (v.ubicacionActual ?? '').toLowerCase(),
    cell: (VehiculoEntity v) => FlotaCellText(GestionFormatters.texto(v.ubicacionActual)),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Próx. ITV',
    width: 100,
    sortValue: (VehiculoEntity v) => v.proximaItv.millisecondsSinceEpoch,
    cell: (VehiculoEntity v) => VehiculoFechaVencimiento(fecha: v.proximaItv),
  ),
];

/// Filtra vehículos por texto (matrícula, marca, modelo, nº interno, alias), estado y tipo
List<VehiculoEntity> filtrarVehiculos(
  List<VehiculoEntity> vehiculos, {
  required String query,
  required VehiculoEstado? estado,
  required String? tipo,
}) {
  final String q = query.trim().toLowerCase();
  return vehiculos.where((VehiculoEntity v) {
    final bool matchesSearch = q.isEmpty ||
        v.matricula.toLowerCase().contains(q) ||
        v.marca.toLowerCase().contains(q) ||
        v.modelo.toLowerCase().contains(q) ||
        (v.numeroInterno?.toLowerCase().contains(q) ?? false) ||
        (v.alias?.toLowerCase().contains(q) ?? false);
    final bool matchesEstado = estado == null || v.estado == estado;
    final bool matchesTipo = tipo == null || v.tipoVehiculo == tipo;
    return matchesSearch && matchesEstado && matchesTipo;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenVehiculos(List<VehiculoEntity> todos, int filtrados) {
  int count(VehiculoEstado e) => todos.where((VehiculoEntity v) => v.estado == e).length;
  return <String>[
    flotaResumenRegistros(todos.length, filtrados),
    'Disponibles ${count(VehiculoEstado.activo)}',
    'Mantenimiento ${count(VehiculoEstado.mantenimiento)}',
    'Reparación ${count(VehiculoEstado.reparacion)}',
    'Baja ${count(VehiculoEstado.baja)}',
  ];
}

/// Imprime el listado de vehículos (filtrado y ordenado)
Future<void> imprimirVehiculos(List<VehiculoEntity> vehiculos) {
  return GestionPrint.listado(
    title: 'Vehículos',
    headers: const <String>[
      'Matrícula', 'Marca', 'Modelo', 'Año', 'Tipo', 'Estado', 'Km', 'Ubicación', 'Próx. ITV',
    ],
    rows: vehiculos
        .map(
          (VehiculoEntity v) => <String>[
            v.matricula,
            GestionFormatters.texto(v.marca),
            GestionFormatters.texto(v.modelo),
            '${v.anioFabricacion}',
            GestionFormatters.texto(v.tipoVehiculo),
            vehiculoEstadoLabel(v.estado),
            flotaKm(v.kmActual),
            GestionFormatters.texto(v.ubicacionActual),
            GestionFormatters.fecha(v.proximaItv),
          ],
        )
        .toList(),
  );
}
