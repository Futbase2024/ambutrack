import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
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
          context.go('/vacaciones');
          break;
        case NotificacionTipo.ausenciaSolicitada:
        case NotificacionTipo.ausenciaAprobada:
        case NotificacionTipo.ausenciaRechazada:
          // Navegar a ausencias
          context.go('/ausencias');
          break;
        case NotificacionTipo.cambioTurno:
          // Navegar a tráfico diario
          context.go('/trafico-diario');
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

            if (notificaciones.isEmpty) {
              return const _NotificacionesEmptyState(
                icon: Icons.notifications_none_outlined,
                title: 'Sin notificaciones',
                message: 'No tienes notificaciones nuevas',
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Header
                _Header(conteoNoLeidas: conteoNoLeidas),

                // Lista de notificaciones
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: notificaciones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final NotificacionEntity notificacion = notificaciones[index];
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
                    },
                  ),
                ),

                // Footer con botones de acción
                if (notificaciones.isNotEmpty)
                  _FooterButtons(
                    conteoNoLeidas: conteoNoLeidas,
                    totalNotificaciones: notificaciones.length,
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
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.conteoNoLeidas});

  final int conteoNoLeidas;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.notifications_outlined,
            color: AppColors.backgroundLight,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Notificaciones',
            style: TextStyle(
              color: AppColors.backgroundLight,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          if (conteoNoLeidas > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.emergency,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$conteoNoLeidas',
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
      Navigator.of(context).pop();
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
                      Navigator.of(context).pop();
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

