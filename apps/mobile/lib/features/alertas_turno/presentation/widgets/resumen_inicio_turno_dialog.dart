import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/aviso_caducidad.dart';
import 'alertas_turno_lista.dart';
import 'alertas_turno_sheet.dart';

/// Diálogo de "Turno iniciado" con todas las caducidades (solo informa)
Future<void> showResumenInicioTurnoDialog(
  BuildContext context, {
  required String mensaje,
  required List<AvisoCaducidad> avisos,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ResumenInicioTurnoDialog(mensaje: mensaje, avisos: avisos),
  );
}

class _ResumenInicioTurnoDialog extends StatelessWidget {
  const _ResumenInicioTurnoDialog({required this.mensaje, required this.avisos});

  final String mensaje;
  final List<AvisoCaducidad> avisos;

  bool get _hayMaterial => avisos.any((AvisoCaducidad a) => a.origen == OrigenAviso.material);

  @override
  Widget build(BuildContext context) {
    final RoundedRectangleBorder forma = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle_outline, size: 48, color: AppColors.success),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Turno iniciado',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
                ),
                const SizedBox(height: 8),
                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.gray700),
                ),
                const SizedBox(height: 16),
                Flexible(child: SingleChildScrollView(child: AlertasTurnoLista(avisos: avisos))),
                const SizedBox(height: 12),
                if (_hayMaterial) ...<Widget>[
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(rutaCaducidadesMaterial);
                    },
                    icon: const Icon(Icons.medication_outlined),
                    label: const Text('Ver caducidades del material'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: forma),
                  ),
                  const SizedBox(height: 8),
                ],
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: forma,
                  ),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
