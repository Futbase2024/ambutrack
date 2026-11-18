import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/evaluacion_desempeno_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/evaluacion_desempeno_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/evaluacion_desempeno_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/evaluaciones/evaluacion_detail_panel.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/evaluaciones/evaluacion_form_dialog.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/evaluaciones/evaluacion_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/evaluaciones/evaluacion_gestion_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Evaluaciones de desempeño con layout de programa de gestión
class EvaluacionGestionView extends StatefulWidget {
  const EvaluacionGestionView({super.key});

  @override
  State<EvaluacionGestionView> createState() => _EvaluacionGestionViewState();
}

class _EvaluacionGestionViewState extends State<EvaluacionGestionView> {
  final TextEditingController _searchController = TextEditingController();
  final List<GestionColumn<EvaluacionDesempenoEntity>> _columns = evaluacionGestionColumns();
  String _query = '';
  GestionColumnFilters _colFilters = const GestionColumnFilters();
  ValoracionEvaluacion? _valoracion;

  /// Por defecto: fecha más reciente primero
  GestionSort _sort = const GestionSort(columnIndex: 1, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  String? _deletingId;
  String? _deletingNombre;
  List<EvaluacionDesempenoEntity>? _items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _valoracion != null || !_colFilters.isEmpty;

  EvaluacionDesempenoEntity? get _selected =>
      _items?.where((EvaluacionDesempenoEntity e) => e.id == _selectedId).firstOrNull;

  List<EvaluacionDesempenoEntity> get _base => filtrarEvaluaciones(
        _items ?? <EvaluacionDesempenoEntity>[],
        query: _query,
        valoracion: _valoracion,
      );

  List<EvaluacionDesempenoEntity> get _visibles => _sort.apply(_colFilters.apply(_base, _columns), _columns);

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _valoracion = null;
        _colFilters = const GestionColumnFilters();
      });

  void _onColumnFiltersChanged(GestionColumnFilters f) => _updateFilters(() => _colFilters = f);

  void _refresh() => context.read<EvaluacionDesempenoBloc>().add(const EvaluacionDesempenoLoadRequested());

  Future<void> _openForm([EvaluacionDesempenoEntity? item]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<EvaluacionDesempenoBloc>.value(
        value: context.read<EvaluacionDesempenoBloc>(),
        child: EvaluacionFormDialog(item: item),
      ),
    );
  }

  Future<void> _confirmDelete(EvaluacionDesempenoEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar evaluación',
      message: '¿Estás seguro de que deseas eliminar esta evaluación? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Personal': item.personalNombre ?? GestionFormatters.vacio,
        'Fecha': GestionFormatters.fecha(item.fecha),
        if (item.periodo?.isNotEmpty ?? false) 'Periodo': item.periodo!,
        'Media': evaluacionMediaTexto(item.puntuacionMedia),
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingId = item.id;
        _deletingNombre = item.personalNombre;
      });
      context.read<EvaluacionDesempenoBloc>().add(EvaluacionDesempenoDeleteRequested(item.id));
    }
  }

  void _onStateChanged(BuildContext context, EvaluacionDesempenoState state) {
    if (state is EvaluacionDesempenoLoaded) {
      final String? deletingId = _deletingId;
      final bool eliminado = deletingId != null && !state.items.any((EvaluacionDesempenoEntity e) => e.id == deletingId);
      final String? nombre = _deletingNombre;
      setState(() {
        _items = state.items;
        if (eliminado) {
          _deletingId = null;
          _deletingNombre = null;
        }
      });
      if (eliminado) {
        GestionFeedback.eliminado(context, entidad: 'Evaluación', nombre: nombre);
      }
    } else if (state is EvaluacionDesempenoError && _deletingId != null) {
      setState(() {
        _deletingId = null;
        _deletingNombre = null;
      });
      showResultDialog(
        context: context,
        title: 'Error al eliminar evaluación',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EvaluacionDesempenoBloc, EvaluacionDesempenoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, EvaluacionDesempenoState state) {
        final List<EvaluacionDesempenoEntity> visibles = _visibles;
        final EvaluacionDesempenoEntity? selected = _selected;
        return GestionLayout(
          toolbar: GestionStandardToolbar(
            title: 'Evaluaciones de Desempeño',
            icon: Icons.assessment_outlined,
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirEvaluaciones(visibles),
          ),
          filterBar: EvaluacionGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            valoracion: _valoracion,
            onValoracionChanged: (ValoracionEvaluacion? v) => _updateFilters(() => _valoracion = v),
            columnFilters: _colFilters,
            columns: _columns,
            onColumnFiltersChanged: _onColumnFiltersChanged,
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: GestionGridContent<EvaluacionDesempenoEntity>(
            hasData: _items != null,
            isLoading: state is EvaluacionDesempenoLoading,
            errorMessage: state is EvaluacionDesempenoError ? state.message : null,
            errorTitle: 'Error al cargar las evaluaciones',
            columns: _columns,
            rows: gestionPageOf(visibles, _page, _pageSize),
            filters: _colFilters,
            onFiltersChanged: _onColumnFiltersChanged,
            filterSource: _base,
            rowId: (EvaluacionDesempenoEntity e) => e.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            onSelect: (EvaluacionDesempenoEntity e) => setState(() => _selectedId = e.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
            emptyMessage: _hasFilters
                ? 'Ninguna evaluación coincide con los filtros'
                : 'No hay evaluaciones registradas. Pulsa "Nuevo" para añadir una.',
          ),
          detailPanel: EvaluacionDetailPanel(
            item: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenEvaluaciones(_items ?? <EvaluacionDesempenoEntity>[], visibles.length),
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
}
