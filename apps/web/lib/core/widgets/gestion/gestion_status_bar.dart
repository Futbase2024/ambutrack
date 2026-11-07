import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Estado de paginación de la barra de estado
class GestionPagination {
  const GestionPagination({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.pageSizes = const <int>[25, 50, 100],
  });

  /// Página actual (base 0)
  final int page;
  final int pageSize;
  final int totalItems;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;
  final List<int> pageSizes;

  int get totalPages => totalItems == 0 ? 1 : (totalItems / pageSize).ceil();
  int get firstItem => totalItems == 0 ? 0 : page * pageSize + 1;
  int get lastItem => ((page + 1) * pageSize).clamp(0, totalItems);
}

/// Barra de estado inferior: resumen a la izquierda y paginación a la derecha
class GestionStatusBar extends StatelessWidget {
  const GestionStatusBar({
    required this.items,
    this.pagination,
    super.key,
  });

  /// Textos de resumen ("3 registros", "Propios 1", ...)
  final List<String> items;
  final GestionPagination? pagination;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              items.join('   ·   '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.gray600),
            ),
          ),
          if (pagination != null) _PaginationControls(p: pagination!),
        ],
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  const _PaginationControls({required this.p});

  final GestionPagination p;

  @override
  Widget build(BuildContext context) {
    final bool back = p.page > 0;
    final bool forward = p.page < p.totalPages - 1;
    const TextStyle style = TextStyle(fontSize: 12, color: AppColors.gray600);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text('Filas:', style: style),
        const SizedBox(width: 4),
        DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: p.pageSize,
            isDense: true,
            focusColor: Colors.transparent,
            icon: const Icon(Icons.expand_more, size: 14),
            style: const TextStyle(fontSize: 12, color: AppColors.gray900),
            items: p.pageSizes
                .map((int s) => DropdownMenuItem<int>(value: s, child: Text('$s')))
                .toList(),
            onChanged: (int? v) {
              if (v != null) {
                p.onPageSizeChanged(v);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Text('${p.firstItem}–${p.lastItem} de ${p.totalItems}', style: style),
        const SizedBox(width: 10),
        _PageButton(
          icon: Icons.first_page,
          tooltip: 'Primera página',
          onTap: back ? () => p.onPageChanged(0) : null,
        ),
        _PageButton(
          icon: Icons.chevron_left,
          tooltip: 'Anterior',
          onTap: back ? () => p.onPageChanged(p.page - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            'Pág ${p.page + 1} de ${p.totalPages}',
            style: style.copyWith(fontWeight: FontWeight.w600, color: AppColors.gray800),
          ),
        ),
        _PageButton(
          icon: Icons.chevron_right,
          tooltip: 'Siguiente',
          onTap: forward ? () => p.onPageChanged(p.page + 1) : null,
        ),
        _PageButton(
          icon: Icons.last_page,
          tooltip: 'Última página',
          onTap: forward ? () => p.onPageChanged(p.totalPages - 1) : null,
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.icon, required this.tooltip, this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 26,
          height: 26,
          child: Icon(
            icon,
            size: 16,
            color: onTap == null ? AppColors.gray300 : AppColors.gray700,
          ),
        ),
      ),
    );
  }
}
