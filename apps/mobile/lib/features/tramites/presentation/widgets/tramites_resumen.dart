import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/ausencias_bloc.dart';
import '../bloc/ausencias_state.dart';
import '../bloc/vacaciones_bloc.dart';
import '../bloc/vacaciones_state.dart';

/// Resumen de trámites del usuario: pendientes, aprobados y rechazados
class TramitesResumen extends StatelessWidget {
  const TramitesResumen({super.key});

  @override
  Widget build(BuildContext context) {
    final VacacionesState vacaciones = context.watch<VacacionesBloc>().state;
    final AusenciasState ausencias = context.watch<AusenciasBloc>().state;

    final int pendientes = (vacaciones is VacacionesLoaded ? vacaciones.pendientes.length : 0) +
        (ausencias is AusenciasLoaded ? ausencias.pendientes.length : 0);
    final int aprobadas = (vacaciones is VacacionesLoaded ? vacaciones.aprobadas.length : 0) +
        (ausencias is AusenciasLoaded ? ausencias.aprobadas.length : 0);
    final int rechazadas = (vacaciones is VacacionesLoaded ? vacaciones.rechazadas.length : 0) +
        (ausencias is AusenciasLoaded ? ausencias.rechazadas.length : 0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            Expanded(
              child: _Indicador(
                icon: Icons.hourglass_top_rounded,
                color: AppColors.warning,
                valor: pendientes,
                etiqueta: 'Pendientes',
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.gray200),
            Expanded(
              child: _Indicador(
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                valor: aprobadas,
                etiqueta: 'Aprobadas',
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.gray200),
            Expanded(
              child: _Indicador(
                icon: Icons.cancel_outlined,
                color: AppColors.error,
                valor: rechazadas,
                etiqueta: 'Rechazadas',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicador individual del resumen
class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.icon,
    required this.color,
    required this.valor,
    required this.etiqueta,
  });

  final IconData icon;
  final Color color;
  final int valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(
            '$valor',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              etiqueta,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
