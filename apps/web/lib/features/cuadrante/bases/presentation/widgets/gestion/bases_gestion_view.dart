import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/bloc/bloc.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/base_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/gestion/bases_detail_panel.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/gestion/bases_gestion_bars.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/gestion/bases_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de bases con layout de programa de gestión
class BasesGestionView extends StatefulWidget {
  const BasesGestionView({super.key});

  @override
  State<BasesGestionView> createState() => _BasesGestionViewState();
}

class _BasesGestionViewState extends State<BasesGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  BaseEstadoFiltro _estado = BaseEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<BaseCentroEntity>? _bases;

  @override
  void initState() {
    super.initState();
    final BasesBloc bloc = context.read<BasesBloc>();
    final BasesState state = bloc.state;
    if (state is BasesLoaded) {
      _bases = state.bases;
    } else if (state is BasesInitial) {
      bloc.add(const BasesLoadRequested());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != BaseEstadoFiltro.todos;

  BaseCentroEntity? get _selected {
    for (final BaseCentroEntity b in _bases ?? const <BaseCentroEntity>[]) {
      if (b.id == _selectedId) {
        return b;
      }
    }
    return null;
  }

  List<BaseCentroEntity> get _visibles => _sort.apply(
        filtrarBases(_bases ?? <BaseCentroEntity>[], query: _query, estado: _estado),
        basesGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = BaseEstadoFiltro.todos;
      });

  void _refresh() => context.read<BasesBloc>().add(const BasesLoadRequested());

  Future<void> _openForm([BaseCentroEntity? base]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<BasesBloc>.value(
        value: context.read<BasesBloc>(),
        child: BaseFormDialog(base: base),
      ),
    );
  }

  Future<void> _confirmToggleActivo(BaseCentroEntity base) async {
    final bool activa = base.activo;
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar ${activa ? 'desactivación' : 'activación'}',
      message: '¿Estás seguro de que deseas ${activa ? 'desactivar' : 'activar'} esta base?',
      confirmText: activa ? 'Desactivar' : 'Activar',
      icon: activa ? Icons.block : Icons.check_circle_outline,
      iconColor: activa ? AppColors.error : AppColors.success,
      confirmButtonColor: activa ? AppColors.error : AppColors.success,
      itemDetails: <String, String>{
        'Código': GestionFormatters.texto(base.codigo),
        'Nombre': base.nombre,
        'Dirección': GestionFormatters.texto(base.direccion),
        'Población': GestionFormatters.texto(base.poblacionNombre),
        'Tipo': GestionFormatters.texto(base.tipo),
        'Estado': activa ? 'Activa' : 'Inactiva',
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final BasesBloc bloc = context.read<BasesBloc>();
    if (activa) {
      bloc.add(BaseDeactivateRequested(base.id));
    } else {
      bloc.add(BaseUpdateRequested(base.copyWith(activo: true, updatedAt: DateTime.now())));
    }
  }

  void _onStateChanged(BuildContext context, BasesState state) {
    if (state is BasesLoaded) {
      setState(() => _bases = state.bases);
    } else if (state is BasesError && _bases != null) {
      showResultDialog(
        context: context,
        title: 'Error en bases',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BasesBloc, BasesState>(
      listener: _onStateChanged,
      builder: (BuildContext context, BasesState state) {
        final List<BaseCentroEntity> visibles = _visibles;
        final BaseCentroEntity? selected = _selected;
        return GestionLayout(
          toolbar: BasesGestionToolbar(
            selected: selected,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onToggleActivo: () => _confirmToggleActivo(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirBases(visibles),
          ),
          filterBar: BasesGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (BaseEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _BasesGridContent(
            state: state,
            hasData: _bases != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (BaseCentroEntity b) => setState(() => _selectedId = b.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: BasesDetailPanel(
            base: selected,
            onEdit: () => _openForm(selected),
            onToggleActivo: () => _confirmToggleActivo(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenBases(_bases ?? <BaseCentroEntity>[], visibles.length),
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

  List<BaseCentroEntity> _pageOf(List<BaseCentroEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _BasesGridContent extends StatelessWidget {
  const _BasesGridContent({
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

  final BasesState state;
  final bool hasData;
  final List<BaseCentroEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<BaseCentroEntity> onSelect;
  final ValueChanged<BaseCentroEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final BasesState s = state;
    if (!hasData && s is BasesError) {
      return _BasesLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<BaseCentroEntity>(
          columns: basesGestionColumns,
          rows: rows,
          rowId: (BaseCentroEntity b) => b.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ninguna base coincide con los filtros'
              : 'No hay bases registradas. Pulsa "Nueva" para crear una.',
        ),
        if (s is BasesLoading)
          const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}

class _BasesLoadError extends StatelessWidget {
  const _BasesLoadError({required this.message, required this.onRetry});

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
            'Error al cargar bases',
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
