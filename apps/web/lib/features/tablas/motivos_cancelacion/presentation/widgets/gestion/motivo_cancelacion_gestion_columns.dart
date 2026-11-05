import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Indicador de estado activo/inactivo
class MotivoCancelacionEstadoDot extends StatelessWidget {
  const MotivoCancelacionEstadoDot({required this.activo, super.key});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: activo ? 'Activo' : 'Inactivo',
      color: activo ? AppColors.success : AppColors.inactive,
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class MotivoCancelacionCellText extends StatelessWidget {
  const MotivoCancelacionCellText(this.value, {this.bold = false, super.key});

  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == GestionFormatters.vacio;
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: empty ? AppColors.gray300 : null,
      ),
    );
  }
}

/// Columnas de la rejilla de motivos de cancelación
final List<GestionColumn<MotivoCancelacionEntity>> motivoCancelacionGestionColumns =
    <GestionColumn<MotivoCancelacionEntity>>[
  GestionColumn<MotivoCancelacionEntity>(
    label: 'Nombre',
    flex: 3,
    sortValue: (MotivoCancelacionEntity e) => e.nombre.toLowerCase(),
    cell: (MotivoCancelacionEntity e) => MotivoCancelacionCellText(e.nombre, bold: true),
  ),
  GestionColumn<MotivoCancelacionEntity>(
    label: 'Descripción',
    flex: 5,
    sortValue: (MotivoCancelacionEntity e) => (e.descripcion ?? '').toLowerCase(),
    cell: (MotivoCancelacionEntity e) => MotivoCancelacionCellText(GestionFormatters.texto(e.descripcion)),
  ),
  GestionColumn<MotivoCancelacionEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (MotivoCancelacionEntity e) => e.activo ? 0 : 1,
    cell: (MotivoCancelacionEntity e) => MotivoCancelacionEstadoDot(activo: e.activo),
  ),
];

/// Filtra por texto (nombre, descripción) y estado (null = todos)
List<MotivoCancelacionEntity> filtrarMotivosCancelacion(
  List<MotivoCancelacionEntity> items, {
  required String query,
  required bool? activo,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((MotivoCancelacionEntity e) {
    final bool matchesSearch = q.isEmpty ||
        e.nombre.toLowerCase().contains(q) ||
        (e.descripcion ?? '').toLowerCase().contains(q);
    final bool matchesEstado = activo == null || e.activo == activo;
    return matchesSearch && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenMotivosCancelacion(List<MotivoCancelacionEntity> todos, int filtrados) {
  final int activos = todos.where((MotivoCancelacionEntity e) => e.activo).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$activos activos',
    '${todos.length - activos} inactivos',
  ];
}

/// Imprime el listado de motivos de cancelación (filtrado y ordenado)
Future<void> imprimirMotivosCancelacion(List<MotivoCancelacionEntity> items) {
  return GestionPrint.listado(
    title: 'Motivos de Cancelación',
    headers: const <String>['Nombre', 'Descripción', 'Estado'],
    rows: items
        .map(
          (MotivoCancelacionEntity e) => <String>[
            e.nombre,
            GestionFormatters.texto(e.descripcion),
            if (e.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
