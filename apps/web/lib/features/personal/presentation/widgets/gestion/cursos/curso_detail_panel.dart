import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/cursos/curso_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del curso seleccionado
class CursoDetailPanel extends StatelessWidget {
  const CursoDetailPanel({
    required this.curso,
    required this.certificacionesNombres,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final CursoEntity? curso;

  /// id de certificación → "CÓDIGO - Nombre"
  final Map<String, String> certificacionesNombres;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final CursoEntity? c = curso;
    if (c == null) {
      return const GestionDetailEmpty(message: 'Selecciona un curso para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(c.id),
      title: c.nombre,
      badges: <Widget>[
        CursoTipoDot(tipo: c.tipo),
        CatalogoEstadoDot(activo: c.activo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _CursoGeneralTab(curso: c, certificacionesNombres: certificacionesNombres),
        ),
      ],
      actions: <Widget>[
        GestionDetailEditButton(onPressed: onEdit),
        GestionDetailDeleteButton(onPressed: onDelete),
      ],
    );
  }
}

class _CursoGeneralTab extends StatelessWidget {
  const _CursoGeneralTab({required this.curso, required this.certificacionesNombres});

  final CursoEntity curso;
  final Map<String, String> certificacionesNombres;

  @override
  Widget build(BuildContext context) {
    final CursoEntity c = curso;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Curso'),
        GestionDetailField(label: 'Nombre', value: c.nombre),
        GestionDetailField(label: 'Tipo', child: CursoTipoDot(tipo: c.tipo)),
        GestionDetailField(label: 'Duración', value: '${c.duracionHoras} horas'),
        GestionDetailField(label: 'Estado', child: CatalogoEstadoDot(activo: c.activo)),
        const GestionDetailSection(title: 'Descripción'),
        GestionDetailNotes(text: c.descripcion),
        const GestionDetailSection(title: 'Certificaciones que otorga'),
        if (c.certificaciones.isEmpty)
          const GestionDetailMessage('Este curso no otorga certificaciones')
        else
          ...c.certificaciones.map(
            (String id) => GestionDetailField(
              label: '•',
              labelWidth: 16,
              value: certificacionesNombres[id] ?? id,
            ),
          ),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(
          label: 'Alta',
          value: c.createdAt == null ? null : GestionFormatters.fecha(c.createdAt),
        ),
        GestionDetailField(
          label: 'Modificado',
          value: c.updatedAt == null ? null : GestionFormatters.fecha(c.updatedAt),
        ),
      ],
    );
  }
}
