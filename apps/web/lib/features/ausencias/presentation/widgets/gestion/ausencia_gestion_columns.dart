import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';

/// Datos auxiliares para resolver nombres de personal y tipos de ausencia
class AusenciaLookup {
  const AusenciaLookup({required this.personal, required this.tipos});

  final Map<String, PersonalEntity> personal;
  final Map<String, TipoAusenciaEntity> tipos;

  /// Nombre completo del trabajador (o marcador de vacío si no se conoce)
  String nombre(String idPersonal) =>
      GestionFormatters.texto(personal[idPersonal]?.nombreCompleto);

  TipoAusenciaEntity? tipo(String idTipo) => tipos[idTipo];

  String tipoNombre(String idTipo) => GestionFormatters.texto(tipos[idTipo]?.nombre);

  /// Nombre de quien aprobó (id de personal o, en registros antiguos, id de usuario).
  /// Si no se encuentra, devuelve el valor original.
  String? aprobador(String? id) => nombreAprobador(personal, id);
}

/// Resuelve el nombre del aprobador a partir del id de personal (o de usuario)
String? nombreAprobador(Map<String, PersonalEntity> personal, String? id) {
  if (id == null || id.trim().isEmpty) {
    return null;
  }
  final PersonalEntity? p = personal[id] ??
      personal.values.where((PersonalEntity e) => e.usuarioId == id).firstOrNull;
  return p?.nombreCompleto ?? id;
}

/// Etiqueta visible de cada estado
String ausenciaEstadoLabel(EstadoAusencia estado) => estado.toJson();

/// Color asociado a cada estado
Color ausenciaEstadoColor(EstadoAusencia estado) {
  switch (estado) {
    case EstadoAusencia.pendiente:
      return AppColors.warning;
    case EstadoAusencia.aprobada:
      return AppColors.success;
    case EstadoAusencia.rechazada:
      return AppColors.error;
    case EstadoAusencia.cancelada:
      return AppColors.inactive;
  }
}

/// Color del tipo de ausencia (configurado en la tabla maestra en formato #RRGGBB)
Color tipoAusenciaColor(TipoAusenciaEntity? tipo) {
  if (tipo == null) {
    return AppColors.gray400;
  }
  final String hex = tipo.color.replaceFirst('#', '');
  final int? value = int.tryParse(hex, radix: 16);
  if (value == null) {
    return AppColors.gray400;
  }
  return Color(hex.length <= 6 ? 0xFF000000 | value : value);
}

/// Indicador de estado de la ausencia
class AusenciaEstadoDot extends StatelessWidget {
  const AusenciaEstadoDot({required this.estado, super.key});

  final EstadoAusencia estado;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: ausenciaEstadoLabel(estado),
      color: ausenciaEstadoColor(estado),
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class AusenciaCellText extends StatelessWidget {
  const AusenciaCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de ausencias
List<GestionColumn<AusenciaEntity>> ausenciaGestionColumns(AusenciaLookup lookup) {
  return <GestionColumn<AusenciaEntity>>[
    GestionColumn<AusenciaEntity>(
      label: 'Personal',
      flex: 4,
      sortValue: (AusenciaEntity a) => lookup.nombre(a.idPersonal).toLowerCase(),
      cell: (AusenciaEntity a) => AusenciaCellText(lookup.nombre(a.idPersonal), bold: true),
    ),
    GestionColumn<AusenciaEntity>(
      label: 'Tipo',
      flex: 3,
      sortValue: (AusenciaEntity a) => lookup.tipoNombre(a.idTipoAusencia).toLowerCase(),
      cell: (AusenciaEntity a) => GestionDotLabel(
        label: lookup.tipoNombre(a.idTipoAusencia),
        color: tipoAusenciaColor(lookup.tipo(a.idTipoAusencia)),
      ),
    ),
    GestionColumn<AusenciaEntity>(
      label: 'Inicio',
      width: 100,
      sortValue: (AusenciaEntity a) => a.fechaInicio,
      cell: (AusenciaEntity a) => AusenciaCellText(GestionFormatters.fecha(a.fechaInicio)),
    ),
    GestionColumn<AusenciaEntity>(
      label: 'Fin',
      width: 100,
      sortValue: (AusenciaEntity a) => a.fechaFin,
      cell: (AusenciaEntity a) => AusenciaCellText(GestionFormatters.fecha(a.fechaFin)),
    ),
    GestionColumn<AusenciaEntity>(
      label: 'Días',
      width: 70,
      alignment: Alignment.centerRight,
      sortValue: (AusenciaEntity a) => a.diasAusencia,
      cell: (AusenciaEntity a) => AusenciaCellText('${a.diasAusencia}'),
    ),
    GestionColumn<AusenciaEntity>(
      label: 'Estado',
      width: 120,
      sortValue: (AusenciaEntity a) => a.estado.index,
      cell: (AusenciaEntity a) => AusenciaEstadoDot(estado: a.estado),
    ),
    GestionColumn<AusenciaEntity>(
      label: 'Motivo',
      flex: 3,
      sortValue: (AusenciaEntity a) => (a.motivo ?? '').toLowerCase(),
      cell: (AusenciaEntity a) => AusenciaCellText(GestionFormatters.texto(a.motivo)),
    ),
  ];
}

/// Filtra ausencias por texto (personal, tipo, motivo), tipo y estado
List<AusenciaEntity> filtrarAusencias(
  List<AusenciaEntity> ausencias, {
  required AusenciaLookup lookup,
  required String query,
  required String? tipoId,
  required EstadoAusencia? estado,
}) {
  final String q = query.trim().toLowerCase();
  return ausencias.where((AusenciaEntity a) {
    final bool matchesSearch = q.isEmpty ||
        lookup.nombre(a.idPersonal).toLowerCase().contains(q) ||
        lookup.tipoNombre(a.idTipoAusencia).toLowerCase().contains(q) ||
        (a.motivo?.toLowerCase().contains(q) ?? false) ||
        GestionFormatters.fecha(a.fechaInicio).contains(q) ||
        GestionFormatters.fecha(a.fechaFin).contains(q);
    final bool matchesTipo = tipoId == null || a.idTipoAusencia == tipoId;
    final bool matchesEstado = estado == null || a.estado == estado;
    return matchesSearch && matchesTipo && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenAusencias(List<AusenciaEntity> todas, int filtradas) {
  int count(EstadoAusencia e) => todas.where((AusenciaEntity a) => a.estado == e).length;
  final int dias = todas.fold<int>(0, (int sum, AusenciaEntity a) => sum + a.diasAusencia);
  return <String>[
    if (filtradas == todas.length)
      '${todas.length} registros'
    else
      '$filtradas de ${todas.length} registros',
    'Pendientes ${count(EstadoAusencia.pendiente)}',
    'Aprobadas ${count(EstadoAusencia.aprobada)}',
    'Rechazadas ${count(EstadoAusencia.rechazada)}',
    '$dias días',
  ];
}

/// Imprime el listado de ausencias (filtrado y ordenado)
Future<void> imprimirAusencias(List<AusenciaEntity> ausencias, AusenciaLookup lookup) {
  return GestionPrint.listado(
    title: 'Ausencias del personal',
    headers: const <String>['Personal', 'Tipo', 'Inicio', 'Fin', 'Días', 'Estado', 'Motivo'],
    rows: ausencias
        .map(
          (AusenciaEntity a) => <String>[
            lookup.nombre(a.idPersonal),
            lookup.tipoNombre(a.idTipoAusencia),
            GestionFormatters.fecha(a.fechaInicio),
            GestionFormatters.fecha(a.fechaFin),
            '${a.diasAusencia}',
            ausenciaEstadoLabel(a.estado),
            GestionFormatters.texto(a.motivo),
          ],
        )
        .toList(),
  );
}
