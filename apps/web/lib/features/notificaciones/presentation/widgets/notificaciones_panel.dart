import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_bloc.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_state.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_bloc.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_event.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_state.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/widgets/notificacion_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Panel de notificaciones que se muestra al hacer clic en el icono de campana
class NotificacionesPanel extends StatelessWidget {
  const NotificacionesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, AuthState authState) {
        if (authState is! AuthAuthenticated) {
          return const _NotificacionesEmptyState(
            icon: Icons.lock_outline,
            title: 'No autenticado',
            message: 'Inicia sesión para ver tus notificaciones',
          );
        }

        // Usar el NotificacionBloc provisto por MainLayout
        return const _NotificacionesContent();
      },
    );
  }
}

/// Widget para mostrar una alerta de caducidad individual
class _AlertaCaducidadCard extends StatelessWidget {
  const _AlertaCaducidadCard({
    required this.alerta,
    this.onTap,
  });

  final AlertaCaducidadEntity alerta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color severidadColor = _getSeveridadColor();
    final IconData severidadIcon = _getSeveridadIcon();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.05),
          border: Border(
            left: BorderSide(
              color: severidadColor,
              width: 4,
            ),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Icono según severidad
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: severidadColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                severidadIcon,
                color: severidadColor,
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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          alerta.entidadNombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: severidadColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getTipoAlertaLabel(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: severidadColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Mensaje
                  Text(
                    _getAlertaMessage(),
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Badge de severidad y días restantes
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: severidadColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getSeveridadLabel(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getDiasRestantesLabel(),
                        style: TextStyle(
                          color: severidadColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeveridadColor() {
    switch (alerta.severidad) {
      case AlertaSeveridad.critica:
        return AppColors.emergency;
      case AlertaSeveridad.alta:
        return AppColors.error;
      case AlertaSeveridad.media:
        return AppColors.warning;
      case AlertaSeveridad.baja:
        return AppColors.info;
    }
  }

  IconData _getSeveridadIcon() {
    switch (alerta.tipo) {
      case AlertaTipo.seguro:
        return Icons.security_outlined;
      case AlertaTipo.itv:
        return Icons.directions_car_outlined;
      case AlertaTipo.homologacion:
        return Icons.verified_outlined;
      case AlertaTipo.revisionTecnica:
        return Icons.build_outlined;
      case AlertaTipo.mantenimiento:
        return Icons.settings_outlined;
      case AlertaTipo.revision:
        return Icons.receipt_long_outlined;
    }
  }

  String _getTipoAlertaLabel() {
    switch (alerta.tipo) {
      case AlertaTipo.seguro:
        return 'SEGURO';
      case AlertaTipo.itv:
        return 'ITV';
      case AlertaTipo.homologacion:
        return 'HOMOLOGACIÓN';
      case AlertaTipo.revisionTecnica:
        return 'REVISIÓN TÉCNICA';
      case AlertaTipo.mantenimiento:
        return 'MANTENIMIENTO';
      case AlertaTipo.revision:
        return 'REVISIÓN';
    }
  }

  String _getSeveridadLabel() {
    switch (alerta.severidad) {
      case AlertaSeveridad.critica:
        return 'CRÍTICA';
      case AlertaSeveridad.alta:
        return 'ALTA';
      case AlertaSeveridad.media:
        return 'MEDIA';
      case AlertaSeveridad.baja:
        return 'BAJA';
    }
  }

  String _getAlertaMessage() {
    if (alerta.diasRestantes < 0) {
      return 'Vencida hace ${-alerta.diasRestantes} días';
    } else if (alerta.diasRestantes == 0) {
      return 'Vence hoy';
    } else if (alerta.diasRestantes == 1) {
      return 'Vence mañana';
    } else {
      return 'Vence en ${alerta.diasRestantes} días';
    }
  }

  String _getDiasRestantesLabel() {
    if (alerta.diasRestantes < 0) {
      return '⚠️ ${-alerta.diasRestantes} días vencida';
    } else if (alerta.diasRestantes == 0) {
      return '⚠️ Vence hoy';
    } else if (alerta.diasRestantes == 1) {
      return '1 día restante';
    } else {
      return '${alerta.diasRestantes} días restantes';
    }
  }
}

class _NotificacionesContent extends StatelessWidget {
  const _NotificacionesContent();

  /// Navega al detalle correspondiente según el tipo de notificación
  void _navegarADetalle(BuildContext context, NotificacionEntity notificacion) {
    // Cerrar el panel de notificaciones
    Navigator.of(context).pop();

    // Marcar como leída automáticamente al hacer clic
    if (!notificacion.leida) {
      context.read<NotificacionBloc>().add(
        NotificacionEvent.marcarComoLeida(notificacion.id),
      );
    }

    // Navegar según el tipo de notificación y el ID de entidad
    if (notificacion.entidadId != null) {
      switch (notificacion.tipo) {
        case NotificacionTipo.vacacionSolicitada:
        case NotificacionTipo.vacacionAprobada:
        case NotificacionTipo.vacacionRechazada:
          // Navegar a vacaciones
          context.go('/personal/vacaciones');
          break;
        case NotificacionTipo.ausenciaSolicitada:
        case NotificacionTipo.ausenciaAprobada:
        case NotificacionTipo.ausenciaRechazada:
          // Navegar a ausencias
          context.go('/personal/ausencias');
          break;
        case NotificacionTipo.cambioTurno:
          // Navegar a tráfico diario
          context.go('/trafico-diario');
          break;
        case NotificacionTipo.incidenciaVehiculoReportada:
          // Navegar a historial de averías/incidencias
          context.go('/flota/historial-averias');
          break;
        default:
          // Para otros tipos, quedarse en la página actual
          break;
      }
    }
  }

  /// Elimina una notificación después de confirmar
  Future<void> _eliminarNotificacion(BuildContext context, String notificacionId) async {
    // Capturar el bloc antes del showDialog
    final NotificacionBloc notificacionBloc = context.read<NotificacionBloc>();

    // Mostrar diálogo de confirmación profesional
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: 'Eliminar notificación',
      message: '¿Estás seguro de que deseas eliminar esta notificación?\n\nEsta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      icon: Icons.delete_outline,
    );

    // Si el usuario confirmó, eliminar la notificación
    if (confirmed == true && context.mounted) {
      notificacionBloc.add(
        NotificacionEvent.eliminarNotificacion(notificacionId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertasCaducidadBloc, AlertasCaducidadState>(
      builder: (BuildContext context, AlertasCaducidadState alertasState) {
        // Obtener alertas críticas
        final List<AlertaCaducidadEntity> alertasCriticas = alertasState.maybeWhen(
          loaded: (List<AlertaCaducidadEntity> alertas, _, _, _, _) {
            return alertas.where((AlertaCaducidadEntity a) => a.esCritica == true).toList();
          },
          orElse: () => <AlertaCaducidadEntity>[],
        );

        return BlocConsumer<NotificacionBloc, NotificacionState>(
          listener: (BuildContext context, NotificacionState state) {
            // Mostrar diálogos de error cuando ocurren problemas RLS
            state.whenOrNull(
              error: (String message) {
                // Determinar el tipo de error basado en el mensaje
                final IconData icon;
                final Color iconColor;
                final String title;

                if (message.contains('sesión ha expirado') || message.contains('autenticado')) {
                  icon = Icons.lock_outline;
                  iconColor = AppColors.error;
                  title = 'Sesión expirada';
                } else if (message.contains('permisos')) {
                  icon = Icons.shield_outlined;
                  iconColor = AppColors.error;
                  title = 'Sin permisos';
                } else {
                  icon = Icons.error_outline;
                  iconColor = AppColors.error;
                  title = 'Error';
                }

                // Mostrar diálogo profesional
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return Dialog(
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
                              children: <Widget>[
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
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                      // Recargar notificaciones después de cerrar el error
                                      if (context.mounted) {
                                        final AuthState authState = context.read<AuthBloc>().state;
                                        if (authState is AuthAuthenticated) {
                                          context.read<NotificacionBloc>().add(
                                            NotificacionEvent.subscribeNotificaciones(authState.user.uid),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: iconColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Entendido',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                });
              },
            );
          },
          builder: (BuildContext context, NotificacionState state) {
            return state.map(
              initial: (_) => const Center(child: CircularProgressIndicator()),
              loading: (_) => const Center(child: CircularProgressIndicator()),
              // ignore: always_specify_types
              loaded: (loadedState) {
                final List<NotificacionEntity> notificaciones = loadedState.notificaciones;
                final int conteoNoLeidas = loadedState.conteoNoLeidas;

                // Verificar si ambas listas están vacías
                if (alertasCriticas.isEmpty && notificaciones.isEmpty) {
                  return const _NotificacionesEmptyState(
                    icon: Icons.notifications_none_outlined,
                    title: 'Sin notificaciones',
                    message: 'No tienes notificaciones nuevas',
                  );
                }

                final int alertasCount = alertasCriticas.length;
                final int notificacionesCount = notificaciones.length;
                final int totalCount = alertasCount + notificacionesCount;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Header con conteo combinado
                    _Header(
                      conteoNoLeidas: conteoNoLeidas,
                      alertasCriticasCount: alertasCount,
                      totalCount: totalCount,
                    ),

                    // Contenido combinado
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: totalCount,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (BuildContext context, int index) {
                          // Si el índice está dentro del rango de alertas críticas
                          if (index < alertasCount) {
                            final AlertaCaducidadEntity alerta = alertasCriticas[index];
                            return _AlertaCaducidadCard(
                              alerta: alerta,
                              onTap: () {
                                // Cerrar el panel
                                Navigator.of(context).pop();
                                // Navegar a la página de documentación de vehículos
                                context.go('/flota/documentacion-vehiculos');
                              },
                            );
                          }
                          // Si no, es una notificación normal
                          else {
                            final int notifIndex = index - alertasCount;
                            final NotificacionEntity notificacion = notificaciones[notifIndex];
                            return NotificacionCard(
                              notificacion: notificacion,
                              onTap: () => _navegarADetalle(context, notificacion),
                              onMarkAsRead: !notificacion.leida
                                  ? () => context.read<NotificacionBloc>().add(
                                        NotificacionEvent.marcarComoLeida(notificacion.id),
                                      )
                                  : null,
                              onDelete: () => _eliminarNotificacion(context, notificacion.id),
                            );
                          }
                        },
                      ),
                    ),

                    // Footer con botones de acción (solo para notificaciones)
                    if (notificaciones.isNotEmpty)
                      _FooterButtons(
                        conteoNoLeidas: conteoNoLeidas,
                        totalNotificaciones: notificacionesCount,
                      ),
                  ],
                );
              },
              // ignore: always_specify_types
              error: (errorState) {
                // Mantener la vista anterior en caso de error
                // El diálogo ya se mostró en el listener
                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.conteoNoLeidas,
    this.alertasCriticasCount = 0,
    this.totalCount = 0,
  });

  final int conteoNoLeidas;
  final int alertasCriticasCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final bool hasAlertas = alertasCriticasCount > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasAlertas ? AppColors.warning : AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            hasAlertas ? Icons.warning_amber_rounded : Icons.notifications_outlined,
            color: AppColors.backgroundLight,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            hasAlertas ? 'Alertas y Notificaciones' : 'Notificaciones',
            style: const TextStyle(
              color: AppColors.backgroundLight,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          if (totalCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.emergency,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$totalCount',
                style: const TextStyle(
                  color: AppColors.backgroundLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Spacer(),
          // Botón de cerrar
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: AppColors.backgroundLight,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }
}

class _FooterButtons extends StatelessWidget {
  const _FooterButtons({
    required this.conteoNoLeidas,
    required this.totalNotificaciones,
  });

  final int conteoNoLeidas;
  final int totalNotificaciones;

  Future<void> _eliminarTodas(BuildContext context, String usuarioId) async {
    // Capturar el bloc antes del showDialog
    final NotificacionBloc notificacionBloc = context.read<NotificacionBloc>();

    // Mostrar diálogo de confirmación profesional
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: 'Eliminar todas las notificaciones',
      message: '¿Estás seguro de que deseas eliminar todas tus notificaciones ($totalNotificaciones)?\n\nEsta acción no se puede deshacer.',
      confirmText: 'Eliminar todas',
      icon: Icons.delete_sweep,
    );

    // Si el usuario confirmó, eliminar todas
    if (confirmed == true && context.mounted) {
      notificacionBloc.add(
        NotificacionEvent.eliminarTodasNotificaciones(usuarioId),
      );
      // NO cerrar el panel - el stream se actualizará automáticamente
      // y mostrará el estado vacío
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, AuthState authState) {
        if (authState is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.gray50,
            border: Border(
              top: BorderSide(color: AppColors.gray200),
            ),
          ),
          child: Row(
            children: <Widget>[
              // Botón Eliminar todas
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _eliminarTodas(context, authState.user.uid),
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: const Text('Eliminar todas'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),

              // Espaciado
              if (conteoNoLeidas > 0) const SizedBox(width: 12),

              // Botón Marcar como leídas (solo si hay notificaciones no leídas)
              if (conteoNoLeidas > 0)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      context.read<NotificacionBloc>().add(
                        NotificacionEvent.marcarTodasComoLeidas(authState.user.uid),
                      );
                      // NO cerrar el panel - el stream se actualizará automáticamente
                    },
                    icon: const Icon(Icons.done_all, size: 18),
                    label: Text('Marcar $conteoNoLeidas leídas'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.backgroundLight,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificacionesEmptyState extends StatelessWidget {
  const _NotificacionesEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 48,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

