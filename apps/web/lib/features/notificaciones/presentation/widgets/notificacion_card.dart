import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget que muestra una notificación individual
class NotificacionCard extends StatelessWidget {
  const NotificacionCard({
    super.key,
    required this.notificacion,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  final NotificacionEntity notificacion;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

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

            // Menú de acciones
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                size: 20,
                color: AppColors.gray600,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              elevation: 8,
              offset: const Offset(0, 8),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                // Marcar como leída (solo si no está leída)
                if (!isLeida) ...<PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'mark_read',
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Marcar como leída',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 1),
                ],
                // Eliminar
                PopupMenuItem<String>(
                  value: 'delete',
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Eliminar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (String value) {
                if (value == 'mark_read' && onMarkAsRead != null) {
                  onMarkAsRead!();
                } else if (value == 'delete' && onDelete != null) {
                  onDelete!();
                }
              },
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
      case NotificacionTipo.incidenciaVehiculoReportada:
        return AppColors.error;
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
      case NotificacionTipo.incidenciaVehiculoReportada:
        return Icons.car_crash_outlined;
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
