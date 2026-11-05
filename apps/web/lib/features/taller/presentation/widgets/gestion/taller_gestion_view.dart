import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_detail_panel.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_bars.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/taller_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de talleres con layout de programa de gestión:
/// barra de herramientas + filtros + rejilla + ficha lateral + barra de estado
class TallerGestionView extends StatefulWidget {
  const TallerGestionView({super.key});

  @override
  State<TallerGestionView> createState() => _TallerGestionViewState();
}

class _TallerGestionViewState extends State<TallerGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  TipoTaller? _tipo;
  TallerEstadoFiltro _estado = TallerEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Nombre del taller cuyo borrado está en curso (para el aviso de éxito)
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<TallerEntity>? _talleres;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _tipo != null || _estado != TallerEstadoFiltro.todos;

  TallerEntity? get _selected {
    for (final TallerEntity t in _talleres ?? const <TallerEntity>[]) {
      if (t.id == _selectedId) {
        return t;
      }
    }
    return null;
  }

  List<TallerEntity> get _visibles => _sort.apply(
        filtrarTalleres(_talleres ?? <TallerEntity>[], query: _query, tipo: _tipo, estado: _estado),
        tallerGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipo = null;
        _estado = TallerEstadoFiltro.todos;
      });

  void _refresh() {
    context.read<TallerBloc>().add(const TallerLoadRequested());
    context.read<OrdenReparacionBloc>().add(const OrdenReparacionLoadRequested(silent: true));
  }

  Future<void> _openForm([TallerEntity? taller]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<TallerBloc>.value(
        value: context.read<TallerBloc>(),
        child: TallerFormDialog(taller: taller),
      ),
    );
  }

  Future<void> _confirmDelete(TallerEntity taller) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar taller',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': taller.nombre,
        'Tipo': taller.tipo.displayName,
        'Ciudad': GestionFormatters.texto(taller.ciudad),
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingNombre = taller.nombre;
      });
      context.read<TallerBloc>().add(TallerDeleteRequested(id: taller.id));
    }
  }

  void _onStateChanged(BuildContext context, TallerState state) {
    if (state is TallerLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _talleres = state.talleres;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Taller', nombre: eliminado);
      }
    } else if (state is TallerError && _talleres != null) {
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en talleres',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TallerBloc, TallerState>(
      listener: _onStateChanged,
      builder: (BuildContext context, TallerState state) {
        final List<TallerEntity> visibles = _visibles;
        final TallerEntity? selected = _selected;
        return GestionLayout(
          toolbar: TallerGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirTalleres(visibles),
          ),
          filterBar: TallerGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipo: _tipo,
            onTipoChanged: (TipoTaller? v) => _updateFilters(() => _tipo = v),
            estado: _estado,
            onEstadoChanged: (TallerEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _TallerGridContent(
            state: state,
            hasData: _talleres != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (TallerEntity t) => setState(() => _selectedId = t.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: TallerDetailPanel(
            taller: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenTalleres(_talleres ?? <TallerEntity>[], visibles.length),
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

  List<TallerEntity> _pageOf(List<TallerEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _TallerGridContent extends StatelessWidget {
  const _TallerGridContent({
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

  final TallerState state;
  final bool hasData;
  final List<TallerEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<TallerEntity> onSelect;
  final ValueChanged<TallerEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (!hasData && state is TallerError) {
      return _TallerLoadError(
        message: (state as TallerError).message,
        onRetry: onRetry,
      );
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<TallerEntity>(
          columns: tallerGestionColumns,
          rows: rows,
          rowId: (TallerEntity t) => t.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún taller coincide con los filtros'
              : 'No hay talleres registrados. Pulsa "Nuevo" para crear uno.',
        ),
        if (state is TallerLoading)
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

class _TallerLoadError extends StatelessWidget {
  const _TallerLoadError({required this.message, required this.onRetry});

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
            'Error al cargar talleres',
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
