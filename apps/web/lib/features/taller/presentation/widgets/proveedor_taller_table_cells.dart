import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/taller_table_states.dart';
import 'package:flutter/material.dart';

/// Columnas de la tabla de Proveedores de Taller
const List<DataGridColumn> proveedorTallerTableColumns = <DataGridColumn>[
  DataGridColumn(label: 'NOMBRE', flexWidth: 3, sortable: true),
  DataGridColumn(label: 'TIPO', flexWidth: 2, sortable: true),
  DataGridColumn(label: 'CIUDAD', flexWidth: 2),
  DataGridColumn(label: 'TELÉFONO', flexWidth: 2),
  DataGridColumn(label: 'CONTACTO', flexWidth: 2),
  DataGridColumn(label: 'FORMA PAGO', flexWidth: 2),
  DataGridColumn(label: 'ESTADO', flexWidth: 2, sortable: true),
];

/// Opciones del filtro por tipo de proveedor
const List<DropdownMenuItem<String>> proveedorTipoFilterItems = <DropdownMenuItem<String>>[
  DropdownMenuItem<String>(value: 'todos', child: Text('Todos')),
  DropdownMenuItem<String>(value: 'repuestos', child: Text('Repuestos')),
  DropdownMenuItem<String>(value: 'servicios', child: Text('Servicios')),
  DropdownMenuItem<String>(value: 'lubricantes', child: Text('Lubricantes')),
  DropdownMenuItem<String>(value: 'neumaticos', child: Text('Neumáticos')),
  DropdownMenuItem<String>(value: 'otros', child: Text('Otros')),
];

/// Tipo de badge según el tipo de proveedor
StatusBadgeType proveedorTipoBadgeType(TipoProveedor tipo) {
  switch (tipo) {
    case TipoProveedor.repuestos:
      return StatusBadgeType.disponible;
    case TipoProveedor.servicios:
      return StatusBadgeType.enServicio;
    case TipoProveedor.lubricantes:
      return StatusBadgeType.warning;
    case TipoProveedor.neumaticos:
      return StatusBadgeType.success;
    case TipoProveedor.otros:
      return StatusBadgeType.inactivo;
  }
}

/// Construye las celdas de una fila de Proveedor
List<DataGridCell> buildProveedorTallerCells(ProveedorTallerEntity p) {
  return <DataGridCell>[
    DataGridCell(
      child: Text(
        p.nombre,
        style: AppTextStyles.tableCell.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    DataGridCell(
      child: TallerBadgeCell(
        child: StatusBadge(
          label: p.tipo.displayName,
          type: proveedorTipoBadgeType(p.tipo),
        ),
      ),
    ),
    DataGridCell(child: Text(p.ciudad ?? '-', style: AppTextStyles.tableCell)),
    DataGridCell(child: Text(p.telefono ?? '-', style: AppTextStyles.tableCell)),
    DataGridCell(
      child: Text(p.contactoNombre ?? '-', style: AppTextStyles.tableCell),
    ),
    DataGridCell(child: Text(p.formaPago ?? '-', style: AppTextStyles.tableCell)),
    DataGridCell(
      child: TallerBadgeCell(
        child: StatusBadge(
          label: p.activo ? 'Activo' : 'Inactivo',
          type: p.activo ? StatusBadgeType.success : StatusBadgeType.inactivo,
        ),
      ),
    ),
  ];
}

/// Filtra proveedores por búsqueda (nombre, ciudad, teléfono) y tipo
List<ProveedorTallerEntity> filterProveedoresTaller(
  List<ProveedorTallerEntity> proveedores, {
  required String query,
  required String tipo,
}) {
  final String q = query.toLowerCase();
  return proveedores.where((ProveedorTallerEntity p) {
    final bool matchesSearch = q.isEmpty ||
        p.nombre.toLowerCase().contains(q) ||
        (p.ciudad?.toLowerCase().contains(q) ?? false) ||
        (p.telefono?.contains(query) ?? false);
    final bool matchesTipo = tipo == 'todos' || p.tipo.value == tipo;
    return matchesSearch && matchesTipo;
  }).toList();
}
