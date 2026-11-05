import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Indicador de estado activo/inactivo
class MotivoTrasladoEstadoDot extends StatelessWidget {
  const MotivoTrasladoEstadoDot({required this.activo, super.key});

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
class MotivoTrasladoCellText extends StatelessWidget {
  const MotivoTrasladoCellText(this.value, {this.bold = false, super.key});

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

/// Tiempo de espera en minutos formateado ("45 min")
String motivoTrasladoTiempo(int minutos) => '$minutos min';

/// Columnas de la rejilla de motivos de traslado
final List<GestionColumn<MotivoTrasladoEntity>> motivoTrasladoGestionColumns =
    <GestionColumn<MotivoTrasladoEntity>>[
  GestionColumn<MotivoTrasladoEntity>(
    label: 'Nombre',
    flex: 3,
    sortValue: (MotivoTrasladoEntity e) => e.nombre.toLowerCase(),
    cell: (MotivoTrasladoEntity e) => MotivoTrasladoCellText(e.nombre, bold: true),
  ),
  GestionColumn<MotivoTrasladoEntity>(
    label: 'Descripción',
    flex: 5,
    sortValue: (MotivoTrasladoEntity e) => e.descripcion.toLowerCase(),
    cell: (MotivoTrasladoEntity e) => MotivoTrasladoCellText(GestionFormatters.texto(e.descripcion)),
  ),
  GestionColumn<MotivoTrasladoEntity>(
    label: 'T. espera',
    width: 100,
    alignment: Alignment.centerRight,
    sortValue: (MotivoTrasladoEntity e) => e.tiempo,
    cell: (MotivoTrasladoEntity e) => MotivoTrasladoCellText(motivoTrasladoTiempo(e.tiempo)),
  ),
  GestionColumn<MotivoTrasladoEntity>(
    label: 'Vuelta',
    width: 80,
    sortValue: (MotivoTrasladoEntity e) => e.vuelta ? 0 : 1,
    cell: (MotivoTrasladoEntity e) => MotivoTrasladoCellText(e.vuelta ? 'Sí' : 'No'),
  ),
  GestionColumn<MotivoTrasladoEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (MotivoTrasladoEntity e) => e.activo ? 0 : 1,
    cell: (MotivoTrasladoEntity e) => MotivoTrasladoEstadoDot(activo: e.activo),
  ),
];

/// Filtra por texto (nombre, descripción) y estado (null = todos)
List<MotivoTrasladoEntity> filtrarMotivosTraslado(
  List<MotivoTrasladoEntity> items, {
  required String query,
  required bool? activo,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((MotivoTrasladoEntity e) {
    final bool matchesSearch = q.isEmpty ||
        e.nombre.toLowerCase().contains(q) ||
        e.descripcion.toLowerCase().contains(q);
    final bool matchesEstado = activo == null || e.activo == activo;
    return matchesSearch && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenMotivosTraslado(List<MotivoTrasladoEntity> todos, int filtrados) {
  final int activos = todos.where((MotivoTrasladoEntity e) => e.activo).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$activos activos',
    '${todos.length - activos} inactivos',
  ];
}

/// Imprime el listado de motivos de traslado (filtrado y ordenado)
Future<void> imprimirMotivosTraslado(List<MotivoTrasladoEntity> items) {
  return GestionPrint.listado(
    title: 'Motivos de Traslado',
    headers: const <String>['Nombre', 'Descripción', 'T. espera', 'Vuelta', 'Estado'],
    rows: items
        .map(
          (MotivoTrasladoEntity e) => <String>[
            e.nombre,
            GestionFormatters.texto(e.descripcion),
            motivoTrasladoTiempo(e.tiempo),
            if (e.vuelta) 'Sí' else 'No',
            if (e.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
