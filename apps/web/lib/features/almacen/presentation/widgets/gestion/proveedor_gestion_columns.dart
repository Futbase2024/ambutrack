import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/almacen_gestion_common.dart';

/// Columnas de la rejilla de proveedores del almacén
final List<GestionColumn<ProveedorEntity>> proveedorGestionColumns = <GestionColumn<ProveedorEntity>>[
  GestionColumn<ProveedorEntity>(
    label: 'Código',
    flex: 2,
    sortValue: (ProveedorEntity p) => p.codigo.toLowerCase(),
    cell: (ProveedorEntity p) => AlmacenCellText(GestionFormatters.texto(p.codigo), bold: true),
  ),
  GestionColumn<ProveedorEntity>(
    label: 'Nombre comercial',
    flex: 4,
    sortValue: (ProveedorEntity p) => p.nombreComercial.toLowerCase(),
    cell: (ProveedorEntity p) => AlmacenCellText(p.nombreComercial, bold: true),
  ),
  GestionColumn<ProveedorEntity>(
    label: 'CIF/NIF',
    flex: 2,
    sortValue: (ProveedorEntity p) => (p.cifNif ?? '').toLowerCase(),
    cell: (ProveedorEntity p) => AlmacenCellText(GestionFormatters.texto(p.cifNif)),
  ),
  GestionColumn<ProveedorEntity>(
    label: 'Teléfono',
    flex: 2,
    sortValue: (ProveedorEntity p) => p.telefono ?? '',
    cell: (ProveedorEntity p) => AlmacenCellText(GestionFormatters.telefono(p.telefono)),
  ),
  GestionColumn<ProveedorEntity>(
    label: 'Email',
    flex: 3,
    sortValue: (ProveedorEntity p) => (p.email ?? '').toLowerCase(),
    cell: (ProveedorEntity p) => AlmacenCellText(GestionFormatters.texto(p.email)),
  ),
  GestionColumn<ProveedorEntity>(
    label: 'Ciudad',
    flex: 2,
    sortValue: (ProveedorEntity p) => (p.ciudad ?? '').toLowerCase(),
    cell: (ProveedorEntity p) => AlmacenCellText(GestionFormatters.texto(p.ciudad)),
  ),
  GestionColumn<ProveedorEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (ProveedorEntity p) => p.activo ? 0 : 1,
    cell: (ProveedorEntity p) => AlmacenEstadoDot(activo: p.activo),
  ),
];

/// Filtra proveedores por texto (código, nombres, CIF, email, teléfono, ciudad) y estado
List<ProveedorEntity> filtrarProveedores(
  List<ProveedorEntity> proveedores, {
  required String query,
  required AlmacenEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  bool contiene(String? value) => value?.toLowerCase().contains(q) ?? false;
  return proveedores.where((ProveedorEntity p) {
    final bool matchesSearch = q.isEmpty ||
        contiene(p.codigo) ||
        contiene(p.nombreComercial) ||
        contiene(p.razonSocial) ||
        contiene(p.cifNif) ||
        contiene(p.email) ||
        contiene(p.telefono) ||
        contiene(p.ciudad);
    return matchesSearch && almacenCumpleEstado(estado, activo: p.activo);
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenProveedores(List<ProveedorEntity> todos, int filtrados) {
  final int activos = todos.where((ProveedorEntity p) => p.activo).length;
  return <String>[
    almacenRegistrosLabel(todos.length, filtrados),
    '$activos activos',
    '${todos.length - activos} inactivos',
  ];
}

/// Imprime el listado de proveedores (filtrado y ordenado)
Future<void> imprimirProveedores(List<ProveedorEntity> proveedores) {
  return GestionPrint.listado(
    title: 'Proveedores del Almacén',
    headers: const <String>[
      'Código', 'Nombre comercial', 'Razón social', 'CIF/NIF', 'Teléfono', 'Email', 'Ciudad', 'Estado',
    ],
    rows: proveedores
        .map(
          (ProveedorEntity p) => <String>[
            GestionFormatters.texto(p.codigo),
            p.nombreComercial,
            GestionFormatters.texto(p.razonSocial),
            GestionFormatters.texto(p.cifNif),
            GestionFormatters.telefono(p.telefono),
            GestionFormatters.texto(p.email),
            GestionFormatters.texto(p.ciudad),
            if (p.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
