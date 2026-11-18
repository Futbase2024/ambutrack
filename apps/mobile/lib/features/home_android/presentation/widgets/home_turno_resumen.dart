import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';

/// Resumen del turno en curso: hora de entrada, tiempo trabajado y vehículo
class HomeTurnoResumen extends StatefulWidget {
  const HomeTurnoResumen({super.key, required this.entrada, this.matricula});

  final DateTime? entrada;
  final String? matricula;

  @override
  State<HomeTurnoResumen> createState() => _HomeTurnoResumenState();
}

class _HomeTurnoResumenState extends State<HomeTurnoResumen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Refresca el tiempo trabajado cada minuto
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? entrada = widget.entrada;
    final String? matricula = widget.matricula;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            _Metrica(
              icon: Icons.login_rounded,
              etiqueta: 'Entrada',
              valor: entrada != null ? DateFormat('HH:mm').format(entrada.toLocal()) : '--:--',
            ),
            const VerticalDivider(width: 1, color: AppColors.gray200),
            _Metrica(
              icon: Icons.timer_outlined,
              etiqueta: 'Trabajado',
              valor: entrada != null ? _duracion(DateTime.now().difference(entrada)) : '--',
            ),
            const VerticalDivider(width: 1, color: AppColors.gray200),
            _Metrica(
              icon: Icons.airport_shuttle_outlined,
              etiqueta: 'Vehículo',
              valor: (matricula != null && matricula.isNotEmpty) ? matricula : 'Sin asignar',
            ),
          ],
        ),
      ),
    );
  }

  static String _duracion(Duration d) {
    if (d.isNegative) {
      return '0 min';
    }
    final int horas = d.inHours;
    final int minutos = d.inMinutes.remainder(60);
    return horas > 0 ? '${horas}h ${minutos.toString().padLeft(2, '0')}m' : '$minutos min';
  }
}

/// Métrica individual del resumen
class _Metrica extends StatelessWidget {
  const _Metrica({required this.icon, required this.etiqueta, required this.valor});

  final IconData icon;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gray900),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: const TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }
}
