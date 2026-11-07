import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:flutter/material.dart';

/// Filtro por estado del curso
enum CursoEstadoFiltro { todos, activos, inactivos }

/// Texto visible del tipo de curso
String cursoTipoLabel(String tipo) {
  switch (tipo) {
    case CursoTipo.presencial:
      return 'Presencial';
    case CursoTipo.online:
      return 'Online';
    case CursoTipo.mixto:
      return 'Mixto';
    default:
      return tipo;
  }
}

/// Color asociado al tipo de curso
Color cursoTipoColor(String tipo) {
  switch (tipo) {
    case CursoTipo.presencial:
      return AppColors.primary;
    case CursoTipo.online:
      return AppColors.info;
    case CursoTipo.mixto:
      return AppColors.warning;
    default:
      return AppColors.gray600;
  }
}

/// Indicador de tipo de curso
class CursoTipoDot extends StatelessWidget {
  const CursoTipoDot({required this.tipo, super.key});

  final String tipo;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(label: cursoTipoLabel(tipo), color: cursoTipoColor(tipo));
  }
}

/// Columnas de la rejilla de cursos
final List<GestionColumn<CursoEntity>> cursoGestionColumns = <GestionColumn<CursoEntity>>[
  GestionColumn<CursoEntity>(
    label: 'Nombre',
    flex: 4,
    sortValue: (CursoEntity c) => c.nombre.toLowerCase(),
    cell: (CursoEntity c) => GestionCellText(c.nombre, bold: true),
  ),
  GestionColumn<CursoEntity>(
    label: 'Tipo',
    flex: 2,
    sortValue: (CursoEntity c) => cursoTipoLabel(c.tipo),
    cell: (CursoEntity c) => CursoTipoDot(tipo: c.tipo),
  ),
  GestionColumn<CursoEntity>(
    label: 'Duración',
    width: 110,
    alignment: Alignment.centerRight,
    sortValue: (CursoEntity c) => c.duracionHoras,
    cell: (CursoEntity c) => GestionCellText('${c.duracionHoras} h'),
  ),
  GestionColumn<CursoEntity>(
    label: 'Certificaciones',
    width: 130,
    alignment: Alignment.centerRight,
    sortValue: (CursoEntity c) => c.certificaciones.length,
    cell: (CursoEntity c) => GestionCellText(
      c.certificaciones.isEmpty ? GestionFormatters.vacio : '${c.certificaciones.length}',
    ),
  ),
  GestionColumn<CursoEntity>(
    label: 'Descripción',
    flex: 4,
    cell: (CursoEntity c) => GestionCellText(GestionFormatters.texto(c.descripcion)),
  ),
  GestionColumn<CursoEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (CursoEntity c) => c.activo ? 0 : 1,
    cell: (CursoEntity c) => CatalogoEstadoDot(activo: c.activo),
  ),
];

/// Filtra cursos por texto (nombre, descripción), tipo y estado
List<CursoEntity> filtrarCursos(
  List<CursoEntity> cursos, {
  required String query,
  required String? tipo,
  required CursoEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return cursos.where((CursoEntity c) {
    final bool matchesSearch = q.isEmpty ||
        c.nombre.toLowerCase().contains(q) ||
        (c.descripcion?.toLowerCase().contains(q) ?? false);
    final bool matchesTipo = tipo == null || c.tipo == tipo;
    final bool matchesEstado = estado == CursoEstadoFiltro.todos ||
        (estado == CursoEstadoFiltro.activos ? c.activo : !c.activo);
    return matchesSearch && matchesTipo && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenCursos(List<CursoEntity> todos, int filtrados) {
  int count(String tipo) => todos.where((CursoEntity c) => c.tipo == tipo).length;
  final int activos = todos.where((CursoEntity c) => c.activo).length;
  return <String>[
    gestionResumenRegistros(todos.length, filtrados),
    '$activos activos',
    'Presenciales ${count(CursoTipo.presencial)}',
    'Online ${count(CursoTipo.online)}',
    'Mixtos ${count(CursoTipo.mixto)}',
  ];
}

/// Imprime el listado de cursos (filtrado y ordenado)
Future<void> imprimirCursos(List<CursoEntity> cursos) {
  return GestionPrint.listado(
    title: 'Catálogo de Cursos',
    headers: const <String>['Nombre', 'Tipo', 'Duración', 'Certificaciones', 'Descripción', 'Estado'],
    rows: cursos
        .map(
          (CursoEntity c) => <String>[
            c.nombre,
            cursoTipoLabel(c.tipo),
            '${c.duracionHoras} h',
            '${c.certificaciones.length}',
            GestionFormatters.texto(c.descripcion),
            if (c.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
