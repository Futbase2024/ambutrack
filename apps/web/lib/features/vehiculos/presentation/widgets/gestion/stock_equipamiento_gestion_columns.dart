import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Texto del estado general de stock
String stockGeneralLabel(EstadoStockGeneral estado) {
  switch (estado) {
    case EstadoStockGeneral.ok:
      return 'OK';
    case EstadoStockGeneral.atencion:
      return 'Atención';
    case EstadoStockGeneral.critico:
      return 'Crítico';
  }
}

/// Color del estado general de stock
Color stockGeneralColor(EstadoStockGeneral estado) {
  switch (estado) {
    case EstadoStockGeneral.ok:
      return AppColors.success;
    case EstadoStockGeneral.atencion:
      return AppColors.warning;
    case EstadoStockGeneral.critico:
      return AppColors.error;
  }
}

/// Indicador del estado general de stock
class StockGeneralDot extends StatelessWidget {
  const StockGeneralDot({required this.estado, super.key});

  final EstadoStockGeneral estado;

  @override
  Widget build(BuildContext context) =>
      GestionDotLabel(label: stockGeneralLabel(estado), color: stockGeneralColor(estado));
}

/// Contador que se resalta con [color] cuando es mayor que cero
class StockCountCell extends StatelessWidget {
  const StockCountCell({required this.value, required this.color, super.key});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$value',
      style: TextStyle(
        fontWeight: value > 0 ? FontWeight.w600 : FontWeight.w400,
        color: value > 0 ? color : AppColors.gray400,
      ),
    );
  }
}

GestionColumn<VehiculoStockResumenEntity> _countColumn(
  String label,
  int Function(VehiculoStockResumenEntity v) value,
  Color color,
) {
  return GestionColumn<VehiculoStockResumenEntity>(
    label: label,
    width: 96,
    alignment: Alignment.centerRight,
    sortValue: value,
    cell: (VehiculoStockResumenEntity v) => StockCountCell(value: value(v), color: color),
  );
}

/// Columnas de la rejilla de stock de equipamiento
final List<GestionColumn<VehiculoStockResumenEntity>> stockEquipamientoGestionColumns =
    <GestionColumn<VehiculoStockResumenEntity>>[
  GestionColumn<VehiculoStockResumenEntity>(
    label: 'Matrícula',
    width: 110,
    sortValue: (VehiculoStockResumenEntity v) => v.matricula.toLowerCase(),
    cell: (VehiculoStockResumenEntity v) => FlotaCellText(v.matricula, bold: true),
  ),
  GestionColumn<VehiculoStockResumenEntity>(
    label: 'Vehículo',
    flex: 3,
    sortValue: (VehiculoStockResumenEntity v) => '${v.marca} ${v.modelo}'.toLowerCase(),
    cell: (VehiculoStockResumenEntity v) =>
        FlotaCellText(GestionFormatters.texto('${v.marca} ${v.modelo}')),
  ),
  GestionColumn<VehiculoStockResumenEntity>(
    label: 'Tipo',
    flex: 2,
    sortValue: (VehiculoStockResumenEntity v) => v.tipoVehiculo.toLowerCase(),
    cell: (VehiculoStockResumenEntity v) => FlotaCellText(GestionFormatters.texto(v.tipoVehiculo)),
  ),
  GestionColumn<VehiculoStockResumenEntity>(
    label: 'Estado',
    width: 110,
    sortValue: (VehiculoStockResumenEntity v) => v.estadoGeneral.index,
    cell: (VehiculoStockResumenEntity v) => StockGeneralDot(estado: v.estadoGeneral),
  ),
  _countColumn('Total', (VehiculoStockResumenEntity v) => v.totalItems, AppColors.gray900),
  _countColumn('OK', (VehiculoStockResumenEntity v) => v.itemsOk, AppColors.success),
  _countColumn('Caducados', (VehiculoStockResumenEntity v) => v.itemsCaducados, AppColors.error),
  _countColumn('Sin stock', (VehiculoStockResumenEntity v) => v.itemsSinStock, AppColors.error),
  _countColumn('Bajo', (VehiculoStockResumenEntity v) => v.itemsStockBajo, AppColors.warning),
  _countColumn(
    'Próximos',
    (VehiculoStockResumenEntity v) => v.itemsProximosCaducar,
    AppColors.warning,
  ),
];

/// Filtra por texto (matrícula, marca, modelo, tipo) y estado general
List<VehiculoStockResumenEntity> filtrarStockEquipamiento(
  List<VehiculoStockResumenEntity> items, {
  required String query,
  required EstadoStockGeneral? estado,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((VehiculoStockResumenEntity v) {
    final bool matchesSearch = q.isEmpty ||
        v.matricula.toLowerCase().contains(q) ||
        v.marca.toLowerCase().contains(q) ||
        v.modelo.toLowerCase().contains(q) ||
        v.tipoVehiculo.toLowerCase().contains(q);
    return matchesSearch && (estado == null || v.estadoGeneral == estado);
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenStockEquipamiento(List<VehiculoStockResumenEntity> todos, int filtrados) {
  int count(EstadoStockGeneral e) =>
      todos.where((VehiculoStockResumenEntity v) => v.estadoGeneral == e).length;
  return <String>[
    flotaResumenRegistros(todos.length, filtrados),
    'OK ${count(EstadoStockGeneral.ok)}',
    'Atención ${count(EstadoStockGeneral.atencion)}',
    'Crítico ${count(EstadoStockGeneral.critico)}',
  ];
}

/// Imprime el resumen de stock (filtrado y ordenado)
Future<void> imprimirStockEquipamiento(List<VehiculoStockResumenEntity> items) {
  return GestionPrint.listado(
    title: 'Stock de Equipamiento',
    headers: const <String>[
      'Matrícula', 'Vehículo', 'Tipo', 'Estado', 'Total', 'OK', 'Caducados', 'Sin stock', 'Bajo',
      'Próximos',
    ],
    rows: items
        .map(
          (VehiculoStockResumenEntity v) => <String>[
            v.matricula,
            '${v.marca} ${v.modelo}',
            v.tipoVehiculo,
            stockGeneralLabel(v.estadoGeneral),
            '${v.totalItems}',
            '${v.itemsOk}',
            '${v.itemsCaducados}',
            '${v.itemsSinStock}',
            '${v.itemsStockBajo}',
            '${v.itemsProximosCaducar}',
          ],
        )
        .toList(),
  );
}
