import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Item de acción para el menú contextual
class ActionMenuItem {
  const ActionMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor = AppColors.primary,
    this.textColor = AppColors.textPrimaryLight,
    this.isDanger = false,
    this.isDisabled = false,
    this.description,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color iconColor;
  final Color textColor;
  final bool isDanger;
  final bool isDisabled;
  final String? description;
}

/// Menú contextual profesional con diseño moderno
///
/// Uso:
/// ```dart
/// ActionMenu(
///   items: [
///     ActionMenuItem(
///       value: 'edit',
///       label: 'Editar',
///       icon: Icons.edit_outlined,
///       iconColor: AppColors.primary,
///     ),
///     ActionMenuItem(
///       value: 'delete',
///       label: 'Eliminar',
///       icon: Icons.delete_outline,
///       isDanger: true,
///     ),
///   ],
///   onSelected: (value) {
///     print('Selected: $value');
///   },
/// )
/// ```
class ActionMenu extends StatelessWidget {
  const ActionMenu({
    required this.items,
    required this.onSelected,
    this.icon,
    this.tooltip = 'Acciones',
    this.iconSize = 20,
    this.menuWidth = 220,
    super.key,
  });

  final List<ActionMenuItem> items;
  final void Function(String) onSelected;
  final Widget? icon;
  final String tooltip;
  final double iconSize;
  final double menuWidth;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.15),
      ),
      child: PopupMenuButton<String>(
        icon: icon ??
            Icon(
              Icons.more_vert_rounded,
              size: iconSize,
              color: AppColors.primary,
            ),
        tooltip: tooltip,
        offset: const Offset(0, 8),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          side: const BorderSide(
            color: AppColors.gray200,
          ),
        ),
        padding: EdgeInsets.zero,
        splashRadius: 20,
        onSelected: onSelected,
        itemBuilder: (BuildContext context) {
          return items.asMap().entries.map((MapEntry<int, ActionMenuItem> entry) {
            final int index = entry.key;
            final ActionMenuItem item = entry.value;
            final bool isLast = index == items.length - 1;
            final bool isDividerBefore = index > 0 && items[index - 1].isDanger != item.isDanger;

            return PopupMenuItem<String>(
              value: item.value,
              enabled: !item.isDisabled,
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Divider opcional antes del item
                  if (isDividerBefore)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.gray200,
                    ),

                  // Item del menú
                  Container(
                    width: menuWidth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSmall,
                      vertical: 10,
                    ),
                    child: Row(
                      children: <Widget>[
                        // Icono (solo si está definido)
                        if (item.icon != null) ...<Widget>[
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: item.isDisabled
                                  ? AppColors.gray100
                                  : item.iconColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            ),
                            child: Icon(
                              item.icon,
                              size: 16,
                              color: item.isDisabled
                                  ? AppColors.gray400
                                  : item.isDanger
                                      ? AppColors.error
                                      : item.iconColor,
                            ),
                          ),
                          const SizedBox(width: AppSizes.paddingSmall),
                        ],

                        // Label y descripción
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // Label
                              Text(
                                item.label,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: item.isDisabled
                                      ? AppColors.gray400
                                      : item.isDanger
                                          ? AppColors.error
                                          : item.textColor,
                                ),
                              ),

                              // Descripción opcional
                              if (item.description != null &&
                                  item.description!.isNotEmpty) ...<Widget>[
                                const SizedBox(height: 2),
                                Text(
                                  item.description!,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textSecondaryLight,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Indicador de peligro
                        if (item.isDanger && !item.isDisabled)
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Divider al final si no es el último
                  if (!isLast && !isDividerBefore)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.gray100,
                    ),
                ],
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
