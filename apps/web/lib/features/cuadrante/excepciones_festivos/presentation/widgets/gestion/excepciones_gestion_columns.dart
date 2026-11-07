import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado de la excepción/festivo
enum ExcepcionEstadoFiltro { todos, activos, inactivos }

/// Tipos con su texto visible
const Map<String, String> excepcionTipos = <String, String>{
  ExcepcionFestivoEntity.tipoFestivo: 'Festivo',
  ExcepcionFestivoEntity.tipoExcepcion: 'Excepción',
  ExcepcionFestivoEntity.tipoEspecial: 'Especial',
};

String excepcionTipoLabel(String tipo) => excepcionTipos[tipo] ?? tipo;

Color excepcionTipoColor(String tipo) {
  switch (tipo) {
    case ExcepcionFestivoEntity.tipoFestivo:
      return AppColors.success;
    case ExcepcionFestivoEntity.tipoExcepcion:
      return AppColors.warning;
    case ExcepcionFestivoEntity.tipoEspecial:
      return AppColors.info;
    default:
      return AppColors.gray400;
  }
}

/// Indicador del tipo
class ExcepcionTipoDot extends StatelessWidget {
  const ExcepcionTipoDot({required this.tipo, super.key});

  final String tipo;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(label: excepcionTipoLabel(tipo), color: excepcionTipoColor(tipo));
  }
}

/// Indicador de estado activo/inactivo
class ExcepcionEstadoDot extends StatelessWidget {
  const ExcepcionEstadoDot({required this.activo, super.key});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: activo ? 'Activo' : 'Inactivo',
      color: activo ? AppColors.success : AppColors.inactive,
    );
  }
}

/// Texto Sí / No (el "No" en gris claro)
class ExcepcionSiNo extends StatelessWidget {
  const ExcepcionSiNo({required this.value, super.key});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value ? 'Sí' : 'No',
      style: TextStyle(
        fontWeight: value ? FontWeight.w600 : FontWeight.w400,
        color: value ? null : AppColors.gray400,
      ),
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class ExcepcionCellText extends StatelessWidget {
  const ExcepcionCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de excepciones/festivos
final List<GestionColumn<ExcepcionFestivoEntity>> excepcionesGestionColumns =
    <GestionColumn<ExcepcionFestivoEntity>>[
  GestionColumn<ExcepcionFestivoEntity>(
    label: 'Fecha',
    width: 110,
    sortValue: (ExcepcionFestivoEntity e) => e.fecha.millisecondsSinceEpoch,
    cell: (ExcepcionFestivoEntity e) => ExcepcionCellText(GestionFormatters.fecha(e.fecha)),
  ),
  GestionColumn<ExcepcionFestivoEntity>(
    label: 'Nombre',
    flex: 3,
    sortValue: (ExcepcionFestivoEntity e) => e.nombre.toLowerCase(),
    cell: (ExcepcionFestivoEntity e) => ExcepcionCellText(e.nombre, bold: true),
  ),
  GestionColumn<ExcepcionFestivoEntity>(
    label: 'Descripción',
    flex: 3,
    cell: (ExcepcionFestivoEntity e) => ExcepcionCellText(GestionFormatters.texto(e.descripcion)),
  ),
  GestionColumn<ExcepcionFestivoEntity>(
    label: 'Tipo',
    width: 120,
    sortValue: (ExcepcionFestivoEntity e) => e.tipo,
    cell: (ExcepcionFestivoEntity e) => ExcepcionTipoDot(tipo: e.tipo),
  ),
  GestionColumn<ExcepcionFestivoEntity>(
    label: 'Anual',
    width: 80,
    sortValue: (ExcepcionFestivoEntity e) => e.repetirAnualmente ? 0 : 1,
    cell: (ExcepcionFestivoEntity e) => ExcepcionSiNo(value: e.repetirAnualmente),
  ),
  GestionColumn<ExcepcionFestivoEntity>(
    label: 'Afecta dotaciones',
    width: 140,
    sortValue: (ExcepcionFestivoEntity e) => e.afectaDotaciones ? 0 : 1,
    cell: (ExcepcionFestivoEntity e) => ExcepcionSiNo(value: e.afectaDotaciones),
  ),
  GestionColumn<ExcepcionFestivoEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (ExcepcionFestivoEntity e) => e.activo ? 0 : 1,
    cell: (ExcepcionFestivoEntity e) => ExcepcionEstadoDot(activo: e.activo),
  ),
];

/// Filtra por texto (nombre, tipo, descripción), tipo y estado
List<ExcepcionFestivoEntity> filtrarExcepciones(
  List<ExcepcionFestivoEntity> items, {
  required String query,
  required String? tipo,
  required ExcepcionEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((ExcepcionFestivoEntity e) {
    final bool matchesSearch = q.isEmpty ||
        e.nombre.toLowerCase().contains(q) ||
        e.tipo.toLowerCase().contains(q) ||
        (e.descripcion?.toLowerCase().contains(q) ?? false);
    final bool matchesTipo = tipo == null || e.tipo == tipo;
    final bool matchesEstado = estado == ExcepcionEstadoFiltro.todos ||
        (estado == ExcepcionEstadoFiltro.activos ? e.activo : !e.activo);
    return matchesSearch && matchesTipo && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenExcepciones(List<ExcepcionFestivoEntity> todos, int filtrados) {
  int count(String tipo) => todos.where((ExcepcionFestivoEntity e) => e.tipo == tipo).length;
  return <String>[
    if (filtrados == todos.length) '${todos.length} registros' else '$filtrados de ${todos.length} registros',
    '${todos.where((ExcepcionFestivoEntity e) => e.activo).length} activos',
    '${todos.where((ExcepcionFestivoEntity e) => e.repetirAnualmente).length} anuales',
    'Festivos ${count(ExcepcionFestivoEntity.tipoFestivo)}',
    'Excepciones ${count(ExcepcionFestivoEntity.tipoExcepcion)}',
    'Especiales ${count(ExcepcionFestivoEntity.tipoEspecial)}',
  ];
}

/// Imprime el listado (filtrado y ordenado)
Future<void> imprimirExcepciones(List<ExcepcionFestivoEntity> items) {
  return GestionPrint.listado(
    title: 'Excepciones y Festivos',
    headers: const <String>['Fecha', 'Nombre', 'Descripción', 'Tipo', 'Anual', 'Afecta dotaciones', 'Estado'],
    rows: items
        .map(
          (ExcepcionFestivoEntity e) => <String>[
            GestionFormatters.fecha(e.fecha),
            e.nombre,
            GestionFormatters.texto(e.descripcion),
            excepcionTipoLabel(e.tipo),
            if (e.repetirAnualmente) 'Sí' else 'No',
            if (e.afectaDotaciones) 'Sí' else 'No',
            if (e.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
