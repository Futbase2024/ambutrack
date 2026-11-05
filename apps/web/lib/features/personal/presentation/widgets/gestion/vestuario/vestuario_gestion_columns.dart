import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por situación de la prenda
enum VestuarioEstadoFiltro { todos, asignados, devueltos }

/// Indicador Asignado / Devuelto
class VestuarioEstadoDot extends StatelessWidget {
  const VestuarioEstadoDot({required this.item, super.key});

  final VestuarioEntity item;

  @override
  Widget build(BuildContext context) {
    final bool asignado = item.estaAsignado;
    return GestionDotLabel(
      label: asignado ? 'Asignado' : 'Devuelto',
      color: asignado ? AppColors.success : AppColors.inactive,
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class VestuarioCellText extends StatelessWidget {
  const VestuarioCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de vestuario
List<GestionColumn<VestuarioEntity>> vestuarioColumns(String Function(String personalId) nombre) {
  return <GestionColumn<VestuarioEntity>>[
    GestionColumn<VestuarioEntity>(
      label: 'Trabajador',
      flex: 3,
      sortValue: (VestuarioEntity v) => nombre(v.personalId).toLowerCase(),
      cell: (VestuarioEntity v) => VestuarioCellText(nombre(v.personalId), bold: true),
    ),
    GestionColumn<VestuarioEntity>(
      label: 'Prenda',
      flex: 3,
      sortValue: (VestuarioEntity v) => v.prenda.toLowerCase(),
      cell: (VestuarioEntity v) => VestuarioCellText(GestionFormatters.texto(v.prenda)),
    ),
    GestionColumn<VestuarioEntity>(
      label: 'Talla',
      width: 80,
      sortValue: (VestuarioEntity v) => v.talla.toLowerCase(),
      cell: (VestuarioEntity v) => VestuarioCellText(GestionFormatters.texto(v.talla)),
    ),
    GestionColumn<VestuarioEntity>(
      label: 'Cantidad',
      width: 90,
      alignment: Alignment.centerRight,
      sortValue: (VestuarioEntity v) => v.cantidad ?? 1,
      cell: (VestuarioEntity v) => VestuarioCellText('${v.cantidad ?? 1}'),
    ),
    GestionColumn<VestuarioEntity>(
      label: 'Marca',
      flex: 2,
      sortValue: (VestuarioEntity v) => (v.marca ?? '').toLowerCase(),
      cell: (VestuarioEntity v) => VestuarioCellText(GestionFormatters.texto(v.marca)),
    ),
    GestionColumn<VestuarioEntity>(
      label: 'Entrega',
      width: 110,
      sortValue: (VestuarioEntity v) => v.fechaEntrega,
      cell: (VestuarioEntity v) => VestuarioCellText(GestionFormatters.fecha(v.fechaEntrega)),
    ),
    GestionColumn<VestuarioEntity>(
      label: 'Estado',
      width: 110,
      sortValue: (VestuarioEntity v) => v.estaAsignado ? 0 : 1,
      cell: (VestuarioEntity v) => VestuarioEstadoDot(item: v),
    ),
  ];
}

/// Prendas distintas presentes en los datos (para el filtro)
List<String> prendasVestuario(List<VestuarioEntity> items) {
  return items.map((VestuarioEntity v) => v.prenda).toSet().toList()..sort();
}

/// Filtra por texto (trabajador, prenda, talla, marca, color), estado y prenda
List<VestuarioEntity> filtrarVestuario(
  List<VestuarioEntity> items, {
  required String query,
  required VestuarioEstadoFiltro estado,
  required String? prenda,
  required String Function(String personalId) nombre,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((VestuarioEntity v) {
    final bool matchesSearch = q.isEmpty ||
        nombre(v.personalId).toLowerCase().contains(q) ||
        v.prenda.toLowerCase().contains(q) ||
        v.talla.toLowerCase().contains(q) ||
        (v.marca?.toLowerCase().contains(q) ?? false) ||
        (v.color?.toLowerCase().contains(q) ?? false);
    final bool matchesEstado = estado == VestuarioEstadoFiltro.todos ||
        (estado == VestuarioEstadoFiltro.asignados ? v.estaAsignado : !v.estaAsignado);
    final bool matchesPrenda = prenda == null || v.prenda == prenda;
    return matchesSearch && matchesEstado && matchesPrenda;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenVestuario(List<VestuarioEntity> todos, int filtrados) {
  final int asignados = todos.where((VestuarioEntity v) => v.estaAsignado).length;
  final int devueltos = todos.where((VestuarioEntity v) => v.fueDevuelto).length;
  final int activos = todos.where((VestuarioEntity v) => v.activo).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$asignados asignados',
    '$devueltos devueltos',
    '$activos activos',
  ];
}

/// Imprime el listado de vestuario (filtrado y ordenado)
Future<void> imprimirVestuario(
  List<VestuarioEntity> items,
  String Function(String personalId) nombre,
) {
  return GestionPrint.listado(
    title: 'Vestuario del Personal',
    headers: const <String>[
      'Trabajador', 'Prenda', 'Talla', 'Cantidad', 'Marca', 'Color', 'Entrega', 'Devolución', 'Estado',
    ],
    rows: items
        .map(
          (VestuarioEntity v) => <String>[
            nombre(v.personalId),
            v.prenda,
            v.talla,
            '${v.cantidad ?? 1}',
            GestionFormatters.texto(v.marca),
            GestionFormatters.texto(v.color),
            GestionFormatters.fecha(v.fechaEntrega),
            GestionFormatters.fecha(v.fechaDevolucion),
            if (v.estaAsignado) 'Asignado' else 'Devuelto',
          ],
        )
        .toList(),
  );
}
