import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_event.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_bloc.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_event.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_state.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/stock_vestuario/stock_vestuario_detail_panel.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/stock_vestuario/stock_vestuario_gestion_bars.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/stock_vestuario/stock_vestuario_gestion_columns.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/stock_vestuario_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de stock de vestuario con layout de programa de gestión
class StockVestuarioGestionView extends StatefulWidget {
  const StockVestuarioGestionView({super.key});

  @override
  State<StockVestuarioGestionView> createState() => _StockVestuarioGestionViewState();
}

class _StockVestuarioGestionViewState extends State<StockVestuarioGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  NivelStock? _nivel;
  StockEstadoFiltro _estado = StockEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<StockVestuarioEntity>? _items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _nivel != null || _estado != StockEstadoFiltro.todos;

  StockVestuarioEntity? get _selected {
    for (final StockVestuarioEntity s in _items ?? const <StockVestuarioEntity>[]) {
      if (s.id == _selectedId) {
        return s;
      }
    }
    return null;
  }

  List<StockVestuarioEntity> get _visibles => _sort.apply(
        filtrarStockVestuario(
          _items ?? <StockVestuarioEntity>[],
          query: _query,
          nivel: _nivel,
          estado: _estado,
        ),
        stockVestuarioColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _nivel = null;
        _estado = StockEstadoFiltro.todos;
      });

  void _refresh() {
    context.read<StockVestuarioBloc>().add(const StockVestuarioLoadRequested());
    context.read<VestuarioBloc>().add(const VestuarioLoadRequested());
  }

  Future<void> _openForm([StockVestuarioEntity? item]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<StockVestuarioBloc>.value(
        value: context.read<StockVestuarioBloc>(),
        child: StockVestuarioFormDialog(item: item),
      ),
    );
  }

  Future<void> _confirmDelete(StockVestuarioEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar artículo de stock',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Prenda': item.prenda,
        'Talla': item.talla,
        'Marca': GestionFormatters.texto(item.marca),
        'Color': GestionFormatters.texto(item.color),
        'Cantidad Total': '${item.cantidadTotal}',
        'Cantidad Asignada': '${item.cantidadAsignada}',
        'Cantidad Disponible': '${item.cantidadDisponible}',
        'Estado': item.activo ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando artículo de stock: ${item.prenda} (${item.id})');
      setState(() {
        _selectedId = null;
        _deletingNombre = '${item.prenda} (${item.talla})';
      });
      context.read<StockVestuarioBloc>().add(StockVestuarioDeleteRequested(item.id));
    }
  }

  void _onStateChanged(BuildContext context, StockVestuarioState state) {
    if (state is StockVestuarioLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _items = state.items;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Artículo', nombre: eliminado);
      }
    } else if (state is StockVestuarioError && _deletingNombre != null) {
      setState(() => _deletingNombre = null);
      showResultDialog(
        context: context,
        title: 'Error al eliminar',
        message: 'No se pudo eliminar el artículo de stock.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StockVestuarioBloc, StockVestuarioState>(
      listener: _onStateChanged,
      builder: (BuildContext context, StockVestuarioState state) {
        final List<StockVestuarioEntity> visibles = _visibles;
        final StockVestuarioEntity? selected = _selected;
        return GestionLayout(
          toolbar: StockVestuarioGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirStockVestuario(visibles),
          ),
          filterBar: StockVestuarioGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            nivel: _nivel,
            onNivelChanged: (NivelStock? v) => _updateFilters(() => _nivel = v),
            estado: _estado,
            onEstadoChanged: (StockEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _StockGridContent(
            state: state,
            hasData: _items != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (StockVestuarioEntity s) => setState(() => _selectedId = s.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: StockVestuarioDetailPanel(
            item: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenStockVestuario(_items ?? <StockVestuarioEntity>[], visibles.length),
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

  List<StockVestuarioEntity> _pageOf(List<StockVestuarioEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _StockGridContent extends StatelessWidget {
  const _StockGridContent({
    required this.state,
    required this.hasData,
    required this.rows,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.hasFilters,
    required this.onSelect,
    required this.onActivate,
    required this.onSort,
    required this.onRetry,
  });

  final StockVestuarioState state;
  final bool hasData;
  final List<StockVestuarioEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<StockVestuarioEntity> onSelect;
  final ValueChanged<StockVestuarioEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final StockVestuarioState s = state;
    if (!hasData && s is StockVestuarioError) {
      return _StockLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<StockVestuarioEntity>(
          columns: stockVestuarioColumns,
          rows: rows,
          rowId: (StockVestuarioEntity e) => e.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún artículo coincide con los filtros'
              : 'No hay artículos de stock registrados. Pulsa "Nuevo" para crear uno.',
        ),
        if (s is StockVestuarioLoading)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}

class _StockLoadError extends StatelessWidget {
  const _StockLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 40, color: AppColors.error),
          const SizedBox(height: 8),
          const Text(
            'Error al cargar el stock de vestuario',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error),
          ),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(fontSize: 12.5, color: AppColors.gray600)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
