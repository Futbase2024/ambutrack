import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_state.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_detail_panel.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_columns.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslados_gestion_bars.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslados_gestion_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Vista genérica tipo programa de gestión sobre los traslados de
/// `TrasladosConsultaBloc`: barra de herramientas, filtros, rejilla,
/// ficha lateral de solo lectura y barra de estado con recuentos.
class TrasladosGestionView extends StatefulWidget {
  const TrasladosGestionView({
    required this.config,
    required this.onRefresh,
    super.key,
  });

  final TrasladosGestionConfig config;

  /// Recarga los datos (la pantalla decide qué consulta lanzar)
  final VoidCallback onRefresh;

  @override
  State<TrasladosGestionView> createState() => _TrasladosGestionViewState();
}

class _TrasladosGestionViewState extends State<TrasladosGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _estado;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 50;
  String? _selectedId;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  TrasladosConsultaLoaded? _loaded;

  @override
  void didUpdateWidget(TrasladosGestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.filtersSignature != widget.config.filtersSignature) {
      _page = 0;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != null;

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = null;
      });

  void _onStateChanged(BuildContext context, TrasladosConsultaState state) {
    if (state is TrasladosConsultaLoaded) {
      setState(() => _loaded = state);
    } else if (state is TrasladosConsultaError && _loaded != null) {
      showResultDialog(
        context: context,
        title: 'Error al actualizar',
        message: 'No se pudieron recargar los traslados. Se muestran los últimos datos.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  List<TrasladoEntity> _base() {
    final List<TrasladoEntity> all = _loaded?.traslados ?? const <TrasladoEntity>[];
    return widget.config.preFilter?.call(all) ?? all;
  }

  TrasladoEntity? _find(List<TrasladoEntity> rows) {
    for (final TrasladoEntity t in rows) {
      if (t.id == _selectedId) {
        return t;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrasladosConsultaBloc, TrasladosConsultaState>(
      listener: _onStateChanged,
      builder: (BuildContext context, TrasladosConsultaState state) {
        final TrasladosGestionConfig config = widget.config;
        final TrasladosConsultaLoaded? loaded = _loaded;
        final Map<String, String> nombres = loaded?.personal ?? const <String, String>{};
        final List<TrasladoEntity> base = _base();
        final List<GestionColumn<TrasladoEntity>> columns =
            trasladoGestionColumns(nombres: nombres, conFecha: config.conFecha);
        final List<TrasladoEntity> visibles = _sort.apply(
          TrasladoGestion.filtrar(base, query: _query, estado: _estado, nombres: nombres),
          columns,
        );
        final int start = (_page * _pageSize).clamp(0, visibles.length);
        final int end = (start + _pageSize).clamp(0, visibles.length);
        return GestionLayout(
          toolbar: TrasladosGestionToolbar(
            config: config,
            onRefresh: widget.onRefresh,
            onPrint: visibles.isEmpty
                ? null
                : () => TrasladoGestion.imprimir(
                      title: config.title,
                      subtitle: config.printSubtitle,
                      traslados: visibles,
                      nombres: nombres,
                    ),
          ),
          filterBar: TrasladosGestionFilters(
            config: config,
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (String? v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: TrasladosGridContent(
            state: state,
            hasData: loaded != null,
            columns: columns,
            rows: visibles.sublist(start, end),
            firstRowNumber: start + 1,
            selectedId: _selectedId,
            sort: _sort,
            emptyMessage: _hasFilters
                ? 'Ningún traslado coincide con los filtros'
                : config.emptyMessage,
            onSelect: (TrasladoEntity t) => setState(() => _selectedId = t.id),
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: widget.onRefresh,
          ),
          detailPanel: TrasladoDetailPanel(traslado: _find(visibles), nombres: nombres),
          statusBar: GestionStatusBar(
            items: <String>[
              TrasladoGestion.totalRegistros(visibles.length, base.length),
              ...?config.extraStatus?.call(base),
              if (loaded != null) 'Actualizado ${TrasladoGestion.hora(loaded.actualizadoEn)}',
            ],
            pagination: GestionPagination(
              page: _page,
              pageSize: _pageSize,
              totalItems: visibles.length,
              pageSizes: const <int>[25, 50, 100, 200],
              onPageChanged: (int p) => setState(() => _page = p),
              onPageSizeChanged: (int s) => _updateFilters(() => _pageSize = s),
            ),
          ),
        );
      },
    );
  }
}
