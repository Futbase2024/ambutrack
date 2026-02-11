import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Diálogo profesional de confirmación
///
/// Características:
/// - Diseño moderno con icono grande y colores según severidad
/// - barrierDismissible: false (no se cierra tocando fuera)
/// - Botones con estilos consistentes
/// - Padding y spacing profesionales
///
/// Uso:
/// ```dart
/// final confirmed = await showProfessionalConfirmDialog(
///   context,
///   title: '¿Eliminar notificación?',
///   message: 'Esta acción no se puede deshacer.',
///   icon: Icons.warning_amber_rounded,
///   iconColor: AppColors.warning,
///   confirmLabel: 'Eliminar',
///   cancelLabel: 'Cancelar',
/// );
/// ```
Future<bool?> showProfessionalConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required IconData icon,
  required Color iconColor,
  String? cancelLabel,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono con fondo de color
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Mensaje
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.gray700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                if (cancelLabel != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.gray300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        cancelLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
