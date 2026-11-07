import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/almacen_gestion_common.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/stock_detail_panel.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/stock_gestion_bars.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/stock_gestion_columns.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/stock_edit_form_dialog.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/stock_entrada_form_dialog.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/stock_transferencia_form_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de stock del Almacén General con layout de programa de gestión
class StockGestionView extends StatefulWidget {
  const StockGestionView({super.key});

  @override
  State<StockGestionView> createState() => _StockGestionViewState();
}

class _StockGestionViewState extends State<StockGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  CategoriaProducto? _categoria;
  StockSituacion? _situacion;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<StockEntity>? _items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _categoria != null || _situacion != null;

  StockEntity? get _selected {
    for (final StockEntity s in _items ?? const <StockEntity>[]) {
      if (s.id == _selectedId) {
        return s;
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
        _categoria = null;
        _situacion = null;
      });

  void _refresh() {
    context.read<StockBloc>().add(const StockLoadAllRequested());
    context.read<ProductoBloc>().add(const ProductoLoadAllRequested());
  }

  Future<void> _openDialog(Widget dialog, {bool conVehiculos = false}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<StockBloc>.value(value: context.read<StockBloc>()),
          BlocProvider<ProductoBloc>.value(value: context.read<ProductoBloc>()),
          if (conVehiculos) BlocProvider<VehiculosBloc>.value(value: context.read<VehiculosBloc>()),
        ],
        child: dialog,
      ),
    );
  }

  /// La nueva entrada se abre con la categoría del filtro (o Medicación)
  Future<void> _openNew() => _openDialog(
        StockEntradaFormDialog(categoriaInicial: _categoria ?? CategoriaProducto.medicacion),
      );

  Future<void> _openEdit(StockEntity s) => _openDialog(StockEditFormDialog(stock: s));

  Future<void> _openTransfer(StockEntity s) =>
      _openDialog(StockTransferenciaFormDialog(stock: s), conVehiculos: true);

  Future<void> _openView(StockEntity s, Map<String, ProductoEntity> productos) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SafeArea(
          child: SizedBox(
            width: 440,
            height: 620,
            child: StockDetailPanel(
              item: s,
              productos: productos,
              onEdit: () {
                Navigator.of(dialogContext).pop();
                _openEdit(s);
              },
              onTransfer: () {
                Navigator.of(dialogContext).pop();
                _openTransfer(s);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onStockChanged(BuildContext context, StockState state) {
    if (state is StockLoaded) {
      setState(() => _items = state.stocks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProductoState pState = context.watch<ProductoBloc>().state;
    final Map<String, ProductoEntity> productos = <String, ProductoEntity>{
      if (pState is ProductoLoaded)
        for (final ProductoEntity p in pState.productos) p.id: p,
    };
    final List<GestionColumn<StockEntity>> columns = stockGestionColumns(productos);
    return BlocConsumer<StockBloc, StockState>(
      listener: _onStockChanged,
      builder: (BuildContext context, StockState state) {
        final List<StockEntity> todos = _items ?? <StockEntity>[];
        final List<StockEntity> visibles = _sort.apply(
          filtrarStock(todos, productos: productos, query: _query, categoria: _categoria, situacion: _situacion),
          columns,
        );
        final StockEntity? selected = _selected;
        return GestionLayout(
          toolbar: StockGestionToolbar(
            hasSelection: selected != null,
            onNew: _openNew,
            onEdit: () => _openEdit(selected!),
            onTransfer: () => _openTransfer(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirStock(visibles, productos),
            onView: () => _openView(selected!, productos),
          ),
          filterBar: StockGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            categoria: _categoria,
            onCategoriaChanged: (CategoriaProducto? v) => _updateFilters(() => _categoria = v),
            situacion: _situacion,
            onSituacionChanged: (StockSituacion? v) => _updateFilters(() => _situacion = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: AlmacenGestionGridContent<StockEntity>(
            hasData: _items != null && pState is ProductoLoaded,
            isLoading: state is StockLoading || state is StockOperationInProgress,
            errorMessage: state is StockError ? state.message : null,
            errorTitle: 'Error al cargar el stock',
            columns: columns,
            rows: almacenPageOf(visibles, _page, _pageSize),
            rowId: (StockEntity s) => s.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            emptyMessage: _hasFilters
                ? 'Ninguna línea de stock coincide con los filtros'
                : 'No hay stock registrado. Pulsa "Nueva entrada" para añadirlo.',
            onSelect: (StockEntity s) => setState(() => _selectedId = s.id),
            onActivate: _openEdit,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: StockDetailPanel(
            item: selected,
            productos: productos,
            onEdit: () => _openEdit(selected!),
            onTransfer: () => _openTransfer(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenStock(todos, visibles.length),
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
    );
  }
}
