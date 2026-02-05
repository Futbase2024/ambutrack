import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dropdown con búsqueda para listas grandes
class AppSearchableDropdown<T extends Object> extends StatefulWidget {
  const AppSearchableDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
    this.prefixIcon,
    this.enabled = true,
    this.width,
    this.displayStringForOption,
    this.searchHint = 'Buscar...',
    this.allowClear = true,
  });

  final T? value;
  final List<AppSearchableDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final bool enabled;
  final double? width;
  final String Function(T)? displayStringForOption;
  final String searchHint;
  final bool allowClear;

  @override
  State<AppSearchableDropdown<T>> createState() =>
      _AppSearchableDropdownState<T>();
}

class _AppSearchableDropdownState<T extends Object>
    extends State<AppSearchableDropdown<T>> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(AppSearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      // Actualizar después del frame para evitar "setState during build"
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateControllerText();
        }
      });
    }
  }

  void _updateControllerText() {
    if (widget.value != null) {
      final AppSearchableDropdownItem<T>? selectedItem = widget.items
          .where((AppSearchableDropdownItem<T> item) => item.value == widget.value)
          .firstOrNull;
      if (selectedItem != null) {
        _controller.text = selectedItem.label;
      }
    } else {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _displayStringForOption(T option) {
    if (widget.displayStringForOption != null) {
      return widget.displayStringForOption!(option);
    }
    final AppSearchableDropdownItem<T>? item = widget.items
        .where((AppSearchableDropdownItem<T> i) => i.value == option)
        .firstOrNull;
    return item?.label ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final Widget searchableDropdown = RawAutocomplete<T>(
      focusNode: _focusNode,
      textEditingController: _controller,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return widget.items.map((AppSearchableDropdownItem<T> item) => item.value);
        }
        final String searchText = textEditingValue.text.toLowerCase();
        return widget.items
            .where((AppSearchableDropdownItem<T> item) =>
                item.label.toLowerCase().contains(searchText))
            .map((AppSearchableDropdownItem<T> item) => item.value);
      },
      displayStringForOption: _displayStringForOption,
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          enabled: widget.enabled,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint ?? widget.searchHint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 18, color: AppColors.primary)
                : null,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.value != null && widget.enabled && widget.allowClear)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      textEditingController.clear();
                      widget.onChanged?.call(null);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                // ✅ Hacer clic en la flecha abre el dropdown con todos los items
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 24,
                  ),
                  onPressed: widget.enabled
                      ? () {
                          // Si el campo está vacío, poner un espacio para mostrar todos
                          if (textEditingController.text.isEmpty) {
                            textEditingController.text = ' ';
                          }
                          focusNode.requestFocus();
                          // Limpiar después de un frame para que se muestren todos
                          Future<void>.delayed(const Duration(milliseconds: 50), () {
                            if (textEditingController.text == ' ') {
                              textEditingController.clear();
                            }
                          });
                        }
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: widget.enabled ? AppColors.primary : AppColors.gray400,
                ),
                const SizedBox(width: 8),
              ],
            ),
            filled: true,
            fillColor: widget.enabled ? Colors.white : AppColors.gray50,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.prefixIcon != null ? 12 : 16,
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
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<T> onSelected,
        Iterable<T> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // ✅ Usar el ancho del campo padre o el ancho del widget si está definido
                final double dropdownWidth = widget.width ?? constraints.maxWidth;

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                    minWidth: dropdownWidth,
                    maxWidth: dropdownWidth,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final T option = options.elementAt(index);
                        final AppSearchableDropdownItem<T>? item = widget.items
                            .where((AppSearchableDropdownItem<T> i) => i.value == option)
                            .firstOrNull;

                        if (item == null) {
                          return const SizedBox.shrink();
                        }

                        final bool isSelected = widget.value == option;

                        return InkWell(
                          onTap: () {
                            onSelected(option);
                            widget.onChanged?.call(option);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            color: isSelected
                                ? AppColors.primarySurface
                                : Colors.transparent,
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
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimaryLight,
                                      fontWeight:
                                          isSelected ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      onSelected: (T selection) {
        widget.onChanged?.call(selection);
      },
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: searchableDropdown);
    }

    return searchableDropdown;
  }
}

/// Item para el dropdown con búsqueda
class AppSearchableDropdownItem<T> {
  const AppSearchableDropdownItem({
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
