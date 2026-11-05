import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/bloc/registro_horario_bloc.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/bloc/registro_horario_event.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/bloc/registro_horario_state.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/fichajes/fichajes_detail_panel.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/fichajes/fichajes_gestion_bars.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/fichajes/fichajes_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/ubicacion_fichaje_map_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Evento de carga por defecto: fichajes de los últimos 30 días
LoadAllRegistros fichajesUltimos30Dias() {
  final DateTime hoy = DateTime.now();
  return LoadAllRegistros(
    fechaInicio: hoy.subtract(const Duration(days: 30)),
    fechaFin: hoy.add(const Duration(days: 1)),
  );
}

/// Pantalla de fichajes con layout de programa de gestión (solo lectura)
class FichajesGestionView extends StatefulWidget {
  const FichajesGestionView({super.key});

  @override
  State<FichajesGestionView> createState() => _FichajesGestionViewState();
}

class _FichajesGestionViewState extends State<FichajesGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  FichajeTipoFiltro _tipo = FichajeTipoFiltro.todos;
  DateTime? _desde;
  DateTime? _hasta;
  GestionSort _sort = const GestionSort(columnIndex: 2, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<RegistroHorarioEntity>? _registros;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _tipo != FichajeTipoFiltro.todos || _desde != null || _hasta != null;

  RegistroHorarioEntity? get _selected {
    for (final RegistroHorarioEntity r in _registros ?? const <RegistroHorarioEntity>[]) {
      if (r.id == _selectedId) {
        return r;
      }
    }
    return null;
  }

  List<RegistroHorarioEntity> get _visibles => _sort.apply(
        filtrarFichajes(
          _registros ?? <RegistroHorarioEntity>[],
          query: _query,
          tipo: _tipo,
          desde: _desde,
          hasta: _hasta,
        ),
        fichajesColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipo = FichajeTipoFiltro.todos;
        _desde = null;
        _hasta = null;
      });

  void _refresh() => context.read<RegistroHorarioBloc>().add(fichajesUltimos30Dias());

  Future<void> _showMap(RegistroHorarioEntity registro) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) => UbicacionFichajeMapDialog(registro: registro),
    );
  }

  void _onStateChanged(BuildContext context, RegistroHorarioState state) {
    if (state is RegistroHorarioFichajesLoaded) {
      setState(() => _registros = state.registros);
    } else if (state is RegistroHorarioError && _registros != null) {
      showResultDialog(
        context: context,
        title: 'Error en fichajes',
        message: 'No se pudieron recargar los fichajes.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegistroHorarioBloc, RegistroHorarioState>(
      listener: _onStateChanged,
      builder: (BuildContext context, RegistroHorarioState state) {
        final List<RegistroHorarioEntity> visibles = _visibles;
        final RegistroHorarioEntity? selected = _selected;
        return GestionLayout(
          toolbar: FichajesGestionToolbar(
            onMap: selected == null ? null : () => _showMap(selected),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirFichajes(visibles),
          ),
          filterBar: FichajesGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipo: _tipo,
            onTipoChanged: (FichajeTipoFiltro v) => _updateFilters(() => _tipo = v),
            desde: _desde,
            onDesdeChanged: (DateTime? v) => _updateFilters(() => _desde = v),
            hasta: _hasta,
            onHastaChanged: (DateTime? v) => _updateFilters(() => _hasta = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _FichajesGridContent(
            state: state,
            hasData: _registros != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (RegistroHorarioEntity r) => setState(() => _selectedId = r.id),
            onActivate: _showMap,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: FichajesDetailPanel(
            registro: selected,
            onMap: () => _showMap(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenFichajes(_registros ?? <RegistroHorarioEntity>[], visibles.length),
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

  List<RegistroHorarioEntity> _pageOf(List<RegistroHorarioEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _FichajesGridContent extends StatelessWidget {
  const _FichajesGridContent({
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

  final RegistroHorarioState state;
  final bool hasData;
  final List<RegistroHorarioEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<RegistroHorarioEntity> onSelect;
  final ValueChanged<RegistroHorarioEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final RegistroHorarioState s = state;
    if (!hasData && s is RegistroHorarioError) {
      return _FichajesLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<RegistroHorarioEntity>(
          columns: fichajesColumns,
          rows: rows,
          rowId: (RegistroHorarioEntity r) => r.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún fichaje coincide con los filtros'
              : 'No hay fichajes en los últimos 30 días',
        ),
        if (s is RegistroHorarioLoading)
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

class _FichajesLoadError extends StatelessWidget {
  const _FichajesLoadError({required this.message, required this.onRetry});

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
            'Error al cargar los fichajes',
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
