import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado de la especialidad
enum EspecialidadEstadoFiltro { todos, activas, inactivas }

/// Tipos de especialidad disponibles (mismos valores que el formulario)
const Map<String, String> especialidadTipos = <String, String>{
  'medica': 'Médica',
  'quirurgica': 'Quirúrgica',
  'diagnostica': 'Diagnóstica',
  'apoyo': 'Apoyo',
  'enfermeria': 'Enfermería',
  'tecnica': 'Técnica',
};

/// Etiqueta legible del tipo de especialidad
String especialidadTipoLabel(String tipo) => especialidadTipos[tipo] ?? GestionFormatters.texto(tipo);

/// Color asociado a cada tipo de especialidad
Color especialidadTipoColor(String tipo) {
  switch (tipo) {
    case 'medica':
      return AppColors.primary;
    case 'quirurgica':
      return AppColors.emergency;
    case 'diagnostica':
      return AppColors.info;
    case 'apoyo':
      return AppColors.warning;
    case 'enfermeria':
      return AppColors.secondary;
    case 'tecnica':
      return AppColors.gray600;
    default:
      return AppColors.gray400;
  }
}

/// Indicador de estado activa/inactiva
class EspecialidadEstadoDot extends StatelessWidget {
  const EspecialidadEstadoDot({required this.activo, super.key});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: activo ? 'Activa' : 'Inactiva',
      color: activo ? AppColors.success : AppColors.inactive,
    );
  }
}

/// Indicador del tipo de especialidad
class EspecialidadTipoDot extends StatelessWidget {
  const EspecialidadTipoDot({required this.tipo, super.key});

  final String tipo;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(label: especialidadTipoLabel(tipo), color: especialidadTipoColor(tipo));
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class EspecialidadCellText extends StatelessWidget {
  const EspecialidadCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de especialidades médicas
final List<GestionColumn<EspecialidadEntity>> especialidadGestionColumns =
    <GestionColumn<EspecialidadEntity>>[
  GestionColumn<EspecialidadEntity>(
    label: 'Nombre',
    flex: 3,
    sortValue: (EspecialidadEntity e) => e.nombre.toLowerCase(),
    cell: (EspecialidadEntity e) => EspecialidadCellText(e.nombre, bold: true),
  ),
  GestionColumn<EspecialidadEntity>(
    label: 'Tipo',
    flex: 2,
    sortValue: (EspecialidadEntity e) => especialidadTipoLabel(e.tipoEspecialidad),
    cell: (EspecialidadEntity e) => EspecialidadTipoDot(tipo: e.tipoEspecialidad),
  ),
  GestionColumn<EspecialidadEntity>(
    label: 'Descripción',
    flex: 4,
    sortValue: (EspecialidadEntity e) => (e.descripcion ?? '').toLowerCase(),
    cell: (EspecialidadEntity e) => EspecialidadCellText(GestionFormatters.texto(e.descripcion)),
  ),
  GestionColumn<EspecialidadEntity>(
    label: 'Certificación',
    width: 110,
    sortValue: (EspecialidadEntity e) => e.requiereCertificacion ? 0 : 1,
    cell: (EspecialidadEntity e) => EspecialidadCellText(e.requiereCertificacion ? 'Requerida' : 'No'),
  ),
  GestionColumn<EspecialidadEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (EspecialidadEntity e) => e.activo ? 0 : 1,
    cell: (EspecialidadEntity e) => EspecialidadEstadoDot(activo: e.activo),
  ),
];

/// Filtra especialidades por texto (nombre, descripción), tipo y estado
List<EspecialidadEntity> filtrarEspecialidades(
  List<EspecialidadEntity> especialidades, {
  required String query,
  required String? tipo,
  required EspecialidadEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return especialidades.where((EspecialidadEntity e) {
    final bool matchesSearch = q.isEmpty ||
        e.nombre.toLowerCase().contains(q) ||
        (e.descripcion?.toLowerCase().contains(q) ?? false);
    final bool matchesTipo = tipo == null || e.tipoEspecialidad == tipo;
    final bool matchesEstado = estado == EspecialidadEstadoFiltro.todos ||
        (estado == EspecialidadEstadoFiltro.activas ? e.activo : !e.activo);
    return matchesSearch && matchesTipo && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenEspecialidades(List<EspecialidadEntity> todos, int filtrados) {
  final int activas = todos.where((EspecialidadEntity e) => e.activo).length;
  final int certificacion = todos.where((EspecialidadEntity e) => e.requiereCertificacion).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$activas activas',
    '${todos.length - activas} inactivas',
    '$certificacion con certificación',
  ];
}

/// Imprime el listado de especialidades (filtrado y ordenado)
Future<void> imprimirEspecialidades(List<EspecialidadEntity> especialidades) {
  return GestionPrint.listado(
    title: 'Especialidades Médicas',
    headers: const <String>['Nombre', 'Tipo', 'Descripción', 'Certificación', 'Estado'],
    rows: especialidades
        .map(
          (EspecialidadEntity e) => <String>[
            e.nombre,
            especialidadTipoLabel(e.tipoEspecialidad),
            GestionFormatters.texto(e.descripcion),
            if (e.requiereCertificacion) 'Requerida' else 'No',
            if (e.activo) 'Activa' else 'Inactiva',
          ],
        )
        .toList(),
  );
}
