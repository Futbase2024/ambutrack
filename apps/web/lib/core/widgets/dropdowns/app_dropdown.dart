import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dropdown personalizado profesional para toda la aplicación
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
    this.prefixIcon,
    this.enabled = true,
    this.width,
    this.clearable = true,
  });

  final T? value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final bool enabled;
  final double? width;
  final bool clearable;

  @override
  Widget build(BuildContext context) {
    final Widget dropdown = DropdownButtonHideUnderline(
      child: DropdownButtonFormField<T>(
        key: ValueKey<T?>(value),
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 18, color: AppColors.primary)
              : null,
          filled: true,
          fillColor: enabled ? Colors.white : AppColors.gray50,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: prefixIcon != null ? 12 : 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.gray200, width: 1.5),
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: AppSizes.fontSmall,
            color: AppColors.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: GoogleFonts.inter(
            fontSize: AppSizes.fontSmall,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: AppSizes.fontSmall,
            color: AppColors.gray400,
          ),
        ),
        style: GoogleFonts.inter(
          fontSize: AppSizes.fontSmall,
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: enabled ? AppColors.primary : AppColors.gray400,
          size: 24,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        items: items.map((AppDropdownItem<T> item) {
          return DropdownMenuItem<T>(
            value: item.value,
            child: Row(
              children: <Widget>[
                if (item.icon != null) ...<Widget>[
                  Icon(
                    item.icon,
                    size: 18,
                    color: item.iconColor ?? AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.fontSmall,
                      color: item.value == value
                          ? AppColors.primary
                          : AppColors.textPrimaryLight,
                      fontWeight:
                          item.value == value ? FontWeight.w600 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.value == value)
                  const Icon(
                    Icons.check,
                    size: 18,
                    color: AppColors.primary,
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
        selectedItemBuilder: (BuildContext context) {
          return items.map((AppDropdownItem<T> item) {
            return Row(
              children: <Widget>[
                if (item.icon != null && prefixIcon == null) ...<Widget>[
                  Icon(
                    item.icon,
                    size: 18,
                    color: item.iconColor ?? AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.fontSmall,
                      color: AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
    );

    // Si clearable está activado y hay un valor, envolver en Stack con botón de limpiar
    final Widget dropdownWithClear = clearable && value != null && enabled
        ? Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              dropdown,
              Positioned(
                right: 36,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (onChanged != null) {
                        onChanged!(null);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.clear,
                        size: 16,
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : dropdown;

    if (width != null) {
      return SizedBox(width: width, child: dropdownWithClear);
    }

    return dropdownWithClear;
  }
}

/// Item para el dropdown personalizado
class AppDropdownItem<T> {
  const AppDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });

  final T value;
  final String label;
  final IconData? icon;
  final Color? iconColor;
}
