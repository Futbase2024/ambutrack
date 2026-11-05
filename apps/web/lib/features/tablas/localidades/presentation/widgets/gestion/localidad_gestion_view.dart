import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_bloc.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_event.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_state.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/widgets/gestion/localidad_detail_panel.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/widgets/gestion/localidad_gestion_bars.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/widgets/gestion/localidad_gestion_columns.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/widgets/localidad_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de localidades con layout de programa de gestión
class LocalidadGestionView extends StatefulWidget {
  const LocalidadGestionView({super.key});

  @override
  State<LocalidadGestionView> createState() => _LocalidadGestionViewState();
}

class _LocalidadGestionViewState extends State<LocalidadGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _provinciaId;
  GestionSort _sort = const GestionSort(columnIndex: 1);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Operación lanzada desde esta vista (eliminar/actualizar) pendiente de resultado
  bool _awaitingResult = false;

  /// Nombre del registro cuyo borrado se ha lanzado desde esta vista
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<LocalidadEntity>? _localidades;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _provinciaId != null;

  LocalidadEntity? get _selected {
    for (final LocalidadEntity c in _localidades ?? const <LocalidadEntity>[]) {
      if (c.id == _selectedId) {
        return c;
      }
    }
    return null;
  }

  List<LocalidadEntity> get _visibles => _sort.apply(
        filtrarLocalidades(
          _localidades ?? <LocalidadEntity>[],
          query: _query,
          provinciaId: _provinciaId,
        ),
        localidadGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _provinciaId = null;
      });

  void _refresh() {
    _awaitingResult = true;
    context.read<LocalidadBloc>().add(const LocalidadLoadAllRequested());
  }

  Future<void> _openForm([LocalidadEntity? localidad]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<LocalidadBloc>.value(
        value: context.read<LocalidadBloc>(),
        child: LocalidadFormDialog(localidad: localidad),
      ),
    );
  }

  Future<void> _confirmDelete(LocalidadEntity localidad) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar localidad',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Localidad': localidad.nombre,
        'Código Postal': GestionFormatters.texto(localidad.codigoPostal),
        'Provincia': GestionFormatters.texto(localidad.provinciaNombre),
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _awaitingResult = true;
        _deletingNombre = localidad.nombre;
      });
      context.read<LocalidadBloc>().add(LocalidadDeleteRequested(localidad.id));
    }
  }

  void _onStateChanged(BuildContext context, LocalidadState state) {
    if (state is LocalidadDeleted) {
      final String? eliminado = _deletingNombre;
      _deletingNombre = null;
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Localidad', nombre: eliminado);
      }
    } else if (state is LocalidadLoaded) {
      setState(() {
        _localidades = state.localidades;
        _awaitingResult = false;
      });
    } else if (state is LocalidadError && _localidades != null && _awaitingResult) {
      _awaitingResult = false;
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en localidades',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocalidadBloc, LocalidadState>(
      listener: _onStateChanged,
      builder: (BuildContext context, LocalidadState state) {
        final List<LocalidadEntity> visibles = _visibles;
        final LocalidadEntity? selected = _selected;
        return GestionLayout(
          toolbar: LocalidadGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirLocalidades(visibles),
          ),
          filterBar: LocalidadGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            provincias: provinciasDeLocalidades(_localidades ?? <LocalidadEntity>[]),
            provinciaId: _provinciaId,
            onProvinciaChanged: (String? v) => _updateFilters(() => _provinciaId = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _LocalidadGridContent(
            state: state,
            hasData: _localidades != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (LocalidadEntity c) => setState(() => _selectedId = c.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: LocalidadDetailPanel(
            localidad: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenLocalidades(_localidades ?? <LocalidadEntity>[], visibles.length),
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

  List<LocalidadEntity> _pageOf(List<LocalidadEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _LocalidadGridContent extends StatelessWidget {
  const _LocalidadGridContent({
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

  final LocalidadState state;
  final bool hasData;
  final List<LocalidadEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<LocalidadEntity> onSelect;
  final ValueChanged<LocalidadEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final LocalidadState s = state;
    if (!hasData && s is LocalidadError) {
      return _LocalidadLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<LocalidadEntity>(
          columns: localidadGestionColumns,
          rows: rows,
          rowId: (LocalidadEntity c) => c.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ninguna localidad coincide con los filtros'
              : 'No hay localidades registradas. Pulsa "Nuevo" para crear una.',
        ),
        if (s is LocalidadLoading ||
            s is LocalidadCreating ||
            s is LocalidadUpdating ||
            s is LocalidadDeleting)
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

class _LocalidadLoadError extends StatelessWidget {
  const _LocalidadLoadError({required this.message, required this.onRetry});

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
            'Error al cargar localidades',
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
