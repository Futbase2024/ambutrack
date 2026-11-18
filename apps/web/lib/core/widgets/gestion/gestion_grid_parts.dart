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
  const _GridHeader({required this.grid});

  final GestionGrid<T> grid;

  Future<void> _openFilter(BuildContext cellContext, int index) async {
    final RenderBox box = cellContext.findRenderObject()! as RenderBox;
    final Rect anchor = box.localToGlobal(Offset.zero) & box.size;
    final GestionColumn<T> column = grid.columns[index];
    // Valores posibles según el resto de filtros (como en Excel)
    final List<T> base = grid.filters.apply(grid.filterSource ?? grid.rows, grid.columns, except: index);
    final GestionColumnFilterResult? result = await showGestionColumnFilterMenu(
      context: cellContext,
      anchor: anchor,
      title: column.label,
      options: GestionColumnFilters.distinct(base, column),
      selected: grid.filters.of(index),
    );
    if (result != null) {
      grid.onFiltersChanged?.call(grid.filters.withColumn(index, result.accepted));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<GestionColumn<T>> columns = grid.columns;
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
          if (grid.showChecks)
            _GridCell(
              width: _kCheckWidth,
              alignment: Alignment.center,
              child: _RowCheck(value: grid.allCheckedState, onTap: grid.toggleAllChecked),
            ),
          for (int i = 0; i < columns.length; i++)
            _GridCell(
              flex: columns[i].flex,
              width: columns[i].width,
              alignment: columns[i].alignment,
              child: _HeaderLabel(
                label: columns[i].label,
                sortable: columns[i].sortable && grid.onSort != null,
                active: grid.sort.columnIndex == i,
                ascending: grid.sort.ascending,
                onTap: () => grid.onSort?.call(grid.sort.toggle(i)),
                filterable: columns[i].filterable && grid.onFiltersChanged != null,
                filtered: grid.filters.isActive(i),
                onFilter: (BuildContext cellContext) => _openFilter(cellContext, i),
                alignment: columns[i].alignment,
                icon: columns[i].headerIcon,
                iconOnly: columns[i].headerIconOnly,
              ),
            ),
        ],
      ),
    );
  }
}

/// Casilla compacta para marcar filas
class _RowCheck extends StatelessWidget {
  const _RowCheck({required this.value, required this.onTap});

  final bool? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool on = value ?? true;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Icon(
        value == null
            ? Icons.indeterminate_check_box
            : on
                ? Icons.check_box
                : Icons.check_box_outline_blank,
        size: 18,
        color: value == false ? AppColors.gray400 : AppColors.primary,
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
    required this.filterable,
    required this.filtered,
    required this.onFilter,
    this.alignment = Alignment.centerLeft,
    this.icon,
    this.iconOnly = false,
  });

  final String label;
  final bool sortable;
  final bool active;
  final bool ascending;
  final VoidCallback onTap;
  final bool filterable;
  final bool filtered;
  final ValueChanged<BuildContext> onFilter;
  final Alignment alignment;
  final IconData? icon;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final Color color = filtered ? AppColors.primary : AppColors.tableHeaderText;
    final Widget title = _HeaderTitle(label: label, color: color, icon: icon, iconOnly: iconOnly && icon != null);
    final Widget sortPart = !sortable
        ? title
        : InkWell(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(child: title),
                const SizedBox(width: 3),
                Icon(
                  active ? (ascending ? Icons.arrow_upward : Icons.arrow_downward) : Icons.unfold_more,
                  size: 13,
                  color: active ? AppColors.primary : AppColors.gray400,
                ),
              ],
            ),
          );
    // El título ocupa todo el ancho libre (con su alineación); el embudo, a la derecha
    return Row(
      children: <Widget>[
        Expanded(
          child: Tooltip(
            message: label,
            waitDuration: const Duration(milliseconds: 600),
            child: Align(alignment: Alignment(alignment.x, 0), child: sortPart),
          ),
        ),
        if (filterable) ...<Widget>[
          const SizedBox(width: 2),
          _HeaderFilterButton(filtered: filtered, onFilter: onFilter),
        ],
      ],
    );
  }
}

/// Icono (opcional) + texto de la cabecera
class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({required this.label, required this.color, required this.icon, required this.iconOnly});

  final String label;
  final Color color;
  final IconData? icon;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final Widget text = Text(
      label.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _headerStyle.copyWith(color: color),
    );
    final IconData? i = icon;
    if (i == null) {
      return text;
    }
    final Widget iconWidget = Icon(i, size: iconOnly ? 17 : 14, color: color);
    if (iconOnly) {
      return iconWidget;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        iconWidget,
        const SizedBox(width: 5),
        Flexible(child: text),
      ],
    );
  }
}

/// Embudo de la cabecera (azul y relleno si la columna está filtrada)
class _HeaderFilterButton extends StatelessWidget {
  const _HeaderFilterButton({required this.filtered, required this.onFilter});

  final bool filtered;
  final ValueChanged<BuildContext> onFilter;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: filtered ? 'Filtro activo: pulsa para cambiarlo' : 'Filtrar columna',
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: () => onFilter(context),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: filtered
              ? BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(4))
              : null,
          child: Icon(
            filtered ? Icons.filter_alt : Icons.filter_alt_outlined,
            size: 14,
            color: filtered ? AppColors.primary : AppColors.gray400,
          ),
        ),
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
    required this.editing,
    required this.checked,
    required this.onCheck,
    this.onDoubleTap,
  });

  final T item;
  final int number;
  final List<GestionColumn<T>> columns;
  final bool striped;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final bool editing;

  /// null = sin columna de casillas
  final bool? checked;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final Color bg = selected || (checked ?? false)
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
                if (checked != null)
                  _GridCell(
                    width: _kCheckWidth,
                    alignment: Alignment.center,
                    child: _RowCheck(value: checked, onTap: onCheck),
                  ),
                for (final GestionColumn<T> c in columns)
                  _GridCell(
                    flex: c.flex,
                    width: c.width,
                    alignment: c.alignment,
                    child: editing && c.editable
                        ? c.editCell!(item)
                        : c.onCellDoubleTap == null
                            ? c.cell(item)
                            : _DoubleTapCell(onDoubleTap: () => c.onCellDoubleTap!(item), child: c.cell(item)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Celda con su propia acción de doble clic (gana a la de la fila)
class _DoubleTapCell extends StatelessWidget {
  const _DoubleTapCell({required this.onDoubleTap, required this.child});

  final VoidCallback onDoubleTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Doble clic para cambiar',
      waitDuration: const Duration(milliseconds: 800),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: onDoubleTap,
        child: SizedBox.expand(child: Align(child: child)),
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
