import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// AppBar mejorado para Home Dashboard con notificaciones
///
/// Características:
/// - Título "AmbuTrack" centrado
/// - Icono de menú a la izquierda
/// - Campana de notificaciones con badge pulsante
/// - Elevation con sombra suave
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.onMenuPressed,
    this.onNotificationsPressed,
    this.hasUnreadNotifications = true,
  });

  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationsPressed;
  final bool hasUnreadNotifications;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 24),
        onPressed: onMenuPressed,
        tooltip: 'Menú',
      ),
      title: const Text(
        'AmbuTrack',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        if (onNotificationsPressed != null)
          _NotificationButton(
            onPressed: onNotificationsPressed!,
            hasUnread: hasUnreadNotifications,
          ),
      ],
    );
  }
}

/// Botón de notificaciones con badge pulsante
class _NotificationButton extends StatefulWidget {
  const _NotificationButton({
    required this.onPressed,
    required this.hasUnread,
  });

  final VoidCallback onPressed;
  final bool hasUnread;

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 24,
          ),
          if (widget.hasUnread)
            Positioned(
              top: 2,
              right: 2,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
            ),
        ],
      ),
      onPressed: widget.onPressed,
      tooltip: 'Notificaciones',
    );
  }
}
