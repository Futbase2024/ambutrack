import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/bloc/auditoria_bloc.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/bloc/auditoria_event.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/bloc/auditoria_state.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_columns.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_content.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_detail_panel.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_filters.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_helpers.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_print.dart';
import 'package:ambutrack_web/features/administracion/shared/admin_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Vista de gestión (solo lectura) del registro de auditoría
class AuditoriaGestionView extends StatefulWidget {
  const AuditoriaGestionView({super.key});

  @override
  State<AuditoriaGestionView> createState() => _AuditoriaGestionViewState();
}

class _AuditoriaGestionViewState extends State<AuditoriaGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  GestionSort _sort = const GestionSort();
  int _page = 0;
  int _pageSize = 50;
  String? _selectedId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  AuditoriaBloc get _bloc => context.read<AuditoriaBloc>();

  void _refresh() => _bloc.add(const AuditoriaLoadRequested());

  void _setFiltros(AuditoriaFiltros f) {
    setState(() {
      _page = 0;
      _selectedId = null;
    });
    _bloc.add(AuditoriaFiltrosChanged(f));
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _query = '';
    });
    _setFiltros(AuditoriaFiltros.inicial());
  }

  bool _hasFilters(AuditoriaFiltros f) => _query.isNotEmpty || f != AuditoriaFiltros.inicial();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuditoriaBloc, AuditoriaState>(
      builder: (BuildContext context, AuditoriaState state) {
        final List<AuditLogEntity> visibles =
            _sort.apply(filtrarAuditoria(state.registros, _query), auditoriaColumns);
        final bool busy = state.isLoading || state.isLoadingMore;

        return GestionLayout(
          toolbar: GestionToolbar(
            title: 'Auditorías y Logs',
            icon: Icons.manage_search,
            groups: <List<GestionToolbarAction>>[
              <GestionToolbarAction>[
                GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: busy ? null : _refresh),
                GestionToolbarAction(
                  icon: Icons.print_outlined,
                  label: 'Imprimir',
                  onPressed: visibles.isEmpty
                      ? null
                      : () => imprimirAuditoria(rows: visibles, filtros: state.filtros),
                ),
              ],
              <GestionToolbarAction>[
                GestionToolbarAction(
                  icon: Icons.expand_more,
                  label: 'Cargar más',
                  tooltip: 'Cargar los siguientes ${AuditoriaBloc.pageSize} registros',
                  onPressed: state.hasMore && !busy
                      ? () => _bloc.add(const AuditoriaLoadMoreRequested())
                      : null,
                ),
              ],
            ],
            trailing: const AdminSoloLecturaBadge(
              tooltip: 'Los registros los genera automáticamente la base de datos',
            ),
          ),
          filterBar: AuditoriaFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => setState(() {
              _query = v;
              _page = 0;
            }),
            filtros: state.filtros,
            usuarios: state.usuarios,
            registros: state.registros,
            onFiltrosChanged: _setFiltros,
            onClear: _hasFilters(state.filtros) ? _clearFilters : null,
          ),
          content: AuditoriaContent(
            state: state,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasSearch: _query.isNotEmpty,
            onSelect: (AuditLogEntity e) => setState(() => _selectedId = '${e.id}'),
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: AuditoriaDetailPanel(registro: _findSelected(state.registros)),
          statusBar: GestionStatusBar(
            items: _resumen(state, visibles.length),
            pagination: GestionPagination(
              page: _page,
              pageSize: _pageSize,
              totalItems: visibles.length,
              pageSizes: const <int>[50, 100, 200],
              onPageChanged: (int p) => setState(() => _page = p),
              onPageSizeChanged: (int s) => setState(() {
                _pageSize = s;
                _page = 0;
              }),
            ),
          ),
        );
      },
    );
  }

  AuditLogEntity? _findSelected(List<AuditLogEntity> registros) {
    for (final AuditLogEntity e in registros) {
      if ('${e.id}' == _selectedId) {
        return e;
      }
    }
    return null;
  }

  List<String> _resumen(AuditoriaState state, int visibles) {
    if (state.isLoading) {
      return <String>['Cargando...'];
    }
    final List<AuditLogEntity> r = state.registros;
    final int? total = state.total;
    return <String>[
      if (total != null) '${r.length} de $total registros cargados' else '${r.length} registros cargados',
      'Altas ${r.where((AuditLogEntity e) => e.esAlta).length}',
      'Modif. ${r.where((AuditLogEntity e) => e.esModificacion).length}',
      'Bajas ${r.where((AuditLogEntity e) => e.esBaja).length}',
      if (_query.isNotEmpty) 'Mostrando $visibles',
      auditoriaRangoTexto(state.filtros),
      if (state.errorMessage != null && state.status == AuditoriaStatus.loaded) 'Error al cargar más registros',
    ];
  }

  List<AuditLogEntity> _pageOf(List<AuditLogEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}
