import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/vestuario/vestuario_detail_panel.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/vestuario/vestuario_gestion_bars.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/vestuario/vestuario_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/vestuario/vestuario_grid_content.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/vestuario/vestuario_related_tabs.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/vestuario_form_dialog.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_bloc.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_event.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de vestuario con layout de programa de gestión
class VestuarioGestionView extends StatefulWidget {
  const VestuarioGestionView({super.key});

  @override
  State<VestuarioGestionView> createState() => _VestuarioGestionViewState();
}

class _VestuarioGestionViewState extends State<VestuarioGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  VestuarioEstadoFiltro _estado = VestuarioEstadoFiltro.todos;
  String? _prenda;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<VestuarioEntity>? _items;
  Map<String, String> _nombres = <String, String>{};

  @override
  void initState() {
    super.initState();
    _nombres = _mapNombres(context.read<PersonalBloc>().state) ?? _nombres;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static Map<String, String>? _mapNombres(PersonalState state) {
    if (state is! PersonalLoaded) {
      return null;
    }
    return <String, String>{
      for (final PersonalEntity p in state.personal) p.id: p.nombreCompleto,
    };
  }

  void _onPersonalChanged(BuildContext _, PersonalState state) {
    final Map<String, String>? nombres = _mapNombres(state);
    if (nombres != null) {
      setState(() => _nombres = nombres);
    }
  }

  String _nombre(String personalId) => _nombres[personalId] ?? 'Desconocido';

  bool get _hasFilters =>
      _query.isNotEmpty || _prenda != null || _estado != VestuarioEstadoFiltro.todos;

  VestuarioEntity? get _selected {
    for (final VestuarioEntity v in _items ?? const <VestuarioEntity>[]) {
      if (v.id == _selectedId) {
        return v;
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
        _prenda = null;
        _estado = VestuarioEstadoFiltro.todos;
      });

  void _refresh() {
    context.read<VestuarioBloc>().add(const VestuarioLoadRequested());
    context.read<StockVestuarioBloc>().add(const StockVestuarioLoadRequested());
  }

  Future<void> _openForm([VestuarioEntity? item]) {
    final VestuarioBloc vestuarioBloc = context.read<VestuarioBloc>();
    final PersonalBloc personalBloc = context.read<PersonalBloc>();
    final StockVestuarioBloc stockBloc = context.read<StockVestuarioBloc>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<VestuarioBloc>.value(value: vestuarioBloc),
          BlocProvider<PersonalBloc>.value(value: personalBloc),
          BlocProvider<StockVestuarioBloc>.value(value: stockBloc),
        ],
        child: VestuarioFormDialog(item: item),
      ),
    );
  }

  Future<void> _confirmDelete(VestuarioEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar asignación de vestuario',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Trabajador': _nombre(item.personalId),
        'Prenda': item.prenda,
        'Talla': item.talla,
        'Marca': GestionFormatters.texto(item.marca),
        'Color': GestionFormatters.texto(item.color),
        'Cantidad': '${item.cantidad ?? 1}',
        'Fecha Entrega': GestionFormatters.fecha(item.fechaEntrega),
        'Estado': item.estaAsignado ? 'Asignado' : 'Devuelto',
      },
      warningMessage: item.estaAsignado ? 'Las unidades asignadas se devolverán al stock.' : null,
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando vestuario: ${item.prenda} (${item.id})');
      _devolverAlStock(item);
      setState(() {
        _selectedId = null;
        _deletingNombre = '${item.prenda} (${item.talla}) — ${_nombre(item.personalId)}';
      });
      context.read<VestuarioBloc>().add(VestuarioDeleteRequested(item.id));
    }
  }

  /// Si la prenda estaba asignada, devuelve sus unidades al stock
  void _devolverAlStock(VestuarioEntity item) {
    if (!item.estaAsignado) {
      debugPrint('ℹ️ Vestuario ya estaba devuelto, no se incrementa stock');
      return;
    }
    final StockVestuarioBloc stockBloc = context.read<StockVestuarioBloc>();
    final StockVestuarioState stockState = stockBloc.state;
    if (stockState is! StockVestuarioLoaded) {
      debugPrint('⚠️ Stock no está cargado (estado: $stockState)');
      return;
    }
    final StockVestuarioEntity? stock = stockDeVestuario(stockState.items, item);
    if (stock == null) {
      debugPrint('⚠️ No se encontró stock para devolver: ${item.prenda} ${item.talla}');
      return;
    }
    debugPrint('📦 Devolviendo al stock: ${item.prenda} (${item.talla}) - Cantidad: ${item.cantidad ?? 1}');
    stockBloc.add(StockVestuarioDecrementarAsignadaRequested(stock.id, item.cantidad ?? 1));
  }

  void _onStateChanged(BuildContext context, VestuarioState state) {
    if (state is VestuarioLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _items = state.items;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Prenda', nombre: eliminado);
      }
    } else if (state is VestuarioError && _deletingNombre != null) {
      setState(() => _deletingNombre = null);
      showResultDialog(
        context: context,
        title: 'Error al eliminar',
        message: 'No se pudo eliminar el registro de vestuario.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonalBloc, PersonalState>(
      listener: _onPersonalChanged,
      child: BlocConsumer<VestuarioBloc, VestuarioState>(
        listener: _onStateChanged,
        builder: (BuildContext context, VestuarioState state) {
          final List<VestuarioEntity> todos = _items ?? <VestuarioEntity>[];
          final List<String> prendas = prendasVestuario(todos);
          final List<GestionColumn<VestuarioEntity>> columns = vestuarioColumns(_nombre);
          final List<VestuarioEntity> visibles = _sort.apply(
            filtrarVestuario(
              todos,
              query: _query,
              estado: _estado,
              prenda: prendas.contains(_prenda) ? _prenda : null,
              nombre: _nombre,
            ),
            columns,
          );
          final VestuarioEntity? selected = _selected;
          return GestionLayout(
            toolbar: VestuarioGestionToolbar(
              hasSelection: selected != null,
              onNew: _openForm,
              onEdit: () => _openForm(selected),
              onDelete: () => _confirmDelete(selected!),
              onRefresh: _refresh,
              onPrint: visibles.isEmpty ? null : () => imprimirVestuario(visibles, _nombre),
            ),
            filterBar: VestuarioGestionFilters(
              searchController: _searchController,
              onSearchChanged: (String v) => _updateFilters(() => _query = v),
              estado: _estado,
              onEstadoChanged: (VestuarioEstadoFiltro v) => _updateFilters(() => _estado = v),
              prenda: _prenda,
              prendas: prendas,
              onPrendaChanged: (String? v) => _updateFilters(() => _prenda = v),
              onClear: _hasFilters ? _clearFilters : null,
            ),
            content: VestuarioGridContent(
              state: state,
              hasData: _items != null,
              columns: columns,
              rows: _pageOf(visibles),
              firstRowNumber: _page * _pageSize + 1,
              selectedId: _selectedId,
              sort: _sort,
              hasFilters: _hasFilters,
              onSelect: (VestuarioEntity v) => setState(() => _selectedId = v.id),
              onActivate: _openForm,
              onSort: (GestionSort s) => setState(() => _sort = s),
              onRetry: _refresh,
            ),
            detailPanel: VestuarioDetailPanel(
              item: selected,
              todos: todos,
              nombre: _nombre,
              onEdit: () => _openForm(selected),
              onDelete: () => _confirmDelete(selected!),
            ),
            statusBar: GestionStatusBar(
              items: resumenVestuario(todos, visibles.length),
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

  List<VestuarioEntity> _pageOf(List<VestuarioEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}
