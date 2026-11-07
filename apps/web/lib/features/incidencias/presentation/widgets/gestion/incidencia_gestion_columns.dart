import 'package:ambutrack_core_datasource/incidencias.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat _hora = DateFormat('HH:mm');

/// Fecha y hora "28/10/2026 09:30"
String incidenciaFechaHora(DateTime? value) => value == null
    ? GestionFormatters.vacio
    : '${GestionFormatters.fecha(value)} ${_hora.format(value.toLocal())}';

/// Color asociado a cada categoría
Color incidenciaCategoriaColor(CategoriaIncidencia c) {
  switch (c) {
    case CategoriaIncidencia.servicio:
      return AppColors.primary;
    case CategoriaIncidencia.vehiculo:
      return AppColors.averia;
    case CategoriaIncidencia.personal:
      return AppColors.secondary;
    case CategoriaIncidencia.instalacion:
      return AppColors.warning;
    case CategoriaIncidencia.equipamiento:
      return AppColors.info;
    case CategoriaIncidencia.otro:
      return AppColors.gray500;
  }
}

/// Color asociado a cada prioridad
Color incidenciaPrioridadColor(PrioridadIncidencia p) {
  switch (p) {
    case PrioridadIncidencia.critica:
      return AppColors.error;
    case PrioridadIncidencia.alta:
      return AppColors.highPriority;
    case PrioridadIncidencia.media:
      return AppColors.mediumPriority;
    case PrioridadIncidencia.baja:
      return AppColors.lowPriority;
  }
}

/// Color asociado a cada estado
Color incidenciaEstadoColor(EstadoIncidencia e) {
  switch (e) {
    case EstadoIncidencia.reportada:
      return AppColors.warning;
    case EstadoIncidencia.enProceso:
      return AppColors.info;
    case EstadoIncidencia.resuelta:
      return AppColors.success;
    case EstadoIncidencia.cerrada:
      return AppColors.inactive;
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class IncidenciaCellText extends StatelessWidget {
  const IncidenciaCellText(this.value, {this.bold = false, super.key});

  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == GestionFormatters.vacio;
    return Text(
      value,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: empty ? AppColors.gray300 : null,
      ),
    );
  }
}

/// Columnas de la rejilla de incidencias
final List<GestionColumn<IncidenciaEntity>> incidenciaGestionColumns =
    <GestionColumn<IncidenciaEntity>>[
  GestionColumn<IncidenciaEntity>(
    label: 'Título',
    flex: 4,
    sortValue: (IncidenciaEntity i) => i.titulo.toLowerCase(),
    cell: (IncidenciaEntity i) => IncidenciaCellText(i.titulo, bold: true),
  ),
  GestionColumn<IncidenciaEntity>(
    label: 'Categoría',
    flex: 2,
    sortValue: (IncidenciaEntity i) => i.categoria.displayName,
    cell: (IncidenciaEntity i) => GestionDotLabel(
      label: i.categoria.displayName,
      color: incidenciaCategoriaColor(i.categoria),
    ),
  ),
  GestionColumn<IncidenciaEntity>(
    label: 'Prioridad',
    width: 110,
    sortValue: (IncidenciaEntity i) => i.prioridad.index,
    cell: (IncidenciaEntity i) => GestionDotLabel(
      label: i.prioridad.displayName,
      color: incidenciaPrioridadColor(i.prioridad),
    ),
  ),
  GestionColumn<IncidenciaEntity>(
    label: 'Estado',
    width: 120,
    sortValue: (IncidenciaEntity i) => i.estado.displayName,
    cell: (IncidenciaEntity i) => GestionDotLabel(
      label: i.estado.displayName,
      color: incidenciaEstadoColor(i.estado),
    ),
  ),
  GestionColumn<IncidenciaEntity>(
    label: 'Fecha',
    width: 140,
    sortValue: (IncidenciaEntity i) => i.fechaIncidencia,
    cell: (IncidenciaEntity i) => IncidenciaCellText(incidenciaFechaHora(i.fechaIncidencia)),
  ),
  GestionColumn<IncidenciaEntity>(
    label: 'Vehículo',
    width: 100,
    sortValue: (IncidenciaEntity i) => (i.vehiculoMatricula ?? '').toLowerCase(),
    cell: (IncidenciaEntity i) => IncidenciaCellText(GestionFormatters.texto(i.vehiculoMatricula)),
  ),
  GestionColumn<IncidenciaEntity>(
    label: 'Responsable',
    flex: 2,
    sortValue: (IncidenciaEntity i) => (i.responsableNombre ?? '').toLowerCase(),
    cell: (IncidenciaEntity i) => IncidenciaCellText(GestionFormatters.texto(i.responsableNombre)),
  ),
];

/// Filtra incidencias con los mismos criterios que el BLoC
List<IncidenciaEntity> filtrarIncidencias(List<IncidenciaEntity> items, IncidenciaFilters f) {
  final String q = f.searchQuery.trim().toLowerCase();
  return items.where((IncidenciaEntity i) {
    final bool matchesSearch = q.isEmpty ||
        i.titulo.toLowerCase().contains(q) ||
        (i.descripcion ?? '').toLowerCase().contains(q) ||
        (i.responsableNombre ?? '').toLowerCase().contains(q);
    final bool matchesDesde = f.fechaDesde == null || !i.fechaIncidencia.isBefore(f.fechaDesde!);
    final bool matchesHasta = f.fechaHasta == null || !i.fechaIncidencia.isAfter(f.fechaHasta!);
    return matchesSearch &&
        (f.categoria == null || i.categoria == f.categoria) &&
        (f.prioridad == null || i.prioridad == f.prioridad) &&
        (f.estado == null || i.estado == f.estado) &&
        matchesDesde &&
        matchesHasta;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenIncidencias(List<IncidenciaEntity> todas, int filtradas) {
  int estado(EstadoIncidencia e) => todas.where((IncidenciaEntity i) => i.estado == e).length;
  final int criticas =
      todas.where((IncidenciaEntity i) => i.prioridad == PrioridadIncidencia.critica).length;
  return <String>[
    if (filtradas == todas.length) '${todas.length} registros' else '$filtradas de ${todas.length} registros',
    'Críticas $criticas',
    'Reportadas ${estado(EstadoIncidencia.reportada)}',
    'En proceso ${estado(EstadoIncidencia.enProceso)}',
    'Resueltas ${estado(EstadoIncidencia.resuelta)}',
    'Cerradas ${estado(EstadoIncidencia.cerrada)}',
  ];
}

/// Imprime el listado de incidencias (filtrado y ordenado)
Future<void> imprimirIncidencias(List<IncidenciaEntity> incidencias) {
  return GestionPrint.listado(
    title: 'Incidencias',
    headers: const <String>[
      'Título', 'Categoría', 'Prioridad', 'Estado', 'Fecha', 'Vehículo', 'Responsable', 'Reportado por',
    ],
    rows: incidencias
        .map(
          (IncidenciaEntity i) => <String>[
            i.titulo,
            i.categoria.displayName,
            i.prioridad.displayName,
            i.estado.displayName,
            incidenciaFechaHora(i.fechaIncidencia),
            GestionFormatters.texto(i.vehiculoMatricula),
            GestionFormatters.texto(i.responsableNombre),
            GestionFormatters.texto(i.reportadoPorNombre),
          ],
        )
        .toList(),
  );
}
