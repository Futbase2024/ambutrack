import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_detail_panel.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/resultado_generacion_entity.dart';
import 'package:flutter/material.dart';

/// Resumen compacto del resultado de la generación automática
class GeneracionResultadoBody extends StatelessWidget {
  const GeneracionResultadoBody({required this.resultado, super.key});

  final ResultadoGeneracionEntity resultado;

  static const double _labelWidth = 160;

  @override
  Widget build(BuildContext context) {
    final EstadisticasGeneracion stats = resultado.estadisticas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _Aviso(
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          texto: '¡Generación completada! Revisa el resumen antes de guardar.',
        ),
        const GestionFormSection(title: 'Resumen'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionDetailField(
                  label: 'Turnos generados',
                  value: '${stats.totalTurnosGenerados}',
                  labelWidth: _labelWidth,
                ),
                GestionDetailField(
                  label: 'Personal asignado',
                  value: '${stats.totalPersonalAsignado}',
                  labelWidth: _labelWidth,
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionDetailField(
                  label: 'Horas promedio/persona',
                  value: '${stats.horasPromedioPorPersona.toStringAsFixed(1)} h',
                  labelWidth: _labelWidth,
                ),
                GestionDetailField(
                  label: 'Cobertura',
                  value: '${stats.coberturaCompletada.toStringAsFixed(1)}%',
                  labelWidth: _labelWidth,
                ),
              ],
            ),
          ],
        ),
        if (resultado.tieneConflictos) ...<Widget>[
          GestionFormSection(title: 'Conflictos (${resultado.conflictos.length})'),
          _MensajesLista(
            mensajes: resultado.conflictos.map((ConflictoGeneracion c) => c.mensaje).toList(),
            icon: Icons.error_outline,
            color: AppColors.error,
          ),
        ],
        if (resultado.tieneAdvertencias) ...<Widget>[
          GestionFormSection(title: 'Advertencias (${resultado.advertencias.length})'),
          _MensajesLista(
            mensajes: resultado.advertencias.map((AdvertenciaGeneracion a) => a.mensaje).toList(),
            icon: Icons.warning_amber,
            color: AppColors.warning,
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.icon, required this.color, required this.texto});

  final IconData icon;
  final Color color;
  final String texto;

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
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}

/// Lista de mensajes (máx. 5 visibles) con indicador de los restantes
class _MensajesLista extends StatelessWidget {
  const _MensajesLista({required this.mensajes, required this.icon, required this.color});

  final List<String> mensajes;
  final IconData icon;
  final Color color;

  static const int _maxVisibles = 5;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final String mensaje in mensajes.take(_maxVisibles))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(mensaje, style: const TextStyle(fontSize: 12.5, color: AppColors.gray800)),
                  ),
                ],
              ),
            ),
          if (mensajes.length > _maxVisibles)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: AppColors.gray50,
              child: Text(
                '... y ${mensajes.length - _maxVisibles} más',
                style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: AppColors.gray500),
              ),
            ),
        ],
      ),
    );
  }
}
