import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_bloc.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_event.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_state.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/gestion/itv_detail_panel.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/gestion/itv_gestion_bars.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/gestion/itv_gestion_columns.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/itv_revision_edit_dialog.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/itv_revision_form_dialog.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/itv_revision_view_dialog.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de ITV y Revisiones con layout de programa de gestión
class ItvGestionView extends StatefulWidget {
  const ItvGestionView({super.key});

  @override
  State<ItvGestionView> createState() => _ItvGestionViewState();
}

class _ItvGestionViewState extends State<ItvGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  TipoItvRevision? _tipo;
  ResultadoItvRevision? _resultado;
  EstadoItvRevision? _estado;
  GestionSort _sort = const GestionSort(columnIndex: 2, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Registro cuyo borrado se ha solicitado desde esta vista (para el aviso de éxito)
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<ItvRevisionEntity>? _items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _tipo != null || _resultado != null || _estado != null;

  ItvRevisionEntity? get _selected {
    for (final ItvRevisionEntity i in _items ?? const <ItvRevisionEntity>[]) {
      if (i.id == _selectedId) {
        return i;
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
        _tipo = null;
        _resultado = null;
        _estado = null;
      });

  void _refresh() {
    context.read<ItvRevisionBloc>().add(const ItvRevisionLoadRequested());
    context.read<VehiculosBloc>().add(const VehiculosRefreshRequested());
  }

  Future<void> _openNew() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<VehiculosBloc>.value(value: context.read<VehiculosBloc>()),
          BlocProvider<ItvRevisionBloc>.value(value: context.read<ItvRevisionBloc>()),
          BlocProvider<TallerBloc>.value(value: context.read<TallerBloc>()),
        ],
        child: const ItvRevisionFormDialog(),
      ),
    );
  }

  Future<void> _openEdit(ItvRevisionEntity item) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<ItvRevisionBloc>.value(value: context.read<ItvRevisionBloc>()),
          BlocProvider<TallerBloc>.value(value: context.read<TallerBloc>()),
        ],
        child: ItvRevisionEditDialog(itvRevision: item),
      ),
    );
  }

  Future<void> _openView(ItvRevisionEntity item) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) => ItvRevisionViewDialog(itvRevision: item),
    );
  }

  Future<void> _confirmDelete(ItvRevisionEntity item, Map<String, VehiculoEntity> vehiculos) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar ${item.tipo.displayName}',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Vehículo': itvMatricula(item, vehiculos),
        'Tipo': item.tipo.displayName,
        'Fecha': GestionFormatters.fecha(item.fecha),
        if (item.fechaVencimiento != null) 'Vencimiento': GestionFormatters.fecha(item.fechaVencimiento),
        'Resultado': item.resultado.displayName,
        'Kilometraje': flotaKm(item.kmVehiculo),
        'Coste': GestionFormatters.moneda(item.costoTotal),
        'Estado': item.estado.displayName,
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingNombre = '${itvMatricula(item, vehiculos)} — ${GestionFormatters.fecha(item.fecha)}';
      });
      context.read<ItvRevisionBloc>().add(ItvRevisionDeleteRequested(id: item.id));
    }
  }

  void _onStateChanged(BuildContext context, ItvRevisionState state) {
    if (state is ItvRevisionLoaded) {
      setState(() => _items = state.itvRevisiones);
    } else if (state is ItvRevisionOperationSuccess && _deletingNombre != null) {
      final String eliminado = _deletingNombre!;
      setState(() => _deletingNombre = null);
      GestionFeedback.eliminado(context, entidad: 'ITV/Revisión', nombre: eliminado);
    } else if (state is ItvRevisionError && _items != null) {
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en ITV y Revisiones',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final VehiculosState vState = context.watch<VehiculosBloc>().state;
    final Map<String, VehiculoEntity> vehiculos = <String, VehiculoEntity>{
      if (vState is VehiculosLoaded)
        for (final VehiculoEntity v in vState.vehiculos) v.id: v,
    };
    final List<GestionColumn<ItvRevisionEntity>> columns = itvGestionColumns(vehiculos);
    return BlocConsumer<ItvRevisionBloc, ItvRevisionState>(
      listener: _onStateChanged,
      builder: (BuildContext context, ItvRevisionState state) {
        final List<ItvRevisionEntity> todos = _items ?? <ItvRevisionEntity>[];
        final List<ItvRevisionEntity> visibles = _sort.apply(
          filtrarItv(todos, vehiculos: vehiculos, query: _query, tipo: _tipo, resultado: _resultado, estado: _estado),
          columns,
        );
        final ItvRevisionEntity? selected = _selected;
        return GestionLayout(
          toolbar: ItvGestionToolbar(
            hasSelection: selected != null,
            onNew: _openNew,
            onEdit: () => _openEdit(selected!),
            onDelete: () => _confirmDelete(selected!, vehiculos),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirItv(visibles, vehiculos),
            onView: () => _openView(selected!),
          ),
          filterBar: ItvGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipo: _tipo,
            onTipoChanged: (TipoItvRevision? v) => _updateFilters(() => _tipo = v),
            resultado: _resultado,
            onResultadoChanged: (ResultadoItvRevision? v) => _updateFilters(() => _resultado = v),
            estado: _estado,
            onEstadoChanged: (EstadoItvRevision? v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: FlotaGridArea(
            hasData: _items != null,
            loading: state is ItvRevisionLoading,
            errorMessage: state is ItvRevisionError ? state.message : null,
            errorTitle: 'Error al cargar ITV/Revisiones',
            onRetry: _refresh,
            child: GestionGrid<ItvRevisionEntity>(
              columns: columns,
              rows: flotaPageOf(visibles, _page, _pageSize),
              rowId: (ItvRevisionEntity i) => i.id,
              selectedId: _selectedId,
              onSelect: (ItvRevisionEntity i) => setState(() => _selectedId = i.id),
              onActivate: _openEdit,
              sort: _sort,
              onSort: (GestionSort s) => setState(() => _sort = s),
              firstRowNumber: _page * _pageSize + 1,
              emptyMessage: _hasFilters
                  ? 'Ninguna ITV/Revisión coincide con los filtros'
                  : 'No hay ITV/Revisiones registradas. Pulsa "Nuevo" para programar una.',
            ),
          ),
          detailPanel: ItvDetailPanel(
            item: selected,
            todos: todos,
            vehiculos: vehiculos,
            onEdit: () => _openEdit(selected!),
            onDelete: () => _confirmDelete(selected!, vehiculos),
          ),
          statusBar: GestionStatusBar(
            items: resumenItv(todos, visibles.length),
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
