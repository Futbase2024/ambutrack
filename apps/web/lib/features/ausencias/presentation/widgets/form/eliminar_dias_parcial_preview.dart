import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Periodo que queda tras eliminar días de una solicitud
class PeriodoRestante {
  const PeriodoRestante({
    required this.fechaInicio,
    required this.fechaFin,
    required this.dias,
  });

  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int dias;
}

/// Aviso compacto de una línea con icono y color
class EliminarDiasAviso extends StatelessWidget {
  const EliminarDiasAviso({
    required this.icon,
    required this.color,
    required this.texto,
    this.detalle,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String texto;
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(texto, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                if (detalle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(detalle!, style: const TextStyle(fontSize: 12, color: AppColors.gray700)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Previsualización del resultado: periodos restantes o aviso de eliminación total
class EliminarDiasPreview extends StatelessWidget {
  const EliminarDiasPreview({
    required this.entidad,
    required this.periodos,
    required this.diasRestantes,
    super.key,
  });

  /// Nombre de la solicitud en minúsculas ("ausencia", "vacación")
  final String entidad;
  final List<PeriodoRestante> periodos;
  final int diasRestantes;

  @override
  Widget build(BuildContext context) {
    if (periodos.isEmpty) {
      return EliminarDiasAviso(
        icon: Icons.warning_amber,
        color: AppColors.warning,
        texto: 'Se eliminará toda la $entidad',
        detalle: 'Esta acción eliminará completamente la $entidad del registro.',
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final PeriodoRestante periodo in periodos) _PeriodoFila(periodo: periodo),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: AppColors.gray50,
            child: Text(
              'Días restantes: $diasRestantes',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodoFila extends StatelessWidget {
  const _PeriodoFila({required this.periodo});

  final PeriodoRestante periodo;

  static final DateFormat _fmt = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.event, size: 15, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_fmt.format(periodo.fechaInicio)} - ${_fmt.format(periodo.fechaFin)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray900),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${periodo.dias} días',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}
