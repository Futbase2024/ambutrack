import 'package:flutter/material.dart';

/// Estado vacío cuando no hay notificaciones
class NotificacionesEmptyState extends StatelessWidget {
  const NotificacionesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay notificaciones',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Cuando recibas nuevas notificaciones aparecerán aquí',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
