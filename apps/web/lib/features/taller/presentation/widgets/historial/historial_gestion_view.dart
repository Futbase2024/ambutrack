import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/historial_reparaciones_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/historial_reparaciones_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/historial_reparaciones_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/taller_consulta_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/historial/historial_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/historial/historial_detail_panel.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/historial/historial_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

const String _rutaOrdenes = '/taller/ordenes-reparacion';

/// Pantalla de consulta del historial de reparaciones
class HistorialGestionView extends StatefulWidget {
  const HistorialGestionView({super.key});

  @override
  State<HistorialGestionView> createState() => _HistorialGestionViewState();
}

class _HistorialGestionViewState extends State<HistorialGestionView> {
  final TextEditingController _searchController = TextEditingController();
  HistorialFiltro _filtro = const HistorialFiltro();
  GestionSort _sort = const GestionSort(columnIndex: 6, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<OrdenReparacionEntity>? _ordenes;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrdenReparacionEntity> get _todas => _ordenes ?? <OrdenReparacionEntity>[];

  List<OrdenReparacionEntity> get _visibles =>
      _sort.apply(_todas.where(_filtro.matches).toList(), historialColumns);

  OrdenReparacionEntity? get _selected {
    for (final OrdenReparacionEntity o in _todas) {
      if (o.id == _selectedId) {
        return o;
      }
    }
    return null;
  }

  void _setFiltro(HistorialFiltro f) => setState(() {
        _filtro = f;
        _page = 0;
      });

  void _clearFilters() {
    _searchController.clear();
    _setFiltro(const HistorialFiltro());
  }

  void _refresh() => context.read<HistorialReparacionesBloc>().add(const HistorialReparacionesLoadRequested());

  void _onStateChanged(BuildContext context, HistorialReparacionesState state) {
    if (state is HistorialReparacionesLoaded) {
      setState(() => _ordenes = state.ordenes);
    } else if (state is HistorialReparacionesError && _ordenes != null) {
      showResultDialog(
        context: context,
        title: 'Error en el historial',
        message: 'No se pudo recargar el historial de reparaciones.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HistorialReparacionesBloc, HistorialReparacionesState>(
      listener: _onStateChanged,
      builder: (BuildContext context, HistorialReparacionesState state) {
        final List<OrdenReparacionEntity> visibles = _visibles;
        return GestionLayout(
          toolbar: TallerConsultaToolbar(
            title: 'Historial de Reparaciones',
            icon: Icons.history,
            onRefresh: _refresh,
            onPrint: visibles.isEmpty
                ? null
                : () => imprimirHistorial(visibles, subtitle: tallerRangoTexto(_filtro.rango)),
            extraActions: <GestionToolbarAction>[
              GestionToolbarAction(
                icon: Icons.build_outlined,
                label: 'Órdenes activas',
                tooltip: 'Ir a la gestión de órdenes de reparación',
                onPressed: () => context.go(_rutaOrdenes),
              ),
            ],
          ),
          filterBar: HistorialFilters(
            searchController: _searchController,
            filtro: _filtro,
            vehiculos: tallerOpcionesDe(_todas.map((OrdenReparacionEntity o) => o.vehiculoMatricula)),
            talleres: tallerOpcionesDe(_todas.map((OrdenReparacionEntity o) => o.tallerNombre)),
            onChanged: _setFiltro,
            onClear: _filtro.activo ? _clearFilters : null,
          ),
          content: TallerGestionGridContent<OrdenReparacionEntity>(
            hasData: _ordenes != null,
            isLoading: state is HistorialReparacionesLoading,
            errorTitle: 'Error al cargar el historial',
            errorMessage: state is HistorialReparacionesError ? state.message : null,
            columns: historialColumns,
            rows: tallerPageOf(visibles, _page, _pageSize),
            rowId: (OrdenReparacionEntity o) => o.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            emptyMessage: _filtro.activo
                ? 'Ninguna orden coincide con los filtros'
                : 'Todavía no hay reparaciones terminadas',
            onSelect: (OrdenReparacionEntity o) => setState(() => _selectedId = o.id),
            onActivate: (OrdenReparacionEntity o) => setState(() => _selectedId = o.id),
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: HistorialDetailPanel(
            orden: _selected,
            onVerOrdenes: () => context.go(_rutaOrdenes),
          ),
          statusBar: GestionStatusBar(
            items: resumenHistorial(_todas, visibles),
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
