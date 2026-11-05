import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/dotacion_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/gestion/dotaciones_catalogos.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/gestion/dotaciones_detail_panel.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/gestion/dotaciones_gestion_bars.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/gestion/dotaciones_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de dotaciones con layout de programa de gestión
class DotacionesGestionView extends StatefulWidget {
  const DotacionesGestionView({super.key});

  @override
  State<DotacionesGestionView> createState() => _DotacionesGestionViewState();
}

class _DotacionesGestionViewState extends State<DotacionesGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _tipoDestino;
  DotacionEstadoFiltro _estado = DotacionEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Borrado solicitado desde esta vista (id + nombre para el aviso de éxito)
  String? _deletingId;
  String? _deletingNombre;
  DotacionesCatalogos _catalogos = const DotacionesCatalogos();

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<DotacionEntity>? _dotaciones;

  @override
  void initState() {
    super.initState();
    final DotacionesBloc bloc = context.read<DotacionesBloc>();
    final DotacionesState state = bloc.state;
    if (state is DotacionesLoaded) {
      _dotaciones = state.dotaciones;
    } else if (state is DotacionesInitial) {
      bloc.add(const DotacionesLoadRequested());
    }
    _loadCatalogos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogos() async {
    final DotacionesCatalogos cat = await DotacionesCatalogos.cargar();
    if (mounted) {
      setState(() => _catalogos = cat);
    }
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _tipoDestino != null || _estado != DotacionEstadoFiltro.todos;

  List<GestionColumn<DotacionEntity>> get _columns => dotacionesGestionColumns(_catalogos);

  DotacionEntity? get _selected {
    for (final DotacionEntity d in _dotaciones ?? const <DotacionEntity>[]) {
      if (d.id == _selectedId) {
        return d;
      }
    }
    return null;
  }

  List<DotacionEntity> _visibles(List<GestionColumn<DotacionEntity>> columns) => _sort.apply(
        filtrarDotaciones(
          _dotaciones ?? <DotacionEntity>[],
          query: _query,
          tipoDestino: _tipoDestino,
          estado: _estado,
        ),
        columns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipoDestino = null;
        _estado = DotacionEstadoFiltro.todos;
      });

  void _refresh() {
    context.read<DotacionesBloc>().add(const DotacionesLoadRequested());
    _loadCatalogos();
  }

  Future<void> _openForm([DotacionEntity? dotacion]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<DotacionesBloc>.value(
        value: context.read<DotacionesBloc>(),
        child: DotacionFormDialog(dotacion: dotacion),
      ),
    );
  }

  Future<void> _confirmDelete(DotacionEntity d) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar dotación',
      message: '¿Estás seguro de que deseas eliminar esta dotación? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Código': GestionFormatters.texto(d.codigo),
        'Nombre': d.nombre,
        'Destino': '${d.tipoDestino} ${_catalogos.destinoNombre(d) ?? ''}'.trim(),
        'Unidades': '${d.cantidadUnidades}',
        'Prioridad': '${d.prioridad}',
        'Estado': d.activo ? 'Activa' : 'Inactiva',
      },
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando dotación: ${d.nombre} (${d.id})');
      setState(() {
        _selectedId = null;
        _deletingId = d.id;
        _deletingNombre = d.nombre;
      });
      context.read<DotacionesBloc>().add(DotacionDeleteRequested(d.id));
    }
  }

  void _onStateChanged(BuildContext context, DotacionesState state) {
    if (state is DotacionesLoaded) {
      final String? deletingId = _deletingId;
      final bool eliminado =
          deletingId != null && !state.dotaciones.any((DotacionEntity d) => d.id == deletingId);
      final String? nombre = _deletingNombre;
      setState(() {
        _dotaciones = state.dotaciones;
        if (eliminado) {
          _deletingId = null;
          _deletingNombre = null;
        }
      });
      if (eliminado) {
        GestionFeedback.eliminado(context, entidad: 'Dotación', nombre: nombre);
      }
    } else if (state is DotacionesError && _dotaciones != null) {
      _deletingId = null;
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en dotaciones',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DotacionesBloc, DotacionesState>(
      listener: _onStateChanged,
      builder: (BuildContext context, DotacionesState state) {
        final List<GestionColumn<DotacionEntity>> columns = _columns;
        final List<DotacionEntity> visibles = _visibles(columns);
        final DotacionEntity? selected = _selected;
        return GestionLayout(
          toolbar: DotacionesGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirDotaciones(visibles, _catalogos),
          ),
          filterBar: DotacionesGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipoDestino: _tipoDestino,
            onTipoDestinoChanged: (String? v) => _updateFilters(() => _tipoDestino = v),
            estado: _estado,
            onEstadoChanged: (DotacionEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _DotacionesGridContent(
            state: state,
            hasData: _dotaciones != null,
            columns: columns,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (DotacionEntity d) => setState(() => _selectedId = d.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: DotacionesDetailPanel(
            dotacion: selected,
            catalogos: _catalogos,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenDotaciones(_dotaciones ?? <DotacionEntity>[], visibles.length),
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

  List<DotacionEntity> _pageOf(List<DotacionEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _DotacionesGridContent extends StatelessWidget {
  const _DotacionesGridContent({
    required this.state,
    required this.hasData,
    required this.columns,
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

  final DotacionesState state;
  final bool hasData;
  final List<GestionColumn<DotacionEntity>> columns;
  final List<DotacionEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<DotacionEntity> onSelect;
  final ValueChanged<DotacionEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final DotacionesState s = state;
    if (!hasData && s is DotacionesError) {
      return _DotacionesLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<DotacionEntity>(
          columns: columns,
          rows: rows,
          rowId: (DotacionEntity d) => d.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ninguna dotación coincide con los filtros'
              : 'No hay dotaciones registradas. Pulsa "Nueva" para crear una.',
        ),
        if (s is DotacionesLoading)
          const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}

class _DotacionesLoadError extends StatelessWidget {
  const _DotacionesLoadError({required this.message, required this.onRetry});

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
            'Error al cargar dotaciones',
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
