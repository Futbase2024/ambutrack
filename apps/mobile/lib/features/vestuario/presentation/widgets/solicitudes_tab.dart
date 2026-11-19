import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/vestuario_state.dart';
import 'vestuario_comunes.dart';

/// Pestaña "Solicitudes": estado de lo pedido, con opción de cancelar las pendientes
class SolicitudesTab extends StatelessWidget {
  const SolicitudesTab({required this.state, required this.onCancelar, required this.onRefrescar, super.key});

  final VestuarioState state;
  final ValueChanged<SolicitudVestuarioEntity> onCancelar;
  final Future<void> Function() onRefrescar;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefrescar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: <Widget>[
          if (state.solicitudes.isEmpty)
            const VestuarioVacio(
              icono: Icons.inventory_2_outlined,
              texto: 'No has hecho ninguna solicitud.\nPide prendas, reposiciones o cambios de talla con "Solicitar".',
            ),
          for (final SolicitudVestuarioEntity s in state.solicitudes)
            _SolicitudCard(solicitud: s, onCancelar: onCancelar),
        ],
      ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  const _SolicitudCard({required this.solicitud, required this.onCancelar});

  final SolicitudVestuarioEntity solicitud;
  final ValueChanged<SolicitudVestuarioEntity> onCancelar;

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy HH:mm');

  IconData get _icono {
    switch (solicitud.tipo) {
      case TipoSolicitudVestuario.nueva:
        return Icons.add_shopping_cart_rounded;
      case TipoSolicitudVestuario.reposicion:
        return Icons.autorenew_rounded;
      case TipoSolicitudVestuario.cambioTalla:
        return Icons.straighten_rounded;
      case TipoSolicitudVestuario.devolucion:
        return Icons.assignment_return_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = colorEstadoSolicitud(solicitud.estado);
    final String detalle = <String>[
      if (solicitud.talla != null) 'Talla ${solicitud.talla}',
      'x${solicitud.cantidad}',
      if (solicitud.createdAt != null) _fecha.format(solicitud.createdAt!.toLocal()),
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(_icono, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(solicitud.prenda, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(solicitud.tipo.label, style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
                    ],
                  ),
                ),
                BadgeVestuario(texto: solicitud.estado.label.toUpperCase(), color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(detalle, style: const TextStyle(fontSize: 13, color: AppColors.gray700)),
            if (solicitud.motivo != null) ...<Widget>[
              const SizedBox(height: 4),
              Text('"${solicitud.motivo}"', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
            ],
            if (solicitud.estado == EstadoSolicitudVestuario.rechazada && solicitud.motivoRechazo != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                'Motivo del rechazo: ${solicitud.motivoRechazo}',
                style: const TextStyle(fontSize: 13, color: AppColors.error),
              ),
            ],
            if (solicitud.estado == EstadoSolicitudVestuario.pendiente)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => onCancelar(solicitud),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Cancelar solicitud'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
