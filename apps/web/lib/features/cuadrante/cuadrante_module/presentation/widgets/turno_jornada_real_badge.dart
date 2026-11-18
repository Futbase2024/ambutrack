import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/jornada_real.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Badge con la jornada real del turno según los fichajes:
/// - "● En curso 2h 10m" (azul) si fichó entrada y no salida
/// - "✓ 8h 05m" (verde) si finalizó dentro de lo planificado
/// - "✓ 9h 10m (+1h 10m)" (naranja) si se desvía más de 30 min
/// No se muestra nada si no hay fichajes asociados al turno.
class TurnoJornadaRealBadge extends StatelessWidget {
  const TurnoJornadaRealBadge({required this.turno, required this.fichajes, super.key});

  final TurnoEntity turno;
  final List<RegistroHorarioEntity> fichajes;

  @override
  Widget build(BuildContext context) {
    final JornadaReal? jornada = JornadaReal.calcular(turno, fichajes);
    if (jornada == null) {
      return const SizedBox.shrink();
    }

    final Duration desvio = jornada.desvio(turno);
    final bool desviado = jornada.finalizada && desvio.abs() > JornadaReal.margenDesvio;
    final Color color = !jornada.finalizada
        ? AppColors.info
        : desviado
            ? AppColors.warning
            : AppColors.success;
    final String signo = desvio.isNegative ? '-' : '+';
    final String texto = jornada.finalizada
        ? '✓ ${JornadaReal.formatear(jornada.trabajado)}'
            '${desviado ? ' ($signo${JornadaReal.formatear(desvio)})' : ''}'
        : '● En curso ${JornadaReal.formatear(jornada.trabajado)}';

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Tooltip(
          message: _tooltip(jornada),
          child: Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ),
      ),
    );
  }

  String _tooltip(JornadaReal jornada) {
    final DateFormat hora = DateFormat('HH:mm');
    final Duration planificado = turno.finReal.difference(turno.inicioReal);
    final String salida = jornada.salida == null ? 'sin fichar' : hora.format(jornada.salida!);
    return 'Jornada real según fichajes\n'
        'Entrada: ${hora.format(jornada.entrada)} · Salida: $salida\n'
        'Trabajado: ${JornadaReal.formatear(jornada.trabajado)} · '
        'Planificado: ${JornadaReal.formatear(planificado)}';
  }
}
