import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:flutter/material.dart';

/// Banda de valoración según la puntuación media
enum ValoracionEvaluacion {
  alta('Alta (≥ 4)'),
  media('Media (3 – 4)'),
  baja('Baja (< 3)');

  const ValoracionEvaluacion(this.label);

  final String label;

  static ValoracionEvaluacion de(double media) {
    if (media >= 4) {
      return ValoracionEvaluacion.alta;
    }
    return media >= 3 ? ValoracionEvaluacion.media : ValoracionEvaluacion.baja;
  }
}

/// Color de una puntuación (criterio o media)
Color evaluacionColor(double puntuacion) {
  switch (ValoracionEvaluacion.de(puntuacion)) {
    case ValoracionEvaluacion.alta:
      return AppColors.success;
    case ValoracionEvaluacion.media:
      return AppColors.warning;
    case ValoracionEvaluacion.baja:
      return AppColors.error;
  }
}

/// Media con dos decimales y coma decimal ("3,75")
String evaluacionMediaTexto(double media) => media.toStringAsFixed(2).replaceAll('.', ',');

/// Puntuación media con indicador de color
class EvaluacionMediaDot extends StatelessWidget {
  const EvaluacionMediaDot({required this.media, super.key});

  final double media;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(label: evaluacionMediaTexto(media), color: evaluacionColor(media));
  }
}

String _personal(EvaluacionDesempenoEntity e) => e.personalNombre ?? GestionFormatters.vacio;

GestionColumn<EvaluacionDesempenoEntity> _criterio(String label, int Function(EvaluacionDesempenoEntity) valor) {
  return GestionColumn<EvaluacionDesempenoEntity>(
    label: label,
    filterValue: (EvaluacionDesempenoEntity e) => '${valor(e)}',
    width: 95,
    sortValue: valor,
    cell: (EvaluacionDesempenoEntity e) => GestionCellText('${valor(e)}'),
  );
}

/// Columnas de la rejilla de evaluaciones de desempeño
List<GestionColumn<EvaluacionDesempenoEntity>> evaluacionGestionColumns() {
  return <GestionColumn<EvaluacionDesempenoEntity>>[
    GestionColumn<EvaluacionDesempenoEntity>(
      label: 'Personal',
      filterValue: (EvaluacionDesempenoEntity e) => gestionFiltroTexto(e.personalNombre),
      flex: 4,
      sortValue: (EvaluacionDesempenoEntity e) => _personal(e).toLowerCase(),
      cell: (EvaluacionDesempenoEntity e) => GestionCellText(_personal(e), bold: true),
    ),
    GestionColumn<EvaluacionDesempenoEntity>(
      label: 'Fecha',
      width: 105,
      sortValue: (EvaluacionDesempenoEntity e) => e.fecha,
      cell: (EvaluacionDesempenoEntity e) => GestionCellText(GestionFormatters.fecha(e.fecha)),
    ),
    GestionColumn<EvaluacionDesempenoEntity>(
      label: 'Periodo',
      filterValue: (EvaluacionDesempenoEntity e) => gestionFiltroTexto(e.periodo),
      width: 100,
      sortValue: (EvaluacionDesempenoEntity e) => e.periodo ?? '',
      cell: (EvaluacionDesempenoEntity e) => GestionCellText(GestionFormatters.texto(e.periodo)),
    ),
    GestionColumn<EvaluacionDesempenoEntity>(
      label: 'Evaluador',
      filterValue: (EvaluacionDesempenoEntity e) => gestionFiltroTexto(e.evaluadorNombre),
      flex: 3,
      sortValue: (EvaluacionDesempenoEntity e) => (e.evaluadorNombre ?? '').toLowerCase(),
      cell: (EvaluacionDesempenoEntity e) => GestionCellText(GestionFormatters.texto(e.evaluadorNombre)),
    ),
    _criterio('Puntualidad', (EvaluacionDesempenoEntity e) => e.puntualidad),
    _criterio('Trato pac.', (EvaluacionDesempenoEntity e) => e.tratoPaciente),
    _criterio('Equipo', (EvaluacionDesempenoEntity e) => e.trabajoEquipo),
    _criterio('Protocolos', (EvaluacionDesempenoEntity e) => e.cumplimientoProtocolos),
    GestionColumn<EvaluacionDesempenoEntity>(
      label: 'Media',
      filterValue: (EvaluacionDesempenoEntity e) => ValoracionEvaluacion.de(e.puntuacionMedia).label,
      width: 90,
      sortValue: (EvaluacionDesempenoEntity e) => e.puntuacionMedia,
      cell: (EvaluacionDesempenoEntity e) => EvaluacionMediaDot(media: e.puntuacionMedia),
    ),
  ];
}

/// Filtra evaluaciones por texto y banda de valoración
List<EvaluacionDesempenoEntity> filtrarEvaluaciones(
  List<EvaluacionDesempenoEntity> items, {
  required String query,
  required ValoracionEvaluacion? valoracion,
}) {
  final String q = query.trim().toLowerCase();
  bool contains(String? v) => v?.toLowerCase().contains(q) ?? false;
  return items.where((EvaluacionDesempenoEntity e) {
    final bool matchesSearch = q.isEmpty ||
        contains(e.personalNombre) ||
        contains(e.evaluadorNombre) ||
        contains(e.periodo) ||
        contains(e.comentarios);
    return matchesSearch && (valoracion == null || ValoracionEvaluacion.de(e.puntuacionMedia) == valoracion);
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenEvaluaciones(List<EvaluacionDesempenoEntity> todos, int filtrados) {
  final double global = todos.isEmpty
      ? 0
      : todos.fold<double>(0, (double a, EvaluacionDesempenoEntity e) => a + e.puntuacionMedia) / todos.length;
  return <String>[
    gestionResumenRegistros(todos.length, filtrados),
    'Media global ${evaluacionMediaTexto(global)}',
    '${todos.where((EvaluacionDesempenoEntity e) => e.puntuacionMedia < 3).length} con valoración baja',
  ];
}

/// Imprime el listado de evaluaciones (filtrado y ordenado)
Future<void> imprimirEvaluaciones(List<EvaluacionDesempenoEntity> items) {
  return GestionPrint.listado(
    title: 'Evaluaciones de Desempeño',
    headers: const <String>[
      'Personal', 'Fecha', 'Periodo', 'Evaluador', 'Puntualidad', 'Trato paciente', 'Trabajo equipo',
      'Protocolos', 'Media',
    ],
    rows: items
        .map(
          (EvaluacionDesempenoEntity e) => <String>[
            _personal(e),
            GestionFormatters.fecha(e.fecha),
            GestionFormatters.texto(e.periodo),
            GestionFormatters.texto(e.evaluadorNombre),
            '${e.puntualidad}',
            '${e.tratoPaciente}',
            '${e.trabajoEquipo}',
            '${e.cumplimientoProtocolos}',
            evaluacionMediaTexto(e.puntuacionMedia),
          ],
        )
        .toList(),
  );
}
