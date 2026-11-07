import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Indicador de estado activo/inactivo
class TipoPacienteEstadoDot extends StatelessWidget {
  const TipoPacienteEstadoDot({required this.activo, super.key});

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
class TipoPacienteCellText extends StatelessWidget {
  const TipoPacienteCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de tipos de paciente
final List<GestionColumn<TipoPacienteEntity>> tipoPacienteGestionColumns =
    <GestionColumn<TipoPacienteEntity>>[
  GestionColumn<TipoPacienteEntity>(
    label: 'Nombre',
    flex: 3,
    sortValue: (TipoPacienteEntity e) => e.nombre.toLowerCase(),
    cell: (TipoPacienteEntity e) => TipoPacienteCellText(e.nombre, bold: true),
  ),
  GestionColumn<TipoPacienteEntity>(
    label: 'Descripción',
    flex: 5,
    sortValue: (TipoPacienteEntity e) => (e.descripcion ?? '').toLowerCase(),
    cell: (TipoPacienteEntity e) => TipoPacienteCellText(GestionFormatters.texto(e.descripcion)),
  ),
  GestionColumn<TipoPacienteEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (TipoPacienteEntity e) => e.activo ? 0 : 1,
    cell: (TipoPacienteEntity e) => TipoPacienteEstadoDot(activo: e.activo),
  ),
];

/// Filtra por texto (nombre, descripción) y estado (null = todos)
List<TipoPacienteEntity> filtrarTiposPaciente(
  List<TipoPacienteEntity> items, {
  required String query,
  required bool? activo,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((TipoPacienteEntity e) {
    final bool matchesSearch = q.isEmpty ||
        e.nombre.toLowerCase().contains(q) ||
        (e.descripcion ?? '').toLowerCase().contains(q);
    final bool matchesEstado = activo == null || e.activo == activo;
    return matchesSearch && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenTiposPaciente(List<TipoPacienteEntity> todos, int filtrados) {
  final int activos = todos.where((TipoPacienteEntity e) => e.activo).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$activos activos',
    '${todos.length - activos} inactivos',
  ];
}

/// Imprime el listado de tipos de paciente (filtrado y ordenado)
Future<void> imprimirTiposPaciente(List<TipoPacienteEntity> items) {
  return GestionPrint.listado(
    title: 'Tipos de Paciente',
    headers: const <String>['Nombre', 'Descripción', 'Estado'],
    rows: items
        .map(
          (TipoPacienteEntity e) => <String>[
            e.nombre,
            GestionFormatters.texto(e.descripcion),
            if (e.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
