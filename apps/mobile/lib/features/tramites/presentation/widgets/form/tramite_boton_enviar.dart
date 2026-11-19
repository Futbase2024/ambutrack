import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/dialogs/professional_result_dialog.dart';

/// Barra inferior fija con el botón de enviar la solicitud
class TramiteBotonEnviar extends StatelessWidget {
  const TramiteBotonEnviar({
    super.key,
    required this.onPressed,
    this.enviando = false,
    this.texto = 'Enviar solicitud',
  });

  final VoidCallback onPressed;
  final bool enviando;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: enviando ? null : onPressed,
              icon: enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, size: 20),
              label: Text(
                enviando ? 'Enviando…' : texto,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Diálogos comunes de los formularios de trámites
abstract final class TramiteDialogos {
  /// Falta un dato obligatorio
  static Future<void> faltaDato(BuildContext context, String mensaje) {
    return showProfessionalResultDialog(
      context,
      title: 'Faltan datos',
      message: mensaje,
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
    );
  }

  /// Error al enviar la solicitud
  static Future<void> error(BuildContext context, String mensaje) {
    return showProfessionalResultDialog(
      context,
      title: 'No se pudo enviar',
      message: mensaje,
      icon: Icons.error_outline,
      iconColor: AppColors.error,
    );
  }

  /// Solicitud enviada; al cerrar el diálogo vuelve a la pantalla anterior
  static Future<void> enviada(BuildContext context, String mensaje) async {
    await showProfessionalResultDialog(
      context,
      title: 'Solicitud enviada',
      message: mensaje,
      icon: Icons.check_circle_outline,
      iconColor: AppColors.success,
    );
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
