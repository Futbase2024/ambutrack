import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_bloc.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_state.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/widgets/gestion/motivo_cancelacion_detail_panel.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/widgets/gestion/motivo_cancelacion_gestion_bars.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/widgets/gestion/motivo_cancelacion_gestion_columns.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/widgets/motivo_cancelacion_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de motivos de cancelación con layout de programa de gestión:
/// barra de herramientas + filtros + rejilla + ficha lateral + barra de estado
class MotivoCancelacionGestionView extends StatefulWidget {
  const MotivoCancelacionGestionView({super.key});

  @override
  State<MotivoCancelacionGestionView> createState() => _MotivoCancelacionGestionViewState();
}

class _MotivoCancelacionGestionViewState extends State<MotivoCancelacionGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool? _activo;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<MotivoCancelacionEntity>? _items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _activo != null;

  MotivoCancelacionEntity? get _selected {
    for (final MotivoCancelacionEntity e in _items ?? const <MotivoCancelacionEntity>[]) {
      if (e.id == _selectedId) {
        return e;
      }
    }
    return null;
  }

  List<MotivoCancelacionEntity> get _visibles => _sort.apply(
        filtrarMotivosCancelacion(_items ?? <MotivoCancelacionEntity>[], query: _query, activo: _activo),
        motivoCancelacionGestionColumns,
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

  void _refresh() => context.read<MotivoCancelacionBloc>().add(const MotivoCancelacionLoadRequested());

  Future<void> _openForm([MotivoCancelacionEntity? item]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<MotivoCancelacionBloc>.value(
        value: context.read<MotivoCancelacionBloc>(),
        child: MotivoCancelacionFormDialog(motivo: item),
      ),
    );
  }

  Future<void> _confirmDelete(MotivoCancelacionEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar motivo de cancelación',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': item.nombre,
        'Descripción': GestionFormatters.texto(item.descripcion),
        'Estado': item.activo ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando motivo de cancelación: ${item.nombre} (${item.id})');
      setState(() {
        _selectedId = null;
        _deletingNombre = item.nombre;
      });
      context.read<MotivoCancelacionBloc>().add(MotivoCancelacionDeleteRequested(item.id));
    }
  }

  void _onStateChanged(BuildContext context, MotivoCancelacionState state) {
    if (state is MotivoCancelacionLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _items = state.motivos;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Motivo de cancelación', nombre: eliminado);
      }
    } else if (state is MotivoCancelacionError && _deletingNombre != null) {
      setState(() => _deletingNombre = null);
      showResultDialog(
        context: context,
        title: 'Error al eliminar',
        message: 'No se pudo eliminar el motivo de cancelación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MotivoCancelacionBloc, MotivoCancelacionState>(
      listener: _onStateChanged,
      builder: (BuildContext context, MotivoCancelacionState state) {
        final List<MotivoCancelacionEntity> visibles = _visibles;
        final MotivoCancelacionEntity? selected = _selected;
        return GestionLayout(
          toolbar: MotivoCancelacionGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirMotivosCancelacion(visibles),
          ),
          filterBar: MotivoCancelacionGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            activo: _activo,
            onActivoChanged: (bool? v) => _updateFilters(() => _activo = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _MotivoCancelacionGridContent(
            state: state,
            hasData: _items != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (MotivoCancelacionEntity e) => setState(() => _selectedId = e.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: MotivoCancelacionDetailPanel(
            item: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenMotivosCancelacion(_items ?? <MotivoCancelacionEntity>[], visibles.length),
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

  List<MotivoCancelacionEntity> _pageOf(List<MotivoCancelacionEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _MotivoCancelacionGridContent extends StatelessWidget {
  const _MotivoCancelacionGridContent({
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

  final MotivoCancelacionState state;
  final bool hasData;
  final List<MotivoCancelacionEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<MotivoCancelacionEntity> onSelect;
  final ValueChanged<MotivoCancelacionEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final MotivoCancelacionState s = state;
    if (!hasData && s is MotivoCancelacionError) {
      return _MotivoCancelacionLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<MotivoCancelacionEntity>(
          columns: motivoCancelacionGestionColumns,
          rows: rows,
          rowId: (MotivoCancelacionEntity e) => e.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún motivo de cancelación coincide con los filtros'
              : 'No hay motivos de cancelación registrados. Pulsa "Nuevo" para crear uno.',
        ),
        if (state is MotivoCancelacionLoading)
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

class _MotivoCancelacionLoadError extends StatelessWidget {
  const _MotivoCancelacionLoadError({required this.message, required this.onRetry});

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
            'Error al cargar motivos de cancelación',
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
