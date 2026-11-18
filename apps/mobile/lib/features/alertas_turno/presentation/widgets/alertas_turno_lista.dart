import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/aviso_caducidad.dart';

/// Lista de caducidades agrupada en "Caducado" y "A punto de caducar"
class AlertasTurnoLista extends StatelessWidget {
  const AlertasTurnoLista({required this.avisos, super.key});

  final List<AvisoCaducidad> avisos;

  @override
  Widget build(BuildContext context) {
    final List<AvisoCaducidad> caducados = avisos.where((AvisoCaducidad a) => a.caducado).toList();
    final List<AvisoCaducidad> proximos = avisos.where((AvisoCaducidad a) => !a.caducado).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (caducados.isNotEmpty) _Grupo(titulo: 'Caducado', color: AppColors.error, avisos: caducados),
        if (proximos.isNotEmpty) _Grupo(titulo: 'A punto de caducar', color: AppColors.warning, avisos: proximos),
      ],
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo({required this.titulo, required this.color, required this.avisos});

  final String titulo;
  final Color color;
  final List<AvisoCaducidad> avisos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                color == AppColors.error ? Icons.block_rounded : Icons.warning_amber_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '${titulo.toUpperCase()} (${avisos.length})',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.6),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final AvisoCaducidad a in avisos) _Fila(aviso: a, color: color),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.aviso, required this.color});

  final AvisoCaducidad aviso;
  final Color color;

  static final DateFormat _formato = DateFormat('dd/MM/yyyy');

  IconData get _icono {
    switch (aviso.origen) {
      case OrigenAviso.vehiculo:
        return Icons.local_shipping_outlined;
      case OrigenAviso.personal:
        return Icons.badge_outlined;
      case OrigenAviso.material:
        return Icons.medication_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fecha = aviso.fecha == null ? '' : _formato.format(aviso.fecha!);
    final String detalle = <String>[aviso.origen.label, ?aviso.detalle].join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: <Widget>[
          Icon(_icono, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(aviso.titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(detalle, style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
              ],
            ),
          ),
          if (fecha.isNotEmpty)
            Text(fecha, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
