import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado de la categoría
enum CategoriaVehiculoEstadoFiltro { todos, activos, inactivos }

/// Indicador de estado activo/inactivo
class CategoriaVehiculoEstadoDot extends StatelessWidget {
  const CategoriaVehiculoEstadoDot({required this.activo, super.key});

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
class CategoriaVehiculoCellText extends StatelessWidget {
  const CategoriaVehiculoCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de categorías de vehículo
final List<GestionColumn<CategoriaVehiculoEntity>> categoriaVehiculoGestionColumns =
    <GestionColumn<CategoriaVehiculoEntity>>[
  GestionColumn<CategoriaVehiculoEntity>(
    label: 'Nombre',
    flex: 3,
    sortValue: (CategoriaVehiculoEntity c) => c.nombre.toLowerCase(),
    cell: (CategoriaVehiculoEntity c) => CategoriaVehiculoCellText(c.nombre, bold: true),
  ),
  GestionColumn<CategoriaVehiculoEntity>(
    label: 'Descripción',
    flex: 5,
    sortValue: (CategoriaVehiculoEntity c) => (c.descripcion ?? '').toLowerCase(),
    cell: (CategoriaVehiculoEntity c) =>
        CategoriaVehiculoCellText(GestionFormatters.texto(c.descripcion)),
  ),
  GestionColumn<CategoriaVehiculoEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (CategoriaVehiculoEntity c) => c.activo ? 0 : 1,
    cell: (CategoriaVehiculoEntity c) => CategoriaVehiculoEstadoDot(activo: c.activo),
  ),
];

/// Filtra categorías por texto (nombre, descripción) y estado
List<CategoriaVehiculoEntity> filtrarCategoriasVehiculo(
  List<CategoriaVehiculoEntity> categorias, {
  required String query,
  required CategoriaVehiculoEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return categorias.where((CategoriaVehiculoEntity c) {
    final bool matchesSearch = q.isEmpty ||
        c.nombre.toLowerCase().contains(q) ||
        (c.descripcion?.toLowerCase().contains(q) ?? false);
    final bool matchesEstado = estado == CategoriaVehiculoEstadoFiltro.todos ||
        (estado == CategoriaVehiculoEstadoFiltro.activos ? c.activo : !c.activo);
    return matchesSearch && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenCategoriasVehiculo(List<CategoriaVehiculoEntity> todos, int filtrados) {
  final int activos = todos.where((CategoriaVehiculoEntity c) => c.activo).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$activos activas',
    '${todos.length - activos} inactivas',
  ];
}

/// Imprime el listado de categorías (filtrado y ordenado)
Future<void> imprimirCategoriasVehiculo(List<CategoriaVehiculoEntity> categorias) {
  return GestionPrint.listado(
    title: 'Categorías de Vehículo',
    headers: const <String>['Nombre', 'Descripción', 'Orden', 'Estado'],
    rows: categorias
        .map(
          (CategoriaVehiculoEntity c) => <String>[
            c.nombre,
            GestionFormatters.texto(c.descripcion),
            c.orden?.toString() ?? GestionFormatters.vacio,
            if (c.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
