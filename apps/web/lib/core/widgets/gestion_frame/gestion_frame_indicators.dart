import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Interruptor compacto tipo "chip" para filtros booleanos
class GestionToggleChip extends StatelessWidget {
  const GestionToggleChip({
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
    super.key,
  });

  final String label;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final Color fg = value ? AppColors.primary : AppColors.gray600;
    return Material(
      color: value ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: value ? AppColors.primary : AppColors.gray300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                value ? Icons.check_box : Icons.check_box_outline_blank,
                size: 16,
                color: fg,
              ),
              const SizedBox(width: 6),
              if (icon != null) ...<Widget>[
                Icon(icon, size: 14, color: fg),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Indicador compacto para la barra de herramientas (aviso, KPI, estado)
class GestionToolbarBadge extends StatelessWidget {
  const GestionToolbarBadge({
    required this.label,
    required this.color,
    this.icon,
    super.key,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
