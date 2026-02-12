import 'package:flutter/material.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../../../core/theme/app_colors.dart';

/// Diálogo de notificación in-app que aparece en medio de la pantalla
///
/// Se muestra cuando la app está en primer plano (abierta)
/// Diseño profesional con icono, título, mensaje y botones de acción
class NotificacionInAppDialog extends StatelessWidget {
  const NotificacionInAppDialog({
    required this.notificacion,
    required this.onAbrirNotificaciones,
    super.key,
  });

  final NotificacionEntity notificacion;
  final VoidCallback onAbrirNotificaciones;

  @override
  Widget build(BuildContext context) {
    final config = _getNotificationConfig(notificacion.tipo);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: config.color.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: config.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.icon,
                size: 48,
                color: config.color,
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              notificacion.titulo,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Mensaje
            Text(
              notificacion.mensaje,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: AppColors.gray300),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onAbrirNotificaciones();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: config.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ver',
                      style: TextStyle(
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
    );
  }

  /// Obtiene la configuración visual según el tipo de notificación
  _NotificationConfig _getNotificationConfig(NotificacionTipo tipo) {
    switch (tipo) {
      case NotificacionTipo.alerta:
        return _NotificationConfig(
          icon: Icons.warning_rounded,
          color: AppColors.error,
        );

      case NotificacionTipo.trasladoAsignado:
        return _NotificationConfig(
          icon: Icons.local_shipping_rounded,
          color: AppColors.primary,
        );

      case NotificacionTipo.trasladoDesadjudicado:
        return _NotificationConfig(
          icon: Icons.cancel_rounded,
          color: AppColors.primary, // ✅ Azul (era warning/naranja)
        );

      case NotificacionTipo.trasladoIniciado:
        return _NotificationConfig(
          icon: Icons.play_circle_rounded,
          color: AppColors.primary, // ✅ Azul (era success/verde)
        );

      case NotificacionTipo.trasladoFinalizado:
        return _NotificationConfig(
          icon: Icons.check_circle_rounded,
          color: AppColors.primary, // ✅ Azul (era success/verde)
        );

      case NotificacionTipo.trasladoCancelado:
        return _NotificationConfig(
          icon: Icons.cancel_rounded,
          color: AppColors.primary, // ✅ Azul (era error/rojo)
        );

      default:
        return _NotificationConfig(
          icon: Icons.notifications_rounded,
          color: AppColors.primary, // ✅ Azul (era info)
        );
    }
  }
}

/// Configuración visual de la notificación
class _NotificationConfig {
  const _NotificationConfig({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}
