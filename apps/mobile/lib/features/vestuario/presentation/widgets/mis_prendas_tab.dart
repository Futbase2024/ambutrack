import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/vestuario_state.dart';
import 'vestuario_comunes.dart';

/// Acción sobre una prenda propia (reposición, cambio de talla, devolución)
typedef AccionPrenda = void Function(VestuarioEntity prenda, TipoSolicitudVestuario tipo);

/// Pestaña "Mis prendas": lo que tiene ahora y el historial
class MisPrendasTab extends StatelessWidget {
  const MisPrendasTab({required this.state, required this.onAccion, required this.onRefrescar, super.key});

  final VestuarioState state;
  final AccionPrenda onAccion;
  final Future<void> Function() onRefrescar;

  @override
  Widget build(BuildContext context) {
    final List<VestuarioEntity> activas = state.prendasActivas;
    final List<VestuarioEntity> historial = state.prendasHistorial;
    return RefreshIndicator(
      onRefresh: onRefrescar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: <Widget>[
          if (activas.isEmpty)
            const VestuarioVacio(
              icono: Icons.checkroom_outlined,
              texto: 'Aún no tienes prendas asignadas.\nPuedes pedir una con el botón "Solicitar".',
            ),
          for (final VestuarioEntity p in activas)
            _PrendaCard(prenda: p, bloqueada: state.tieneSolicitudAbierta(p.id), onAccion: onAccion),
          if (historial.isNotEmpty)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('Historial (${historial.length})', style: const TextStyle(fontWeight: FontWeight.w600)),
              children: <Widget>[for (final VestuarioEntity p in historial) _PrendaCard(prenda: p)],
            ),
        ],
      ),
    );
  }
}

class _PrendaCard extends StatelessWidget {
  const _PrendaCard({required this.prenda, this.bloqueada = false, this.onAccion});

  final VestuarioEntity prenda;

  /// Ya tiene una solicitud abierta
  final bool bloqueada;

  /// null = historial (sin acciones)
  final AccionPrenda? onAccion;

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final String detalle = <String>[
      'Talla ${prenda.talla}',
      if ((prenda.cantidad ?? 1) > 1) 'x${prenda.cantidad}',
      ?prenda.color,
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.checkroom_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    prenda.prenda.toUpperCase(),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gray900),
                  ),
                ),
                if (onAccion != null && !bloqueada) _MenuAcciones(prenda: prenda, onAccion: onAccion!),
              ],
            ),
            const SizedBox(height: 6),
            Text(detalle, style: const TextStyle(fontSize: 13, color: AppColors.gray700)),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                BadgeVestuario(texto: capitalizar(prenda.estado), color: colorEstadoPrenda(prenda.estado)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    prenda.activo
                        ? 'Entregada ${_fecha.format(prenda.fechaEntrega)}'
                        : 'Devuelta ${prenda.fechaDevolucion == null ? '' : _fecha.format(prenda.fechaDevolucion!)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                  ),
                ),
              ],
            ),
            if (bloqueada)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Tiene una solicitud en curso',
                  style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuAcciones extends StatelessWidget {
  const _MenuAcciones({required this.prenda, required this.onAccion});

  final VestuarioEntity prenda;
  final AccionPrenda onAccion;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TipoSolicitudVestuario>(
      tooltip: 'Acciones',
      onSelected: (TipoSolicitudVestuario tipo) => onAccion(prenda, tipo),
      itemBuilder: (_) => const <PopupMenuEntry<TipoSolicitudVestuario>>[
        PopupMenuItem<TipoSolicitudVestuario>(
          value: TipoSolicitudVestuario.reposicion,
          child: ListTile(leading: Icon(Icons.autorenew_rounded), title: Text('Pedir reposición')),
        ),
        PopupMenuItem<TipoSolicitudVestuario>(
          value: TipoSolicitudVestuario.cambioTalla,
          child: ListTile(leading: Icon(Icons.straighten_rounded), title: Text('Cambiar talla')),
        ),
        PopupMenuItem<TipoSolicitudVestuario>(
          value: TipoSolicitudVestuario.devolucion,
          child: ListTile(leading: Icon(Icons.assignment_return_outlined), title: Text('Devolver')),
        ),
      ],
    );
  }
}
