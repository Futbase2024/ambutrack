import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado del pendiente
enum AgendaEstadoFiltro { todos, pendientes, completados }

/// Filtro por fecha del pendiente
enum AgendaFechaFiltro { todas, hoy, proximas, anteriores }

DateTime _soloDia(DateTime d) {
  final DateTime l = d.toLocal();
  return DateTime(l.year, l.month, l.day);
}

/// Indica si el pendiente es para hoy
bool agendaEsHoy(AgendaPendienteEntity p) => _soloDia(p.fecha) == _soloDia(DateTime.now());

/// Indicador de estado Pendiente / Completado
class AgendaEstadoDot extends StatelessWidget {
  const AgendaEstadoDot({required this.completado, super.key});

  final bool completado;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: completado ? 'Completado' : 'Pendiente',
      color: completado ? AppColors.success : AppColors.warning,
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class AgendaCellText extends StatelessWidget {
  const AgendaCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de la agenda de pendientes
final List<GestionColumn<AgendaPendienteEntity>> agendaGestionColumns =
    <GestionColumn<AgendaPendienteEntity>>[
  GestionColumn<AgendaPendienteEntity>(
    label: 'Fecha',
    width: 100,
    sortValue: (AgendaPendienteEntity p) => p.fecha,
    cell: (AgendaPendienteEntity p) => AgendaCellText(GestionFormatters.fecha(p.fecha)),
  ),
  GestionColumn<AgendaPendienteEntity>(
    label: 'Nombre y apellidos',
    flex: 3,
    sortValue: (AgendaPendienteEntity p) => p.nombreApellidos.toLowerCase(),
    cell: (AgendaPendienteEntity p) => AgendaCellText(p.nombreApellidos, bold: true),
  ),
  GestionColumn<AgendaPendienteEntity>(
    label: 'Domicilio',
    flex: 3,
    sortValue: (AgendaPendienteEntity p) => (p.domicilio ?? '').toLowerCase(),
    cell: (AgendaPendienteEntity p) => AgendaCellText(GestionFormatters.texto(p.domicilio)),
  ),
  GestionColumn<AgendaPendienteEntity>(
    label: 'Localidad',
    flex: 2,
    sortValue: (AgendaPendienteEntity p) => (p.localidad ?? '').toLowerCase(),
    cell: (AgendaPendienteEntity p) => AgendaCellText(GestionFormatters.texto(p.localidad)),
  ),
  GestionColumn<AgendaPendienteEntity>(
    label: 'Descripción',
    flex: 4,
    cell: (AgendaPendienteEntity p) => Tooltip(
      message: p.descripcion,
      waitDuration: const Duration(milliseconds: 500),
      child: AgendaCellText(GestionFormatters.texto(p.descripcion)),
    ),
  ),
  GestionColumn<AgendaPendienteEntity>(
    label: 'Estado',
    width: 120,
    sortValue: (AgendaPendienteEntity p) => p.completado ? 1 : 0,
    cell: (AgendaPendienteEntity p) => AgendaEstadoDot(completado: p.completado),
  ),
];

/// Filtra pendientes por texto (nombre, domicilio, localidad, descripción), estado y fecha
List<AgendaPendienteEntity> filtrarAgenda(
  List<AgendaPendienteEntity> pendientes, {
  required String query,
  required AgendaEstadoFiltro estado,
  required AgendaFechaFiltro fecha,
}) {
  final String q = query.trim().toLowerCase();
  final DateTime hoy = _soloDia(DateTime.now());
  return pendientes.where((AgendaPendienteEntity p) {
    final bool matchesSearch = q.isEmpty ||
        p.nombreApellidos.toLowerCase().contains(q) ||
        (p.domicilio?.toLowerCase().contains(q) ?? false) ||
        (p.localidad?.toLowerCase().contains(q) ?? false) ||
        p.descripcion.toLowerCase().contains(q);
    final bool matchesEstado = estado == AgendaEstadoFiltro.todos ||
        (estado == AgendaEstadoFiltro.completados ? p.completado : !p.completado);
    final DateTime dia = _soloDia(p.fecha);
    final bool matchesFecha = switch (fecha) {
      AgendaFechaFiltro.todas => true,
      AgendaFechaFiltro.hoy => dia == hoy,
      AgendaFechaFiltro.proximas => dia.isAfter(hoy),
      AgendaFechaFiltro.anteriores => dia.isBefore(hoy),
    };
    return matchesSearch && matchesEstado && matchesFecha;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenAgenda(List<AgendaPendienteEntity> todos, int filtrados, int pendientesHoy) {
  final int completados = todos.where((AgendaPendienteEntity p) => p.completado).length;
  return <String>[
    if (filtrados == todos.length) '${todos.length} registros' else '$filtrados de ${todos.length} registros',
    'Pendientes ${todos.length - completados}',
    'Completados $completados',
    'Para hoy $pendientesHoy',
  ];
}

/// Imprime el listado de pendientes (filtrado y ordenado)
Future<void> imprimirAgenda(List<AgendaPendienteEntity> pendientes) {
  return GestionPrint.listado(
    title: 'Agenda de Pendientes',
    headers: const <String>['Fecha', 'Nombre y apellidos', 'Domicilio', 'Localidad', 'Descripción', 'Estado'],
    rows: pendientes
        .map(
          (AgendaPendienteEntity p) => <String>[
            GestionFormatters.fecha(p.fecha),
            p.nombreApellidos,
            GestionFormatters.texto(p.domicilio),
            GestionFormatters.texto(p.localidad),
            GestionFormatters.texto(p.descripcion),
            if (p.completado) 'Completado' else 'Pendiente',
          ],
        )
        .toList(),
  );
}
