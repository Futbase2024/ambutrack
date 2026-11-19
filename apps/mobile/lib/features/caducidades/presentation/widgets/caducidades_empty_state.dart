import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Estado vacío para caducidades
///
/// Se muestra cuando:
/// - No hay items con caducidad en el vehículo
/// - El filtro aplicado no devuelve resultados
class CaducidadesEmptyState extends StatelessWidget {
  const CaducidadesEmptyState({
    super.key,
    this.mensaje,
    this.icon,
  });

  final String? mensaje;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 24),
            Text(
              mensaje ?? 'No hay items con caducidad',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Los items con fecha de caducidad aparecerán aquí',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
