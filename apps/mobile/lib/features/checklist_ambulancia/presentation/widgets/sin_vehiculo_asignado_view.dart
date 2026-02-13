import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Vista cuando el usuario no tiene vehículo asignado hoy
///
/// Se muestra cuando el personal no tiene un vehículo asignado en el trafico diario
class SinVehiculoAsignadoView extends StatelessWidget {
  const SinVehiculoAsignadoView({
    super.key,
    this.onSeleccionarManual,
    this.mostrarBotonSeleccion = false,
  });

  /// Callback para seleccionar vehículo manualmente (solo admin/coordinador)
  final VoidCallback? onSeleccionarManual;

  /// Mostrar botón de selección manual (solo para admin/coordinador)
  final bool mostrarBotonSeleccion;

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
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                size: 64,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),

            // Título
            const Text(
              'Sin Vehículo Asignado',
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
              'No tienes un vehículo asignado para hoy.\n\n'
              'Contacta con tu coordinador para que te asigne un vehículo en el tráfico diario.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.gray600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // Botón de selección manual (solo admin/coordinador)
            if (mostrarBotonSeleccion && onSeleccionarManual != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onSeleccionarManual,
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
                icon: const Icon(Icons.settings, size: 20),
                label: const Text(
                  'Seleccionar Vehículo',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
