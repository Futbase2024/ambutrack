import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/tecnicos_en_turno/tecnicos_en_turno_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat _hhmm = DateFormat('HH:mm');

/// Muestra el detalle de técnicos en turno: sin fichar, fichados y por llegar
Future<void> showTecnicosEnTurnoDialog(BuildContext context, TecnicosEnTurnoLoaded data) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => _TecnicosEnTurnoDialog(data: data),
  );
}

class _TecnicosEnTurnoDialog extends StatelessWidget {
  const _TecnicosEnTurnoDialog({required this.data});

  final TecnicosEnTurnoLoaded data;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Cabecera(data: data),
                const SizedBox(height: 16),
                Flexible(
                  child: data.tecnicos.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No hay técnicos con turno en curso ni próximo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: AppColors.gray500),
                          ),
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            _Seccion(
                              titulo: 'Sin fichar',
                              color: AppColors.error,
                              tecnicos: data.sinFichar,
                              ahora: data.calculadoEn,
                            ),
                            _Seccion(
                              titulo: 'Fichados',
                              color: AppColors.success,
                              tecnicos: data.fichados,
                              ahora: data.calculadoEn,
                            ),
                            _Seccion(
                              titulo: 'Por llegar (próximas 2 h)',
                              color: AppColors.gray500,
                              tecnicos: data.porLlegar,
                              ahora: data.calculadoEn,
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cerrar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.data});

  final TecnicosEnTurnoLoaded data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.groups_outlined, size: 28, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Técnicos en turno',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
              ),
              const SizedBox(height: 2),
              Text(
                '${data.fichados.length} de ${data.enTurno} fichados · TES y conductores · '
                'actualizado ${_hhmm.format(data.calculadoEn)}',
                style: const TextStyle(fontSize: 13, color: AppColors.gray600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.color, required this.tecnicos, required this.ahora});

  final String titulo;
  final Color color;
  final List<TecnicoEnTurnoEntity> tecnicos;
  final DateTime ahora;

  @override
  Widget build(BuildContext context) {
    if (tecnicos.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '${titulo.toUpperCase()} (${tecnicos.length})',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: color),
          ),
          const SizedBox(height: 6),
          for (final TecnicoEnTurnoEntity t in tecnicos) _FilaTecnico(tecnico: t, color: color, ahora: ahora),
        ],
      ),
    );
  }
}

class _FilaTecnico extends StatelessWidget {
  const _FilaTecnico({required this.tecnico, required this.color, required this.ahora});

  final TecnicoEnTurnoEntity tecnico;
  final Color color;
  final DateTime ahora;

  String _detalle() {
    switch (tecnico.presencia(ahora)) {
      case PresenciaTecnico.fichado:
        return 'Entrada ${_hhmm.format(tecnico.ultimoFichajeHora!)}';
      case PresenciaTecnico.sinFichar:
        final int min = ahora.difference(tecnico.inicioTurno).inMinutes;
        return min < 60 ? 'Retraso $min min' : 'Retraso ${min ~/ 60} h ${min % 60} min';
      case PresenciaTecnico.porLlegar:
        return 'Empieza ${_hhmm.format(tecnico.inicioTurno)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gray100))),
      child: Row(
        children: <Widget>[
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  tecnico.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.gray900),
                ),
                Text(
                  '${tecnico.categoria} · ${_hhmm.format(tecnico.inicioTurno)}–${_hhmm.format(tecnico.finTurno)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_detalle(), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
