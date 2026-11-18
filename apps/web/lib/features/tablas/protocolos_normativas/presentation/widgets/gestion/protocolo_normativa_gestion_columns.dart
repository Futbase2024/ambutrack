import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado del protocolo
enum ProtocoloEstadoFiltro { todos, activos, inactivos }

/// Indicador de estado activo/inactivo
class ProtocoloEstadoDot extends StatelessWidget {
  const ProtocoloEstadoDot({required this.activo, super.key});

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
class ProtocoloCellText extends StatelessWidget {
  const ProtocoloCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de protocolos y normativas
final List<GestionColumn<ProtocoloNormativaEntity>> protocoloGestionColumns =
    <GestionColumn<ProtocoloNormativaEntity>>[
  GestionColumn<ProtocoloNormativaEntity>(
    label: 'Código',
    width: 120,
    sortValue: (ProtocoloNormativaEntity p) => (p.codigo ?? '').toLowerCase(),
    cell: (ProtocoloNormativaEntity p) => ProtocoloCellText(GestionFormatters.texto(p.codigo)),
  ),
  GestionColumn<ProtocoloNormativaEntity>(
    label: 'Título',
    flex: 4,
    sortValue: (ProtocoloNormativaEntity p) => p.titulo.toLowerCase(),
    cell: (ProtocoloNormativaEntity p) => ProtocoloCellText(p.titulo, bold: true),
  ),
  GestionColumn<ProtocoloNormativaEntity>(
    label: 'Categoría',
    flex: 2,
    sortValue: (ProtocoloNormativaEntity p) => p.categoria.label,
    filterValue: (ProtocoloNormativaEntity p) => p.categoria.label,
    cell: (ProtocoloNormativaEntity p) => ProtocoloCellText(p.categoria.label),
  ),
  GestionColumn<ProtocoloNormativaEntity>(
    label: 'Versión',
    width: 90,
    sortValue: (ProtocoloNormativaEntity p) => (p.version ?? '').toLowerCase(),
    cell: (ProtocoloNormativaEntity p) => ProtocoloCellText(GestionFormatters.texto(p.version)),
  ),
  GestionColumn<ProtocoloNormativaEntity>(
    label: 'Vigencia',
    width: 110,
    sortValue: (ProtocoloNormativaEntity p) => p.fechaVigencia?.millisecondsSinceEpoch ?? 0,
    cell: (ProtocoloNormativaEntity p) => ProtocoloCellText(GestionFormatters.fecha(p.fechaVigencia)),
  ),
  GestionColumn<ProtocoloNormativaEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (ProtocoloNormativaEntity p) => p.activo ? 0 : 1,
    filterValue: (ProtocoloNormativaEntity p) => p.activo ? 'Activo' : 'Inactivo',
    cell: (ProtocoloNormativaEntity p) => ProtocoloEstadoDot(activo: p.activo),
  ),
];

/// Filtra por texto (título, código, descripción) y estado
List<ProtocoloNormativaEntity> filtrarProtocolos(
  List<ProtocoloNormativaEntity> protocolos, {
  required String query,
  required ProtocoloEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return protocolos.where((ProtocoloNormativaEntity p) {
    final bool matchesSearch = q.isEmpty ||
        p.titulo.toLowerCase().contains(q) ||
        (p.codigo?.toLowerCase().contains(q) ?? false) ||
        (p.descripcion?.toLowerCase().contains(q) ?? false);
    final bool matchesEstado = estado == ProtocoloEstadoFiltro.todos ||
        (estado == ProtocoloEstadoFiltro.activos ? p.activo : !p.activo);
    return matchesSearch && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenProtocolos(List<ProtocoloNormativaEntity> todos, int filtrados) {
  final int activos = todos.where((ProtocoloNormativaEntity p) => p.activo).length;
  return <String>[
    if (filtrados == todos.length) '${todos.length} registros' else '$filtrados de ${todos.length} registros',
    '$activos activos',
    '${todos.length - activos} inactivos',
  ];
}

/// Imprime el listado (filtrado y ordenado)
Future<void> imprimirProtocolos(List<ProtocoloNormativaEntity> protocolos) {
  return GestionPrint.listado(
    title: 'Protocolos y Normativas',
    headers: const <String>['Código', 'Título', 'Categoría', 'Versión', 'Vigencia', 'Estado'],
    rows: protocolos
        .map(
          (ProtocoloNormativaEntity p) => <String>[
            GestionFormatters.texto(p.codigo),
            p.titulo,
            p.categoria.label,
            GestionFormatters.texto(p.version),
            GestionFormatters.fecha(p.fechaVigencia),
            if (p.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
