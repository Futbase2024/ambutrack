import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/loading/app_skeleton.dart';
import '../../../../../core/widgets/menu/app_menu.dart';
import '../estado_tramite_badge.dart';
import 'tramite_item.dart';

/// Lista de trámites agrupada por estado, con estados de carga, error y vacío
class TramitesLista extends StatelessWidget {
  const TramitesLista({
    super.key,
    required this.pendientes,
    required this.aprobados,
    required this.rechazados,
    required this.onRefresh,
    required this.textoVacio,
    this.cargando = false,
    this.error,
  });

  final List<TramiteItem> pendientes;
  final List<TramiteItem> aprobados;
  final List<TramiteItem> rechazados;
  final Future<void> Function() onRefresh;
  final String textoVacio;
  final bool cargando;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final List<Widget> contenido = <Widget>[
      if (cargando)
        const _ListaSkeleton()
      else if (error != null)
        _Mensaje(icono: Icons.cloud_off_outlined, titulo: 'No se pudieron cargar tus trámites', texto: error!)
      else if (pendientes.isEmpty && aprobados.isEmpty && rechazados.isEmpty)
        _Mensaje(icono: Icons.inbox_outlined, titulo: 'Sin solicitudes', texto: textoVacio)
      else ...<Widget>[
        _Grupo(titulo: 'Pendientes', items: pendientes),
        _Grupo(titulo: 'Aprobadas', items: aprobados),
        _Grupo(titulo: 'Rechazadas', items: rechazados),
      ],
    ];

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: contenido,
      ),
    );
  }
}

/// Grupo de trámites con el mismo estado
class _Grupo extends StatelessWidget {
  const _Grupo({required this.titulo, required this.items});

  final String titulo;
  final List<TramiteItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppMenuSeccion('$titulo · ${items.length}'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray200),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                for (int i = 0; i < items.length; i++) ...<Widget>[
                  if (i > 0) const Divider(height: 1, indent: 70, color: AppColors.gray100),
                  TramiteFila(item: items[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila compacta de un trámite: tipo, periodo, duración y estado
class TramiteFila extends StatelessWidget {
  const TramiteFila({super.key, required this.item});

  final TramiteItem item;

  static String periodo(DateTime inicio, DateTime fin) {
    final DateFormat dia = DateFormat('d MMM', 'es');
    if (DateUtils.isSameDay(inicio, fin)) {
      return DateFormat('d MMM yyyy', 'es').format(inicio);
    }
    return '${dia.format(inicio)} – ${DateFormat('d MMM yyyy', 'es').format(fin)}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => item.abrir(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icono, size: 21, color: item.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${periodo(item.inicio, item.fin)} · ${item.dias} ${item.dias == 1 ? 'día' : 'días'}',
                    style: const TextStyle(fontSize: 13, color: AppColors.gray500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IntrinsicWidth(child: EstadoTramiteBadge(estado: item.estado, isAusencia: item.esAusencia)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}

/// Mensaje centrado para vacío o error
class _Mensaje extends StatelessWidget {
  const _Mensaje({required this.icono, required this.titulo, required this.texto});

  final IconData icono;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(color: AppColors.gray100, shape: BoxShape.circle),
            child: Icon(icono, size: 36, color: AppColors.gray400),
          ),
          const SizedBox(height: 16),
          Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray800)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.gray500, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Esqueleto de la lista mientras carga
class _ListaSkeleton extends StatelessWidget {
  const _ListaSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppSkeleton(width: 110, height: 12),
        SizedBox(height: 10),
        AppSkeleton(height: 68, radius: 16),
        SizedBox(height: 8),
        AppSkeleton(height: 68, radius: 16),
        SizedBox(height: 8),
        AppSkeleton(height: 68, radius: 16),
      ],
    );
  }
}
