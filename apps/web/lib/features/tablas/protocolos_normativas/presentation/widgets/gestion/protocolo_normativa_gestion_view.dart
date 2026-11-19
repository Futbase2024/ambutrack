import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/bloc/protocolo_normativa_bloc.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/bloc/protocolo_normativa_event.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/bloc/protocolo_normativa_state.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/widgets/gestion/protocolo_normativa_detail_panel.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/widgets/gestion/protocolo_normativa_gestion_bars.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/widgets/gestion/protocolo_normativa_gestion_columns.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/widgets/protocolo_normativa_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de protocolos y normativas con layout de programa de gestión
class ProtocoloNormativaGestionView extends StatefulWidget {
  const ProtocoloNormativaGestionView({super.key});

  @override
  State<ProtocoloNormativaGestionView> createState() => _ProtocoloNormativaGestionViewState();
}

class _ProtocoloNormativaGestionViewState extends State<ProtocoloNormativaGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  GestionColumnFilters _colFilters = const GestionColumnFilters();
  ProtocoloEstadoFiltro _estado = ProtocoloEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 1);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Operación lanzada desde esta vista pendiente de resultado
  bool _awaitingResult = false;

  /// Título del protocolo cuyo borrado está en curso (para el aviso de éxito)
  String? _deletingTitulo;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<ProtocoloNormativaEntity>? _protocolos;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => !_colFilters.isEmpty || _query.isNotEmpty || _estado != ProtocoloEstadoFiltro.todos;

  ProtocoloNormativaEntity? get _selected {
    for (final ProtocoloNormativaEntity p in _protocolos ?? const <ProtocoloNormativaEntity>[]) {
      if (p.id == _selectedId) {
        return p;
      }
    }
    return null;
  }

  List<ProtocoloNormativaEntity> get _base =>
      filtrarProtocolos(_protocolos ?? <ProtocoloNormativaEntity>[], query: _query, estado: _estado);

  List<ProtocoloNormativaEntity> get _visibles =>
      _sort.apply(_colFilters.apply(_base, protocoloGestionColumns), protocoloGestionColumns);

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _onColumnFiltersChanged(GestionColumnFilters f) => _updateFilters(() => _colFilters = f);

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _colFilters = const GestionColumnFilters();
        _estado = ProtocoloEstadoFiltro.todos;
      });

  void _refresh() {
    _awaitingResult = true;
    context.read<ProtocoloNormativaBloc>().add(const ProtocoloNormativaLoadAllRequested());
  }

  Future<void> _openForm([ProtocoloNormativaEntity? protocolo]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<ProtocoloNormativaBloc>.value(
        value: context.read<ProtocoloNormativaBloc>(),
        child: ProtocoloNormativaFormDialog(protocolo: protocolo),
      ),
    );
  }

  Future<void> _confirmDelete(ProtocoloNormativaEntity protocolo) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar protocolo',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Título': protocolo.titulo,
        'Código': GestionFormatters.texto(protocolo.codigo),
        'Categoría': protocolo.categoria.label,
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _awaitingResult = true;
        _deletingTitulo = protocolo.titulo;
      });
      context.read<ProtocoloNormativaBloc>().add(ProtocoloNormativaDeleteRequested(protocolo.id));
    }
  }

  void _onStateChanged(BuildContext context, ProtocoloNormativaState state) {
    if (state is ProtocoloNormativaDeleted) {
      final String? eliminado = _deletingTitulo;
      if (eliminado != null) {
        _deletingTitulo = null;
        GestionFeedback.eliminado(context, entidad: 'Protocolo', nombre: eliminado);
      }
    } else if (state is ProtocoloNormativaLoaded) {
      setState(() {
        _protocolos = state.protocolos;
        _awaitingResult = false;
      });
    } else if (state is ProtocoloNormativaError && _protocolos != null && _awaitingResult) {
      _awaitingResult = false;
      _deletingTitulo = null;
      showResultDialog(
        context: context,
        title: 'Error en protocolos y normativas',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProtocoloNormativaBloc, ProtocoloNormativaState>(
      listener: _onStateChanged,
      builder: (BuildContext context, ProtocoloNormativaState state) {
        final List<ProtocoloNormativaEntity> visibles = _visibles;
        final ProtocoloNormativaEntity? selected = _selected;
        return GestionLayout(
          toolbar: ProtocoloGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirProtocolos(visibles),
          ),
          filterBar: ProtocoloGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (ProtocoloEstadoFiltro v) => _updateFilters(() => _estado = v),
            columnFilters: _colFilters,
            onColumnFiltersChanged: _onColumnFiltersChanged,
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _ProtocoloGridContent(
            state: state,
            hasData: _protocolos != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            filters: _colFilters,
            onFiltersChanged: _onColumnFiltersChanged,
            filterSource: _base,
            onSelect: (ProtocoloNormativaEntity p) => setState(() => _selectedId = p.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: ProtocoloDetailPanel(
            protocolo: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenProtocolos(_protocolos ?? <ProtocoloNormativaEntity>[], visibles.length),
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

  List<ProtocoloNormativaEntity> _pageOf(List<ProtocoloNormativaEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _ProtocoloGridContent extends StatelessWidget {
  const _ProtocoloGridContent({
    required this.state,
    required this.hasData,
    required this.rows,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.hasFilters,
    required this.filters,
    required this.onFiltersChanged,
    required this.filterSource,
    required this.onSelect,
    required this.onActivate,
    required this.onSort,
    required this.onRetry,
  });

  final ProtocoloNormativaState state;
  final bool hasData;
  final List<ProtocoloNormativaEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final GestionColumnFilters filters;
  final ValueChanged<GestionColumnFilters> onFiltersChanged;
  final List<ProtocoloNormativaEntity> filterSource;
  final ValueChanged<ProtocoloNormativaEntity> onSelect;
  final ValueChanged<ProtocoloNormativaEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ProtocoloNormativaState s = state;
    if (!hasData && s is ProtocoloNormativaError) {
      return _ProtocoloLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<ProtocoloNormativaEntity>(
          columns: protocoloGestionColumns,
          rows: rows,
          filters: filters,
          onFiltersChanged: onFiltersChanged,
          filterSource: filterSource,
          rowId: (ProtocoloNormativaEntity p) => p.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún protocolo coincide con los filtros'
              : 'No hay protocolos registrados. Pulsa "Nuevo" para crear uno.',
        ),
        if (s is ProtocoloNormativaLoading || s is ProtocoloNormativaSaving)
          const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}

class _ProtocoloLoadError extends StatelessWidget {
  const _ProtocoloLoadError({required this.message, required this.onRetry});

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
            'Error al cargar protocolos y normativas',
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
