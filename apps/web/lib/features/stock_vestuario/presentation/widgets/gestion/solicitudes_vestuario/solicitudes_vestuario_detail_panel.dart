import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/solicitudes_vestuario/solicitudes_vestuario_columns.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/tallas/tallas_personal_tab.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la solicitud de vestuario seleccionada
class SolicitudesVestuarioDetailPanel extends StatelessWidget {
  const SolicitudesVestuarioDetailPanel({
    required this.solicitud,
    required this.procesando,
    required this.onAprobar,
    required this.onRechazar,
    required this.onEntregar,
    required this.onFoto,
    super.key,
  });

  final SolicitudVestuarioEntity? solicitud;

  /// Hay una acción en curso (deshabilita los botones)
  final bool procesando;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final VoidCallback onEntregar;
  final VoidCallback onFoto;

  @override
  Widget build(BuildContext context) {
    final SolicitudVestuarioEntity? s = solicitud;
    if (s == null) {
      return const GestionDetailEmpty(message: 'Selecciona una solicitud para ver su ficha');
    }
    final String trabajador = GestionFormatters.texto(s.personalNombre);
    return GestionDetailPanel(
      key: ValueKey<String>(s.id),
      title: '${s.prenda} · ${GestionFormatters.texto(s.talla)}',
      badges: <Widget>[
        SolicitudEstadoBadge(estado: s.estado, inCell: false),
        SolicitudVestuarioBadge(label: tipoSolicitudCorto(s.tipo), color: AppColors.primary, inCell: false),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _SolicitudGeneralTab(solicitud: s)),
        GestionDetailTab(
          label: 'Tallas',
          child: TallasPersonalTab(personalId: s.personalId, trabajador: trabajador, prenda: s.prenda),
        ),
      ],
      actions: <Widget>[
        if (s.fotoUrl?.isNotEmpty ?? false)
          _PanelButton(icon: Icons.photo_outlined, label: 'Foto', color: AppColors.info, onPressed: onFoto),
        if (s.estado.abierta)
          _PanelButton(
            icon: Icons.local_shipping_outlined,
            label: s.tipo.entregaPrenda ? 'Entregar' : 'Registrar',
            color: AppColors.success,
            onPressed: procesando ? null : onEntregar,
          ),
        if (s.estado == EstadoSolicitudVestuario.pendiente)
          _PanelButton(
            icon: Icons.check_circle_outline,
            label: 'Aprobar',
            color: AppColors.info,
            onPressed: procesando ? null : onAprobar,
          ),
        if (s.estado.abierta)
          _PanelButton(
            icon: Icons.cancel_outlined,
            label: 'Rechazar',
            color: AppColors.error,
            onPressed: procesando ? null : onRechazar,
          ),
      ],
    );
  }
}

class _SolicitudGeneralTab extends StatelessWidget {
  const _SolicitudGeneralTab({required this.solicitud});

  final SolicitudVestuarioEntity solicitud;

  @override
  Widget build(BuildContext context) {
    final SolicitudVestuarioEntity s = solicitud;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Solicitud'),
        GestionDetailField(label: 'Trabajador', value: s.personalNombre),
        GestionDetailField(label: 'Fecha', value: solicitudFecha(s)),
        GestionDetailField(label: 'Tipo', value: s.tipo.label),
        GestionDetailField(label: 'Estado', child: SolicitudEstadoBadge(estado: s.estado)),
        const GestionDetailSection(title: 'Prenda'),
        GestionDetailField(label: 'Prenda', value: s.prenda),
        GestionDetailField(label: 'Talla', value: s.talla),
        GestionDetailField(label: 'Cantidad', value: '${s.cantidad}'),
        GestionDetailField(label: 'Prenda actual', value: s.vestuarioId == null ? null : 'Indicada por el trabajador'),
        GestionDetailField(label: 'Foto', value: (s.fotoUrl?.isNotEmpty ?? false) ? 'Disponible' : null),
        const GestionDetailSection(title: 'Motivo'),
        _TextoLibre(texto: s.motivo),
        const GestionDetailSection(title: 'Gestión'),
        GestionDetailField(
          label: 'Gestionada',
          value: s.gestionadoAt == null ? null : fechaHoraVestuario(s.gestionadoAt),
        ),
        GestionDetailField(label: 'Motivo rechazo', value: s.motivoRechazo),
        GestionDetailField(
          label: 'Entregada',
          value: s.entregadoAt == null ? null : fechaHoraVestuario(s.entregadoAt),
        ),
      ],
    );
  }
}

class _TextoLibre extends StatelessWidget {
  const _TextoLibre({required this.texto});

  final String? texto;

  @override
  Widget build(BuildContext context) {
    final bool vacio = texto?.trim().isEmpty ?? true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        GestionFormatters.texto(texto),
        style: TextStyle(fontSize: 12.5, height: 1.4, color: vacio ? AppColors.gray300 : AppColors.gray800),
      ),
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
