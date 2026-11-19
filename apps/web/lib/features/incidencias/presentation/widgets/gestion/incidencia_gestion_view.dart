import 'package:ambutrack_core_datasource/incidencias.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_bloc.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_event.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_state.dart';
import 'package:ambutrack_web/features/incidencias/presentation/widgets/gestion/incidencia_detail_panel.dart';
import 'package:ambutrack_web/features/incidencias/presentation/widgets/gestion/incidencia_gestion_bars.dart';
import 'package:ambutrack_web/features/incidencias/presentation/widgets/gestion/incidencia_gestion_columns.dart';
import 'package:ambutrack_web/features/incidencias/presentation/widgets/incidencia_form_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart' show SingleChildWidget;

/// Pantalla de incidencias con layout de programa de gestión
class IncidenciaGestionView extends StatefulWidget {
  const IncidenciaGestionView({super.key});

  @override
  State<IncidenciaGestionView> createState() => _IncidenciaGestionViewState();
}

class _IncidenciaGestionViewState extends State<IncidenciaGestionView> {
  final TextEditingController _searchController = TextEditingController();
  IncidenciaFilters _filters = const IncidenciaFilters();
  GestionSort _sort = const GestionSort(columnIndex: 4, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Borrado solicitado desde esta vista (id + título para el aviso de éxito)
  String? _deletingId;
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<IncidenciaEntity>? _incidencias;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IncidenciaEntity? get _selected {
    for (final IncidenciaEntity i in _incidencias ?? const <IncidenciaEntity>[]) {
      if (i.id == _selectedId) {
        return i;
      }
    }
    return null;
  }

  List<IncidenciaEntity> get _visibles => _sort.apply(
        filtrarIncidencias(_incidencias ?? <IncidenciaEntity>[], _filters),
        incidenciaGestionColumns,
      );

  void _onFiltersChanged(IncidenciaFilters filters) => setState(() {
        _filters = filters;
        _page = 0;
      });

  void _clearFilters() {
    _searchController.clear();
    _onFiltersChanged(const IncidenciaFilters());
  }

  void _refresh() => context.read<IncidenciaBloc>().add(const IncidenciaLoadAllRequested());

  Future<void> _openForm([IncidenciaEntity? incidencia]) {
    final IncidenciaBloc bloc = context.read<IncidenciaBloc>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => MultiBlocProvider(
        providers: <SingleChildWidget>[
          BlocProvider<IncidenciaBloc>.value(value: bloc),
          BlocProvider<VehiculosBloc>.value(value: context.read<VehiculosBloc>()),
        ],
        child: IncidenciaFormDialog(
          incidencia: incidencia,
          onSave: (IncidenciaEntity entity) async {
            bloc.add(
              incidencia == null ? IncidenciaCreateRequested(entity) : IncidenciaUpdateRequested(entity),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(IncidenciaEntity incidencia) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar incidencia',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Título': incidencia.titulo,
        'Categoría': incidencia.categoria.displayName,
        'Estado': incidencia.estado.displayName,
        'Fecha': incidenciaFechaHora(incidencia.fechaIncidencia),
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingId = incidencia.id;
        _deletingNombre = incidencia.titulo;
      });
      context.read<IncidenciaBloc>().add(IncidenciaDeleteRequested(incidencia.id));
    }
  }

  void _onStateChanged(BuildContext context, IncidenciaState state) {
    if (state is IncidenciaLoaded) {
      final String? deletingId = _deletingId;
      final bool eliminado =
          deletingId != null && !state.allIncidencias.any((IncidenciaEntity i) => i.id == deletingId);
      final String? nombre = _deletingNombre;
      setState(() {
        _incidencias = state.allIncidencias;
        if (eliminado) {
          _deletingId = null;
          _deletingNombre = null;
        }
      });
      if (eliminado) {
        GestionFeedback.eliminado(context, entidad: 'Incidencia', nombre: nombre);
      }
    } else if (state is IncidenciaError && _incidencias != null) {
      _deletingId = null;
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en incidencias',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncidenciaBloc, IncidenciaState>(
      listener: _onStateChanged,
      builder: (BuildContext context, IncidenciaState state) {
        final List<IncidenciaEntity> visibles = _visibles;
        final IncidenciaEntity? selected = _selected;
        return GestionLayout(
          toolbar: IncidenciaGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirIncidencias(visibles),
          ),
          filterBar: IncidenciaGestionFilters(
            searchController: _searchController,
            filters: _filters,
            onChanged: _onFiltersChanged,
            onClear: _filters.hasActiveFilters ? _clearFilters : null,
          ),
          content: _IncidenciaGridContent(
            state: state,
            hasData: _incidencias != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _filters.hasActiveFilters,
            onSelect: (IncidenciaEntity i) => setState(() => _selectedId = i.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: IncidenciaDetailPanel(
            incidencia: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenIncidencias(_incidencias ?? <IncidenciaEntity>[], visibles.length),
            pagination: GestionPagination(
              page: _page,
              pageSize: _pageSize,
              totalItems: visibles.length,
              onPageChanged: (int p) => setState(() => _page = p),
              onPageSizeChanged: (int s) => setState(() {
                _pageSize = s;
                _page = 0;
              }),
            ),
          ),
        );
      },
    );
  }

  List<IncidenciaEntity> _pageOf(List<IncidenciaEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _IncidenciaGridContent extends StatelessWidget {
  const _IncidenciaGridContent({
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

  final IncidenciaState state;
  final bool hasData;
  final List<IncidenciaEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<IncidenciaEntity> onSelect;
  final ValueChanged<IncidenciaEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final IncidenciaState s = state;
    if (!hasData && s is IncidenciaError) {
      return _IncidenciaLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<IncidenciaEntity>(
          columns: incidenciaGestionColumns,
          rows: rows,
          rowId: (IncidenciaEntity i) => i.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ninguna incidencia coincide con los filtros'
              : 'No hay incidencias registradas. Pulsa "Nuevo" para crear una.',
        ),
        if (s is IncidenciaLoading)
          const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}

class _IncidenciaLoadError extends StatelessWidget {
  const _IncidenciaLoadError({required this.message, required this.onRetry});

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
            'Error al cargar incidencias',
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
