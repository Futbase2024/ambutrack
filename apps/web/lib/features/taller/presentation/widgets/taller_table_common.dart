import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Decoración de input compartida por los filtros del módulo Taller
const InputDecoration _filterInputDecoration = InputDecoration(
  isDense: true,
  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  ),
);

/// Barra de filtros: búsqueda de texto + dropdown de tipo
class TallerSearchFilterBar extends StatelessWidget {
  const TallerSearchFilterBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.filterValue,
    required this.filterItems,
    required this.onFilterChanged,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String filterValue;
  final List<DropdownMenuItem<String>> filterItems;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: _filterInputDecoration.copyWith(
                  hintText: 'Buscar por nombre, ciudad o teléfono...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                ),
                onChanged: onSearchChanged,
              ),
            ),
            const SizedBox(width: AppSizes.spacingMedium),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                initialValue: filterValue,
                decoration: _filterInputDecoration.copyWith(labelText: 'Tipo'),
                items: filterItems,
                onChanged: (String? value) => onFilterChanged(value ?? 'todos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Controles de paginación (25 items/página, 4 botones + badge)
class TallerPaginationBar extends StatelessWidget {
  const TallerPaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.entityLabel,
    required this.onPageChanged,
    super.key,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final String entityLabel;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final int startItem = totalItems == 0 ? 0 : currentPage * itemsPerPage + 1;
    final int endItem = totalItems == 0
        ? 0
        : ((currentPage + 1) * itemsPerPage).clamp(0, totalItems);
    final bool canGoBack = currentPage > 0;
    final bool canGoForward = currentPage < totalPages - 1;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Mostrando $startItem-$endItem de $totalItems $entityLabel',
            style: AppTextStyles.bodySmallSecondary,
          ),
          Row(
            children: <Widget>[
              _PaginationButton(
                onPressed: canGoBack ? () => onPageChanged(0) : null,
                icon: Icons.first_page,
                tooltip: 'Primera página',
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              _PaginationButton(
                onPressed: canGoBack ? () => onPageChanged(currentPage - 1) : null,
                icon: Icons.chevron_left,
                tooltip: 'Página anterior',
              ),
              const SizedBox(width: AppSizes.spacing),
              _PageBadge(currentPage: currentPage, totalPages: totalPages),
              const SizedBox(width: AppSizes.spacing),
              _PaginationButton(
                onPressed: canGoForward ? () => onPageChanged(currentPage + 1) : null,
                icon: Icons.chevron_right,
                tooltip: 'Página siguiente',
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              _PaginationButton(
                onPressed: canGoForward ? () => onPageChanged(totalPages - 1) : null,
                icon: Icons.last_page,
                tooltip: 'Última página',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Badge azul "Página X de Y"
class _PageBadge extends StatelessWidget {
  const _PageBadge({required this.currentPage, required this.totalPages});

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        'Página ${currentPage + 1} de ${totalPages > 0 ? totalPages : 1}',
        style: GoogleFonts.inter(
          fontSize: AppSizes.fontSmall,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Botón de paginación reutilizable
class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacingSmall),
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.gray200,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: enabled
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.gray300,
            ),
          ),
          child: Icon(
            icon,
            size: AppSizes.iconSmall,
            color: enabled ? AppColors.primary : AppColors.gray400,
          ),
        ),
      ),
    );
  }
}
