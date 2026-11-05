import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_grid_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'gestion_grid_column.dart';

const double _kRowHeight = 32;
const double _kHeaderHeight = 34;
const double _kNumberWidth = 44;

/// Rejilla densa estilo programa de gestión.
///
/// - Filas de 32px con líneas de rejilla y filas alternas
/// - Selección de fila (clic), activación (doble clic / Intro)
/// - Navegación con flechas ↑ ↓
/// - Cabeceras ordenables
class GestionGrid<T> extends StatefulWidget {
  const GestionGrid({
    required this.columns,
    required this.rows,
    required this.rowId,
    required this.onSelect,
    this.selectedId,
    this.onActivate,
    this.sort = const GestionSort(),
    this.onSort,
    this.firstRowNumber = 1,
    this.emptyMessage = 'No hay registros',
    super.key,
  });

  final List<GestionColumn<T>> columns;
  final List<T> rows;
  final String Function(T item) rowId;
  final String? selectedId;
  final ValueChanged<T> onSelect;
  final ValueChanged<T>? onActivate;
  final GestionSort sort;
  final ValueChanged<GestionSort>? onSort;

  /// Número de la primera fila (para paginación)
  final int firstRowNumber;
  final String emptyMessage;

  @override
  State<GestionGrid<T>> createState() => _GestionGridState<T>();
}

class _GestionGridState<T> extends State<GestionGrid<T>> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'GestionGrid');
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _focusNode.dispose();
    _scroll.dispose();
    super.dispose();
  }

  int get _selectedIndex => widget.selectedId == null
      ? -1
      : widget.rows.indexWhere((T r) => widget.rowId(r) == widget.selectedId);

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || widget.rows.isEmpty) {
      return KeyEventResult.ignored;
    }
    final int current = _selectedIndex;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _moveTo((current + 1).clamp(0, widget.rows.length - 1));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveTo((current - 1).clamp(0, widget.rows.length - 1));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter && current >= 0) {
      widget.onActivate?.call(widget.rows[current]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _moveTo(int index) {
    widget.onSelect(widget.rows[index]);
    if (!_scroll.hasClients) {
      return;
    }
    final double top = index * _kRowHeight;
    final double viewport = _scroll.position.viewportDimension;
    if (top < _scroll.offset) {
      _scroll.jumpTo(top);
    } else if (top + _kRowHeight > _scroll.offset + viewport) {
      _scroll.jumpTo(top + _kRowHeight - viewport);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _GridHeader<T>(
            columns: widget.columns,
            sort: widget.sort,
            onSort: widget.onSort,
          ),
          Expanded(
            child: widget.rows.isEmpty
                ? _GridEmpty(message: widget.emptyMessage)
                : ListView.builder(
                    controller: _scroll,
                    itemExtent: _kRowHeight,
                    itemCount: widget.rows.length,
                    itemBuilder: (BuildContext context, int i) {
                      final T item = widget.rows[i];
                      return _GridRow<T>(
                        item: item,
                        number: widget.firstRowNumber + i,
                        columns: widget.columns,
                        striped: i.isOdd,
                        selected: widget.rowId(item) == widget.selectedId,
                        onTap: () {
                          _focusNode.requestFocus();
                          widget.onSelect(item);
                        },
                        onDoubleTap: widget.onActivate == null
                            ? null
                            : () => widget.onActivate!(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

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
