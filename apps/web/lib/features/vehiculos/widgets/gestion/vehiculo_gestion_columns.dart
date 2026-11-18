import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/lang/app_strings.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/export/gestion_report.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_edit_cells.dart';
import 'package:flutter/material.dart';

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
      return AppColors.highPriority;
    case VehiculoEstado.baja:
      return AppColors.error;
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

/// Rojo si [fecha] ya ha vencido, naranja si vence en 30 días o menos, null si no
Color? vehiculoVencimientoColor(DateTime? fecha) {
  if (fecha == null) {
    return null;
  }
  final DateTime ahora = DateTime.now();
  if (fecha.isBefore(ahora)) {
    return AppColors.error;
  }
  return fecha.difference(ahora).inDays <= 30 ? AppColors.warning : null;
}

/// Celda exportable de una fecha de vencimiento (mismo color que en la rejilla)
GestionCell vehiculoVencimientoCell(DateTime? fecha) {
  final Color? color = vehiculoVencimientoColor(fecha);
  return GestionCell(fecha, color: color, bold: color != null);
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
    final Color? color = vehiculoVencimientoColor(f);
    return FlotaCellText(GestionFormatters.fecha(f), color: color, bold: color != null);
  }
}

/// Celda ✓ / — para características booleanas del vehículo
class VehiculoFlagCell extends StatelessWidget {
  const VehiculoFlagCell({required this.value, super.key});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: value
          ? const Icon(Icons.check_circle, size: 18, color: AppColors.success)
          : const FlotaCellText(GestionFormatters.vacio),
    );
  }
}

/// Situación de la próxima ITV para el filtro de columna
String vehiculoItvSituacion(DateTime fecha) {
  final Color? color = vehiculoVencimientoColor(fecha);
  if (color == null) {
    return 'Vigente';
  }
  return color == AppColors.error ? 'Vencida' : 'Vence en 30 días';
}

/// Edición en la rejilla: recibe el vehículo con el cambio ya aplicado
typedef VehiculoInlineEdit = void Function(VehiculoEntity actualizado);

/// Columnas de la rejilla de vehículos (sin edición; para ordenar y exportar)
final List<GestionColumn<VehiculoEntity>> vehiculoGestionColumns = buildVehiculoGestionColumns();

/// Columnas de la rejilla de vehículos. Con [onEdit], CAP, silla eléctrica,
/// carros, estado y km se pueden cambiar en "modo edición".
List<GestionColumn<VehiculoEntity>> buildVehiculoGestionColumns({VehiculoInlineEdit? onEdit}) =>
    <GestionColumn<VehiculoEntity>>[
  GestionColumn<VehiculoEntity>(
    label: 'Matrícula',
    headerIcon: Icons.pin_outlined,
    width: 130,
    sortValue: (VehiculoEntity v) => v.matricula.toLowerCase(),
    cell: (VehiculoEntity v) => FlotaCellText(
      v.matricula,
      bold: true,
      color: v.estado == VehiculoEstado.baja ? AppColors.error : null,
    ),
    exportValue: (VehiculoEntity v) =>
        GestionCell(v.matricula, bold: true, color: v.estado == VehiculoEstado.baja ? AppColors.error : null),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Marca',
    headerIcon: Icons.factory_outlined,
    minWidth: 130,
    sortValue: (VehiculoEntity v) => v.marca.toLowerCase(),
    cell: (VehiculoEntity v) => FlotaCellText(GestionFormatters.texto(v.marca)),
    exportValue: (VehiculoEntity v) => v.marca,
    filterValue: (VehiculoEntity v) => v.marca,
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Año',
    headerIcon: Icons.calendar_today_outlined,
    width: 100,
    sortValue: (VehiculoEntity v) => v.anioFabricacion,
    cell: (VehiculoEntity v) => FlotaCellText('${v.anioFabricacion}'),
    exportValue: (VehiculoEntity v) => '${v.anioFabricacion}',
    filterValue: (VehiculoEntity v) => '${v.anioFabricacion}',
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Tipo',
    headerIcon: Icons.category_outlined,
    minWidth: 140,
    sortValue: (VehiculoEntity v) => v.tipoVehiculo.toLowerCase(),
    cell: (VehiculoEntity v) => FlotaCellText(GestionFormatters.texto(v.tipoVehiculo)),
    exportValue: (VehiculoEntity v) => v.tipoVehiculo,
    filterValue: (VehiculoEntity v) => v.tipoVehiculo,
  ),
  GestionColumn<VehiculoEntity>(
    label: 'CAP',
    headerIcon: Icons.badge_outlined,
    headerIconOnly: true,
    alignment: Alignment.center,
    width: 72,
    sortValue: (VehiculoEntity v) => v.requiereCap ? 1 : 0,
    cell: (VehiculoEntity v) => VehiculoFlagCell(value: v.requiereCap),
    exportValue: (VehiculoEntity v) => GestionCell.check(checked: v.requiereCap),
    filterValue: (VehiculoEntity v) => flotaSiNo(value: v.requiereCap),
    onCellDoubleTap: onEdit == null
        ? null
        : (VehiculoEntity v) => onEdit(v.copyWith(requiereCap: !v.requiereCap)),
    editCell: onEdit == null
        ? null
        : (VehiculoEntity v) => VehiculoFlagEditCell(
              value: v.requiereCap,
              onChanged: (bool x) => onEdit(v.copyWith(requiereCap: x)),
            ),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Silla eléc.',
    headerIcon: Icons.stairs_outlined,
    headerIconOnly: true,
    alignment: Alignment.center,
    width: 72,
    sortValue: (VehiculoEntity v) => v.tieneSillaElectrica ? 1 : 0,
    cell: (VehiculoEntity v) => VehiculoFlagCell(value: v.tieneSillaElectrica),
    exportValue: (VehiculoEntity v) => GestionCell.check(checked: v.tieneSillaElectrica),
    filterValue: (VehiculoEntity v) => flotaSiNo(value: v.tieneSillaElectrica),
    onCellDoubleTap: onEdit == null
        ? null
        : (VehiculoEntity v) => onEdit(v.copyWith(tieneSillaElectrica: !v.tieneSillaElectrica)),
    editCell: onEdit == null
        ? null
        : (VehiculoEntity v) => VehiculoFlagEditCell(
              value: v.tieneSillaElectrica,
              onChanged: (bool x) => onEdit(v.copyWith(tieneSillaElectrica: x)),
            ),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Soporte silla eléc.',
    headerIcon: Icons.chair_alt_outlined,
    headerIconOnly: true,
    alignment: Alignment.center,
    width: 72,
    sortValue: (VehiculoEntity v) => v.tieneSoporteSillaElectrica ? 1 : 0,
    cell: (VehiculoEntity v) => VehiculoFlagCell(value: v.tieneSoporteSillaElectrica),
    exportValue: (VehiculoEntity v) => GestionCell.check(checked: v.tieneSoporteSillaElectrica),
    filterValue: (VehiculoEntity v) => flotaSiNo(value: v.tieneSoporteSillaElectrica),
    onCellDoubleTap: onEdit == null
        ? null
        : (VehiculoEntity v) => onEdit(v.copyWith(tieneSoporteSillaElectrica: !v.tieneSoporteSillaElectrica)),
    editCell: onEdit == null
        ? null
        : (VehiculoEntity v) => VehiculoFlagEditCell(
              value: v.tieneSoporteSillaElectrica,
              onChanged: (bool x) => onEdit(v.copyWith(tieneSoporteSillaElectrica: x)),
            ),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Carros',
    headerIcon: Icons.accessible_forward,
    headerIconOnly: true,
    alignment: Alignment.center,
    width: 80,
    sortValue: (VehiculoEntity v) => v.numeroCarros ?? 0,
    cell: (VehiculoEntity v) =>
        FlotaCellText(v.numeroCarros == null ? GestionFormatters.vacio : '${v.numeroCarros}'),
    exportValue: (VehiculoEntity v) => v.numeroCarros,
    filterValue: (VehiculoEntity v) => v.numeroCarros == null ? '' : '${v.numeroCarros}',
    editCell: onEdit == null
        ? null
        : (VehiculoEntity v) => VehiculoCarrosEditCell(
              carros: v.numeroCarros,
              onChanged: (int n) => onEdit(v.copyWith(numeroCarros: n)),
            ),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Estado',
    headerIcon: Icons.toggle_on_outlined,
    minWidth: 150,
    sortValue: (VehiculoEntity v) => v.estado.index,
    cell: (VehiculoEntity v) => VehiculoEstadoDot(estado: v.estado),
    exportValue: (VehiculoEntity v) =>
        GestionCell.dot(vehiculoEstadoLabel(v.estado), color: vehiculoEstadoColor(v.estado)),
    filterValue: (VehiculoEntity v) => vehiculoEstadoLabel(v.estado),
    editCell: onEdit == null
        ? null
        : (VehiculoEntity v) => VehiculoEstadoEditCell(
              estado: v.estado,
              onChanged: (VehiculoEstado e) => onEdit(v.copyWith(estado: e)),
            ),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Km',
    headerIcon: Icons.speed,
    alignment: Alignment.centerRight,
    width: 120,
    sortValue: (VehiculoEntity v) => v.kmActual ?? -1,
    cell: (VehiculoEntity v) => FlotaCellText(flotaKm(v.kmActual)),
    exportValue: (VehiculoEntity v) => v.kmActual?.round(),
    editCell: onEdit == null
        ? null
        : (VehiculoEntity v) => GestionInlineTextCell(
              value: v.kmActual == null ? '' : '${v.kmActual!.round()}',
              numeric: true,
              textAlign: TextAlign.end,
              hint: 'Km',
              onSubmitted: (String t) {
                final int? km = int.tryParse(t);
                if (km != null) {
                  onEdit(v.copyWith(kmActual: km.toDouble()));
                }
              },
            ),
  ),
  GestionColumn<VehiculoEntity>(
    label: 'Próx. ITV',
    headerIcon: Icons.fact_check_outlined,
    width: 140,
    sortValue: (VehiculoEntity v) => v.proximaItv.millisecondsSinceEpoch,
    cell: (VehiculoEntity v) => VehiculoFechaVencimiento(fecha: v.proximaItv),
    exportValue: (VehiculoEntity v) => vehiculoVencimientoCell(v.proximaItv),
    filterValue: (VehiculoEntity v) => vehiculoItvSituacion(v.proximaItv),
  ),
];

/// Filtra vehículos por texto (matrícula, marca, modelo, nº interno, alias)
List<VehiculoEntity> filtrarVehiculos(List<VehiculoEntity> vehiculos, {required String query}) {
  final String q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return vehiculos;
  }
  return vehiculos
      .where(
        (VehiculoEntity v) =>
            v.matricula.toLowerCase().contains(q) ||
            v.marca.toLowerCase().contains(q) ||
            v.modelo.toLowerCase().contains(q) ||
            (v.numeroInterno?.toLowerCase().contains(q) ?? false) ||
            (v.alias?.toLowerCase().contains(q) ?? false),
      )
      .toList();
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
