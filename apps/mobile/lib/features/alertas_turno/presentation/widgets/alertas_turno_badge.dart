import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/alertas_turno_cubit.dart';
import 'alertas_turno_sheet.dart';

/// Icono permanente en la barra superior cuando hay algo caducado o por caducar
///
/// - Rojo: hay algo caducado (el número cuenta todo)
/// - Naranja: solo cosas a punto de caducar
/// - Oculto: todo en orden
class AlertasTurnoBadge extends StatelessWidget {
  const AlertasTurnoBadge({this.colorIcono, super.key});

  /// Color del icono (blanco sobre AppBar azul)
  final Color? colorIcono;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertasTurnoCubit, AlertasTurnoState>(
      builder: (BuildContext context, AlertasTurnoState state) {
        if (!state.hayAvisos) {
          return const SizedBox.shrink();
        }
        final Color color = state.caducados > 0 ? AppColors.error : AppColors.warning;
        return IconButton(
          tooltip: state.caducados > 0 ? 'Hay elementos caducados' : 'Hay elementos a punto de caducar',
          onPressed: () => showAlertasTurnoSheet(context),
          icon: Badge(
            backgroundColor: color,
            label: Text('${state.avisos.length}'),
            child: Icon(Icons.event_busy_rounded, color: colorIcono),
          ),
        );
      },
    );
  }
}
