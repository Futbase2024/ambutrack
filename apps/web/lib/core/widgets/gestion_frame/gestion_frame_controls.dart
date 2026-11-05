import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Opción de un selector segmentado compacto
class GestionSegmentOption<T> {
  const GestionSegmentOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// Selector segmentado compacto (32px) para cambiar de vista/modo
class GestionSegmentedSelector<T> extends StatelessWidget {
  const GestionSegmentedSelector({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<GestionSegmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final GestionSegmentOption<T> option in options)
            _SegmentButton(
              label: option.label,
              icon: option.icon,
              selected: option.value == selected,
              onTap: () => onChanged(option.value),
            ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? Colors.white : AppColors.gray700;
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 14, color: fg),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navegador de periodo compacto: `‹  13 - 19 oct  ›`
///
/// Si [onLabelTap] no es null, el texto es pulsable (p. ej. para abrir un
/// selector de fecha).
class GestionPeriodNavigator extends StatelessWidget {
  const GestionPeriodNavigator({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    this.previousTooltip = 'Anterior',
    this.nextTooltip = 'Siguiente',
    this.onLabelTap,
    super.key,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final String previousTooltip;
  final String nextTooltip;
  final VoidCallback? onLabelTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _NavIconButton(icon: Icons.chevron_left, tooltip: previousTooltip, onTap: onPrevious),
          InkWell(
            onTap: onLabelTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  if (onLabelTap != null) ...<Widget>[
                    const SizedBox(width: 6),
                    const Icon(Icons.calendar_today, size: 13, color: AppColors.primary),
                  ],
                ],
              ),
            ),
          ),
          _NavIconButton(icon: Icons.chevron_right, tooltip: nextTooltip, onTap: onNext),
        ],
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 28,
          height: 30,
          child: Icon(icon, size: 18, color: AppColors.gray700),
        ),
      ),
    );
  }
}

/// Desplegable compacto (32px) de ancho fijo con etiqueta delante.
///
/// Admite el valor `null` como opción (p. ej. "Todos").
class GestionCompactDropdown<T> extends StatelessWidget {
  const GestionCompactDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.width = 220,
    super.key,
  });

  final String label;
  final T? value;

  /// Valor → texto visible. Puede incluir la clave `null`.
  final Map<T?, String> options;
  final ValueChanged<T?> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final T? current = options.containsKey(value) ? value : null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '$label:',
          style: const TextStyle(fontSize: 12.5, color: AppColors.gray600),
        ),
        const SizedBox(width: 6),
        Container(
          width: width,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.gray300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T?>(
              value: current,
              isDense: true,
              isExpanded: true,
              focusColor: Colors.transparent,
              icon: const Icon(Icons.expand_more, size: 16),
              style: const TextStyle(fontSize: 13, color: AppColors.gray900),
              items: options.entries
                  .map(
                    (MapEntry<T?, String> e) => DropdownMenuItem<T?>(
                      value: e.key,
                      child: Text(e.value, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
