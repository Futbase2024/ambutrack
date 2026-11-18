import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/jornada_real.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_tabla_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Resumen semanal de la persona: horas planificadas vs referencia (40h)
/// y horas reales según fichajes
class CuadranteResumenSemanaCell extends StatelessWidget {
  const CuadranteResumenSemanaCell({required this.persona, required this.lunes, super.key});

  final PersonalConTurnosEntity persona;
  final DateTime lunes;

  @override
  Widget build(BuildContext context) {
    final List<TurnoEntity> turnos = persona.turnos
        .where((TurnoEntity t) => duracionEnSemana(t, lunes) > Duration.zero)
        .toList();
    final Duration planificado =
        turnos.fold(Duration.zero, (Duration s, TurnoEntity t) => s + duracionEnSemana(t, lunes));
    final Duration real = turnos.fold(Duration.zero, (Duration s, TurnoEntity t) {
      return s + (JornadaReal.calcular(t, persona.fichajes)?.trabajado ?? Duration.zero);
    });

    const Duration ref = CuadranteTablaMedidas.referenciaSemana;
    final Color color = planificado == Duration.zero
        ? AppColors.gray400
        : planificado > ref
            ? AppColors.warning
            : AppColors.primary;
    final double ratio = (planificado.inMinutes / ref.inMinutes).clamp(0, 1).toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(color: AppColors.gray50),
      child: Tooltip(
        message: 'Planificado: ${formatearHoras(planificado)} en ${turnos.length} '
            '${turnos.length == 1 ? 'turno' : 'turnos'}\n'
            'Real (fichajes): ${formatearHoras(real)}\n'
            'Referencia: ${formatearHoras(ref)} semanales (jornada ordinaria)',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: formatearHoras(planificado),
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: color),
                  ),
                  TextSpan(
                    text: ' / ${formatearHoras(ref)}',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.gray500),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 4,
                color: color,
                backgroundColor: AppColors.gray200,
              ),
            ),
            if (real > Duration.zero) ...<Widget>[
              const SizedBox(height: 3),
              Text(
                'Real ${formatearHoras(real)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.gray600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
