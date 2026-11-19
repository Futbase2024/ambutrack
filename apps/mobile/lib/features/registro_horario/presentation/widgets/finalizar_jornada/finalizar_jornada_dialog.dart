import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../servicios/domain/repositories/traslados_repository.dart';
import '../../../domain/repositories/turno_actual_repository.dart';
import '../../cubit/finalizar_jornada_cubit.dart';
import 'fin_turno_campos.dart';

/// Confirmación de fin de jornada con resumen y comprobación de traslados.
///
/// - Traslados iniciados (en origen/tránsito/destino) → no deja finalizar
/// - Traslados de hoy sin iniciar → avisa pero deja finalizar
/// - Si hay inicio de turno abierto pide km final (obligatorio) y P-10 (opcional)
///   y los guarda antes de devolver true.
/// Devuelve true si el trabajador confirma.
Future<bool> showFinalizarJornadaDialog(
  BuildContext context, {
  required String idPersonal,
  DateTime? entrada,
  String? matricula,
}) async {
  final bool? confirmado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider<FinalizarJornadaCubit>(
      create: (_) => FinalizarJornadaCubit(getIt<TrasladosRepository>(), getIt<TurnoActualRepository>())
        ..cargar(idPersonal),
      child: FinalizarJornadaDialog(entrada: entrada, matricula: matricula),
    ),
  );
  return confirmado ?? false;
}

class FinalizarJornadaDialog extends StatefulWidget {
  const FinalizarJornadaDialog({this.entrada, this.matricula, super.key});

  final DateTime? entrada;
  final String? matricula;

  @override
  State<FinalizarJornadaDialog> createState() => _FinalizarJornadaDialogState();
}

class _FinalizarJornadaDialogState extends State<FinalizarJornadaDialog> {
  final TextEditingController _km = TextEditingController();
  final TextEditingController _p10 = TextEditingController();
  String? _errorKm;

  @override
  void dispose() {
    _km.dispose();
    _p10.dispose();
    super.dispose();
  }

  Future<void> _finalizar() async {
    final FinalizarJornadaCubit cubit = context.read<FinalizarJornadaCubit>();
    final int? kmInicial = cubit.state.inicioAbierto?.kmInicial;
    final int? km = int.tryParse(_km.text.trim());
    if (cubit.state.pideKmFinal) {
      final String? error = km == null
          ? 'Indica los km finales del vehículo'
          : kmInicial != null && km < kmInicial
              ? 'No puede ser menor que los km iniciales ($kmInicial)'
              : null;
      setState(() => _errorKm = error);
      if (error != null) {
        return;
      }
    }
    final bool ok = await cubit.confirmar(kmFinal: km, numerosP10: _p10.text.trim());
    if (ok && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<FinalizarJornadaCubit, FinalizarJornadaState>(
            builder: (BuildContext context, FinalizarJornadaState state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const _Icono(),
                  const SizedBox(height: 16),
                  const Text(
                    'Finalizar jornada',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
                  ),
                  const SizedBox(height: 16),
                  _Resumen(entrada: widget.entrada, matricula: widget.matricula),
                  if (state.cargando)
                    const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
                  else ...<Widget>[
                    if (state.bloqueado)
                      _AvisoTraslados(
                        traslados: state.enCurso,
                        color: AppColors.error,
                        texto: 'Tienes traslados en curso. Finalízalos antes de terminar la jornada. '
                            'Si es un error, avisa a coordinación.',
                      )
                    else if (state.pendientesHoy.isNotEmpty)
                      _AvisoTraslados(
                        traslados: state.pendientesHoy,
                        color: AppColors.warning,
                        texto: 'Tienes servicios de hoy asignados sin realizar. '
                            'Coordinación tendrá que reasignarlos.',
                      ),
                    if (state.pideKmFinal && !state.bloqueado)
                      FinTurnoCampos(
                        kmController: _km,
                        p10Controller: _p10,
                        kmInicial: state.inicioAbierto?.kmInicial,
                        errorKm: _errorKm ?? state.error,
                      ),
                  ],
                  const SizedBox(height: 24),
                  _Botones(
                    puedeFinalizar: !state.cargando && !state.bloqueado && !state.guardando,
                    guardando: state.guardando,
                    onFinalizar: _finalizar,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Icono extends StatelessWidget {
  const _Icono();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: const Icon(Icons.logout_rounded, size: 48, color: AppColors.warning),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({this.entrada, this.matricula});

  final DateTime? entrada;
  final String? matricula;

  @override
  Widget build(BuildContext context) {
    final DateTime? inicio = entrada?.toLocal();
    final Duration trabajado = inicio == null ? Duration.zero : DateTime.now().difference(inicio);
    final String horas = '${trabajado.inHours}h ${trabajado.inMinutes.remainder(60).toString().padLeft(2, '0')}m';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: <Widget>[
          _Dato(etiqueta: 'Entrada', valor: inicio == null ? '-' : DateFormat('HH:mm').format(inicio)),
          _Dato(etiqueta: 'Tiempo trabajado', valor: inicio == null ? '-' : horas),
          _Dato(etiqueta: 'Vehículo', valor: matricula ?? 'Sin vehículo'),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(etiqueta, style: const TextStyle(fontSize: 14, color: AppColors.gray600)),
          Text(valor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gray900)),
        ],
      ),
    );
  }
}

class _AvisoTraslados extends StatelessWidget {
  const _AvisoTraslados({required this.traslados, required this.color, required this.texto});

  final List<TrasladoEntity> traslados;
  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(texto, style: const TextStyle(fontSize: 13, color: AppColors.gray800, height: 1.4)),
          const SizedBox(height: 8),
          ...traslados.take(3).map(
                (TrasladoEntity t) => Text(
                  '• ${t.codigo ?? 'Traslado'} · ${t.estadoEnum?.label ?? t.estado ?? ''}'
                  '${t.pacienteNombre != null ? ' · ${t.pacienteNombre}' : ''}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          if (traslados.length > 3)
            Text('y ${traslados.length - 3} más', style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
        ],
      ),
    );
  }
}

class _Botones extends StatelessWidget {
  const _Botones({required this.puedeFinalizar, required this.guardando, required this.onFinalizar});

  final bool puedeFinalizar;
  final bool guardando;
  final VoidCallback onFinalizar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton(
            onPressed: guardando ? null : () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Volver'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: puedeFinalizar ? onFinalizar : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: guardando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Finalizar'),
          ),
        ),
      ],
    );
  }
}
