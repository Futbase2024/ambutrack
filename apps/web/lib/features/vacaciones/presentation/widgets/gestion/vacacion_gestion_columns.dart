import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';

/// Estados posibles de una solicitud de vacaciones
const List<String> vacacionEstados = <String>['pendiente', 'aprobada', 'rechazada', 'cancelada'];

/// Etiqueta visible del estado ("pendiente" → "Pendiente")
String vacacionEstadoLabel(String estado) {
  if (estado.isEmpty) {
    return GestionFormatters.vacio;
  }
  return '${estado[0].toUpperCase()}${estado.substring(1)}';
}

/// Color asociado a cada estado
Color vacacionEstadoColor(String estado) {
  switch (estado) {
    case 'aprobada':
      return AppColors.success;
    case 'pendiente':
      return AppColors.warning;
    case 'rechazada':
      return AppColors.error;
    case 'cancelada':
      return AppColors.inactive;
    default:
      return AppColors.gray400;
  }
}

/// Resuelve el nombre del personal a partir de su id
String vacacionNombre(Map<String, PersonalEntity> personal, String idPersonal) =>
    GestionFormatters.texto(personal[idPersonal]?.nombreCompleto);

/// Resuelve el nombre del aprobador a partir del id de personal (o de usuario).
/// Si no se encuentra, devuelve el valor original.
String? vacacionAprobador(Map<String, PersonalEntity> personal, String? id) {
  if (id == null || id.trim().isEmpty) {
    return null;
  }
  final PersonalEntity? p = personal[id] ??
      personal.values.where((PersonalEntity e) => e.usuarioId == id).firstOrNull;
  return p?.nombreCompleto ?? id;
}

/// Indicador de estado de la vacación
class VacacionEstadoDot extends StatelessWidget {
  const VacacionEstadoDot({required this.estado, this.fontSize = 12.5, super.key});

  final String estado;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: vacacionEstadoLabel(estado),
      color: vacacionEstadoColor(estado),
      fontSize: fontSize,
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class VacacionCellText extends StatelessWidget {
  const VacacionCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de vacaciones
List<GestionColumn<VacacionesEntity>> vacacionGestionColumns(Map<String, PersonalEntity> personal) {
  return <GestionColumn<VacacionesEntity>>[
    GestionColumn<VacacionesEntity>(
      label: 'Personal',
      flex: 4,
      sortValue: (VacacionesEntity v) => vacacionNombre(personal, v.idPersonal).toLowerCase(),
      cell: (VacacionesEntity v) => VacacionCellText(vacacionNombre(personal, v.idPersonal), bold: true),
    ),
    GestionColumn<VacacionesEntity>(
      label: 'Inicio',
      width: 100,
      sortValue: (VacacionesEntity v) => v.fechaInicio,
      cell: (VacacionesEntity v) => VacacionCellText(GestionFormatters.fecha(v.fechaInicio)),
    ),
    GestionColumn<VacacionesEntity>(
      label: 'Fin',
      width: 100,
      sortValue: (VacacionesEntity v) => v.fechaFin,
      cell: (VacacionesEntity v) => VacacionCellText(GestionFormatters.fecha(v.fechaFin)),
    ),
    GestionColumn<VacacionesEntity>(
      label: 'Días',
      width: 70,
      alignment: Alignment.centerRight,
      sortValue: (VacacionesEntity v) => v.diasSolicitados,
      cell: (VacacionesEntity v) => VacacionCellText('${v.diasSolicitados}'),
    ),
    GestionColumn<VacacionesEntity>(
      label: 'Estado',
      width: 120,
      sortValue: (VacacionesEntity v) => v.estado,
      cell: (VacacionesEntity v) => VacacionEstadoDot(estado: v.estado),
    ),
    GestionColumn<VacacionesEntity>(
      label: 'Solicitud',
      width: 100,
      sortValue: (VacacionesEntity v) => v.fechaSolicitud ?? DateTime(0),
      cell: (VacacionesEntity v) => VacacionCellText(GestionFormatters.fecha(v.fechaSolicitud)),
    ),
    GestionColumn<VacacionesEntity>(
      label: 'Observaciones',
      flex: 3,
      cell: (VacacionesEntity v) => VacacionCellText(GestionFormatters.texto(v.observaciones)),
    ),
  ];
}

/// Filtra vacaciones por texto (personal, observaciones, fechas) y estado
List<VacacionesEntity> filtrarVacaciones(
  List<VacacionesEntity> vacaciones, {
  required Map<String, PersonalEntity> personal,
  required String query,
  required String? estado,
}) {
  final String q = query.trim().toLowerCase();
  return vacaciones.where((VacacionesEntity v) {
    final bool matchesSearch = q.isEmpty ||
        vacacionNombre(personal, v.idPersonal).toLowerCase().contains(q) ||
        (v.observaciones?.toLowerCase().contains(q) ?? false) ||
        GestionFormatters.fecha(v.fechaInicio).contains(q) ||
        GestionFormatters.fecha(v.fechaFin).contains(q);
    final bool matchesEstado = estado == null || v.estado == estado;
    return matchesSearch && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenVacaciones(List<VacacionesEntity> todas, int filtradas) {
  int count(String e) => todas.where((VacacionesEntity v) => v.estado == e).length;
  final int dias = todas.fold<int>(0, (int sum, VacacionesEntity v) => sum + v.diasSolicitados);
  return <String>[
    if (filtradas == todas.length)
      '${todas.length} registros'
    else
      '$filtradas de ${todas.length} registros',
    'Pendientes ${count('pendiente')}',
    'Aprobadas ${count('aprobada')}',
    'Rechazadas ${count('rechazada')}',
    '$dias días',
  ];
}

/// Imprime el listado de vacaciones (filtrado y ordenado)
Future<void> imprimirVacaciones(
  List<VacacionesEntity> vacaciones,
  Map<String, PersonalEntity> personal,
  int year,
) {
  return GestionPrint.listado(
    title: 'Vacaciones del personal',
    subtitle: 'Año $year',
    headers: const <String>['Personal', 'Inicio', 'Fin', 'Días', 'Estado', 'Solicitud', 'Observaciones'],
    rows: vacaciones
        .map(
          (VacacionesEntity v) => <String>[
            vacacionNombre(personal, v.idPersonal),
            GestionFormatters.fecha(v.fechaInicio),
            GestionFormatters.fecha(v.fechaFin),
            '${v.diasSolicitados}',
            vacacionEstadoLabel(v.estado),
            GestionFormatters.fecha(v.fechaSolicitud),
            GestionFormatters.texto(v.observaciones),
          ],
        )
        .toList(),
  );
}
