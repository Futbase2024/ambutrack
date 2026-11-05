import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/gestion/stock_equipamiento_detail_panel.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/gestion/stock_equipamiento_gestion_bars.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/gestion/stock_equipamiento_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/stock_equipamiento_view_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/stock_manual_form_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de stock de equipamiento por vehículo con layout de programa de gestión
class StockEquipamientoGestionView extends StatefulWidget {
  const StockEquipamientoGestionView({super.key});

  @override
  State<StockEquipamientoGestionView> createState() => _StockEquipamientoGestionViewState();
}

class _StockEquipamientoGestionViewState extends State<StockEquipamientoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  EstadoStockGeneral? _estado;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<VehiculoStockResumenEntity>? _items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != null;

  VehiculoStockResumenEntity? get _selected {
    for (final VehiculoStockResumenEntity v in _items ?? const <VehiculoStockResumenEntity>[]) {
      if (v.vehiculoId == _selectedId) {
        return v;
      }
    }
    return null;
  }

  List<VehiculoStockResumenEntity> get _visibles => _sort.apply(
        filtrarStockEquipamiento(_items ?? <VehiculoStockResumenEntity>[], query: _query, estado: _estado),
        stockEquipamientoGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = null;
      });

  void _refresh() => context.read<StockEquipamientoBloc>().add(const StockEquipamientoRefreshRequested());

  void _retry() => context.read<StockEquipamientoBloc>().add(const StockEquipamientoLoadRequested());

  Future<void> _verStock(VehiculoStockResumenEntity item) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) => StockEquipamientoViewDialog(
        vehiculoId: item.vehiculoId,
        matricula: item.matricula,
        marca: item.marca,
        modelo: item.modelo,
      ),
    );
  }

  Future<void> _addStock(VehiculoStockResumenEntity item) async {
    final StockEquipamientoBloc bloc = context.read<StockEquipamientoBloc>();
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => StockManualFormDialog(vehiculoId: item.vehiculoId),
    );
    if (result == true) {
      bloc.add(StockEquipamientoVehiculoUpdated(vehiculoId: item.vehiculoId));
    }
  }

  void _onStateChanged(BuildContext context, StockEquipamientoState state) {
    if (state is StockEquipamientoLoaded) {
      setState(() => _items = state.vehiculos);
    } else if (state is StockEquipamientoError) {
      if (_items == null && state.previousVehiculos != null) {
        setState(() => _items = state.previousVehiculos);
      }
      if (_items != null) {
        showResultDialog(
          context: context,
          title: 'Error en stock de equipamiento',
          message: 'No se pudo completar la operación.',
          details: state.message,
          type: ResultType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StockEquipamientoBloc, StockEquipamientoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, StockEquipamientoState state) {
        final List<VehiculoStockResumenEntity> visibles = _visibles;
        final VehiculoStockResumenEntity? selected = _selected;
        final bool refreshing = state is StockEquipamientoLoading ||
            (state is StockEquipamientoLoaded && state.isRefreshing);
        return GestionLayout(
          toolbar: StockEquipamientoGestionToolbar(
            hasSelection: selected != null,
            refreshing: refreshing,
            onVer: () => _verStock(selected!),
            onAdd: () => _addStock(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirStockEquipamiento(visibles),
          ),
          filterBar: StockEquipamientoGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (EstadoStockGeneral? v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: FlotaGridArea(
            hasData: _items != null,
            loading: refreshing,
            errorMessage: state is StockEquipamientoError ? state.message : null,
            errorTitle: 'Error al cargar el stock',
            onRetry: _retry,
            child: GestionGrid<VehiculoStockResumenEntity>(
              columns: stockEquipamientoGestionColumns,
              rows: flotaPageOf(visibles, _page, _pageSize),
              rowId: (VehiculoStockResumenEntity v) => v.vehiculoId,
              selectedId: _selectedId,
              onSelect: (VehiculoStockResumenEntity v) => setState(() => _selectedId = v.vehiculoId),
              onActivate: _verStock,
              sort: _sort,
              onSort: (GestionSort s) => setState(() => _sort = s),
              firstRowNumber: _page * _pageSize + 1,
              emptyMessage: _hasFilters
                  ? 'Ningún vehículo coincide con los filtros'
                  : 'No hay vehículos registrados',
            ),
          ),
          detailPanel: StockEquipamientoDetailPanel(
            resumen: selected,
            onVer: () => _verStock(selected!),
            onAdd: () => _addStock(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenStockEquipamiento(_items ?? <VehiculoStockResumenEntity>[], visibles.length),
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
