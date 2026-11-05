import 'dart:js_interop';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/historial_medico/historial_medico_gestion_columns.dart';
import 'package:flutter/material.dart';

@JS('window.open')
external JSObject? _windowOpen(String url, String target);

/// Ficha lateral del reconocimiento médico seleccionado
class HistorialMedicoDetailPanel extends StatelessWidget {
  const HistorialMedicoDetailPanel({
    required this.item,
    required this.todos,
    required this.nombre,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final HistorialMedicoEntity? item;

  /// Todos los reconocimientos cargados (para la pestaña "Historial")
  final List<HistorialMedicoEntity> todos;
  final String Function(String personalId) nombre;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final HistorialMedicoEntity? h = item;
    if (h == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona un reconocimiento para ver su ficha',
      );
    }
    final List<HistorialMedicoEntity> delPersonal = todos
        .where((HistorialMedicoEntity o) => o.personalId == h.personalId)
        .toList()
      ..sort((HistorialMedicoEntity a, HistorialMedicoEntity b) =>
          b.fechaReconocimiento.compareTo(a.fechaReconocimiento));
    return GestionDetailPanel(
      key: ValueKey<String>(h.id),
      title: nombre(h.personalId),
      badges: <Widget>[
        AptitudDot(aptitud: h.aptitud),
        VigenciaDot(item: h),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _HistorialGeneralTab(item: h)),
        GestionDetailTab(
          label: 'Historial',
          child: _HistorialPersonalTab(items: delPersonal, selectedId: h.id),
        ),
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

class _HistorialGeneralTab extends StatelessWidget {
  const _HistorialGeneralTab({required this.item});

  final HistorialMedicoEntity item;

  @override
  Widget build(BuildContext context) {
    final HistorialMedicoEntity h = item;
    final int dias = h.fechaCaducidad.difference(DateTime.now()).inDays;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Reconocimiento'),
        GestionDetailField(label: 'Fecha', value: GestionFormatters.fecha(h.fechaReconocimiento)),
        GestionDetailField(label: 'Caducidad', value: GestionFormatters.fecha(h.fechaCaducidad)),
        GestionDetailField(
          label: dias < 0 ? 'Caducado hace' : 'Caduca en',
          value: '${dias.abs()} días',
        ),
        GestionDetailField(label: 'Estado', child: VigenciaDot(item: h)),
        GestionDetailField(label: 'Registro', value: h.activo ? 'Activo' : 'Inactivo'),
        const GestionDetailSection(title: 'Aptitud'),
        GestionDetailField(label: 'Aptitud', child: AptitudDot(aptitud: h.aptitud)),
        _HistorialLongText(text: h.restricciones, label: 'Restricciones'),
        const GestionDetailSection(title: 'Centro'),
        GestionDetailField(label: 'Centro médico', value: h.centroMedico),
        GestionDetailField(label: 'Médico', value: h.nombreMedico),
        const GestionDetailSection(title: 'Documento'),
        _HistorialDocumento(url: h.documentoUrl),
        const GestionDetailSection(title: 'Observaciones'),
        _HistorialLongText(text: h.observaciones),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(h.createdAt)),
        GestionDetailField(
          label: 'Modificado',
          value: h.updatedAt == null ? null : GestionFormatters.fecha(h.updatedAt),
        ),
      ],
    );
  }
}

/// Texto multilínea (observaciones/restricciones) con marcador de vacío
class _HistorialLongText extends StatelessWidget {
  const _HistorialLongText({required this.text, this.label});

  final String? text;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final bool hasText = text?.trim().isNotEmpty ?? false;
    final Widget content = Text(
      GestionFormatters.texto(text),
      style: TextStyle(
        fontSize: 12.5,
        height: 1.4,
        color: hasText ? AppColors.gray800 : AppColors.gray300,
      ),
    );
    if (label != null) {
      return GestionDetailField(label: label!, child: content);
    }
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: content);
  }
}

class _HistorialDocumento extends StatelessWidget {
  const _HistorialDocumento({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final String? u = url;
    if (u == null || u.trim().isEmpty) {
      return const GestionDetailField(label: 'Adjunto');
    }
    return GestionDetailField(
      label: 'Adjunto',
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () {
            debugPrint('👁️ HistorialMedico: abriendo documento $u');
            _windowOpen(u, '_blank');
          },
          icon: const Icon(Icons.open_in_new, size: 14),
          label: const Text('Ver documento', style: TextStyle(fontSize: 12.5)),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 24),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}

/// Pestaña "Historial": reconocimientos del mismo trabajador
class _HistorialPersonalTab extends StatelessWidget {
  const _HistorialPersonalTab({required this.items, required this.selectedId});

  final List<HistorialMedicoEntity> items;
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Resumen'),
        GestionDetailField(label: 'Reconocimientos', value: '${items.length}'),
        GestionDetailField(
          label: 'Último',
          value: items.isEmpty ? null : GestionFormatters.fecha(items.first.fechaReconocimiento),
        ),
        const GestionDetailSection(title: 'Reconocimientos del trabajador'),
        ...items.map(
          (HistorialMedicoEntity h) => _HistorialMiniRow(item: h, selected: h.id == selectedId),
        ),
      ],
    );
  }
}

class _HistorialMiniRow extends StatelessWidget {
  const _HistorialMiniRow({required this.item, required this.selected});

  final HistorialMedicoEntity item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = TextStyle(
      fontSize: 12,
      color: AppColors.gray800,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
    );
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 84,
            child: Text(GestionFormatters.fecha(item.fechaReconocimiento), style: base),
          ),
          Expanded(
            child: GestionDotLabel(
              label: aptitudLabel(item.aptitud),
              color: aptitudColor(item.aptitud),
              fontSize: 11.5,
            ),
          ),
          Text(
            'Cad. ${GestionFormatters.fecha(item.fechaCaducidad)}',
            style: base.copyWith(color: AppColors.gray500, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
