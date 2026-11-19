import 'dart:js_interop';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/widgets/gestion/protocolo_normativa_gestion_columns.dart';
import 'package:flutter/material.dart';

@JS('window.open')
external JSObject? _windowOpen(String url, String target);

/// Ficha lateral del protocolo seleccionado
class ProtocoloDetailPanel extends StatelessWidget {
  const ProtocoloDetailPanel({
    required this.protocolo,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ProtocoloNormativaEntity? protocolo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ProtocoloNormativaEntity? p = protocolo;
    if (p == null) {
      return const GestionDetailEmpty(message: 'Selecciona un protocolo para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(p.id),
      title: p.titulo,
      badges: <Widget>[ProtocoloEstadoDot(activo: p.activo)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _ProtocoloGeneralTab(protocolo: p)),
      ],
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Editar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('Eliminar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _ProtocoloGeneralTab extends StatelessWidget {
  const _ProtocoloGeneralTab({required this.protocolo});

  final ProtocoloNormativaEntity protocolo;

  @override
  Widget build(BuildContext context) {
    final ProtocoloNormativaEntity p = protocolo;
    final bool hasDescripcion = p.descripcion?.trim().isNotEmpty ?? false;
    final String? url = p.urlDocumento?.trim();
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Código', value: p.codigo),
        GestionDetailField(label: 'Categoría', value: p.categoria.label),
        GestionDetailField(label: 'Versión', value: p.version),
        GestionDetailField(label: 'Vigencia', value: GestionFormatters.fecha(p.fechaVigencia)),
        GestionDetailField(label: 'Estado', child: ProtocoloEstadoDot(activo: p.activo)),
        const GestionDetailSection(title: 'Documento'),
        if (url == null || url.isEmpty)
          const GestionDetailField(label: 'Enlace')
        else
          _DocumentoLink(url: url),
        const GestionDetailSection(title: 'Descripción'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            GestionFormatters.texto(p.descripcion),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: hasDescripcion ? AppColors.gray800 : AppColors.gray300,
            ),
          ),
        ),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(p.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(p.updatedAt)),
      ],
    );
  }
}

/// Botón para abrir el documento en una pestaña nueva
class _DocumentoLink extends StatelessWidget {
  const _DocumentoLink({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _windowOpen(url, '_blank'),
        icon: const Icon(Icons.open_in_new, size: 16),
        label: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontSize: 12.5),
        ),
      ),
    );
  }
}
