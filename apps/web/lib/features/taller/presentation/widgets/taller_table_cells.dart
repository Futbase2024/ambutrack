import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/taller_table_states.dart';
import 'package:flutter/material.dart';

/// Columnas de la tabla de Talleres
const List<DataGridColumn> tallerTableColumns = <DataGridColumn>[
  DataGridColumn(label: 'NOMBRE', flexWidth: 3, sortable: true),
  DataGridColumn(label: 'TIPO', flexWidth: 2, sortable: true),
  DataGridColumn(label: 'CIUDAD', flexWidth: 2),
  DataGridColumn(label: 'TELÉFONO', flexWidth: 2),
  DataGridColumn(label: 'CONTACTO', flexWidth: 2),
  DataGridColumn(label: 'ESPECIALIDAD', flexWidth: 2),
  DataGridColumn(label: 'ESTADO', flexWidth: 2, sortable: true),
];

/// Opciones del filtro por tipo de taller
const List<DropdownMenuItem<String>> tallerTipoFilterItems = <DropdownMenuItem<String>>[
  DropdownMenuItem<String>(value: 'todos', child: Text('Todos')),
  DropdownMenuItem<String>(value: 'propio', child: Text('Propio')),
  DropdownMenuItem<String>(value: 'externo', child: Text('Externo')),
  DropdownMenuItem<String>(value: 'itv', child: Text('Estación ITV')),
];

/// Tipo de badge según el tipo de taller
StatusBadgeType tallerTipoBadgeType(TipoTaller tipo) {
  switch (tipo) {
    case TipoTaller.propio:
      return StatusBadgeType.success;
    case TipoTaller.externo:
      return StatusBadgeType.disponible;
    case TipoTaller.itv:
      return StatusBadgeType.enServicio;
  }
}

/// Construye las celdas de una fila de Taller
List<DataGridCell> buildTallerCells(TallerEntity t) {
  return <DataGridCell>[
    DataGridCell(
      child: Text(
        t.nombre,
        style: AppTextStyles.tableCell.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    DataGridCell(
      child: TallerBadgeCell(
        child: StatusBadge(
          label: t.tipo.displayName,
          type: tallerTipoBadgeType(t.tipo),
        ),
      ),
    ),
    DataGridCell(child: Text(t.ciudad ?? '-', style: AppTextStyles.tableCell)),
    DataGridCell(child: Text(t.telefono ?? '-', style: AppTextStyles.tableCell)),
    DataGridCell(
      child: Text(t.contactoNombre ?? '-', style: AppTextStyles.tableCell),
    ),
    DataGridCell(
      child: Text(t.especialidad ?? '-', style: AppTextStyles.tableCell),
    ),
    DataGridCell(
      child: TallerBadgeCell(
        child: StatusBadge(
          label: t.activo ? 'Activo' : 'Inactivo',
          type: t.activo ? StatusBadgeType.success : StatusBadgeType.inactivo,
        ),
      ),
    ),
  ];
}

/// Filtra talleres por búsqueda (nombre, ciudad, teléfono) y tipo
List<TallerEntity> filterTalleres(
  List<TallerEntity> talleres, {
  required String query,
  required String tipo,
}) {
  final String q = query.toLowerCase();
  return talleres.where((TallerEntity t) {
    final bool matchesSearch = q.isEmpty ||
        t.nombre.toLowerCase().contains(q) ||
        (t.ciudad?.toLowerCase().contains(q) ?? false) ||
        (t.telefono?.contains(query) ?? false);
    final bool matchesTipo = tipo == 'todos' || t.tipo.value == tipo;
    return matchesSearch && matchesTipo;
  }).toList();
}
