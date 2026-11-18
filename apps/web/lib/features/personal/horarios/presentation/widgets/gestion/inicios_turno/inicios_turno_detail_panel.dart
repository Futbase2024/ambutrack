import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/inicios_turno/inicio_turno_detail_tabs.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/inicios_turno/inicios_turno_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del inicio de turno seleccionado
class IniciosTurnoDetailPanel extends StatelessWidget {
  const IniciosTurnoDetailPanel({
    required this.inicio,
    required this.validando,
    required this.onAprobar,
    required this.onRechazar,
    required this.onFoto,
    super.key,
  });

  final InicioTurnoEntity? inicio;

  /// Hay una aprobación / rechazo en curso (deshabilita los botones)
  final bool validando;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final VoidCallback onFoto;

  @override
  Widget build(BuildContext context) {
    final InicioTurnoEntity? i = inicio;
    if (i == null) {
      return const GestionDetailEmpty(message: 'Selecciona un inicio de turno para ver su ficha');
    }
    final bool pendiente = esPendiente(i);
    return GestionDetailPanel(
      key: ValueKey<String>(i.id),
      title: GestionFormatters.texto(i.personalNombre),
      badges: <Widget>[
        InicioEstadoBadge(estado: i.estadoValidacion, inCell: false),
        InicioFueraBaseBadge(fueraDeBase: i.fueraDeBase, inCell: false),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: InicioTurnoGeneralTab(inicio: i),
        ),
        GestionDetailTab(
          label: 'Checklist (${i.checklistItems.length})',
          child: InicioTurnoChecklistTab(inicio: i),
        ),
        GestionDetailTab(
          label: 'Avisos (${i.avisos.length})',
          child: InicioTurnoAvisosTab(inicio: i),
        ),
      ],
      actions: <Widget>[
        if (i.fotoKmUrl?.isNotEmpty ?? false)
          _PanelButton(icon: Icons.photo_camera_outlined, label: 'Foto km', color: AppColors.info, onPressed: onFoto),
        if (pendiente) ...<Widget>[
          _PanelButton(
            icon: Icons.check_circle_outline,
            label: 'Aprobar',
            color: AppColors.success,
            onPressed: validando ? null : onAprobar,
          ),
          _PanelButton(
            icon: Icons.cancel_outlined,
            label: 'Rechazar',
            color: AppColors.error,
            onPressed: validando ? null : onRechazar,
          ),
        ],
      ],
    );
  }
}

class _PanelButton extends StatelessWidget {
  const _PanelButton({required this.icon, required this.label, required this.color, required this.onPressed});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(0, 34),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
