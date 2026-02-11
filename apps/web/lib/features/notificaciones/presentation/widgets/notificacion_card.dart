import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Widget que muestra una notificación individual
class NotificacionCard extends StatelessWidget {
  const NotificacionCard({
    super.key,
    required this.notificacion,
    this.onTap,
    this.onMarkAsRead,
  });

  final NotificacionEntity notificacion;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isLeida = notificacion.leida;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLeida
              ? AppColors.backgroundLight
              : AppColors.primary.withValues(alpha: 0.05),
          border: Border(
            left: BorderSide(
              color: isLeida ? AppColors.gray300 : _getTipoColor(),
              width: isLeida ? 2 : 4,
            ),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Icono según tipo
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getTipoColor().withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTipoIcon(),
                color: _getTipoColor(),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Título
                  Text(
                    notificacion.titulo,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isLeida ? FontWeight.normal : FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Mensaje
                  Text(
                    notificacion.mensaje,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Fecha
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(notificacion.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Botón de marcar como leída (si no está leída)
            if (!isLeida && onMarkAsRead != null)
              IconButton(
                icon: const Icon(Icons.check_circle_outline, size: 20),
                color: AppColors.success,
                onPressed: onMarkAsRead,
                tooltip: 'Marcar como leída',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTipoColor() {
    switch (notificacion.tipo) {
      case NotificacionTipo.vacacionSolicitada:
      case NotificacionTipo.ausenciaSolicitada:
        return AppColors.info;
      case NotificacionTipo.vacacionAprobada:
      case NotificacionTipo.ausenciaAprobada:
        return AppColors.success;
      case NotificacionTipo.vacacionRechazada:
      case NotificacionTipo.ausenciaRechazada:
        return AppColors.error;
      case NotificacionTipo.alerta:
        return AppColors.emergency;
      case NotificacionTipo.cambioTurno:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTipoIcon() {
    switch (notificacion.tipo) {
      case NotificacionTipo.vacacionSolicitada:
      case NotificacionTipo.vacacionAprobada:
      case NotificacionTipo.vacacionRechazada:
        return Icons.beach_access_outlined;
      case NotificacionTipo.ausenciaSolicitada:
      case NotificacionTipo.ausenciaAprobada:
      case NotificacionTipo.ausenciaRechazada:
        return Icons.event_busy_outlined;
      case NotificacionTipo.cambioTurno:
        return Icons.swap_horiz_outlined;
      case NotificacionTipo.alerta:
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
