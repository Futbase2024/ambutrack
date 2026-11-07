import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/almacen_gestion_common.dart';
import 'package:flutter/material.dart';

/// Color asociado a cada categoría de producto
Color productoCategoriaColor(CategoriaProducto? categoria) {
  switch (categoria) {
    case null:
      return AppColors.gray400;
    case CategoriaProducto.medicacion:
      return AppColors.primary;
    case CategoriaProducto.electromedicina:
      return AppColors.warning;
    case CategoriaProducto.fungibles:
      return AppColors.success;
    case CategoriaProducto.materialAmbulancia:
      return AppColors.secondary;
    case CategoriaProducto.gasesMedicinales:
      return AppColors.info;
    case CategoriaProducto.otros:
      return AppColors.inactive;
  }
}

/// Indicador de categoría (punto de color + nombre)
class ProductoCategoriaDot extends StatelessWidget {
  const ProductoCategoriaDot({required this.categoria, super.key});

  final CategoriaProducto? categoria;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: categoria?.label ?? 'Sin categoría',
      color: productoCategoriaColor(categoria),
    );
  }
}

/// Columnas de la rejilla de productos
final List<GestionColumn<ProductoEntity>> productoGestionColumns = <GestionColumn<ProductoEntity>>[
  GestionColumn<ProductoEntity>(
    label: 'Código',
    flex: 2,
    sortValue: (ProductoEntity p) => (p.codigo ?? '').toLowerCase(),
    cell: (ProductoEntity p) => AlmacenCellText(GestionFormatters.texto(p.codigo), bold: true),
  ),
  GestionColumn<ProductoEntity>(
    label: 'Nombre',
    flex: 4,
    sortValue: (ProductoEntity p) => p.nombre.toLowerCase(),
    cell: (ProductoEntity p) => AlmacenCellText(p.nombre, bold: true),
  ),
  GestionColumn<ProductoEntity>(
    label: 'Nombre comercial',
    flex: 3,
    sortValue: (ProductoEntity p) => (p.nombreComercial ?? '').toLowerCase(),
    cell: (ProductoEntity p) => AlmacenCellText(GestionFormatters.texto(p.nombreComercial)),
  ),
  GestionColumn<ProductoEntity>(
    label: 'Categoría',
    flex: 3,
    sortValue: (ProductoEntity p) => p.categoria?.label ?? '',
    cell: (ProductoEntity p) => ProductoCategoriaDot(categoria: p.categoria),
  ),
  GestionColumn<ProductoEntity>(
    label: 'Unidad',
    flex: 2,
    sortValue: (ProductoEntity p) => p.unidadMedida.toLowerCase(),
    cell: (ProductoEntity p) => AlmacenCellText(GestionFormatters.texto(p.unidadMedida)),
  ),
  GestionColumn<ProductoEntity>(
    label: 'Precio medio',
    width: 110,
    alignment: Alignment.centerRight,
    sortValue: (ProductoEntity p) => p.precioMedio ?? 0,
    cell: (ProductoEntity p) => AlmacenCellText(
      p.precioMedio == null ? GestionFormatters.vacio : GestionFormatters.moneda(p.precioMedio!),
    ),
  ),
  GestionColumn<ProductoEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (ProductoEntity p) => p.activo ? 0 : 1,
    cell: (ProductoEntity p) => AlmacenEstadoDot(activo: p.activo),
  ),
];

/// Filtra productos por texto (código, nombre, comercial, categoría), categoría y estado
List<ProductoEntity> filtrarProductos(
  List<ProductoEntity> productos, {
  required String query,
  required CategoriaProducto? categoria,
  required AlmacenEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return productos.where((ProductoEntity p) {
    final bool matchesSearch = q.isEmpty ||
        (p.codigo?.toLowerCase().contains(q) ?? false) ||
        p.nombre.toLowerCase().contains(q) ||
        (p.nombreComercial?.toLowerCase().contains(q) ?? false) ||
        (p.categoria?.label.toLowerCase().contains(q) ?? false);
    final bool matchesCategoria = categoria == null || p.categoria == categoria;
    return matchesSearch && matchesCategoria && almacenCumpleEstado(estado, activo: p.activo);
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenProductos(List<ProductoEntity> todos, int filtrados) {
  int count(CategoriaProducto c) => todos.where((ProductoEntity p) => p.categoria == c).length;
  final int activos = todos.where((ProductoEntity p) => p.activo).length;
  return <String>[
    almacenRegistrosLabel(todos.length, filtrados),
    '$activos activos',
    'Medicación ${count(CategoriaProducto.medicacion)}',
    'Electromedicina ${count(CategoriaProducto.electromedicina)}',
    'Fungibles ${count(CategoriaProducto.fungibles)}',
    'Material ${count(CategoriaProducto.materialAmbulancia)}',
  ];
}

/// Imprime el listado de productos (filtrado y ordenado)
Future<void> imprimirProductos(List<ProductoEntity> productos) {
  return GestionPrint.listado(
    title: 'Catálogo de Productos',
    headers: const <String>[
      'Código', 'Nombre', 'Nombre comercial', 'Categoría', 'Unidad', 'Precio medio', 'Estado',
    ],
    rows: productos
        .map(
          (ProductoEntity p) => <String>[
            GestionFormatters.texto(p.codigo),
            p.nombre,
            GestionFormatters.texto(p.nombreComercial),
            p.categoria?.label ?? GestionFormatters.vacio,
            GestionFormatters.texto(p.unidadMedida),
            if (p.precioMedio == null) GestionFormatters.vacio else GestionFormatters.moneda(p.precioMedio!),
            if (p.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
