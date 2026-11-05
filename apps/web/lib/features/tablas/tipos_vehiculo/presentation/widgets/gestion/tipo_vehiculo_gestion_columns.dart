import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado del tipo
enum TipoVehiculoEstadoFiltro { todos, activos, inactivos }

/// Indicador de estado activo/inactivo
class TipoVehiculoEstadoDot extends StatelessWidget {
  const TipoVehiculoEstadoDot({required this.activo, super.key});

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
class TipoVehiculoCellText extends StatelessWidget {
  const TipoVehiculoCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de tipos de vehículo
final List<GestionColumn<TipoVehiculoEntity>> tipoVehiculoGestionColumns =
    <GestionColumn<TipoVehiculoEntity>>[
  GestionColumn<TipoVehiculoEntity>(
    label: 'Nombre',
    flex: 3,
    sortValue: (TipoVehiculoEntity c) => c.nombre.toLowerCase(),
    cell: (TipoVehiculoEntity c) => TipoVehiculoCellText(c.nombre, bold: true),
  ),
  GestionColumn<TipoVehiculoEntity>(
    label: 'Descripción',
    flex: 5,
    sortValue: (TipoVehiculoEntity c) => (c.descripcion ?? '').toLowerCase(),
    cell: (TipoVehiculoEntity c) =>
        TipoVehiculoCellText(GestionFormatters.texto(c.descripcion)),
  ),
  GestionColumn<TipoVehiculoEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (TipoVehiculoEntity c) => c.activo ? 0 : 1,
    cell: (TipoVehiculoEntity c) => TipoVehiculoEstadoDot(activo: c.activo),
  ),
];

/// Filtra tipos por texto (nombre, descripción) y estado
List<TipoVehiculoEntity> filtrarTiposVehiculo(
  List<TipoVehiculoEntity> tipos, {
  required String query,
  required TipoVehiculoEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return tipos.where((TipoVehiculoEntity c) {
    final bool matchesSearch = q.isEmpty ||
        c.nombre.toLowerCase().contains(q) ||
        (c.descripcion?.toLowerCase().contains(q) ?? false);
    final bool matchesEstado = estado == TipoVehiculoEstadoFiltro.todos ||
        (estado == TipoVehiculoEstadoFiltro.activos ? c.activo : !c.activo);
    return matchesSearch && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenTiposVehiculo(List<TipoVehiculoEntity> todos, int filtrados) {
  final int activos = todos.where((TipoVehiculoEntity c) => c.activo).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$activos activos',
    '${todos.length - activos} inactivos',
  ];
}

/// Imprime el listado de tipos (filtrado y ordenado)
Future<void> imprimirTiposVehiculo(List<TipoVehiculoEntity> tipos) {
  return GestionPrint.listado(
    title: 'Tipos de Vehículo',
    headers: const <String>['Nombre', 'Descripción', 'Orden', 'Estado'],
    rows: tipos
        .map(
          (TipoVehiculoEntity c) => <String>[
            c.nombre,
            GestionFormatters.texto(c.descripcion),
            c.orden?.toString() ?? GestionFormatters.vacio,
            if (c.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
