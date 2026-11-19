import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/documentacion/documentacion_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del documento seleccionado
class DocumentacionDetailPanel extends StatelessWidget {
  const DocumentacionDetailPanel({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final DocumentoPersonalEntity? item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final DocumentoPersonalEntity? d = item;
    if (d == null) {
      return const GestionDetailEmpty(message: 'Selecciona un documento para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(d.id),
      title: d.descripcion,
      badges: <Widget>[DocumentoEstadoDot(estado: d.estado())],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _DocumentoGeneralTab(item: d)),
      ],
      actions: <Widget>[
        GestionDetailEditButton(onPressed: onEdit),
        GestionDetailDeleteButton(onPressed: onDelete),
      ],
    );
  }
}

class _DocumentoGeneralTab extends StatelessWidget {
  const _DocumentoGeneralTab({required this.item});

  final DocumentoPersonalEntity item;

  @override
  Widget build(BuildContext context) {
    final DocumentoPersonalEntity d = item;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Documento'),
        GestionDetailField(label: 'Personal', value: d.personalNombre),
        GestionDetailField(label: 'Tipo', value: d.tipo.label),
        GestionDetailField(label: 'Descripción', value: d.nombre),
        GestionDetailField(label: 'Número', value: d.numero),
        const GestionDetailSection(title: 'Vigencia'),
        GestionDetailField(
          label: 'F. emisión',
          value: d.fechaEmision == null ? null : GestionFormatters.fecha(d.fechaEmision),
        ),
        GestionDetailField(
          label: 'F. caducidad',
          value: d.fechaCaducidad == null ? null : documentoCaducidadTexto(d),
        ),
        GestionDetailField(label: 'Estado', child: DocumentoEstadoDot(estado: d.estado())),
        const GestionDetailSection(title: 'Archivo'),
        GestionDetailField(label: 'URL', value: d.archivoUrl),
        const GestionDetailSection(title: 'Observaciones'),
        GestionDetailNotes(text: d.observaciones),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(
          label: 'Alta',
          value: d.createdAt == null ? null : GestionFormatters.fecha(d.createdAt),
        ),
        GestionDetailField(
          label: 'Modificado',
          value: d.updatedAt == null ? null : GestionFormatters.fecha(d.updatedAt),
        ),
      ],
    );
  }
}
