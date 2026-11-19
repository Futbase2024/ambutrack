import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/certificaciones/certificacion_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la certificación seleccionada
class CertificacionDetailPanel extends StatelessWidget {
  const CertificacionDetailPanel({
    required this.certificacion,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final CertificacionEntity? certificacion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final CertificacionEntity? c = certificacion;
    if (c == null) {
      return const GestionDetailEmpty(message: 'Selecciona una certificación para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(c.id),
      title: '${c.codigo} · ${c.nombre}',
      badges: <Widget>[CertificacionEstadoDot(activa: c.activa)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _CertificacionGeneralTab(certificacion: c)),
      ],
      actions: <Widget>[
        GestionDetailEditButton(onPressed: onEdit),
        GestionDetailDeleteButton(onPressed: onDelete),
      ],
    );
  }
}

class _CertificacionGeneralTab extends StatelessWidget {
  const _CertificacionGeneralTab({required this.certificacion});

  final CertificacionEntity certificacion;

  @override
  Widget build(BuildContext context) {
    final CertificacionEntity c = certificacion;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Código', value: c.codigo),
        GestionDetailField(label: 'Nombre', value: c.nombre),
        GestionDetailField(label: 'Estado', child: CertificacionEstadoDot(activa: c.activa)),
        const GestionDetailSection(title: 'Requisitos'),
        GestionDetailField(label: 'Vigencia', value: certificacionVigencia(c)),
        GestionDetailField(label: 'Horas requeridas', value: '${c.horasRequeridas} h'),
        GestionDetailField(
          label: 'Fecha de baja',
          value: c.fechaBaja == null ? null : GestionFormatters.fecha(c.fechaBaja),
        ),
        const GestionDetailSection(title: 'Descripción'),
        GestionDetailNotes(text: c.descripcion),
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
