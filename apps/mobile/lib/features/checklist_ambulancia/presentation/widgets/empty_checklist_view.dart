import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Vista vacía cuando no hay checklists
///
/// Se muestra cuando el usuario aún no ha realizado ningún checklist
class EmptyChecklistView extends StatelessWidget {
  const EmptyChecklistView({
    super.key,
    this.onCrearChecklist,
  });

  /// Callback cuando el usuario toca el botón de crear checklist
  final VoidCallback? onCrearChecklist;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono grande
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.checklist_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Título
            const Text(
              'No hay checklists',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Descripción
            const Text(
              'Aún no has realizado ningún checklist de ambulancia.\n'
              'Crea tu primer checklist para comenzar.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.gray600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Botón de acción
            if (onCrearChecklist != null)
              ElevatedButton.icon(
                onPressed: onCrearChecklist,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Nuevo Checklist',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
