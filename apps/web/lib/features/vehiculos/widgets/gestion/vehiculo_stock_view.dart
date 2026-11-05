// ignore_for_file: implementation_imports
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_core_datasource/src/datasources/stock/stock_contract.dart' as legacy_stock;
import 'package:ambutrack_core_datasource/src/datasources/stock/stock_factory.dart' as legacy_stock;
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/stock_manual_form_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_stock_bars.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_stock_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_stock_detail_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de stock de un vehículo con layout de programa de gestión.
///
/// Carga el stock con el sistema legacy (tabla `stock_vehiculo`), igual que la
/// versión anterior de la página.
class VehiculoStockView extends StatefulWidget {
  const VehiculoStockView({required this.vehiculoId, super.key});

  final String vehiculoId;

  @override
  State<VehiculoStockView> createState() => _VehiculoStockViewState();
}

class _VehiculoStockViewState extends State<VehiculoStockView> {
  final legacy_stock.StockDataSource _stockDataSource = legacy_stock.StockDataSourceFactory.createSupabase();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _categoria;
  String? _estado;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<StockVehiculoEntity>? _stock;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      debugPrint('📦 VehiculoStock: cargando stock del vehículo ${widget.vehiculoId}');
      final List<StockVehiculoEntity> stock = await _stockDataSource.getStockVehiculo(widget.vehiculoId);
      debugPrint('✅ VehiculoStock: ${stock.length} items');
      if (mounted) {
        setState(() {
          _stock = stock;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ VehiculoStock: error al cargar stock: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  bool get _hasFilters => _query.isNotEmpty || _categoria != null || _estado != null;

  StockVehiculoEntity? get _selected {
    for (final StockVehiculoEntity s in _stock ?? const <StockVehiculoEntity>[]) {
      if (s.id == _selectedId) {
        return s;
      }
    }
    return null;
  }

  List<StockVehiculoEntity> get _visibles => _sort.apply(
        filtrarStockVehiculo(_stock ?? <StockVehiculoEntity>[], query: _query, categoria: _categoria, estado: _estado),
        vehiculoStockColumns,
      );

  List<String> get _categorias => (_stock ?? <StockVehiculoEntity>[])
      .map((StockVehiculoEntity s) => s.categoriaNombre)
      .whereType<String>()
      .toSet()
      .toList()
    ..sort();

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _categoria = null;
        _estado = null;
      });

  Future<void> _addStock() async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => StockManualFormDialog(vehiculoId: widget.vehiculoId),
    );
    if (result == true) {
      await _loadData();
    }
  }

  String _titulo(VehiculoEntity? vehiculo) =>
      vehiculo == null ? 'Stock de Vehículo' : 'Stock · ${vehiculo.matricula} (${vehiculo.marca} ${vehiculo.modelo})';

  @override
  Widget build(BuildContext context) {
    final VehiculosState vState = context.watch<VehiculosBloc>().state;
    VehiculoEntity? vehiculo;
    if (vState is VehiculosLoaded) {
      for (final VehiculoEntity v in vState.vehiculos) {
        if (v.id == widget.vehiculoId) {
          vehiculo = v;
        }
      }
    }
    final List<StockVehiculoEntity> visibles = _visibles;
    return GestionLayout(
      toolbar: VehiculoStockToolbar(
        title: _titulo(vehiculo),
        loading: _loading,
        onAdd: _addStock,
        onRefresh: _loadData,
        onPrint: visibles.isEmpty ? null : () => imprimirStockVehiculo(visibles, _titulo(vehiculo)),
        onClose: () => context.goNamed('vehiculos'),
      ),
      filterBar: VehiculoStockFilters(
        searchController: _searchController,
        onSearchChanged: (String v) => _updateFilters(() => _query = v),
        categorias: _categorias,
        categoria: _categoria,
        onCategoriaChanged: (String? v) => _updateFilters(() => _categoria = v),
        estado: _estado,
        onEstadoChanged: (String? v) => _updateFilters(() => _estado = v),
        onClear: _hasFilters ? _clearFilters : null,
      ),
      content: FlotaGridArea(
        hasData: _stock != null,
        loading: _loading,
        errorMessage: _error,
        errorTitle: 'Error al cargar stock',
        onRetry: _loadData,
        child: GestionGrid<StockVehiculoEntity>(
          columns: vehiculoStockColumns,
          rows: flotaPageOf(visibles, _page, _pageSize),
          rowId: (StockVehiculoEntity s) => s.id,
          selectedId: _selectedId,
          onSelect: (StockVehiculoEntity s) => setState(() => _selectedId = s.id),
          sort: _sort,
          onSort: (GestionSort s) => setState(() => _sort = s),
          firstRowNumber: _page * _pageSize + 1,
          emptyMessage: _hasFilters
              ? 'Ningún producto coincide con los filtros'
              : 'Este vehículo aún no tiene equipamiento registrado. Pulsa "Añadir".',
        ),
      ),
      detailPanel: VehiculoStockDetailPanel(item: _selected),
      statusBar: GestionStatusBar(
        items: resumenStockVehiculo(_stock ?? <StockVehiculoEntity>[], visibles.length),
        pagination: GestionPagination(
          page: _page,
          pageSize: _pageSize,
          totalItems: visibles.length,
          onPageChanged: (int p) => setState(() => _page = p),
          onPageSizeChanged: (int s) => _updateFilters(() => _pageSize = s),
        ),
      ),
    );
  }
}
