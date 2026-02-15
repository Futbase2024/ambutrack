import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Tarjetas de estadísticas de consumo de combustible
class ConsumoStatsCards extends StatelessWidget {
  const ConsumoStatsCards({
    required this.estadisticas,
    super.key,
  });

  final Map<String, double> estadisticas;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatCard(
            title: 'Consumo Promedio',
            value: estadisticas['consumo_promedio']?.toStringAsFixed(1) ?? '0.0',
            unit: 'L/100km',
            icon: Icons.speed,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: _StatCard(
            title: 'Km Este Mes',
            value: estadisticas['km_recorridos']?.toStringAsFixed(0) ?? '0',
            unit: 'km',
            icon: Icons.timeline,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: _StatCard(
            title: 'Costo Este Mes',
            value: estadisticas['costo_total']?.toStringAsFixed(0) ?? '0',
            unit: '€',
            icon: Icons.euro,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: _StatCard(
            title: 'Litros Totales',
            value: estadisticas['litros_totales']?.toStringAsFixed(0) ?? '0',
            unit: 'L',
            icon: Icons.local_gas_station,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
