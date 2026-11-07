import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_bloc.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_event.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_state.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/widgets/centro_hospitalario_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/widgets/gestion/centro_hospitalario_detail_panel.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/widgets/gestion/centro_hospitalario_gestion_bars.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/widgets/gestion/centro_hospitalario_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de centros hospitalarios con layout de programa de gestión
class CentroHospitalarioGestionView extends StatefulWidget {
  const CentroHospitalarioGestionView({super.key});

  @override
  State<CentroHospitalarioGestionView> createState() => _CentroHospitalarioGestionViewState();
}

class _CentroHospitalarioGestionViewState extends State<CentroHospitalarioGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _tipo;
  CentroHospitalarioEstadoFiltro _estado = CentroHospitalarioEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Operación lanzada desde esta vista (eliminar/actualizar) pendiente de resultado
  bool _awaitingResult = false;

  /// Nombre del registro cuyo borrado se ha lanzado desde esta vista
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<CentroHospitalarioEntity>? _centros;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _tipo != null || _estado != CentroHospitalarioEstadoFiltro.todos;

  CentroHospitalarioEntity? get _selected {
    for (final CentroHospitalarioEntity c in _centros ?? const <CentroHospitalarioEntity>[]) {
      if (c.id == _selectedId) {
        return c;
      }
    }
    return null;
  }

  List<CentroHospitalarioEntity> get _visibles => _sort.apply(
        filtrarCentros(
          _centros ?? <CentroHospitalarioEntity>[],
          query: _query,
          tipo: _tipo,
          estado: _estado,
        ),
        centroHospitalarioGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipo = null;
        _estado = CentroHospitalarioEstadoFiltro.todos;
      });

  void _refresh() {
    _awaitingResult = true;
    context.read<CentroHospitalarioBloc>().add(const CentroHospitalarioLoadAllRequested());
  }

  Future<void> _openForm([CentroHospitalarioEntity? centro]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<CentroHospitalarioBloc>.value(
        value: context.read<CentroHospitalarioBloc>(),
        child: CentroHospitalarioFormDialog(centro: centro),
      ),
    );
  }

  Future<void> _confirmDelete(CentroHospitalarioEntity centro) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar centro hospitalario',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': centro.nombre,
        'Tipo': GestionFormatters.texto(centro.tipoCentro),
        'Localidad': GestionFormatters.texto(centro.localidadNombre),
        'Estado': centro.activo ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _awaitingResult = true;
        _deletingNombre = centro.nombre;
      });
      context.read<CentroHospitalarioBloc>().add(CentroHospitalarioDeleteRequested(centro.id));
    }
  }

  void _onStateChanged(BuildContext context, CentroHospitalarioState state) {
    if (state is CentroHospitalarioLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _centros = state.centros;
        _awaitingResult = false;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Centro hospitalario', nombre: eliminado);
      }
    } else if (state is CentroHospitalarioError && _centros != null && _awaitingResult) {
      _awaitingResult = false;
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en centros hospitalarios',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CentroHospitalarioBloc, CentroHospitalarioState>(
      listener: _onStateChanged,
      builder: (BuildContext context, CentroHospitalarioState state) {
        final List<CentroHospitalarioEntity> visibles = _visibles;
        final CentroHospitalarioEntity? selected = _selected;
        return GestionLayout(
          toolbar: CentroHospitalarioGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirCentros(visibles),
          ),
          filterBar: CentroHospitalarioGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipos: tiposDeCentros(_centros ?? <CentroHospitalarioEntity>[]),
            tipo: _tipo,
            onTipoChanged: (String? v) => _updateFilters(() => _tipo = v),
            estado: _estado,
            onEstadoChanged: (CentroHospitalarioEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _CentroHospitalarioGridContent(
            state: state,
            hasData: _centros != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (CentroHospitalarioEntity c) => setState(() => _selectedId = c.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: CentroHospitalarioDetailPanel(
            centro: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenCentros(_centros ?? <CentroHospitalarioEntity>[], visibles.length),
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

  List<CentroHospitalarioEntity> _pageOf(List<CentroHospitalarioEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _CentroHospitalarioGridContent extends StatelessWidget {
  const _CentroHospitalarioGridContent({
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

  final CentroHospitalarioState state;
  final bool hasData;
  final List<CentroHospitalarioEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<CentroHospitalarioEntity> onSelect;
  final ValueChanged<CentroHospitalarioEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final CentroHospitalarioState s = state;
    if (!hasData && s is CentroHospitalarioError) {
      return _CentroHospitalarioLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<CentroHospitalarioEntity>(
          columns: centroHospitalarioGestionColumns,
          rows: rows,
          rowId: (CentroHospitalarioEntity c) => c.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún centro coincide con los filtros'
              : 'No hay centros registrados. Pulsa "Nuevo" para crear uno.',
        ),
        if (s is CentroHospitalarioLoading)
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

class _CentroHospitalarioLoadError extends StatelessWidget {
  const _CentroHospitalarioLoadError({required this.message, required this.onRetry});

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
            'Error al cargar centros hospitalarios',
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
