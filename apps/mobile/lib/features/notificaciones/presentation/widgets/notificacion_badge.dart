import 'package:flutter/material.dart';

/// Badge de notificaciones con contador
///
/// Muestra un icono de campana con un badge rojo si hay notificaciones no leídas
/// - Con notificaciones: campana blanca sobre fondo circular destacado + badge rojo
/// - Sin notificaciones: campana blanca con fondo sutil para mantener visibilidad
class NotificacionBadge extends StatelessWidget {
  const NotificacionBadge({
    required this.conteoNoLeidas,
    required this.onTap,
    super.key,
  });

  final int conteoNoLeidas;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasNotifications = conteoNoLeidas > 0;

    return IconButton(
      icon: Badge(
        label: hasNotifications
            ? Text(
                conteoNoLeidas > 99 ? '99+' : '$conteoNoLeidas',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
        isLabelVisible: hasNotifications,
        backgroundColor: Colors.red,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: hasNotifications
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            hasNotifications
                ? Icons.notifications_active_rounded
                : Icons.notifications_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      onPressed: onTap,
      tooltip: 'Notificaciones',
    );
  }
}
