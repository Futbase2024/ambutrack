import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Mensaje de error de carga con botón "Reintentar"
class GestionLoadError extends StatelessWidget {
  const GestionLoadError({
    required this.title,
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 40, color: AppColors.error),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.error),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: AppColors.gray600),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicador de carga inicial
class GestionLoading extends StatelessWidget {
  const GestionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }
}

/// Envuelve la rejilla con una barra de progreso fina durante recargas
class GestionReloading extends StatelessWidget {
  const GestionReloading({required this.loading, required this.child, super.key});

  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        if (loading)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}
