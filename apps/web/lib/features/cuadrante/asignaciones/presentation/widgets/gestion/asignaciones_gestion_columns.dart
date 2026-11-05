import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/gestion/asignaciones_catalogos.dart';
import 'package:flutter/material.dart';

/// Estados filtrables (valor → texto)
const Map<String, String> asignacionEstados = <String, String>{
  'planificada': 'Planificada',
  'confirmada': 'Confirmada',
  'en_curso': 'En curso',
  'completada': 'Completada',
  'cancelada': 'Cancelada',
};

String asignacionEstadoLabel(String estado) {
  final String e = estado.toLowerCase();
  return asignacionEstados[e == 'finalizada' ? 'completada' : e] ?? estado;
}

Color asignacionEstadoColor(String estado) {
  switch (estado.toLowerCase()) {
    case 'planificada':
      return AppColors.info;
    case 'confirmada':
      return AppColors.success;
    case 'en_curso':
      return AppColors.warning;
    case 'cancelada':
      return AppColors.error;
    default:
      return AppColors.gray400;
  }
}

/// Km recorridos (null si no hay lectura inicial y final)
double? asignacionKm(AsignacionVehiculoTurnoEntity a) =>
    a.kmInicial != null && a.kmFinal != null ? a.kmFinal! - a.kmInicial! : null;

String asignacionKmTexto(AsignacionVehiculoTurnoEntity a) {
  final double? km = asignacionKm(a);
  return km == null ? GestionFormatters.vacio : km.toStringAsFixed(0);
}

String asignacionHorasTexto(AsignacionVehiculoTurnoEntity a) =>
    a.horasEfectivas == null ? GestionFormatters.vacio : '${a.horasEfectivas!.toStringAsFixed(1)} h';

/// Indicador de estado
class AsignacionEstadoDot extends StatelessWidget {
  const AsignacionEstadoDot({required this.estado, super.key});

  final String estado;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(label: asignacionEstadoLabel(estado), color: asignacionEstadoColor(estado));
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class AsignacionCellText extends StatelessWidget {
  const AsignacionCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de asignaciones
List<GestionColumn<AsignacionVehiculoTurnoEntity>> asignacionesGestionColumns(AsignacionesCatalogos cat) {
  return <GestionColumn<AsignacionVehiculoTurnoEntity>>[
    GestionColumn<AsignacionVehiculoTurnoEntity>(
      label: 'Fecha',
      width: 100,
      sortValue: (AsignacionVehiculoTurnoEntity a) => a.fecha.millisecondsSinceEpoch,
      cell: (AsignacionVehiculoTurnoEntity a) => AsignacionCellText(GestionFormatters.fecha(a.fecha)),
    ),
    GestionColumn<AsignacionVehiculoTurnoEntity>(
      label: 'Vehículo',
      flex: 2,
      sortValue: (AsignacionVehiculoTurnoEntity a) => cat.vehiculo(a).toLowerCase(),
      cell: (AsignacionVehiculoTurnoEntity a) => AsignacionCellText(cat.vehiculo(a), bold: true),
    ),
    GestionColumn<AsignacionVehiculoTurnoEntity>(
      label: 'Dotación',
      flex: 3,
      sortValue: (AsignacionVehiculoTurnoEntity a) => cat.dotacion(a).toLowerCase(),
      cell: (AsignacionVehiculoTurnoEntity a) => AsignacionCellText(cat.dotacion(a)),
    ),
    GestionColumn<AsignacionVehiculoTurnoEntity>(
      label: 'Turno',
      flex: 2,
      sortValue: (AsignacionVehiculoTurnoEntity a) => (cat.turno(a) ?? '').toLowerCase(),
      cell: (AsignacionVehiculoTurnoEntity a) => AsignacionCellText(GestionFormatters.texto(cat.turno(a))),
    ),
    GestionColumn<AsignacionVehiculoTurnoEntity>(
      label: 'Destino',
      flex: 3,
      sortValue: (AsignacionVehiculoTurnoEntity a) => (cat.destino(a) ?? '').toLowerCase(),
      cell: (AsignacionVehiculoTurnoEntity a) => AsignacionCellText(
        cat.destino(a) == null ? GestionFormatters.vacio : '${a.tipoDestino} · ${cat.destino(a)}',
      ),
    ),
    GestionColumn<AsignacionVehiculoTurnoEntity>(
      label: 'Estado',
      width: 120,
      sortValue: (AsignacionVehiculoTurnoEntity a) => asignacionEstadoLabel(a.estado),
      cell: (AsignacionVehiculoTurnoEntity a) => AsignacionEstadoDot(estado: a.estado),
    ),
    GestionColumn<AsignacionVehiculoTurnoEntity>(
      label: 'Km',
      width: 80,
      alignment: Alignment.centerRight,
      sortValue: (AsignacionVehiculoTurnoEntity a) => asignacionKm(a) ?? -1,
      cell: (AsignacionVehiculoTurnoEntity a) => AsignacionCellText(asignacionKmTexto(a)),
    ),
    GestionColumn<AsignacionVehiculoTurnoEntity>(
      label: 'Servicios',
      width: 80,
      alignment: Alignment.centerRight,
      sortValue: (AsignacionVehiculoTurnoEntity a) => a.serviciosRealizados ?? 0,
      cell: (AsignacionVehiculoTurnoEntity a) => AsignacionCellText('${a.serviciosRealizados ?? 0}'),
    ),
    GestionColumn<AsignacionVehiculoTurnoEntity>(
      label: 'Horas',
      width: 80,
      alignment: Alignment.centerRight,
      sortValue: (AsignacionVehiculoTurnoEntity a) => a.horasEfectivas ?? -1,
      cell: (AsignacionVehiculoTurnoEntity a) => AsignacionCellText(asignacionHorasTexto(a)),
    ),
  ];
}

/// Filtra por texto (vehículo, dotación, destino, turno — nombre o ID) y estado
List<AsignacionVehiculoTurnoEntity> filtrarAsignaciones(
  List<AsignacionVehiculoTurnoEntity> items,
  AsignacionesCatalogos cat, {
  required String query,
  required String? estado,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((AsignacionVehiculoTurnoEntity a) {
    final List<String?> campos = <String?>[
      a.vehiculoId, cat.vehiculo(a), a.dotacionId, cat.dotacion(a),
      a.hospitalId, a.baseId, cat.destino(a), a.plantillaTurnoId, cat.turno(a),
    ];
    final bool matchesSearch =
        q.isEmpty || campos.any((String? c) => c?.toLowerCase().contains(q) ?? false);
    final String e = a.estado.toLowerCase() == 'finalizada' ? 'completada' : a.estado.toLowerCase();
    final bool matchesEstado = estado == null || e == estado;
    return matchesSearch && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenAsignaciones(List<AsignacionVehiculoTurnoEntity> todas, int filtradas) {
  int count(String e) => todas.where((AsignacionVehiculoTurnoEntity a) => a.estado.toLowerCase() == e).length;
  return <String>[
    if (filtradas == todas.length) '${todas.length} registros' else '$filtradas de ${todas.length} registros',
    'Planificadas ${count('planificada')}',
    'Confirmadas ${count('confirmada')}',
    'En curso ${count('en_curso')}',
    'Canceladas ${count('cancelada')}',
  ];
}

/// Imprime el listado (filtrado y ordenado)
Future<void> imprimirAsignaciones(
  List<AsignacionVehiculoTurnoEntity> items,
  AsignacionesCatalogos cat,
  DateTime fecha,
) {
  return GestionPrint.listado(
    title: 'Asignaciones de vehículos',
    subtitle: 'Fecha: ${GestionFormatters.fecha(fecha)}',
    headers: const <String>[
      'Fecha', 'Vehículo', 'Dotación', 'Turno', 'Destino', 'Estado', 'Km', 'Servicios', 'Horas',
    ],
    rows: items
        .map(
          (AsignacionVehiculoTurnoEntity a) => <String>[
            GestionFormatters.fecha(a.fecha),
            cat.vehiculo(a),
            cat.dotacion(a),
            GestionFormatters.texto(cat.turno(a)),
            GestionFormatters.texto(cat.destino(a)),
            asignacionEstadoLabel(a.estado),
            asignacionKmTexto(a),
            '${a.serviciosRealizados ?? 0}',
            asignacionHorasTexto(a),
          ],
        )
        .toList(),
  );
}
