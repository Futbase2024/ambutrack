import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alerta_mantenimiento.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/taller_consulta_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_common.dart';
import 'package:flutter/material.dart';

/// Color de la severidad: rojo / naranja / azul
Color severidadAlertaColor(SeveridadAlerta s) {
  switch (s) {
    case SeveridadAlerta.critica:
      return AppColors.error;
    case SeveridadAlerta.aviso:
      return AppColors.warning;
    case SeveridadAlerta.info:
      return AppColors.info;
  }
}

/// Opciones del filtro de tipo
final Map<String, String> alertaTipoOptions = <String, String>{
  tallerFiltroTodos: 'Todos',
  for (final TipoAlertaMantenimiento t in TipoAlertaMantenimiento.values) t.name: t.displayName,
};

/// Opciones del filtro de severidad
final Map<String, String> alertaSeveridadOptions = <String, String>{
  tallerFiltroTodos: 'Todas',
  for (final SeveridadAlerta s in SeveridadAlerta.values) s.name: s.displayName,
};

/// Criterios de filtrado de alertas
class AlertasFiltro {
  const AlertasFiltro({this.query = '', this.tipo = tallerFiltroTodos, this.severidad = tallerFiltroTodos});

  final String query;
  final String tipo;
  final String severidad;

  bool get activo => query.isNotEmpty || tipo.isNotEmpty || severidad.isNotEmpty;

  AlertasFiltro copyWith({String? query, String? tipo, String? severidad}) => AlertasFiltro(
        query: query ?? this.query,
        tipo: tipo ?? this.tipo,
        severidad: severidad ?? this.severidad,
      );

  bool matches(AlertaMantenimiento a) {
    final String q = query.trim().toLowerCase();
    final bool texto = q.isEmpty ||
        a.detalle.toLowerCase().contains(q) ||
        (a.vehiculoMatricula?.toLowerCase().contains(q) ?? false);
    return texto && (tipo.isEmpty || a.tipo.name == tipo) && (severidad.isEmpty || a.severidad.name == severidad);
  }
}

/// Columnas de la rejilla de alertas
final List<GestionColumn<AlertaMantenimiento>> alertasColumns = <GestionColumn<AlertaMantenimiento>>[
  GestionColumn<AlertaMantenimiento>(
    label: 'Severidad',
    width: 120,
    sortValue: (AlertaMantenimiento a) => a.severidad.index,
    cell: (AlertaMantenimiento a) =>
        GestionDotLabel(label: a.severidad.displayName, color: severidadAlertaColor(a.severidad)),
  ),
  GestionColumn<AlertaMantenimiento>(
    label: 'Tipo',
    flex: 2,
    sortValue: (AlertaMantenimiento a) => a.tipo.displayName,
    cell: (AlertaMantenimiento a) => TallerCellText(a.tipo.displayName),
  ),
  GestionColumn<AlertaMantenimiento>(
    label: 'Vehículo',
    flex: 2,
    sortValue: (AlertaMantenimiento a) => (a.vehiculoMatricula ?? '').toLowerCase(),
    cell: (AlertaMantenimiento a) => TallerCellText(GestionFormatters.texto(a.vehiculoMatricula), bold: true),
  ),
  GestionColumn<AlertaMantenimiento>(
    label: 'Detalle',
    flex: 6,
    sortValue: (AlertaMantenimiento a) => a.detalle.toLowerCase(),
    cell: (AlertaMantenimiento a) => Text(a.detalle, maxLines: 1, overflow: TextOverflow.ellipsis),
  ),
  GestionColumn<AlertaMantenimiento>(
    label: 'Fecha límite',
    width: 105,
    sortValue: (AlertaMantenimiento a) => a.fechaLimite ?? DateTime(9999),
    cell: (AlertaMantenimiento a) => TallerCellText(GestionFormatters.fecha(a.fechaLimite)),
  ),
  GestionColumn<AlertaMantenimiento>(
    label: 'Días',
    width: 130,
    alignment: Alignment.centerRight,
    sortValue: (AlertaMantenimiento a) => a.urgencia,
    cell: (AlertaMantenimiento a) => Text(
      a.diasTexto,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: a.severidad == SeveridadAlerta.critica ? AppColors.error : null,
      ),
    ),
  ),
];

/// Resumen de la barra de estado
List<String> resumenAlertas(
  List<AlertaMantenimiento> todas,
  List<AlertaMantenimiento> visibles,
  List<String> fuentesConError,
) {
  int contar(SeveridadAlerta s) => visibles.where((AlertaMantenimiento a) => a.severidad == s).length;
  return <String>[
    tallerRegistrosLabel(todas.length, visibles.length).replaceAll('registros', 'alertas'),
    '${contar(SeveridadAlerta.critica)} críticas',
    '${contar(SeveridadAlerta.aviso)} avisos',
    '${contar(SeveridadAlerta.info)} informativas',
    if (fuentesConError.isNotEmpty) 'Sin datos de: ${fuentesConError.join(', ')}',
  ];
}

/// Imprime el listado de alertas filtrado
Future<void> imprimirAlertas(List<AlertaMantenimiento> alertas) {
  return GestionPrint.listado(
    title: 'Alertas de Mantenimiento',
    headers: const <String>['Severidad', 'Tipo', 'Vehículo', 'Detalle', 'Fecha límite', 'Días'],
    rows: alertas
        .map(
          (AlertaMantenimiento a) => <String>[
            a.severidad.displayName,
            a.tipo.displayName,
            GestionFormatters.texto(a.vehiculoMatricula),
            a.detalle,
            GestionFormatters.fecha(a.fechaLimite),
            a.diasTexto,
          ],
        )
        .toList(),
  );
}
