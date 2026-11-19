import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/alertas_turno_cubit.dart';
import 'alertas_turno_lista.dart';

/// Ruta de la pantalla de caducidades del material del vehículo
const String rutaCaducidadesMaterial = '/vehiculo/caducidades';

/// Hoja con todas las caducidades pendientes (se abre desde el icono de la barra)
Future<void> showAlertasTurnoSheet(BuildContext context) {
  final AlertasTurnoCubit cubit = context.read<AlertasTurnoCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => BlocProvider<AlertasTurnoCubit>.value(value: cubit, child: const _AlertasTurnoSheet()),
  );
}

class _AlertasTurnoSheet extends StatelessWidget {
  const _AlertasTurnoSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: BlocBuilder<AlertasTurnoCubit, AlertasTurnoState>(
          builder: (BuildContext context, AlertasTurnoState state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    state.matricula == null ? 'Caducidades' : 'Caducidades · ${state.matricula}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
                  ),
                ),
                Flexible(
                  child: state.hayAvisos
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child: AlertasTurnoLista(avisos: state.avisos),
                        )
                      : const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Todo en orden: no hay nada caducado ni a punto de caducar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.gray600),
                          ),
                        ),
                ),
                _Acciones(mostrarMaterial: state.matricula != null),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Acciones extends StatelessWidget {
  const _Acciones({required this.mostrarMaterial});

  final bool mostrarMaterial;

  @override
  Widget build(BuildContext context) {
    final RoundedRectangleBorder forma = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: <Widget>[
          if (mostrarMaterial) ...<Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push(rutaCaducidadesMaterial);
                },
                icon: const Icon(Icons.medication_outlined),
                label: const Text('Ver material'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: forma),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: forma),
              child: const Text('Entendido'),
            ),
          ),
        ],
      ),
    );
  }
}
