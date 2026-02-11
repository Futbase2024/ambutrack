import 'package:ambutrack_core/src/datasources/notificaciones/entities/notificacion_entity.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_bloc.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_event.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_state.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/widgets/notificacion_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

        final String userId = authState.user.uid;

        return BlocProvider(
          create: (BuildContext context) => NotificacionBloc(context.read())
            ..add(NotificacionEvent.subscribeNotificaciones(userId)),
          child: const _NotificacionesContent(),
        );
      },
    );
  }
}

class _NotificacionesContent extends StatelessWidget {
  const _NotificacionesContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificacionBloc, NotificacionState>(
      builder: (BuildContext context, NotificacionState state) {
        return state.map(
          initial: (_) => const Center(child: CircularProgressIndicator()),
          loading: (_) => const Center(child: CircularProgressIndicator()),
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
                        onMarkAsRead: !notificacion.leida
                            ? () => context.read<NotificacionBloc>().add(
                                  NotificacionEvent.marcarComoLeida(notificacion.id),
                                )
                            : null,
                      );
                    },
                  ),
                ),

                // Footer con botón de marcar todas como leídas
                if (conteoNoLeidas > 0) _MarkAllButton(conteoNoLeidas: conteoNoLeidas),
              ],
            );
          },
          error: (errorState) => _NotificacionesErrorState(message: errorState.message),
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
          const Spacer(),
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
        ],
      ),
    );
  }
}

class _MarkAllButton extends StatelessWidget {
  const _MarkAllButton({required this.conteoNoLeidas});

  final int conteoNoLeidas;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, AuthState authState) {
        if (authState is! AuthAuthenticated) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.gray50,
            border: Border(
              top: BorderSide(color: AppColors.gray200),
            ),
          ),
          child: FilledButton.tonal(
            onPressed: () {
              context.read<NotificacionBloc>().add(
                NotificacionEvent.marcarTodasComoLeidas(authState.user.uid),
              );
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              backgroundColor: AppColors.primary,
            ),
            child: Text('Marcar $conteoNoLeidas como leídas'),
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

class _NotificacionesErrorState extends StatelessWidget {
  const _NotificacionesErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar notificaciones',
            style: TextStyle(
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
