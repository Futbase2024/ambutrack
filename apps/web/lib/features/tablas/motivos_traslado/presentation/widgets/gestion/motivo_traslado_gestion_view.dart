import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_bloc.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_state.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/widgets/gestion/motivo_traslado_detail_panel.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/widgets/gestion/motivo_traslado_gestion_bars.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/widgets/gestion/motivo_traslado_gestion_columns.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/widgets/motivo_traslado_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de motivos de traslado con layout de programa de gestión:
/// barra de herramientas + filtros + rejilla + ficha lateral + barra de estado
class MotivoTrasladoGestionView extends StatefulWidget {
  const MotivoTrasladoGestionView({super.key});

  @override
  State<MotivoTrasladoGestionView> createState() => _MotivoTrasladoGestionViewState();
}

class _MotivoTrasladoGestionViewState extends State<MotivoTrasladoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool? _activo;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<MotivoTrasladoEntity>? _items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _activo != null;

  MotivoTrasladoEntity? get _selected {
    for (final MotivoTrasladoEntity e in _items ?? const <MotivoTrasladoEntity>[]) {
      if (e.id == _selectedId) {
        return e;
      }
    }
    return null;
  }

  List<MotivoTrasladoEntity> get _visibles => _sort.apply(
        filtrarMotivosTraslado(_items ?? <MotivoTrasladoEntity>[], query: _query, activo: _activo),
        motivoTrasladoGestionColumns,
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

  void _refresh() => context.read<MotivoTrasladoBloc>().add(const MotivoTrasladoLoadAllRequested());

  Future<void> _openForm([MotivoTrasladoEntity? item]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<MotivoTrasladoBloc>.value(
        value: context.read<MotivoTrasladoBloc>(),
        child: MotivoTrasladoFormDialog(motivo: item),
      ),
    );
  }

  Future<void> _confirmDelete(MotivoTrasladoEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar motivo de traslado',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': item.nombre,
        'Descripción': GestionFormatters.texto(item.descripcion),
        'Estado': item.activo ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando motivo de traslado: ${item.nombre} (${item.id})');
      setState(() {
        _selectedId = null;
        _deletingNombre = item.nombre;
      });
      context.read<MotivoTrasladoBloc>().add(MotivoTrasladoDeleteRequested(item.id));
    }
  }

  void _onStateChanged(BuildContext context, MotivoTrasladoState state) {
    if (state is MotivoTrasladoOperationSuccess) {
      final String? eliminado = _deletingNombre;
      _deletingNombre = null;
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Motivo de traslado', nombre: eliminado);
      }
    } else if (state is MotivoTrasladoLoaded) {
      setState(() => _items = state.motivos);
    } else if (state is MotivoTrasladoError && _deletingNombre != null) {
      setState(() => _deletingNombre = null);
      showResultDialog(
        context: context,
        title: 'Error al eliminar',
        message: 'No se pudo eliminar el motivo de traslado.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MotivoTrasladoBloc, MotivoTrasladoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, MotivoTrasladoState state) {
        final List<MotivoTrasladoEntity> visibles = _visibles;
        final MotivoTrasladoEntity? selected = _selected;
        return GestionLayout(
          toolbar: MotivoTrasladoGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirMotivosTraslado(visibles),
          ),
          filterBar: MotivoTrasladoGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            activo: _activo,
            onActivoChanged: (bool? v) => _updateFilters(() => _activo = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _MotivoTrasladoGridContent(
            state: state,
            hasData: _items != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (MotivoTrasladoEntity e) => setState(() => _selectedId = e.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: MotivoTrasladoDetailPanel(
            item: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenMotivosTraslado(_items ?? <MotivoTrasladoEntity>[], visibles.length),
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

  List<MotivoTrasladoEntity> _pageOf(List<MotivoTrasladoEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _MotivoTrasladoGridContent extends StatelessWidget {
  const _MotivoTrasladoGridContent({
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

  final MotivoTrasladoState state;
  final bool hasData;
  final List<MotivoTrasladoEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<MotivoTrasladoEntity> onSelect;
  final ValueChanged<MotivoTrasladoEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final MotivoTrasladoState s = state;
    if (!hasData && s is MotivoTrasladoError) {
      return _MotivoTrasladoLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<MotivoTrasladoEntity>(
          columns: motivoTrasladoGestionColumns,
          rows: rows,
          rowId: (MotivoTrasladoEntity e) => e.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún motivo de traslado coincide con los filtros'
              : 'No hay motivos de traslado registrados. Pulsa "Nuevo" para crear uno.',
        ),
        if (state is MotivoTrasladoLoading || state is MotivoTrasladoOperationInProgress)
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

class _MotivoTrasladoLoadError extends StatelessWidget {
  const _MotivoTrasladoLoadError({required this.message, required this.onRetry});

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
            'Error al cargar motivos de traslado',
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
