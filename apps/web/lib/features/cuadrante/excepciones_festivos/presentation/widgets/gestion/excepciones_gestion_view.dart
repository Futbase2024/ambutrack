import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/bloc/excepciones_festivos_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/excepcion_festivo_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/gestion/excepciones_detail_panel.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/gestion/excepciones_gestion_bars.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/gestion/excepciones_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de excepciones y festivos con layout de programa de gestión
class ExcepcionesGestionView extends StatefulWidget {
  const ExcepcionesGestionView({super.key});

  @override
  State<ExcepcionesGestionView> createState() => _ExcepcionesGestionViewState();
}

class _ExcepcionesGestionViewState extends State<ExcepcionesGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _tipo;
  ExcepcionEstadoFiltro _estado = ExcepcionEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Borrado solicitado desde esta vista (id + nombre para el aviso de éxito)
  String? _deletingId;
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<ExcepcionFestivoEntity>? _items;

  @override
  void initState() {
    super.initState();
    final ExcepcionesFestivosBloc bloc = context.read<ExcepcionesFestivosBloc>();
    final ExcepcionesFestivosState state = bloc.state;
    if (state is ExcepcionesFestivosLoaded) {
      _items = state.items;
    } else if (state is ExcepcionesFestivosInitial) {
      bloc.add(const ExcepcionesFestivosLoadRequested());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _tipo != null || _estado != ExcepcionEstadoFiltro.todos;

  ExcepcionFestivoEntity? get _selected {
    for (final ExcepcionFestivoEntity e in _items ?? const <ExcepcionFestivoEntity>[]) {
      if (e.id == _selectedId) {
        return e;
      }
    }
    return null;
  }

  List<ExcepcionFestivoEntity> get _visibles => _sort.apply(
        filtrarExcepciones(_items ?? <ExcepcionFestivoEntity>[], query: _query, tipo: _tipo, estado: _estado),
        excepcionesGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipo = null;
        _estado = ExcepcionEstadoFiltro.todos;
      });

  void _refresh() => context.read<ExcepcionesFestivosBloc>().add(const ExcepcionesFestivosLoadRequested());

  Future<void> _openForm([ExcepcionFestivoEntity? item]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<ExcepcionesFestivosBloc>.value(
        value: context.read<ExcepcionesFestivosBloc>(),
        child: ExcepcionFestivoFormDialog(item: item),
      ),
    );
  }

  Future<void> _confirmDelete(ExcepcionFestivoEntity e) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar excepción/festivo',
      message: '¿Estás seguro de que deseas eliminar esta excepción/festivo? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': e.nombre,
        'Fecha': GestionFormatters.fecha(e.fecha),
        'Tipo': excepcionTipoLabel(e.tipo),
        'Repetir anualmente': e.repetirAnualmente ? 'Sí' : 'No',
        'Afecta dotaciones': e.afectaDotaciones ? 'Sí' : 'No',
        'Estado': e.activo ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando excepción/festivo: ${e.nombre} (${e.id})');
      setState(() {
        _selectedId = null;
        _deletingId = e.id;
        _deletingNombre = '${e.nombre} — ${GestionFormatters.fecha(e.fecha)}';
      });
      context.read<ExcepcionesFestivosBloc>().add(ExcepcionFestivoDeleteRequested(e.id));
    }
  }

  void _onStateChanged(BuildContext context, ExcepcionesFestivosState state) {
    if (state is ExcepcionesFestivosLoaded) {
      final String? deletingId = _deletingId;
      final bool eliminado =
          deletingId != null && !state.items.any((ExcepcionFestivoEntity x) => x.id == deletingId);
      final String? nombre = _deletingNombre;
      setState(() {
        _items = state.items;
        if (eliminado) {
          _deletingId = null;
          _deletingNombre = null;
        }
      });
      if (eliminado) {
        GestionFeedback.eliminado(context, entidad: 'Excepción/Festivo', nombre: nombre);
      }
    } else if (state is ExcepcionesFestivosError && _items != null) {
      _deletingId = null;
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en excepciones y festivos',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExcepcionesFestivosBloc, ExcepcionesFestivosState>(
      listener: _onStateChanged,
      builder: (BuildContext context, ExcepcionesFestivosState state) {
        final List<ExcepcionFestivoEntity> visibles = _visibles;
        final ExcepcionFestivoEntity? selected = _selected;
        return GestionLayout(
          toolbar: ExcepcionesGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirExcepciones(visibles),
          ),
          filterBar: ExcepcionesGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipo: _tipo,
            onTipoChanged: (String? v) => _updateFilters(() => _tipo = v),
            estado: _estado,
            onEstadoChanged: (ExcepcionEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _ExcepcionesGridContent(
            state: state,
            hasData: _items != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (ExcepcionFestivoEntity e) => setState(() => _selectedId = e.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: ExcepcionesDetailPanel(
            item: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenExcepciones(_items ?? <ExcepcionFestivoEntity>[], visibles.length),
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

  List<ExcepcionFestivoEntity> _pageOf(List<ExcepcionFestivoEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _ExcepcionesGridContent extends StatelessWidget {
  const _ExcepcionesGridContent({
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

  final ExcepcionesFestivosState state;
  final bool hasData;
  final List<ExcepcionFestivoEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<ExcepcionFestivoEntity> onSelect;
  final ValueChanged<ExcepcionFestivoEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ExcepcionesFestivosState s = state;
    if (!hasData && s is ExcepcionesFestivosError) {
      return _ExcepcionesLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<ExcepcionFestivoEntity>(
          columns: excepcionesGestionColumns,
          rows: rows,
          rowId: (ExcepcionFestivoEntity e) => e.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún registro coincide con los filtros'
              : 'No hay festivos ni excepciones. Pulsa "Nuevo" para crear uno.',
        ),
        if (s is ExcepcionesFestivosLoading)
          const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}

class _ExcepcionesLoadError extends StatelessWidget {
  const _ExcepcionesLoadError({required this.message, required this.onRetry});

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
            'Error al cargar excepciones y festivos',
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
