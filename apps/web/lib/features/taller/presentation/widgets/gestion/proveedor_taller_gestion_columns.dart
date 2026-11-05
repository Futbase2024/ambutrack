import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Color asociado a cada tipo de proveedor
Color proveedorTallerTipoColor(TipoProveedor tipo) {
  switch (tipo) {
    case TipoProveedor.repuestos:
      return AppColors.info;
    case TipoProveedor.servicios:
      return AppColors.secondary;
    case TipoProveedor.lubricantes:
      return AppColors.warning;
    case TipoProveedor.neumaticos:
      return AppColors.success;
    case TipoProveedor.otros:
      return AppColors.inactive;
  }
}

/// Columnas de la rejilla de proveedores de taller
final List<GestionColumn<ProveedorTallerEntity>> proveedorTallerGestionColumns =
    <GestionColumn<ProveedorTallerEntity>>[
  GestionColumn<ProveedorTallerEntity>(
    label: 'Nombre',
    flex: 4,
    sortValue: (ProveedorTallerEntity p) => p.nombre.toLowerCase(),
    cell: (ProveedorTallerEntity p) => TallerCellText(p.nombre, bold: true),
  ),
  GestionColumn<ProveedorTallerEntity>(
    label: 'Tipo',
    flex: 2,
    sortValue: (ProveedorTallerEntity p) => p.tipo.displayName,
    cell: (ProveedorTallerEntity p) => GestionDotLabel(
      label: p.tipo.displayName,
      color: proveedorTallerTipoColor(p.tipo),
    ),
  ),
  GestionColumn<ProveedorTallerEntity>(
    label: 'Ciudad',
    flex: 2,
    sortValue: (ProveedorTallerEntity p) => (p.ciudad ?? '').toLowerCase(),
    cell: (ProveedorTallerEntity p) => TallerCellText(GestionFormatters.texto(p.ciudad)),
  ),
  GestionColumn<ProveedorTallerEntity>(
    label: 'Teléfono',
    flex: 2,
    cell: (ProveedorTallerEntity p) => TallerCellText(GestionFormatters.telefono(p.telefono)),
  ),
  GestionColumn<ProveedorTallerEntity>(
    label: 'Contacto',
    flex: 2,
    sortValue: (ProveedorTallerEntity p) => (p.contactoNombre ?? '').toLowerCase(),
    cell: (ProveedorTallerEntity p) => TallerCellText(GestionFormatters.texto(p.contactoNombre)),
  ),
  GestionColumn<ProveedorTallerEntity>(
    label: 'Forma pago',
    flex: 2,
    sortValue: (ProveedorTallerEntity p) => (p.formaPago ?? '').toLowerCase(),
    cell: (ProveedorTallerEntity p) => TallerCellText(GestionFormatters.texto(p.formaPago)),
  ),
  GestionColumn<ProveedorTallerEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (ProveedorTallerEntity p) => p.activo ? 0 : 1,
    cell: (ProveedorTallerEntity p) => TallerEstadoDot(activo: p.activo),
  ),
];

/// Filtra proveedores por texto (nombre, ciudad, contacto, teléfono), tipo y estado
List<ProveedorTallerEntity> filtrarProveedoresTaller(
  List<ProveedorTallerEntity> proveedores, {
  required String query,
  required TipoProveedor? tipo,
  required TallerEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  final String qDigits = q.replaceAll(RegExp(r'\D'), '');
  return proveedores.where((ProveedorTallerEntity p) {
    final bool matchesSearch = q.isEmpty ||
        p.nombre.toLowerCase().contains(q) ||
        (p.ciudad?.toLowerCase().contains(q) ?? false) ||
        (p.contactoNombre?.toLowerCase().contains(q) ?? false) ||
        (qDigits.isNotEmpty &&
            (p.telefono?.replaceAll(RegExp(r'\D'), '').contains(qDigits) ?? false));
    final bool matchesTipo = tipo == null || p.tipo == tipo;
    final bool matchesEstado = estado == TallerEstadoFiltro.todos ||
        (estado == TallerEstadoFiltro.activos ? p.activo : !p.activo);
    return matchesSearch && matchesTipo && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenProveedoresTaller(List<ProveedorTallerEntity> todos, int filtrados) {
  int count(TipoProveedor tipo) =>
      todos.where((ProveedorTallerEntity p) => p.tipo == tipo).length;
  final int activos = todos.where((ProveedorTallerEntity p) => p.activo).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$activos activos',
    for (final TipoProveedor t in TipoProveedor.values) '${t.displayName} ${count(t)}',
  ];
}

/// Imprime el listado de proveedores de taller (filtrado y ordenado)
Future<void> imprimirProveedoresTaller(List<ProveedorTallerEntity> proveedores) {
  return GestionPrint.listado(
    title: 'Proveedores de Taller',
    headers: const <String>[
      'Nombre', 'Tipo', 'NIF', 'Ciudad', 'Teléfono', 'Email', 'Contacto', 'Forma pago', 'Estado',
    ],
    rows: proveedores
        .map(
          (ProveedorTallerEntity p) => <String>[
            p.nombre,
            p.tipo.displayName,
            GestionFormatters.texto(p.nif),
            GestionFormatters.texto(p.ciudad),
            GestionFormatters.telefono(p.telefono),
            GestionFormatters.texto(p.email),
            GestionFormatters.texto(p.contactoNombre),
            GestionFormatters.texto(p.formaPago),
            if (p.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
