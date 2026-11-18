import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../domain/services/validador_inicio_turno.dart';
import '../../cubit/inicio_turno_state.dart';

/// Título de sección en mayúsculas
class TituloSeccionInicio extends StatelessWidget {
  const TituloSeccionInicio(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray600, letterSpacing: 0.8),
      ),
    );
  }
}

/// Lista de avisos (naranja) y bloqueos (rojo)
class AvisosInicioTurnoList extends StatelessWidget {
  const AvisosInicioTurnoList({required this.avisos, super.key});

  final List<AvisoInicioTurno> avisos;

  @override
  Widget build(BuildContext context) {
    if (avisos.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: <Widget>[
          for (final AvisoInicioTurno a in avisos)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: _AvisoItem(aviso: a)),
        ],
      ),
    );
  }
}

class _AvisoItem extends StatelessWidget {
  const _AvisoItem({required this.aviso});

  final AvisoInicioTurno aviso;

  @override
  Widget build(BuildContext context) {
    final Color color = aviso.bloquea ? AppColors.error : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(aviso.bloquea ? Icons.block_rounded : Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(aviso.mensaje, style: const TextStyle(fontSize: 13, height: 1.35, color: AppColors.gray800)),
          ),
        ],
      ),
    );
  }
}

/// Indicador de progreso: ●──●──○ con el nombre del paso actual
class IndicadorPasosInicio extends StatelessWidget {
  const IndicadorPasosInicio({required this.actual, super.key});

  final PasoInicioTurno actual;

  @override
  Widget build(BuildContext context) {
    const List<PasoInicioTurno> pasos = PasoInicioTurno.values;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              for (int i = 0; i < pasos.length; i++) ...<Widget>[
                _Punto(numero: i + 1, completado: i < actual.index, actual: i == actual.index),
                if (i < pasos.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i < actual.index ? AppColors.primary : AppColors.gray200,
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Paso ${actual.index + 1} de ${pasos.length} · ${actual.label}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700),
          ),
        ],
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  const _Punto({required this.numero, required this.completado, required this.actual});

  final int numero;
  final bool completado;
  final bool actual;

  @override
  Widget build(BuildContext context) {
    final bool relleno = completado || actual;
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: relleno ? AppColors.primary : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: relleno ? AppColors.primary : AppColors.gray300, width: 2),
      ),
      child: completado
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : Text(
              '$numero',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: actual ? Colors.white : AppColors.gray500,
              ),
            ),
    );
  }
}
