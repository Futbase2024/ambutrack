import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_state.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/widgets/gestion/tipo_traslado_detail_panel.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/widgets/gestion/tipo_traslado_gestion_bars.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/widgets/gestion/tipo_traslado_gestion_columns.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/widgets/tipo_traslado_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de tipos de traslado con layout de programa de gestión:
/// barra de herramientas + filtros + rejilla + ficha lateral + barra de estado
class TipoTrasladoGestionView extends StatefulWidget {
  const TipoTrasladoGestionView({super.key});

  @override
  State<TipoTrasladoGestionView> createState() => _TipoTrasladoGestionViewState();
}

class _TipoTrasladoGestionViewState extends State<TipoTrasladoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool? _activo;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Nombre del registro cuyo borrado está en curso (para el aviso de éxito)
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<TipoTrasladoEntity>? _items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _activo != null;

  TipoTrasladoEntity? get _selected {
    for (final TipoTrasladoEntity e in _items ?? const <TipoTrasladoEntity>[]) {
      if (e.id == _selectedId) {
        return e;
      }
    }
    return null;
  }

  List<TipoTrasladoEntity> get _visibles => _sort.apply(
        filtrarTiposTraslado(_items ?? <TipoTrasladoEntity>[], query: _query, activo: _activo),
        tipoTrasladoGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _activo = null;
      });

  void _refresh() => context.read<TipoTrasladoBloc>().add(const TipoTrasladoLoadRequested());

  Future<void> _openForm([TipoTrasladoEntity? item]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<TipoTrasladoBloc>.value(
        value: context.read<TipoTrasladoBloc>(),
        child: TipoTrasladoFormDialog(tipo: item),
      ),
    );
  }

  Future<void> _confirmDelete(TipoTrasladoEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar tipo de traslado',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': item.nombre,
        'Descripción': GestionFormatters.texto(item.descripcion),
        'Estado': item.activo ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando tipo de traslado: ${item.nombre} (${item.id})');
      setState(() {
        _selectedId = null;
        _deletingNombre = item.nombre;
      });
      context.read<TipoTrasladoBloc>().add(TipoTrasladoDeleteRequested(item.id));
    }
  }

  void _onStateChanged(BuildContext context, TipoTrasladoState state) {
    if (state is TipoTrasladoLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _items = state.tipos;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Tipo de traslado', nombre: eliminado);
      }
    } else if (state is TipoTrasladoError && _items != null && _deletingNombre != null) {
      setState(() => _deletingNombre = null);
      showResultDialog(
        context: context,
        title: 'Error al eliminar',
        message: 'No se pudo eliminar el tipo de traslado.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TipoTrasladoBloc, TipoTrasladoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, TipoTrasladoState state) {
        final List<TipoTrasladoEntity> visibles = _visibles;
        final TipoTrasladoEntity? selected = _selected;
        return GestionLayout(
          toolbar: TipoTrasladoGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirTiposTraslado(visibles),
          ),
          filterBar: TipoTrasladoGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            activo: _activo,
            onActivoChanged: (bool? v) => _updateFilters(() => _activo = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _TipoTrasladoGridContent(
            state: state,
            hasData: _items != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (TipoTrasladoEntity e) => setState(() => _selectedId = e.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: TipoTrasladoDetailPanel(
            item: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenTiposTraslado(_items ?? <TipoTrasladoEntity>[], visibles.length),
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

  List<TipoTrasladoEntity> _pageOf(List<TipoTrasladoEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _TipoTrasladoGridContent extends StatelessWidget {
  const _TipoTrasladoGridContent({
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

  final TipoTrasladoState state;
  final bool hasData;
  final List<TipoTrasladoEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<TipoTrasladoEntity> onSelect;
  final ValueChanged<TipoTrasladoEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final TipoTrasladoState s = state;
    if (!hasData && s is TipoTrasladoError) {
      return _TipoTrasladoLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<TipoTrasladoEntity>(
          columns: tipoTrasladoGestionColumns,
          rows: rows,
          rowId: (TipoTrasladoEntity e) => e.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún tipo de traslado coincide con los filtros'
              : 'No hay tipos de traslado registrados. Pulsa "Nuevo" para crear uno.',
        ),
        if (state is TipoTrasladoLoading)
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

class _TipoTrasladoLoadError extends StatelessWidget {
  const _TipoTrasladoLoadError({required this.message, required this.onRetry});

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
            'Error al cargar tipos de traslado',
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
