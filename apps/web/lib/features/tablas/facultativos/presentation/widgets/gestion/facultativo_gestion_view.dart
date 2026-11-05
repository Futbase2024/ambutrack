import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_bloc.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_event.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_state.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/facultativo_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/gestion/facultativo_detail_panel.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/gestion/facultativo_gestion_bars.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/gestion/facultativo_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de facultativos con layout de programa de gestión
class FacultativoGestionView extends StatefulWidget {
  const FacultativoGestionView({super.key});

  @override
  State<FacultativoGestionView> createState() => _FacultativoGestionViewState();
}

class _FacultativoGestionViewState extends State<FacultativoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _especialidadId;
  FacultativoEstadoFiltro _estado = FacultativoEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Operación lanzada desde esta vista (eliminar/actualizar) pendiente de resultado
  bool _awaitingResult = false;

  /// Nombre del registro cuyo borrado se ha lanzado desde esta vista
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<FacultativoEntity>? _facultativos;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _especialidadId != null || _estado != FacultativoEstadoFiltro.todos;

  FacultativoEntity? get _selected {
    for (final FacultativoEntity c in _facultativos ?? const <FacultativoEntity>[]) {
      if (c.id == _selectedId) {
        return c;
      }
    }
    return null;
  }

  List<FacultativoEntity> get _visibles => _sort.apply(
        filtrarFacultativos(
          _facultativos ?? <FacultativoEntity>[],
          query: _query,
          especialidadId: _especialidadId,
          estado: _estado,
        ),
        facultativoGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _especialidadId = null;
        _estado = FacultativoEstadoFiltro.todos;
      });

  void _refresh() {
    _awaitingResult = true;
    context.read<FacultativoBloc>().add(const FacultativoLoadAllRequested());
  }

  Future<void> _openForm([FacultativoEntity? facultativo]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<FacultativoBloc>.value(
        value: context.read<FacultativoBloc>(),
        child: FacultativoFormDialog(facultativo: facultativo),
      ),
    );
  }

  Future<void> _confirmDelete(FacultativoEntity facultativo) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar facultativo',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': facultativo.nombreCompleto,
        'Nº Colegiado': GestionFormatters.texto(facultativo.numColegiado),
        'Especialidad': GestionFormatters.texto(facultativo.especialidadNombre),
        'Teléfono': GestionFormatters.telefono(facultativo.telefono),
        'Estado': facultativo.activo ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _awaitingResult = true;
        _deletingNombre = facultativo.nombreCompleto;
      });
      context.read<FacultativoBloc>().add(FacultativoDeleteRequested(facultativo.id));
    }
  }

  void _onStateChanged(BuildContext context, FacultativoState state) {
    if (state is FacultativoLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _facultativos = state.facultativos;
        _awaitingResult = false;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Facultativo', nombre: eliminado);
      }
    } else if (state is FacultativoError && _facultativos != null && _awaitingResult) {
      _awaitingResult = false;
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en facultativos',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FacultativoBloc, FacultativoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, FacultativoState state) {
        final List<FacultativoEntity> visibles = _visibles;
        final FacultativoEntity? selected = _selected;
        return GestionLayout(
          toolbar: FacultativoGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirFacultativos(visibles),
          ),
          filterBar: FacultativoGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            especialidades: especialidadesDeFacultativos(_facultativos ?? <FacultativoEntity>[]),
            especialidadId: _especialidadId,
            onEspecialidadChanged: (String? v) => _updateFilters(() => _especialidadId = v),
            estado: _estado,
            onEstadoChanged: (FacultativoEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _FacultativoGridContent(
            state: state,
            hasData: _facultativos != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (FacultativoEntity c) => setState(() => _selectedId = c.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: FacultativoDetailPanel(
            facultativo: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenFacultativos(_facultativos ?? <FacultativoEntity>[], visibles.length),
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

  List<FacultativoEntity> _pageOf(List<FacultativoEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _FacultativoGridContent extends StatelessWidget {
  const _FacultativoGridContent({
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

  final FacultativoState state;
  final bool hasData;
  final List<FacultativoEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<FacultativoEntity> onSelect;
  final ValueChanged<FacultativoEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final FacultativoState s = state;
    if (!hasData && s is FacultativoError) {
      return _FacultativoLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<FacultativoEntity>(
          columns: facultativoGestionColumns,
          rows: rows,
          rowId: (FacultativoEntity c) => c.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún facultativo coincide con los filtros'
              : 'No hay facultativos registrados. Pulsa "Nuevo" para crear uno.',
        ),
        if (s is FacultativoLoading)
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

class _FacultativoLoadError extends StatelessWidget {
  const _FacultativoLoadError({required this.message, required this.onRetry});

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
            'Error al cargar facultativos',
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
