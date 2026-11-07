import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/generacion_traslados_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/generacion_traslados_state.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_state.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Banda con el estado de la generación de traslados:
/// servicios vigentes, cobertura generada y última generación detectada
class GeneracionResumenBanner extends StatelessWidget {
  const GeneracionResumenBanner({super.key});

  /// Fecha de creación más reciente entre los traslados generados desde
  /// servicios recurrentes (aproximación a la última ejecución)
  static DateTime? _ultimaCreacion(TrasladosConsultaState state) {
    if (state is! TrasladosConsultaLoaded) {
      return null;
    }
    DateTime? max;
    for (final TrasladoEntity t in state.traslados) {
      final DateTime? c = t.createdAt;
      if (t.idServicioRecurrente != null && c != null && (max == null || c.isAfter(max))) {
        max = c;
      }
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    final GeneracionTrasladosState gen = context.watch<GeneracionTrasladosBloc>().state;
    final DateTime? ultima = _ultimaCreacion(context.watch<TrasladosConsultaBloc>().state);
    final GeneracionResumen? r = gen.resumen;
    final ResultadoGeneracionTrasladosEntity? res = gen.ultimoResultado;
    final bool aviso = (r?.requierenGeneracion ?? 0) > 0;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: aviso ? AppColors.warning.withValues(alpha: 0.08) : Colors.white,
        border: const Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            if (gen.status == GeneracionStatus.loading && r == null)
              const _BannerText('Cargando estado de la generación...')
            else if (gen.status == GeneracionStatus.error && r == null)
              _BannerText('Error: ${gen.errorMessage ?? ''}', color: AppColors.error)
            else if (r != null) ...<Widget>[
              _BannerText('Servicios vigentes: ${r.serviciosVigentes}'),
              GestionDotLabel(
                label: 'Requieren generación: ${r.requierenGeneracion}',
                color: aviso ? AppColors.warning : AppColors.success,
              ),
              _BannerText('Sin generar: ${r.sinGenerar}'),
              _BannerText('Cobertura mínima: ${GestionFormatters.fecha(r.generadosHastaMin)}'),
              _BannerText('Cobertura máxima: ${GestionFormatters.fecha(r.generadosHastaMax)}'),
            ],
            _BannerText('Última creación detectada: ${TrasladoGestion.fechaHora(ultima)}'),
            if (res != null)
              GestionDotLabel(
                label: 'Última ejecución ${TrasladoGestion.hora(res.ejecutadoEn)}: '
                    '${res.trasladosGenerados} traslados '
                    '(${res.trasladosIda} ida / ${res.trasladosVuelta} vuelta)',
                color: res.tieneErrores ? AppColors.warning : AppColors.success,
              ),
          ],
        ),
      ),
    );
  }
}

class _BannerText extends StatelessWidget {
  const _BannerText(this.text, {this.color = AppColors.gray700});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Text(text, style: TextStyle(fontSize: 12.5, color: color)),
    );
  }
}
