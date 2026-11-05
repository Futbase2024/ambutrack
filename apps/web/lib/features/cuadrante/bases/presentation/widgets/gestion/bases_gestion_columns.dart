import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado de la base
enum BaseEstadoFiltro { todos, activas, inactivas }

/// Color asociado al tipo de base (Permanente / Temporal)
Color baseTipoColor(String? tipo) {
  switch (tipo?.toLowerCase()) {
    case 'permanente':
      return AppColors.info;
    case 'temporal':
      return AppColors.warning;
    default:
      return AppColors.gray400;
  }
}

/// Indicador de estado activo/inactivo
class BaseEstadoDot extends StatelessWidget {
  const BaseEstadoDot({required this.activo, super.key});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: activo ? 'Activa' : 'Inactiva',
      color: activo ? AppColors.success : AppColors.inactive,
    );
  }
}

/// Indicador del tipo de base (o vacío en gris)
class BaseTipoDot extends StatelessWidget {
  const BaseTipoDot({required this.tipo, super.key});

  final String? tipo;

  @override
  Widget build(BuildContext context) {
    final String? t = tipo;
    if (t == null || t.trim().isEmpty) {
      return const BaseCellText(GestionFormatters.vacio);
    }
    return GestionDotLabel(label: t, color: baseTipoColor(t));
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class BaseCellText extends StatelessWidget {
  const BaseCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de bases
final List<GestionColumn<BaseCentroEntity>> basesGestionColumns =
    <GestionColumn<BaseCentroEntity>>[
  GestionColumn<BaseCentroEntity>(
    label: 'Nombre',
    flex: 3,
    sortValue: (BaseCentroEntity b) => b.nombre.toLowerCase(),
    cell: (BaseCentroEntity b) => BaseCellText(b.nombre, bold: true),
  ),
  GestionColumn<BaseCentroEntity>(
    label: 'Dirección',
    flex: 4,
    sortValue: (BaseCentroEntity b) => (b.direccion ?? '').toLowerCase(),
    cell: (BaseCentroEntity b) => BaseCellText(GestionFormatters.texto(b.direccion)),
  ),
  GestionColumn<BaseCentroEntity>(
    label: 'Población',
    flex: 2,
    sortValue: (BaseCentroEntity b) => (b.poblacionNombre ?? '').toLowerCase(),
    cell: (BaseCentroEntity b) => BaseCellText(GestionFormatters.texto(b.poblacionNombre)),
  ),
  GestionColumn<BaseCentroEntity>(
    label: 'Tipo',
    width: 130,
    sortValue: (BaseCentroEntity b) => (b.tipo ?? '').toLowerCase(),
    cell: (BaseCentroEntity b) => BaseTipoDot(tipo: b.tipo),
  ),
  GestionColumn<BaseCentroEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (BaseCentroEntity b) => b.activo ? 0 : 1,
    cell: (BaseCentroEntity b) => BaseEstadoDot(activo: b.activo),
  ),
];

/// Filtra bases por texto (nombre, dirección, población, tipo) y estado
List<BaseCentroEntity> filtrarBases(
  List<BaseCentroEntity> bases, {
  required String query,
  required BaseEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return bases.where((BaseCentroEntity b) {
    final bool matchesSearch = q.isEmpty ||
        b.nombre.toLowerCase().contains(q) ||
        (b.direccion?.toLowerCase().contains(q) ?? false) ||
        (b.poblacionNombre?.toLowerCase().contains(q) ?? false) ||
        (b.tipo?.toLowerCase().contains(q) ?? false);
    final bool matchesEstado = estado == BaseEstadoFiltro.todos ||
        (estado == BaseEstadoFiltro.activas ? b.activo : !b.activo);
    return matchesSearch && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenBases(List<BaseCentroEntity> todas, int filtradas) {
  final int activas = todas.where((BaseCentroEntity b) => b.activo).length;
  int countTipo(String tipo) =>
      todas.where((BaseCentroEntity b) => b.tipo?.toLowerCase() == tipo).length;
  return <String>[
    if (filtradas == todas.length)
      '${todas.length} registros'
    else
      '$filtradas de ${todas.length} registros',
    '$activas activas',
    '${todas.length - activas} inactivas',
    'Permanentes ${countTipo('permanente')}',
    'Temporales ${countTipo('temporal')}',
  ];
}

/// Imprime el listado de bases (filtrado y ordenado)
Future<void> imprimirBases(List<BaseCentroEntity> bases) {
  return GestionPrint.listado(
    title: 'Bases y Centros',
    headers: const <String>['Código', 'Nombre', 'Dirección', 'Población', 'Tipo', 'Estado'],
    rows: bases
        .map(
          (BaseCentroEntity b) => <String>[
            GestionFormatters.texto(b.codigo),
            b.nombre,
            GestionFormatters.texto(b.direccion),
            GestionFormatters.texto(b.poblacionNombre),
            GestionFormatters.texto(b.tipo),
            if (b.activo) 'Activa' else 'Inactiva',
          ],
        )
        .toList(),
  );
}
