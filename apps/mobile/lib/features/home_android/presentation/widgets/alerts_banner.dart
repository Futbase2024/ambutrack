import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Banner de alertas de caducidad para Home Dashboard
///
/// Características:
/// - Gradiente amarillo/amber
/// - Icono de warning
/// - Contador de alertas
/// - Botón de acción
/// - Diseño Material 3
class AlertsBanner extends StatelessWidget {
  const AlertsBanner({
    super.key,
    this.alertCount = 0,
    this.message,
    this.onPressed,
  });

  final int alertCount;
  final String? message;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // No mostrar si no hay alertas
    if (alertCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withValues(alpha: 0.1),
            AppColors.warning.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono de warning
                _WarningIcon(),
                const SizedBox(width: 16),

                // Contenido del mensaje
                Expanded(
                  child: _AlertContent(
                    alertCount: alertCount,
                    message: message,
                  ),
                ),

                // Botón de acción
                if (onPressed != null) _ReviewButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget del icono de warning
class _WarningIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

/// Widget con el contenido de la alerta
class _AlertContent extends StatelessWidget {
  const _AlertContent({
    required this.alertCount,
    this.message,
  });

  final int alertCount;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título
        const Text(
          'Alertas de Caducidad',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.warning,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 4),

        // Mensaje con contador
        Text(
          message ?? _getDefaultMessage(),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.warning.withValues(alpha: 0.85),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  String _getDefaultMessage() {
    if (alertCount == 1) {
      return 'Tienes 1 certificación próxima a vencer. Revisa los detalles.';
    }
    return 'Tienes $alertCount certificaciones próximas a vencer. Revisa los detalles.';
  }
}

/// Widget del botón de revisar
class _ReviewButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'REVISAR',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
