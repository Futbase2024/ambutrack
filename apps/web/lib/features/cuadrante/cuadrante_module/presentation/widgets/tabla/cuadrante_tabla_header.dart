import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_state.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_cobertura.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_tabla_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Cabecera de la tabla: "Personal", los 7 días con su cobertura y "Semana"
class CuadranteTablaHeader extends StatelessWidget {
  const CuadranteTablaHeader({required this.state, required this.dotaciones, super.key});

  final CuadranteLoaded state;

  /// null mientras se cargan las dotaciones
  final List<DotacionEntity>? dotaciones;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(bottom: BorderSide(color: AppColors.gray300, width: 1.5)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: CuadranteTablaMedidas.anchoPersonal,
            child: _TituloColumna(texto: 'Personal', contador: state.personalConTurnos.length),
          ),
          for (final DateTime dia in diasDeSemana(state.primerDiaSemana))
            Expanded(
              child: _DiaHeader(
                dia: dia,
                cobertura: dotaciones == null
                    ? null
                    : calcularCobertura(dia: dia, dotaciones: dotaciones!, state: state),
              ),
            ),
          const SizedBox(
            width: CuadranteTablaMedidas.anchoSemana,
            child: _TituloColumna(texto: 'Semana', alineacion: MainAxisAlignment.center),
          ),
        ],
      ),
    );
  }
}

class _TituloColumna extends StatelessWidget {
  const _TituloColumna({required this.texto, this.contador, this.alineacion = MainAxisAlignment.start});

  final String texto;
  final int? contador;
  final MainAxisAlignment alineacion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: alineacion,
        children: <Widget>[
          Text(
            texto,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray800),
          ),
          if (contador != null) ...<Widget>[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(10)),
              child: Text(
                '$contador',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiaHeader extends StatelessWidget {
  const _DiaHeader({required this.dia, required this.cobertura});

  final DateTime dia;
  final CoberturaDia? cobertura;

  @override
  Widget build(BuildContext context) {
    final bool hoy = esHoy(dia);
    final Color texto = hoy ? AppColors.primary : AppColors.gray600;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: hoy ? AppColors.primary.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <Widget>[
          Text(
            '${DateFormat('EEE', 'es_ES').format(dia).toUpperCase()} ${dia.day}',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: texto),
          ),
          const SizedBox(height: 4),
          if (cobertura != null) _CoberturaPill(cobertura: cobertura!) else const SizedBox(height: 18),
        ],
      ),
    );
  }
}

/// Píldora "🚑 2/4" coloreada según el grado de cobertura del día
class _CoberturaPill extends StatelessWidget {
  const _CoberturaPill({required this.cobertura});

  final CoberturaDia cobertura;

  @override
  Widget build(BuildContext context) {
    final CoberturaDia c = cobertura;
    final Color color = c.sinNecesidades
        ? AppColors.gray400
        : c.cubierto >= c.requerido
            ? AppColors.success
            : c.cubierto == 0
                ? AppColors.error
                : AppColors.warning;

    return Tooltip(
      message: _tooltip(c),
      child: Container(
        height: 18,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.airport_shuttle_outlined, size: 12, color: color),
            const SizedBox(width: 3),
            Text(
              c.sinNecesidades ? '—' : '${c.cubierto}/${c.requerido}',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }

  static String _tooltip(CoberturaDia c) {
    final StringBuffer sb = StringBuffer('Cobertura de dotaciones\n');
    if (c.dotaciones.isEmpty) {
      sb.writeln('Ninguna dotación activa este día');
    }
    for (final CoberturaDotacion d in c.dotaciones) {
      sb.writeln('• ${d.nombre}: ${d.programado}/${d.requerido}');
    }
    sb.write('Personas con turno: ${c.personasConTurno}');
    return sb.toString();
  }
}
