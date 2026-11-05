import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_bloc.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_event.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_state.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/widgets/gestion/provincia_detail_panel.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/widgets/gestion/provincia_gestion_bars.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/widgets/gestion/provincia_gestion_columns.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/widgets/provincia_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de provincias con layout de programa de gestión:
/// barra de herramientas + filtros + rejilla + ficha lateral + barra de estado
class ProvinciaGestionView extends StatefulWidget {
  const ProvinciaGestionView({super.key});

  @override
  State<ProvinciaGestionView> createState() => _ProvinciaGestionViewState();
}

class _ProvinciaGestionViewState extends State<ProvinciaGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _comunidadId;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Nombre de la provincia cuyo borrado está en curso (para el aviso de éxito)
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<ProvinciaEntity>? _items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _comunidadId != null;

  ProvinciaEntity? get _selected {
    for (final ProvinciaEntity e in _items ?? const <ProvinciaEntity>[]) {
      if (e.id == _selectedId) {
        return e;
      }
    }
    return null;
  }

  List<ProvinciaEntity> get _visibles => _sort.apply(
        filtrarProvincias(_items ?? <ProvinciaEntity>[], query: _query, comunidadId: _comunidadId),
        provinciaGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _comunidadId = null;
      });

  void _refresh() => context.read<ProvinciaBloc>().add(const ProvinciaLoadAllRequested());

  Future<void> _openForm([ProvinciaEntity? item]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<ProvinciaBloc>.value(
        value: context.read<ProvinciaBloc>(),
        child: ProvinciaFormDialog(provincia: item),
      ),
    );
  }

  Future<void> _confirmDelete(ProvinciaEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar provincia',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Provincia': item.nombre,
        'Código': GestionFormatters.texto(item.codigo),
        'Comunidad Autónoma': GestionFormatters.texto(item.comunidadAutonoma),
      },
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando provincia: ${item.nombre} (${item.id})');
      setState(() {
        _selectedId = null;
        _deletingNombre = item.nombre;
      });
      context.read<ProvinciaBloc>().add(ProvinciaDeleteRequested(item.id));
    }
  }

  void _onStateChanged(BuildContext context, ProvinciaState state) {
    if (state is ProvinciaDeleted) {
      final String? eliminado = _deletingNombre;
      if (eliminado != null) {
        setState(() => _deletingNombre = null);
        GestionFeedback.eliminado(context, entidad: 'Provincia', nombre: eliminado);
      }
    } else if (state is ProvinciaLoaded) {
      setState(() => _items = state.provincias);
    } else if (state is ProvinciaError && _items != null && _deletingNombre != null) {
      setState(() => _deletingNombre = null);
      showResultDialog(
        context: context,
        title: 'Error al eliminar',
        message: 'No se pudo eliminar la provincia.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProvinciaBloc, ProvinciaState>(
      listener: _onStateChanged,
      builder: (BuildContext context, ProvinciaState state) {
        final List<ProvinciaEntity> visibles = _visibles;
        final ProvinciaEntity? selected = _selected;
        return GestionLayout(
          toolbar: ProvinciaGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirProvincias(visibles),
          ),
          filterBar: ProvinciaGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            comunidadId: _comunidadId,
            comunidades: comunidadesDeProvincias(_items ?? <ProvinciaEntity>[]),
            onComunidadChanged: (String? v) => _updateFilters(() => _comunidadId = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _ProvinciaGridContent(
            state: state,
            hasData: _items != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (ProvinciaEntity e) => setState(() => _selectedId = e.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: ProvinciaDetailPanel(
            item: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenProvincias(_items ?? <ProvinciaEntity>[], visibles.length),
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

  List<ProvinciaEntity> _pageOf(List<ProvinciaEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _ProvinciaGridContent extends StatelessWidget {
  const _ProvinciaGridContent({
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

  final ProvinciaState state;
  final bool hasData;
  final List<ProvinciaEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<ProvinciaEntity> onSelect;
  final ValueChanged<ProvinciaEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ProvinciaState s = state;
    if (!hasData && s is ProvinciaError) {
      return _ProvinciaLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<ProvinciaEntity>(
          columns: provinciaGestionColumns,
          rows: rows,
          rowId: (ProvinciaEntity e) => e.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ninguna provincia coincide con los filtros'
              : 'No hay provincias registradas. Pulsa "Nuevo" para crear una.',
        ),
        if (state is ProvinciaLoading ||
            state is ProvinciaCreating ||
            state is ProvinciaUpdating ||
            state is ProvinciaDeleting)
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

class _ProvinciaLoadError extends StatelessWidget {
  const _ProvinciaLoadError({required this.message, required this.onRetry});

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
            'Error al cargar provincias',
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
