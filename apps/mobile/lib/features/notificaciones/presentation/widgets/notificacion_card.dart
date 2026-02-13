import 'package:flutter/material.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dialogs/dialogs.dart';

/// Widget para mostrar una notificación individual
///
/// Características:
/// - Borde verde si está leída, borde rojo si no está leída
/// - Icono según tipo de notificación
/// - Swipe-to-delete (Dismissible) - se puede deshabilitar con [showSwipeActions]
/// - Tap para marcar como leída
class NotificacionCard extends StatelessWidget {
  const NotificacionCard({
    required this.notificacion,
    required this.onTap,
    this.onDelete,
    this.showSwipeActions = true,
    super.key,
  });

  final NotificacionEntity notificacion;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool showSwipeActions;

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notificacion.leida
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: notificacion.leida
            ? [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NotificationIcon(tipo: notificacion.tipo),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notificacion.titulo,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: notificacion.leida
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (!notificacion.leida)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notificacion.mensaje,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatearFecha(notificacion.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Si no se deben mostrar acciones de swipe, devolver el card directamente
    if (!showSwipeActions || onDelete == null) {
      return cardWidget;
    }

    // Envolver en Dismissible para swipe-to-delete
    return Dismissible(
      key: Key(notificacion.id),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(),
      confirmDismiss: (_) async {
        // Confirmar eliminación con diálogo profesional
        return await showProfessionalConfirmDialog(
          context,
          title: '¿Eliminar notificación?',
          message: '¿Estás seguro de que quieres eliminar esta notificación? Esta acción no se puede deshacer.',
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.warning,
          confirmLabel: 'Eliminar',
          cancelLabel: 'Cancelar',
        );
      },
      onDismissed: (_) => onDelete!(),
      child: cardWidget,
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (diferencia.inHours < 1) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} h';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} ${diferencia.inDays == 1 ? "día" : "días"}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
    }
  }
}

/// Icono de notificación según el tipo
class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.tipo});

  final NotificacionTipo tipo;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getIconAndColor(context);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  (IconData, Color) _getIconAndColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (tipo) {
      case NotificacionTipo.alerta:
        return (Icons.warning_rounded, colorScheme.error);

      case NotificacionTipo.trasladoAsignado:
        return (Icons.local_shipping_rounded, colorScheme.primary);

      case NotificacionTipo.trasladoDesadjudicado:
        return (Icons.cancel_rounded, Colors.orange);

      case NotificacionTipo.trasladoIniciado:
        return (Icons.play_circle_rounded, Colors.green);

      case NotificacionTipo.trasladoFinalizado:
        return (Icons.check_circle_rounded, Colors.teal);

      case NotificacionTipo.trasladoCancelado:
        return (Icons.cancel_rounded, colorScheme.error);

      case NotificacionTipo.checklistPendiente:
        return (Icons.checklist_rounded, Colors.amber);

      case NotificacionTipo.vacacionSolicitada:
      case NotificacionTipo.ausenciaSolicitada:
        return (Icons.event_rounded, Colors.blue);

      case NotificacionTipo.vacacionAprobada:
      case NotificacionTipo.ausenciaAprobada:
        return (Icons.check_circle_rounded, Colors.green);

      case NotificacionTipo.vacacionRechazada:
      case NotificacionTipo.ausenciaRechazada:
        return (Icons.cancel_rounded, colorScheme.error);

      case NotificacionTipo.cambioTurno:
        return (Icons.swap_horiz_rounded, Colors.indigo);

      case NotificacionTipo.incidenciaVehiculoReportada:
        return (Icons.build_circle_rounded, Colors.orange);

      case NotificacionTipo.alertaCaducidad:
        return (Icons.warning_amber_rounded, Colors.orange);

      case NotificacionTipo.info:
        return (Icons.info_rounded, colorScheme.primary);
    }
  }
}

/// Fondo que se muestra al hacer swipe para eliminar
class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.delete_rounded,
        color: Theme.of(context).colorScheme.onError,
        size: 28,
      ),
    );
  }
}
