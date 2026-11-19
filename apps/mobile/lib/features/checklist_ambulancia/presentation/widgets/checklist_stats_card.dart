import 'package:flutter/material.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../../../core/theme/app_colors.dart';

/// Card con estadísticas del checklist
///
/// Muestra:
/// - Porcentaje de completado (circular progress)
/// - Items presentes (verde)
/// - Items ausentes (rojo)
/// - Estado general (badge)
class ChecklistStatsCard extends StatelessWidget {
  const ChecklistStatsCard({
    super.key,
    required this.checklist,
  });

  final ChecklistVehiculoEntity checklist;

  @override
  Widget build(BuildContext context) {
    final porcentaje = checklist.porcentajeCompleto;
    final color = _getColorPorcentaje(porcentaje);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Circular progress indicator
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: porcentaje / 100,
                      backgroundColor: AppColors.gray200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeWidth: 6,
                    ),
                  ),
                  Text(
                    '${porcentaje.toInt()}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Estadísticas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatRow(
                    icon: Icons.check_circle,
                    iconColor: AppColors.success,
                    label: 'Presentes',
                    value: checklist.itemsPresentes.toString(),
                  ),
                  const SizedBox(height: 8),
                  _StatRow(
                    icon: Icons.cancel,
                    iconColor: AppColors.error,
                    label: 'Ausentes',
                    value: checklist.itemsAusentes.toString(),
                  ),
                  const SizedBox(height: 8),
                  _StatRow(
                    icon: Icons.checklist,
                    iconColor: AppColors.info,
                    label: 'Total',
                    value: checklist.items.length.toString(),
                  ),
                ],
              ),
            ),

            // Badge estado
            Align(
              alignment: Alignment.topRight,
              child: _EstadoBadge(completo: checklist.checklistCompleto),
            ),
          ],
        ),
      ),
    );
  }

  /// Determina el color según el porcentaje
  Color _getColorPorcentaje(double porcentaje) {
    if (porcentaje == 100) {
      return AppColors.success;
    } else if (porcentaje >= 80) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}

/// Fila de estadística individual
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.gray600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
      ],
    );
  }
}

/// Badge de estado del checklist
class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.completo});

  final bool completo;

  @override
  Widget build(BuildContext context) {
    final color = completo ? AppColors.success : AppColors.error;
    final label = completo ? 'OK' : 'NOK';

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
