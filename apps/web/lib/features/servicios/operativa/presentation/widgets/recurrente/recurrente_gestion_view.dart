import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/programacion_recurrente_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/programacion_recurrente_event.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/programacion_recurrente_state.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/gestion_load_error.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/recurrente/recurrente_detail_panel.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/recurrente/recurrente_gestion_columns.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/recurrente/recurrente_gestion_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Programación recurrente: servicios con recurrencia activa y su patrón
class RecurrenteGestionView extends StatefulWidget {
  const RecurrenteGestionView({super.key});

  @override
  State<RecurrenteGestionView> createState() => _RecurrenteGestionViewState();
}

class _RecurrenteGestionViewState extends State<RecurrenteGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _tipo;
  RecurrenteVigencia? _vigencia = RecurrenteVigencia.vigente;
  GestionSort _sort = const GestionSort(columnIndex: 1);
  int _page = 0;
  int _pageSize = 50;
  String? _selectedId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _tipo != null || _vigencia != RecurrenteVigencia.vigente;

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipo = null;
        _vigencia = RecurrenteVigencia.vigente;
      });

  void _refresh() =>
      context.read<ProgramacionRecurrenteBloc>().add(const ProgramacionLoadRequested());

  void _select(ServicioRecurrenteEntity s) {
    if (s.id == _selectedId) {
      return;
    }
    setState(() => _selectedId = s.id);
    context
        .read<ProgramacionRecurrenteBloc>()
        .add(ProgramacionTrasladosRequested(idServicioRecurrente: s.id));
  }

  ServicioRecurrenteEntity? _find(List<ServicioRecurrenteEntity> rows) {
    for (final ServicioRecurrenteEntity s in rows) {
      if (s.id == _selectedId) {
        return s;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramacionRecurrenteBloc, ProgramacionRecurrenteState>(
      buildWhen: (ProgramacionRecurrenteState p, ProgramacionRecurrenteState c) =>
          p.status != c.status || p.servicios != c.servicios,
      builder: (BuildContext context, ProgramacionRecurrenteState state) {
        final List<GestionColumn<ServicioRecurrenteEntity>> columns =
            recurrenteGestionColumns(state.pacientes);
        final List<ServicioRecurrenteEntity> visibles = _sort.apply(
          RecurrenteGestion.filtrar(
            state.servicios,
            query: _query,
            tipo: _tipo,
            vigencia: _vigencia,
            pacientes: state.pacientes,
          ),
          columns,
        );
        final int start = (_page * _pageSize).clamp(0, visibles.length);
        final int end = (start + _pageSize).clamp(0, visibles.length);
        return GestionLayout(
          toolbar: GestionToolbar(
            title: 'Programación Recurrente',
            icon: Icons.repeat,
            groups: <List<GestionToolbarAction>>[
              <GestionToolbarAction>[
                GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: _refresh),
                GestionToolbarAction(
                  icon: Icons.print_outlined,
                  label: 'Imprimir',
                  onPressed: visibles.isEmpty
                      ? null
                      : () => RecurrenteGestion.imprimir(visibles, state.pacientes),
                ),
              ],
            ],
          ),
          filterBar: GestionFilterBar(
            children: <Widget>[
              GestionSearchField(
                controller: _searchController,
                hint: 'Buscar código, paciente, origen, destino...',
                onChanged: (String v) => _updateFilters(() => _query = v),
              ),
              GestionFilterDropdown<String?>(
                label: 'Recurrencia',
                value: _tipo,
                options: const <String?, String>{null: 'Todas', ...RecurrenteGestion.tipos},
                onChanged: (String? v) => _updateFilters(() => _tipo = v),
              ),
              GestionFilterDropdown<RecurrenteVigencia?>(
                label: 'Vigencia',
                value: _vigencia,
                options: <RecurrenteVigencia?, String>{
                  null: 'Todas',
                  for (final RecurrenteVigencia v in RecurrenteVigencia.values) v: v.label,
                },
                onChanged: (RecurrenteVigencia? v) => _updateFilters(() => _vigencia = v),
              ),
              GestionClearFiltersButton(onPressed: _hasFilters ? _clearFilters : null),
            ],
          ),
          content: _RecurrenteGridContent(
            state: state,
            columns: columns,
            rows: visibles.sublist(start, end),
            firstRowNumber: start + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: _select,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: RecurrenteDetailPanel(
            servicio: _find(visibles),
            pacientes: state.pacientes,
            motivos: state.motivos,
          ),
          statusBar: GestionStatusBar(
            items: RecurrenteGestion.resumen(state.servicios, visibles.length),
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

/// Contenido central: carga inicial, error o rejilla
class _RecurrenteGridContent extends StatelessWidget {
  const _RecurrenteGridContent({
    required this.state,
    required this.columns,
    required this.rows,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.hasFilters,
    required this.onSelect,
    required this.onSort,
    required this.onRetry,
  });

  final ProgramacionRecurrenteState state;
  final List<GestionColumn<ServicioRecurrenteEntity>> columns;
  final List<ServicioRecurrenteEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<ServicioRecurrenteEntity> onSelect;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (!state.hasData && state.status == ProgramacionStatus.error) {
      return GestionLoadError(
        title: 'Error al cargar la programación',
        message: state.errorMessage ?? '',
        onRetry: onRetry,
      );
    }
    if (!state.hasData) {
      return const GestionLoading();
    }
    return GestionReloading(
      loading: state.status == ProgramacionStatus.loading,
      child: GestionGrid<ServicioRecurrenteEntity>(
        columns: columns,
        rows: rows,
        rowId: (ServicioRecurrenteEntity s) => s.id,
        selectedId: selectedId,
        onSelect: onSelect,
        sort: sort,
        onSort: onSort,
        firstRowNumber: firstRowNumber,
        emptyMessage: hasFilters
            ? 'Ningún servicio coincide con los filtros'
            : 'No hay servicios con recurrencia activa',
      ),
    );
  }
}
