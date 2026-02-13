import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Header con estadísticas y filtros de caducidades
///
/// Muestra chips de filtro con contadores:
/// - Todas (total)
/// - OK (> 30 días)
/// - Próximas (8-30 días)
/// - Críticas (0-7 días)
/// - Caducadas (< 0 días)
class CaducidadesStatsHeader extends StatelessWidget {
  const CaducidadesStatsHeader({
    super.key,
    required this.totalItems,
    required this.itemsOk,
    required this.itemsProximos,
    required this.itemsCriticos,
    required this.itemsCaducados,
    this.filtroActual,
    this.onFiltroChanged,
  });

  final int totalItems;
  final int itemsOk;
  final int itemsProximos;
  final int itemsCriticos;
  final int itemsCaducados;
  final String? filtroActual;
  final ValueChanged<String?>? onFiltroChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.gray50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text(
            'Filtrar por estado',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 12),

          // Chips de filtro
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChipWidget(
                label: 'Todas',
                count: totalItems,
                filtro: null,
                color: AppColors.primary,
                isSelected: filtroActual == null,
                onSelected: onFiltroChanged,
              ),
              _FilterChipWidget(
                label: 'OK',
                count: itemsOk,
                filtro: 'ok',
                color: AppColors.success,
                isSelected: filtroActual == 'ok',
                onSelected: onFiltroChanged,
              ),
              _FilterChipWidget(
                label: 'Próximas',
                count: itemsProximos,
                filtro: 'proximo',
                color: AppColors.warning,
                isSelected: filtroActual == 'proximo',
                onSelected: onFiltroChanged,
              ),
              _FilterChipWidget(
                label: 'Críticas',
                count: itemsCriticos,
                filtro: 'critico',
                color: AppColors.error,
                isSelected: filtroActual == 'critico',
                onSelected: onFiltroChanged,
              ),
              _FilterChipWidget(
                label: 'Caducadas',
                count: itemsCaducados,
                filtro: 'caducado',
                color: AppColors.emergency,
                isSelected: filtroActual == 'caducado',
                onSelected: onFiltroChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget para chip de filtro individual
class _FilterChipWidget extends StatelessWidget {
  const _FilterChipWidget({
    required this.label,
    required this.count,
    required this.filtro,
    required this.color,
    required this.isSelected,
    this.onSelected,
  });

  final String label;
  final int count;
  final String? filtro;
  final Color color;
  final bool isSelected;
  final ValueChanged<String?>? onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? color : Colors.white,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected?.call(filtro),
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : AppColors.gray700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : AppColors.gray300,
        width: isSelected ? 1.5 : 1,
      ),
    );
  }
}
