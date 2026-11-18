import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/jornada_real.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_tabla_acciones.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Iconos de estado del turno: creado desde la app (pendiente) y jornada real.
/// El detalle va en el tooltip para que nunca se trunque.
class TurnoEstadoIconos extends StatelessWidget {
  const TurnoEstadoIconos({
    required this.turno,
    required this.fichajes,
    this.conTexto = true,
    super.key,
  });

  final TurnoEntity turno;
  final List<RegistroHorarioEntity> fichajes;

  /// Muestra la duración/hora junto al icono de jornada (false en minichips)
  final bool conTexto;

  @override
  Widget build(BuildContext context) {
    final JornadaReal? jornada = JornadaReal.calcular(turno, fichajes);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (turno.pendienteValidacion) _AppPendienteIcono(turno: turno),
        if (turno.pendienteValidacion && jornada != null) const SizedBox(width: 4),
        if (jornada != null) _JornadaIcono(turno: turno, jornada: jornada, conTexto: conTexto),
      ],
    );
  }
}

/// 📱 Turno creado desde la app sin validar. Pulsar → validar
class _AppPendienteIcono extends StatelessWidget {
  const _AppPendienteIcono({required this.turno});

  final TurnoEntity turno;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Creado desde la app al iniciar turno · Pendiente de validar\nPulsa para validarlo',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => CuadranteTablaAcciones.validarTurnoApp(context, turno),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.phone_iphone, size: 12, color: AppColors.warning),
          ),
        ),
      ),
    );
  }
}

/// Jornada real según fichajes: en curso (azul), en plazo (verde) o desviada (naranja)
class _JornadaIcono extends StatelessWidget {
  const _JornadaIcono({required this.turno, required this.jornada, required this.conTexto});

  final TurnoEntity turno;
  final JornadaReal jornada;
  final bool conTexto;

  @override
  Widget build(BuildContext context) {
    final Duration desvio = jornada.desvio(turno);
    final bool desviado = jornada.finalizada && desvio.abs() > JornadaReal.margenDesvio;
    final Color color = !jornada.finalizada
        ? AppColors.info
        : desviado
            ? AppColors.warning
            : AppColors.success;
    final String texto = jornada.finalizada
        ? _corto(jornada.trabajado)
        : DateFormat('HH:mm').format(jornada.entradaActual);

    return Tooltip(
      message: _tooltip(desvio, desviado: desviado),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(jornada.finalizada ? Icons.check_circle : Icons.play_circle_fill, size: 13, color: color),
          if (conTexto) ...<Widget>[
            const SizedBox(width: 2),
            Text(
              texto,
              maxLines: 1,
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ],
      ),
    );
  }

  /// "8h05", "45m"
  static String _corto(Duration d) {
    final int h = d.inHours;
    final int m = d.inMinutes.remainder(60);
    return h > 0 ? '${h}h${m.toString().padLeft(2, '0')}' : '${m}m';
  }

  String _tooltip(Duration desvio, {required bool desviado}) {
    final DateFormat hora = DateFormat('HH:mm');
    final Duration planificado = turno.finReal.difference(turno.inicioReal);
    final int n = jornada.tramos.length;
    final String tramos = jornada.tramos
        .map((TramoJornada t) =>
            '  ${hora.format(t.entrada)} – ${t.salida == null ? 'en curso' : hora.format(t.salida!)}'
            '  (${JornadaReal.formatear(t.duracion)})')
        .join('\n');
    final String estado = !jornada.finalizada
        ? 'En curso desde ${hora.format(jornada.entradaActual)}'
        : desviado
            ? '${desvio.isNegative ? 'Faltan' : 'Exceso de'} ${JornadaReal.formatear(desvio)} sobre lo planificado'
            : 'Dentro de lo planificado';
    return 'Jornada real según fichajes\n'
        '$n ${n == 1 ? 'tramo' : 'tramos'} · ${JornadaReal.formatear(jornada.trabajado)} trabajados\n'
        '$tramos\n'
        'Planificado: ${JornadaReal.formatear(planificado)} (${turno.horaInicio} – ${turno.horaFin})\n'
        '$estado';
  }
}
