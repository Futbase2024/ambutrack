import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/cubit/solicitudes_vestuario_cubit.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/cubit/solicitudes_vestuario_state.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/solicitudes_vestuario/solicitudes_vestuario_acciones.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/solicitudes_vestuario/solicitudes_vestuario_columns.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/solicitudes_vestuario/solicitudes_vestuario_detail_panel.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/solicitudes_vestuario/solicitudes_vestuario_gestion_bars.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/solicitudes_vestuario/solicitudes_vestuario_grid_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de solicitudes de vestuario con layout de programa de gestión.
/// Almacén aprueba, rechaza y entrega las prendas que piden los técnicos.
class SolicitudesVestuarioGestionView extends StatefulWidget {
  const SolicitudesVestuarioGestionView({super.key});

  @override
  State<SolicitudesVestuarioGestionView> createState() => _SolicitudesVestuarioGestionViewState();
}

class _SolicitudesVestuarioGestionViewState extends State<SolicitudesVestuarioGestionView>
    with SolicitudesVestuarioAcciones<SolicitudesVestuarioGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  GestionColumnFilters _colFilters = const GestionColumnFilters();
  SolicitudVestuarioFiltro _filtro = SolicitudVestuarioFiltro.abiertas;
  GestionSort _sort = const GestionSort(columnIndex: 0, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Último resultado ya mostrado (evita repetir el diálogo)
  int _resultadoMostrado = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || !_colFilters.isEmpty;

  SolicitudVestuarioEntity? _selected(List<SolicitudVestuarioEntity> todas) {
    for (final SolicitudVestuarioEntity s in todas) {
      if (s.id == _selectedId) {
        return s;
      }
    }
    return null;
  }

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _colFilters = const GestionColumnFilters();
      });

  void _onColumnFiltersChanged(GestionColumnFilters f) => _updateFilters(() => _colFilters = f);

  void _refresh() => context.read<SolicitudesVestuarioCubit>().cargar();

  void _onStateChanged(BuildContext context, SolicitudesVestuarioState state) {
    final SolicitudVestuarioResultado? resultado = state.resultado;
    if (resultado != null && resultado.secuencia != _resultadoMostrado) {
      _resultadoMostrado = resultado.secuencia;
      mostrarResultadoSolicitud(resultado);
    } else if (state.error != null && state.solicitudes != null && !state.cargando) {
      showResultDialog(
        context: context,
        title: 'Error en solicitudes de vestuario',
        message: 'No se pudieron recargar las solicitudes de vestuario.',
        details: state.error,
        type: ResultType.error,
      );
    }
  }

  bool _listenWhen(SolicitudesVestuarioState prev, SolicitudesVestuarioState cur) =>
      prev.resultado != cur.resultado || prev.error != cur.error;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SolicitudesVestuarioCubit, SolicitudesVestuarioState>(
      listenWhen: _listenWhen,
      listener: _onStateChanged,
      builder: (BuildContext context, SolicitudesVestuarioState state) {
        final List<SolicitudVestuarioEntity> todas = state.solicitudes ?? <SolicitudVestuarioEntity>[];
        final List<SolicitudVestuarioEntity> base =
            filtrarSolicitudesVestuario(todas, query: _query, filtro: _filtro);
        final List<SolicitudVestuarioEntity> visibles =
            _sort.apply(_colFilters.apply(base, solicitudesVestuarioColumns), solicitudesVestuarioColumns);
        final SolicitudVestuarioEntity? sel = _selected(todas);
        final bool libre = sel != null && !state.procesando;
        final bool abierta = libre && sel.estado.abierta;
        return GestionLayout(
          toolbar: SolicitudesVestuarioToolbar(
            onAprobar: libre && sel.estado == EstadoSolicitudVestuario.pendiente ? () => aprobarSolicitud(sel) : null,
            onRechazar: abierta ? () => rechazarSolicitud(sel) : null,
            onEntregar: abierta ? () => entregarSolicitud(sel) : null,
            onFoto: (sel?.fotoUrl?.isNotEmpty ?? false) ? () => verFotoSolicitud(sel!) : null,
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirSolicitudesVestuario(visibles),
          ),
          filterBar: SolicitudesVestuarioFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            filtro: _filtro,
            onFiltroChanged: (SolicitudVestuarioFiltro v) => _updateFilters(() => _filtro = v),
            abiertas: state.abiertas,
            columnFilters: _colFilters,
            onColumnFiltersChanged: _onColumnFiltersChanged,
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: SolicitudesVestuarioGridContent(
            state: state,
            rows: _pageOf(visibles),
            filters: _colFilters,
            onFiltersChanged: _onColumnFiltersChanged,
            filterSource: base,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            emptyMessage: _emptyMessage,
            onSelect: (SolicitudVestuarioEntity s) => setState(() => _selectedId = s.id),
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: SolicitudesVestuarioDetailPanel(
            solicitud: sel,
            procesando: state.procesando,
            onAprobar: () => aprobarSolicitud(sel!),
            onRechazar: () => rechazarSolicitud(sel!),
            onEntregar: () => entregarSolicitud(sel!),
            onFoto: () => verFotoSolicitud(sel!),
          ),
          statusBar: GestionStatusBar(
            items: resumenSolicitudesVestuario(todas, visibles.length),
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

  String get _emptyMessage {
    if (_hasFilters) {
      return 'Ninguna solicitud coincide con los filtros';
    }
    return _filtro == SolicitudVestuarioFiltro.abiertas
        ? 'No hay solicitudes de vestuario abiertas'
        : 'No hay solicitudes de vestuario';
  }

  List<SolicitudVestuarioEntity> _pageOf(List<SolicitudVestuarioEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}
