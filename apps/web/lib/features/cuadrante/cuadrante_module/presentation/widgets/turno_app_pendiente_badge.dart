import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Badge "📱 App · Pendiente" para turnos creados desde la app móvil
/// que coordinación aún no ha validado. Al pulsarlo pide confirmación
/// y valida el turno.
class TurnoAppPendienteBadge extends StatelessWidget {
  const TurnoAppPendienteBadge({required this.turno, super.key});

  final TurnoEntity turno;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Tooltip(
          message: 'Turno creado por el trabajador desde la app al iniciar turno.\nPulsa para validarlo.',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _validar(context),
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '📱 App · Pendiente',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _validar(BuildContext context) async {
    final TurnosBloc bloc = context.read<TurnosBloc>();
    final bool? confirmado = await showSimpleConfirmationDialog(
      context: context,
      title: 'Validar turno',
      message: '${turno.nombrePersonal} inició este turno desde la app sin tenerlo planificado.\n\n'
          '${turno.tipoTurno.nombre} · ${turno.horaInicio} - ${turno.horaFin}\n\n'
          'Revisa horario y vehículo (puedes editarlo pulsando el turno) y valídalo.',
      confirmText: 'Validar',
      icon: Icons.verified_outlined,
      iconColor: AppColors.success,
      confirmButtonColor: AppColors.success,
    );
    if (confirmado ?? false) {
      bloc.add(TurnoValidarRequested(turno.id));
    }
  }
}
