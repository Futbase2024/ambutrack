part of 'gestion_grid.dart';

/// Celda con ancho fijo o flexible
class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.child,
    this.flex = 1,
    this.width,
    this.alignment = Alignment.centerLeft,
  });

  final Widget child;
  final int flex;
  final double? width;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.gray200, width: 0.5)),
      ),
      child: child,
    );
    if (width != null) {
      return SizedBox(width: width, child: content);
    }
    return Expanded(flex: flex, child: content);
  }
}

class _GridHeader<T> extends StatelessWidget {
  const _GridHeader({required this.columns, required this.sort, this.onSort});

  final List<GestionColumn<T>> columns;
  final GestionSort sort;
  final ValueChanged<GestionSort>? onSort;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kHeaderHeight,
      decoration: const BoxDecoration(
        color: AppColors.tableHeaderBg,
        border: Border(bottom: BorderSide(color: AppColors.gray300)),
      ),
      child: Row(
        children: <Widget>[
          const _GridCell(
            width: _kNumberWidth,
            alignment: Alignment.center,
            child: Text('#', style: _headerStyle),
          ),
          for (int i = 0; i < columns.length; i++)
            _GridCell(
              flex: columns[i].flex,
              width: columns[i].width,
              alignment: columns[i].alignment,
              child: _HeaderLabel(
                label: columns[i].label,
                sortable: columns[i].sortable && onSort != null,
                active: sort.columnIndex == i,
                ascending: sort.ascending,
                onTap: () => onSort?.call(sort.toggle(i)),
              ),
            ),
        ],
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 11.5,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.3,
  color: AppColors.tableHeaderText,
);

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel({
    required this.label,
    required this.sortable,
    required this.active,
    required this.ascending,
    required this.onTap,
  });

  final String label;
  final bool sortable;
  final bool active;
  final bool ascending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget text = Text(
      label.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _headerStyle,
    );
    if (!sortable) {
      return text;
    }
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(child: text),
          const SizedBox(width: 4),
          Icon(
            active
                ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
                : Icons.unfold_more,
            size: 13,
            color: active ? AppColors.primary : AppColors.gray400,
          ),
        ],
      ),
    );
  }
}

class _GridRow<T> extends StatelessWidget {
  const _GridRow({
    required this.item,
    required this.number,
    required this.columns,
    required this.striped,
    required this.selected,
    required this.onTap,
    this.onDoubleTap,
  });

  final T item;
  final int number;
  final List<GestionColumn<T>> columns;
  final bool striped;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = selected
        ? AppColors.primarySurface
        : striped
            ? AppColors.gray50
            : Colors.white;

    return Material(
      color: bg,
      child: InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        hoverColor: AppColors.gray100,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
              bottom: const BorderSide(color: AppColors.gray200, width: 0.5),
            ),
          ),
          child: DefaultTextStyle(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.gray900),
            child: Row(
              children: <Widget>[
                _GridCell(
                  width: _kNumberWidth - 3,
                  alignment: Alignment.center,
                  child: Text(
                    '$number',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
                  ),
                ),
                for (final GestionColumn<T> c in columns)
                  _GridCell(
                    flex: c.flex,
                    width: c.width,
                    alignment: c.alignment,
                    child: c.cell(item),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridEmpty extends StatelessWidget {
  const _GridEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.inbox_outlined, size: 36, color: AppColors.gray300),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}
