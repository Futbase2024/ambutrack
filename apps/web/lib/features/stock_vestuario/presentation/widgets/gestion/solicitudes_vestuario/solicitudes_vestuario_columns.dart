import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Filtro rápido por estado
enum SolicitudVestuarioFiltro { abiertas, todas }

final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm');

/// Fecha/hora de la solicitud (created_at)
String solicitudFecha(SolicitudVestuarioEntity s) =>
    s.createdAt == null ? GestionFormatters.vacio : _fechaHora.format(s.createdAt!.toLocal());

String fechaHoraVestuario(DateTime? value) =>
    value == null ? GestionFormatters.vacio : _fechaHora.format(value.toLocal());

/// Etiqueta corta del tipo (para la rejilla)
String tipoSolicitudCorto(TipoSolicitudVestuario t) {
  switch (t) {
    case TipoSolicitudVestuario.nueva:
      return 'Nueva';
    case TipoSolicitudVestuario.reposicion:
      return 'Reposición';
    case TipoSolicitudVestuario.cambioTalla:
      return 'Cambio de talla';
    case TipoSolicitudVestuario.devolucion:
      return 'Devolución';
  }
}

/// Color del estado de la solicitud
Color estadoSolicitudColor(EstadoSolicitudVestuario e) {
  switch (e) {
    case EstadoSolicitudVestuario.pendiente:
      return AppColors.warning;
    case EstadoSolicitudVestuario.aprobada:
      return AppColors.info;
    case EstadoSolicitudVestuario.entregada:
      return AppColors.success;
    case EstadoSolicitudVestuario.rechazada:
      return AppColors.error;
    case EstadoSolicitudVestuario.cancelada:
      return AppColors.gray500;
  }
}

/// Badge ajustado al ancho del texto
class SolicitudVestuarioBadge extends StatelessWidget {
  const SolicitudVestuarioBadge({required this.label, required this.color, this.inCell = true, super.key});

  final String label;
  final Color color;

  /// En celdas de tabla se alinea a la izquierda (Align + IntrinsicWidth)
  final bool inCell;

  @override
  Widget build(BuildContext context) {
    final Widget badge = IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
        ),
      ),
    );
    return inCell ? Align(alignment: Alignment.centerLeft, child: badge) : badge;
  }
}

/// Badge del estado de la solicitud
class SolicitudEstadoBadge extends StatelessWidget {
  const SolicitudEstadoBadge({required this.estado, this.inCell = true, super.key});

  final EstadoSolicitudVestuario estado;
  final bool inCell;

  @override
  Widget build(BuildContext context) {
    return SolicitudVestuarioBadge(label: estado.label, color: estadoSolicitudColor(estado), inCell: inCell);
  }
}

/// Texto de celda (gris si está vacío)
class SolicitudCellText extends StatelessWidget {
  const SolicitudCellText(this.value, {this.bold = false, super.key});

  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: value == GestionFormatters.vacio ? AppColors.gray300 : null,
      ),
    );
  }
}

/// Columnas de la rejilla de solicitudes de vestuario
final List<GestionColumn<SolicitudVestuarioEntity>> solicitudesVestuarioColumns =
    <GestionColumn<SolicitudVestuarioEntity>>[
  GestionColumn<SolicitudVestuarioEntity>(
    label: 'Fecha',
    width: 140,
    sortValue: (SolicitudVestuarioEntity s) => s.createdAt ?? DateTime(2000),
    cell: (SolicitudVestuarioEntity s) => SolicitudCellText(solicitudFecha(s)),
  ),
  GestionColumn<SolicitudVestuarioEntity>(
    label: 'Trabajador',
    flex: 3,
    filterValue: (SolicitudVestuarioEntity s) => s.personalNombre ?? '',
    sortValue: (SolicitudVestuarioEntity s) => (s.personalNombre ?? '').toLowerCase(),
    cell: (SolicitudVestuarioEntity s) => SolicitudCellText(GestionFormatters.texto(s.personalNombre), bold: true),
  ),
  GestionColumn<SolicitudVestuarioEntity>(
    label: 'Tipo',
    width: 130,
    filterValue: (SolicitudVestuarioEntity s) => tipoSolicitudCorto(s.tipo),
    sortValue: (SolicitudVestuarioEntity s) => s.tipo.index,
    cell: (SolicitudVestuarioEntity s) => SolicitudCellText(tipoSolicitudCorto(s.tipo)),
  ),
  GestionColumn<SolicitudVestuarioEntity>(
    label: 'Prenda',
    flex: 2,
    filterValue: (SolicitudVestuarioEntity s) => s.prenda,
    sortValue: (SolicitudVestuarioEntity s) => s.prenda.toLowerCase(),
    cell: (SolicitudVestuarioEntity s) => SolicitudCellText(GestionFormatters.texto(s.prenda)),
  ),
  GestionColumn<SolicitudVestuarioEntity>(
    label: 'Talla',
    width: 80,
    filterValue: (SolicitudVestuarioEntity s) => s.talla ?? '',
    sortValue: (SolicitudVestuarioEntity s) => s.talla ?? '',
    cell: (SolicitudVestuarioEntity s) => SolicitudCellText(GestionFormatters.texto(s.talla)),
  ),
  GestionColumn<SolicitudVestuarioEntity>(
    label: 'Cant.',
    width: 70,
    sortValue: (SolicitudVestuarioEntity s) => s.cantidad,
    cell: (SolicitudVestuarioEntity s) => SolicitudCellText('${s.cantidad}'),
  ),
  GestionColumn<SolicitudVestuarioEntity>(
    label: 'Estado',
    width: 115,
    filterValue: (SolicitudVestuarioEntity s) => s.estado.label,
    sortValue: (SolicitudVestuarioEntity s) => s.estado.index,
    cell: (SolicitudVestuarioEntity s) => SolicitudEstadoBadge(estado: s.estado),
  ),
];

/// Filtra por texto (trabajador, prenda, talla, motivo) y por estado rápido
List<SolicitudVestuarioEntity> filtrarSolicitudesVestuario(
  List<SolicitudVestuarioEntity> solicitudes, {
  required String query,
  required SolicitudVestuarioFiltro filtro,
}) {
  final String q = query.trim().toLowerCase();
  return solicitudes.where((SolicitudVestuarioEntity s) {
    final bool matchesSearch = q.isEmpty ||
        <String?>[s.personalNombre, s.prenda, s.talla, s.motivo]
            .any((String? v) => v?.toLowerCase().contains(q) ?? false);
    final bool matchesFiltro = filtro == SolicitudVestuarioFiltro.todas || s.estado.abierta;
    return matchesSearch && matchesFiltro;
  }).toList();
}

int _contar(List<SolicitudVestuarioEntity> l, EstadoSolicitudVestuario e) =>
    l.where((SolicitudVestuarioEntity s) => s.estado == e).length;

/// Resumen para la barra de estado
List<String> resumenSolicitudesVestuario(List<SolicitudVestuarioEntity> todas, int filtradas) {
  return <String>[
    if (filtradas == todas.length) '${todas.length} solicitudes' else '$filtradas de ${todas.length} solicitudes',
    'Pendientes ${_contar(todas, EstadoSolicitudVestuario.pendiente)}',
    'Aprobadas ${_contar(todas, EstadoSolicitudVestuario.aprobada)}',
    'Entregadas ${_contar(todas, EstadoSolicitudVestuario.entregada)}',
  ];
}

/// Imprime el listado de solicitudes (filtrado y ordenado)
Future<void> imprimirSolicitudesVestuario(List<SolicitudVestuarioEntity> solicitudes) {
  return GestionPrint.listado(
    title: 'Solicitudes de vestuario',
    headers: const <String>['Fecha', 'Trabajador', 'Tipo', 'Prenda', 'Talla', 'Cant.', 'Estado'],
    rows: solicitudes
        .map(
          (SolicitudVestuarioEntity s) => <String>[
            solicitudFecha(s),
            GestionFormatters.texto(s.personalNombre),
            tipoSolicitudCorto(s.tipo),
            GestionFormatters.texto(s.prenda),
            GestionFormatters.texto(s.talla),
            '${s.cantidad}',
            s.estado.label,
          ],
        )
        .toList(),
  );
}
