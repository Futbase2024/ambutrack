import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/multicentro/presentation/bloc/multicentro_bloc.dart';
import 'package:ambutrack_web/features/administracion/multicentro/presentation/bloc/multicentro_event.dart';
import 'package:ambutrack_web/features/administracion/multicentro/presentation/bloc/multicentro_state.dart';
import 'package:ambutrack_web/features/administracion/multicentro/presentation/widgets/multicentro_columns.dart';
import 'package:ambutrack_web/features/administracion/multicentro/presentation/widgets/multicentro_detail_panel.dart';
import 'package:ambutrack_web/features/administracion/shared/admin_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Vista de gestión (solo lectura) de empresas multi-tenant
class MulticentroGestionView extends StatefulWidget {
  const MulticentroGestionView({super.key});

  @override
  State<MulticentroGestionView> createState() => _MulticentroGestionViewState();
}

class _MulticentroGestionViewState extends State<MulticentroGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  EmpresaEstadoFiltro _estado = EmpresaEstadoFiltro.todas;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != EmpresaEstadoFiltro.todas;

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = EmpresaEstadoFiltro.todas;
      });

  void _refresh() => context.read<MulticentroBloc>().add(const MulticentroLoadRequested());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MulticentroBloc, MulticentroState>(
      builder: (BuildContext context, MulticentroState state) {
        final MulticentroLoaded? data = state is MulticentroLoaded ? state : null;
        final List<EmpresaRow> todas = data == null
            ? <EmpresaRow>[]
            : data.empresas
                .map((EmpresaTenantEntity e) => EmpresaRow(empresa: e, usuarios: data.usuariosDe(e.id).length))
                .toList();
        final List<EmpresaRow> visibles =
            _sort.apply(filtrarEmpresas(todas, query: _query, estado: _estado), multicentroColumns);
        final EmpresaTenantEntity? selected = _findSelected(data);

        return GestionLayout(
          toolbar: GestionToolbar(
            title: 'Multi-centro / Multi-empresa',
            icon: Icons.business_center,
            groups: <List<GestionToolbarAction>>[
              <GestionToolbarAction>[
                GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: _refresh),
              ],
            ],
            trailing: const AdminSoloLecturaBadge(
              tooltip: 'Las altas y modificaciones de empresas se gestionan en la base de datos',
            ),
          ),
          filterBar: MulticentroFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (EmpresaEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _MulticentroContent(
            state: state,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (EmpresaRow r) => setState(() => _selectedId = r.empresa.id),
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: MulticentroDetailPanel(
            empresa: selected,
            usuarios: selected == null || data == null ? <UserEntity>[] : data.usuariosDe(selected.id),
          ),
          statusBar: GestionStatusBar(
            items: _resumen(data, visibles.length),
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

  EmpresaTenantEntity? _findSelected(MulticentroLoaded? data) {
    for (final EmpresaTenantEntity e in data?.empresas ?? const <EmpresaTenantEntity>[]) {
      if (e.id == _selectedId) {
        return e;
      }
    }
    return null;
  }

  List<String> _resumen(MulticentroLoaded? data, int visibles) {
    if (data == null) {
      return <String>['Cargando...'];
    }
    final int activas = data.empresas.where((EmpresaTenantEntity e) => e.activo).length;
    return <String>[
      '${data.empresas.length} empresas',
      'Activas $activas',
      'Mostrando $visibles',
      '${data.usuarios.length} usuarios',
      'Sin empresa ${data.usuariosSinEmpresa}',
    ];
  }

  List<EmpresaRow> _pageOf(List<EmpresaRow> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

class _MulticentroContent extends StatelessWidget {
  const _MulticentroContent({
    required this.state,
    required this.rows,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.hasFilters,
    required this.onSelect,
    required this.onSort,
    required this.onRetry,
  });

  final MulticentroState state;
  final List<EmpresaRow> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<EmpresaRow> onSelect;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final MulticentroState s = state;
    if (s is MulticentroError) {
      return AdminLoadError(title: 'Error al cargar empresas', message: s.message, onRetry: onRetry);
    }
    if (s is! MulticentroLoaded) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return GestionGrid<EmpresaRow>(
      columns: multicentroColumns,
      rows: rows,
      rowId: (EmpresaRow r) => r.empresa.id,
      selectedId: selectedId,
      onSelect: onSelect,
      sort: sort,
      onSort: onSort,
      firstRowNumber: firstRowNumber,
      emptyMessage: hasFilters
          ? 'Ninguna empresa coincide con los filtros'
          : 'No hay empresas registradas en la tabla "empresas"',
    );
  }
}
