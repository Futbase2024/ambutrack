import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_grid_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'gestion_grid_column.dart';

part 'gestion_grid_parts.dart';

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
  final ScrollController _hScroll = ScrollController();

  @override
  void dispose() {
    _focusNode.dispose();
    _scroll.dispose();
    _hScroll.dispose();
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

  /// Ancho mínimo de la rejilla: nº de fila + mínimo de cada columna
  double get _minGridWidth => widget.columns.fold<double>(
        _kNumberWidth,
        (double sum, GestionColumn<T> c) => sum + c.requiredWidth,
      );

  static bool _isVertical(ScrollNotification n) => n.metrics.axis == Axis.vertical;

  static bool _isHorizontal(ScrollNotification n) => n.metrics.axis == Axis.horizontal;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      // Las barras se dibujan aquí (siempre visibles); se desactivan las automáticas
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double minWidth = _minGridWidth;
            final bool fits = constraints.maxWidth >= minWidth;
            Widget grid = _GridBody<T>(
              grid: widget,
              scroll: _scroll,
              focusNode: _focusNode,
            );
            if (!fits) {
              // No caben las columnas: desplazamiento horizontal en lugar de aplastarlas
              grid = Scrollbar(
                controller: _hScroll,
                thumbVisibility: true,
                trackVisibility: true,
                notificationPredicate: _isHorizontal,
                child: SingleChildScrollView(
                  controller: _hScroll,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(width: minWidth, height: constraints.maxHeight, child: grid),
                ),
              );
            }
            if (widget.rows.isEmpty) {
              return grid;
            }
            // Barra vertical en el borde visible, aunque la rejilla se desplace en horizontal
            return Scrollbar(
              controller: _scroll,
              thumbVisibility: true,
              notificationPredicate: _isVertical,
              child: grid,
            );
          },
        ),
      ),
    );
  }
}

/// Cabecera + filas de la rejilla
class _GridBody<T> extends StatelessWidget {
  const _GridBody({required this.grid, required this.scroll, required this.focusNode});

  final GestionGrid<T> grid;
  final ScrollController scroll;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _GridHeader<T>(columns: grid.columns, sort: grid.sort, onSort: grid.onSort),
        Expanded(
          child: grid.rows.isEmpty
              ? _GridEmpty(message: grid.emptyMessage)
              : ListView.builder(
                  controller: scroll,
                  itemExtent: _kRowHeight,
                  itemCount: grid.rows.length,
                  itemBuilder: (BuildContext context, int i) {
                    final T item = grid.rows[i];
                    return _GridRow<T>(
                      item: item,
                      number: grid.firstRowNumber + i,
                      columns: grid.columns,
                      striped: i.isOdd,
                      selected: grid.rowId(item) == grid.selectedId,
                      onTap: () {
                        focusNode.requestFocus();
                        grid.onSelect(item);
                      },
                      onDoubleTap: grid.onActivate == null ? null : () => grid.onActivate!(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
