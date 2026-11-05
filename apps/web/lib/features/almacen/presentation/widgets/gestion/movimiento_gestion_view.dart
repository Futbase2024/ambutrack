import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity;
// ignore: implementation_imports
import 'package:ambutrack_core_datasource/src/datasources/almacen/entities/movimiento_stock_entity.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/movimiento_stock/movimiento_stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/movimiento_stock/movimiento_stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/movimiento_stock/movimiento_stock_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/almacen_gestion_common.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/movimiento_detail_panel.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/movimiento_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Número máximo de movimientos que se cargan (los más recientes)
const int movimientosLimite = 500;

/// Pantalla de historial de movimientos de stock (solo lectura)
class MovimientoGestionView extends StatefulWidget {
  const MovimientoGestionView({super.key});

  @override
  State<MovimientoGestionView> createState() => _MovimientoGestionViewState();
}

class _MovimientoGestionViewState extends State<MovimientoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  TipoMovimientoStock? _tipo;
  MovimientoSentidoFiltro _sentido = MovimientoSentidoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<MovimientoStockEntity>? _movimientos;
  Map<String, ProductoEntity> _productos = <String, ProductoEntity>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _tipo != null || _sentido != MovimientoSentidoFiltro.todos;

  MovimientoStockEntity? get _selected {
    for (final MovimientoStockEntity m in _movimientos ?? const <MovimientoStockEntity>[]) {
      if (m.id == _selectedId) {
        return m;
      }
    }
    return null;
  }

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipo = null;
        _sentido = MovimientoSentidoFiltro.todos;
      });

  void _refresh() {
    context.read<MovimientoStockBloc>().add(const MovimientoStockLoadAllRequested(limit: movimientosLimite));
    context.read<ProductoBloc>().add(const ProductoLoadAllRequested());
  }

  void _onProductosChanged(BuildContext context, ProductoState state) {
    if (state is ProductoLoaded) {
      setState(() {
        _productos = <String, ProductoEntity>{
          for (final ProductoEntity p in state.productos) p.id: p,
        };
      });
    }
  }

  void _onStateChanged(BuildContext context, MovimientoStockState state) {
    if (state is MovimientoStockLoaded) {
      setState(() => _movimientos = state.movimientos);
    } else if (state is MovimientoStockError && _movimientos != null) {
      showResultDialog(
        context: context,
        title: 'Error en movimientos',
        message: 'No se pudieron recargar los movimientos de stock.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductoBloc, ProductoState>(
      listener: _onProductosChanged,
      child: BlocConsumer<MovimientoStockBloc, MovimientoStockState>(
        listener: _onStateChanged,
        builder: (BuildContext context, MovimientoStockState state) {
          final List<GestionColumn<MovimientoStockEntity>> columns = movimientoGestionColumns(_productos);
          final List<MovimientoStockEntity> visibles = _sort.apply(
            filtrarMovimientos(
              _movimientos ?? <MovimientoStockEntity>[],
              _productos,
              query: _query,
              tipo: _tipo,
              sentido: _sentido,
            ),
            columns,
          );
          final MovimientoStockEntity? selected = _selected;
          return GestionLayout(
            toolbar: GestionToolbar(
              title: 'Movimientos de Stock',
              icon: Icons.history,
              groups: <List<GestionToolbarAction>>[
                <GestionToolbarAction>[
                  GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: _refresh),
                  GestionToolbarAction(
                    icon: Icons.print_outlined,
                    label: 'Imprimir',
                    tooltip: 'Imprimir o guardar como PDF el listado filtrado',
                    onPressed: visibles.isEmpty ? null : () => imprimirMovimientos(visibles, _productos),
                  ),
                ],
              ],
            ),
            filterBar: _MovimientoFilters(
              searchController: _searchController,
              onSearchChanged: (String v) => _updateFilters(() => _query = v),
              tipo: _tipo,
              onTipoChanged: (TipoMovimientoStock? v) => _updateFilters(() => _tipo = v),
              sentido: _sentido,
              onSentidoChanged: (MovimientoSentidoFiltro v) => _updateFilters(() => _sentido = v),
              onClear: _hasFilters ? _clearFilters : null,
            ),
            content: AlmacenGestionGridContent<MovimientoStockEntity>(
              hasData: _movimientos != null,
              isLoading: state is MovimientoStockLoading,
              errorTitle: 'Error al cargar movimientos',
              errorMessage: state is MovimientoStockError ? state.message : null,
              columns: columns,
              rows: almacenPageOf(visibles, _page, _pageSize),
              rowId: (MovimientoStockEntity m) => m.id,
              firstRowNumber: _page * _pageSize + 1,
              selectedId: _selectedId,
              sort: _sort,
              emptyMessage: _hasFilters
                  ? 'Ningún movimiento coincide con los filtros'
                  : 'No hay movimientos de stock registrados',
              onSelect: (MovimientoStockEntity m) => setState(() => _selectedId = m.id),
              onActivate: (MovimientoStockEntity m) => setState(() => _selectedId = m.id),
              onSort: (GestionSort s) => setState(() => _sort = s),
              onRetry: _refresh,
            ),
            detailPanel: MovimientoDetailPanel(
              movimiento: selected,
              producto: selected == null ? null : _productos[selected.idProducto],
            ),
            statusBar: GestionStatusBar(
              items: resumenMovimientos(
                _movimientos ?? <MovimientoStockEntity>[],
                visibles.length,
                movimientosLimite,
              ),
              pagination: GestionPagination(
                page: _page,
                pageSize: _pageSize,
                totalItems: visibles.length,
                onPageChanged: (int p) => setState(() => _page = p),
                onPageSizeChanged: (int s) => _updateFilters(() => _pageSize = s),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Barra de filtros de movimientos de stock
class _MovimientoFilters extends StatelessWidget {
  const _MovimientoFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.tipo,
    required this.onTipoChanged,
    required this.sentido,
    required this.onSentidoChanged,
    required this.onClear,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final TipoMovimientoStock? tipo;
  final ValueChanged<TipoMovimientoStock?> onTipoChanged;
  final MovimientoSentidoFiltro sentido;
  final ValueChanged<MovimientoSentidoFiltro> onSentidoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar producto, lote, nº serie, referencia...',
        ),
        GestionFilterDropdown<TipoMovimientoStock?>(
          label: 'Tipo',
          value: tipo,
          options: <TipoMovimientoStock?, String>{
            null: 'Todos',
            for (final TipoMovimientoStock t in TipoMovimientoStock.values) t: t.label,
          },
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<MovimientoSentidoFiltro>(
          label: 'Sentido',
          value: sentido,
          options: movimientoSentidoOptions,
          onChanged: onSentidoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
