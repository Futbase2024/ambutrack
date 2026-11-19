import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alerta_mantenimiento.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alertas_mantenimiento_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alertas_mantenimiento_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alertas_mantenimiento_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/alertas/alertas_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/alertas/alertas_detail_panel.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/alertas/alertas_filters.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/taller_consulta_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de alertas de mantenimiento calculadas
class AlertasGestionView extends StatefulWidget {
  const AlertasGestionView({super.key});

  @override
  State<AlertasGestionView> createState() => _AlertasGestionViewState();
}

class _AlertasGestionViewState extends State<AlertasGestionView> {
  final TextEditingController _searchController = TextEditingController();
  AlertasFiltro _filtro = const AlertasFiltro();

  /// Filtros por columna (estilo Excel, varios valores por columna)
  GestionColumnFilters _colFilters = const GestionColumnFilters();

  /// Sin ordenación de columna: se respeta el orden por severidad/urgencia del BLoC
  GestionSort _sort = const GestionSort();
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<AlertaMantenimiento>? _alertas;
  List<String> _fuentesConError = <String>[];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AlertaMantenimiento> get _todas => _alertas ?? <AlertaMantenimiento>[];

  /// Alertas con búsqueda y desplegables aplicados (base de los filtros de columna)
  List<AlertaMantenimiento> get _base => _todas.where(_filtro.matches).toList();

  List<AlertaMantenimiento> get _visibles => _sort.apply(_colFilters.apply(_base, alertasColumns), alertasColumns);

  AlertaMantenimiento? get _selected {
    for (final AlertaMantenimiento a in _todas) {
      if (a.id == _selectedId) {
        return a;
      }
    }
    return null;
  }

  void _setFiltro(AlertasFiltro f) => setState(() {
        _filtro = f;
        _page = 0;
      });

  void _onColumnFiltersChanged(GestionColumnFilters f) => setState(() {
        _colFilters = f;
        _page = 0;
      });

  bool get _hasFilters => _filtro.activo || !_colFilters.isEmpty;

  void _clearFilters() {
    _searchController.clear();
    _colFilters = const GestionColumnFilters();
    _setFiltro(const AlertasFiltro());
  }

  void _refresh() => context.read<AlertasMantenimientoBloc>().add(const AlertasMantenimientoLoadRequested());

  void _abrir(AlertaMantenimiento a) {
    debugPrint('🔔 AlertasGestionView: navegando a ${a.tipo.route} (${a.id})');
    context.go(a.tipo.route);
  }

  void _onStateChanged(BuildContext context, AlertasMantenimientoState state) {
    if (state is AlertasMantenimientoLoaded) {
      setState(() {
        _alertas = state.alertas;
        _fuentesConError = state.fuentesConError;
      });
      if (state.fuentesConError.isNotEmpty) {
        showResultDialog(
          context: context,
          title: 'Alertas incompletas',
          message: 'Algunas fuentes de datos no se pudieron cargar; las alertas pueden estar incompletas.',
          details: 'Sin datos de: ${state.fuentesConError.join(', ')}',
          type: ResultType.warning,
        );
      }
    } else if (state is AlertasMantenimientoError && _alertas != null) {
      showResultDialog(
        context: context,
        title: 'Error en alertas',
        message: 'No se pudieron recalcular las alertas de mantenimiento.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AlertasMantenimientoBloc, AlertasMantenimientoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, AlertasMantenimientoState state) {
        final List<AlertaMantenimiento> visibles = _visibles;
        final AlertaMantenimiento? selected = _selected;
        return GestionLayout(
          toolbar: TallerConsultaToolbar(
            title: 'Alertas de Mantenimiento',
            icon: Icons.notifications_active_outlined,
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirAlertas(visibles),
            extraActions: <GestionToolbarAction>[
              GestionToolbarAction(
                icon: Icons.open_in_new,
                label: 'Abrir',
                tooltip: 'Abrir la pantalla relacionada con la alerta (doble clic / Intro)',
                onPressed: selected == null ? null : () => _abrir(selected),
              ),
            ],
          ),
          filterBar: AlertasFilters(
            searchController: _searchController,
            filtro: _filtro,
            onChanged: _setFiltro,
            columnFilters: _colFilters,
            onColumnFiltersChanged: _onColumnFiltersChanged,
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: TallerGestionGridContent<AlertaMantenimiento>(
            hasData: _alertas != null,
            isLoading: state is AlertasMantenimientoLoading,
            errorTitle: 'Error al calcular alertas',
            errorMessage: state is AlertasMantenimientoError ? state.message : null,
            columns: alertasColumns,
            rows: tallerPageOf(visibles, _page, _pageSize),
            rowId: (AlertaMantenimiento a) => a.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            emptyMessage: _hasFilters
                ? 'Ninguna alerta coincide con los filtros'
                : 'No hay alertas de mantenimiento pendientes',
            onSelect: (AlertaMantenimiento a) => setState(() => _selectedId = a.id),
            onActivate: _abrir,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
            filters: _colFilters,
            onFiltersChanged: _onColumnFiltersChanged,
            filterSource: _base,
          ),
          detailPanel: AlertasDetailPanel(alerta: selected, onAbrir: _abrir),
          statusBar: GestionStatusBar(
            items: resumenAlertas(_todas, visibles, _fuentesConError),
            pagination: GestionPagination(
              page: _page,
              pageSize: _pageSize,
              totalItems: visibles.length,
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
}
