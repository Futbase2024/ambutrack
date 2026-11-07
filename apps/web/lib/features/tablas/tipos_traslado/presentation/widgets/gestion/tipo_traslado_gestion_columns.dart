import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Indicador de estado activo/inactivo
class TipoTrasladoEstadoDot extends StatelessWidget {
  const TipoTrasladoEstadoDot({required this.activo, super.key});

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
class TipoTrasladoCellText extends StatelessWidget {
  const TipoTrasladoCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de tipos de traslado
final List<GestionColumn<TipoTrasladoEntity>> tipoTrasladoGestionColumns =
    <GestionColumn<TipoTrasladoEntity>>[
  GestionColumn<TipoTrasladoEntity>(
    label: 'Nombre',
    flex: 3,
    sortValue: (TipoTrasladoEntity e) => e.nombre.toLowerCase(),
    cell: (TipoTrasladoEntity e) => TipoTrasladoCellText(e.nombre, bold: true),
  ),
  GestionColumn<TipoTrasladoEntity>(
    label: 'Descripción',
    flex: 5,
    sortValue: (TipoTrasladoEntity e) => (e.descripcion ?? '').toLowerCase(),
    cell: (TipoTrasladoEntity e) => TipoTrasladoCellText(GestionFormatters.texto(e.descripcion)),
  ),
  GestionColumn<TipoTrasladoEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (TipoTrasladoEntity e) => e.activo ? 0 : 1,
    cell: (TipoTrasladoEntity e) => TipoTrasladoEstadoDot(activo: e.activo),
  ),
];

/// Filtra por texto (nombre, descripción) y estado (null = todos)
List<TipoTrasladoEntity> filtrarTiposTraslado(
  List<TipoTrasladoEntity> items, {
  required String query,
  required bool? activo,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((TipoTrasladoEntity e) {
    final bool matchesSearch = q.isEmpty ||
        e.nombre.toLowerCase().contains(q) ||
        (e.descripcion ?? '').toLowerCase().contains(q);
    final bool matchesEstado = activo == null || e.activo == activo;
    return matchesSearch && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenTiposTraslado(List<TipoTrasladoEntity> todos, int filtrados) {
  final int activos = todos.where((TipoTrasladoEntity e) => e.activo).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$activos activos',
    '${todos.length - activos} inactivos',
  ];
}

/// Imprime el listado de tipos de traslado (filtrado y ordenado)
Future<void> imprimirTiposTraslado(List<TipoTrasladoEntity> items) {
  return GestionPrint.listado(
    title: 'Tipos de Traslado',
    headers: const <String>['Nombre', 'Descripción', 'Estado'],
    rows: items
        .map(
          (TipoTrasladoEntity e) => <String>[
            e.nombre,
            GestionFormatters.texto(e.descripcion),
            if (e.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
