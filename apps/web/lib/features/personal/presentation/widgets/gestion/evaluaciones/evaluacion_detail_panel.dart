import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/evaluaciones/evaluacion_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la evaluación seleccionada
class EvaluacionDetailPanel extends StatelessWidget {
  const EvaluacionDetailPanel({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final EvaluacionDesempenoEntity? item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final EvaluacionDesempenoEntity? e = item;
    if (e == null) {
      return const GestionDetailEmpty(message: 'Selecciona una evaluación para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(e.id),
      title: e.personalNombre ?? 'Evaluación',
      badges: <Widget>[EvaluacionMediaDot(media: e.puntuacionMedia)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _EvaluacionGeneralTab(item: e)),
      ],
      actions: <Widget>[
        GestionDetailEditButton(onPressed: onEdit),
        GestionDetailDeleteButton(onPressed: onDelete),
      ],
    );
  }
}

class _EvaluacionGeneralTab extends StatelessWidget {
  const _EvaluacionGeneralTab({required this.item});

  final EvaluacionDesempenoEntity item;

  @override
  Widget build(BuildContext context) {
    final EvaluacionDesempenoEntity e = item;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Evaluación'),
        GestionDetailField(label: 'Personal', value: e.personalNombre),
        GestionDetailField(label: 'Fecha', value: GestionFormatters.fecha(e.fecha)),
        GestionDetailField(label: 'Periodo', value: e.periodo),
        GestionDetailField(label: 'Evaluador', value: e.evaluadorNombre),
        const GestionDetailSection(title: 'Puntuaciones (1-5)'),
        for (final MapEntry<CriterioEvaluacion, int> p in e.puntuaciones.entries)
          GestionDetailField(
            label: p.key.label,
            child: GestionDotLabel(label: '${p.value}', color: evaluacionColor(p.value.toDouble())),
          ),
        GestionDetailField(label: 'Media', child: EvaluacionMediaDot(media: e.puntuacionMedia)),
        const GestionDetailSection(title: 'Comentarios'),
        GestionDetailNotes(text: e.comentarios),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(
          label: 'Alta',
          value: e.createdAt == null ? null : GestionFormatters.fecha(e.createdAt),
        ),
        GestionDetailField(
          label: 'Modificado',
          value: e.updatedAt == null ? null : GestionFormatters.fecha(e.updatedAt),
        ),
      ],
    );
  }
}
