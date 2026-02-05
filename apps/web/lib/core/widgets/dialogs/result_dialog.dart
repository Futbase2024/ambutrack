import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipo de resultado del diálogo
enum ResultType {
  success,
  error,
  warning,
  info,
}

/// Muestra un diálogo profesional con el resultado de una operación
Future<void> showResultDialog({
  required BuildContext context,
  required String title,
  required String message,
  required ResultType type,
  int? durationMs,
  String? details,
}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return _ResultDialog(
        title: title,
        message: message,
        type: type,
        durationMs: durationMs,
        details: details,
      );
    },
  );
}

class _ResultDialog extends StatelessWidget {
  const _ResultDialog({
    required this.title,
    required this.message,
    required this.type,
    this.durationMs,
    this.details,
  });

  final String title;
  final String message;
  final ResultType type;
  final int? durationMs;
  final String? details;

  Color _getColor() {
    switch (type) {
      case ResultType.success:
        return AppColors.success;
      case ResultType.error:
        return AppColors.error;
      case ResultType.warning:
        return AppColors.warning;
      case ResultType.info:
        return AppColors.info;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case ResultType.success:
        return Icons.check_circle_outline;
      case ResultType.error:
        return Icons.error_outline;
      case ResultType.warning:
        return Icons.warning_amber_outlined;
      case ResultType.info:
        return Icons.info_outline;
    }
  }

  String _getIconEmoji() {
    switch (type) {
      case ResultType.success:
        return '✅';
      case ResultType.error:
        return '❌';
      case ResultType.warning:
        return '⚠️';
      case ResultType.info:
        return 'ℹ️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _getColor();
    final IconData icon = _getIcon();
    final String emoji = _getIconEmoji();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header con color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radius - 2),
                  topRight: Radius.circular(AppSizes.radius - 2),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  // Icono circular
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),
                  // Título
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        if (durationMs != null)
                          Text(
                            '${durationMs}ms',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Mensaje principal
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: AppSizes.spacing),
                      Expanded(
                        child: Text(
                          message,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimaryLight,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Detalles opcionales
                  if (details != null && details!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSizes.spacing),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        border: Border.all(
                          color: AppColors.gray200,
                        ),
                      ),
                      child: Text(
                        details!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSizes.spacingLarge),

                  // Botón de cerrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingMedium,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Entendido',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
